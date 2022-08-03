#!/usr/bin/env python3
from typing import Set
import argparse
import logging
import os
import logging
from pathlib import Path


logging.basicConfig()


def get_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    subparsers = parser.add_subparsers(dest='op')
    install = subparsers.add_parser('install', help='Install a package.')
    uninstall = subparsers.add_parser('uninstall', help='Uninstall a package.')
    for p, op_verb in zip((install, uninstall), ('install', 'uninstall')):
        p.add_argument(
            'pkg',
            help=f'The package name to {op_verb}. If "all", {op_verb} all dotfiles packages instead.',
        )
        p.add_argument(
            '-r',
            '--relative-base',
            metavar='PATH',
            default=str(Path.home()),
            help=f'The directory relative to which to {op_verb} the package.',
        )
        p.add_argument(
            '-v', '--verbose', default=False, action='store_true', help='Toggle verbosity.'
        )
        p.add_argument(
            '-d',
            '--dry-run',
            default=False,
            action='store_true',
            help='Whether to simulate changes. No file system changes will occur.',
        )
    return parser.parse_args()


class Stow:

    HOME = Path.home()
    DOTFILES_DIR = HOME / '.dotfiles'
    IGNORED_PATHS_FILE = DOTFILES_DIR / '.stowignore'
    SUBDIRS_TO_CREATE = [
        HOME / '.local',
        HOME / '.local' / 'share',
        HOME / '.local' / 'bin',
        HOME / '.local' / 'lib',
        HOME / '.cache',
        HOME / '.config',
    ]

    def __init__(
        self,
        verbose: bool = True,
        dry_run: bool = True,
        ignore_errors: bool = False,
        relative_base: Path = None,
    ) -> None:
        self._logger = logging.getLogger('stow')
        self._logger.setLevel((logging.INFO if verbose else logging.WARNING))
        self._dry_run = dry_run
        self._ignore_errors = ignore_errors
        self._relative_base = (relative_base if relative_base is not None else self.HOME).absolute()
        self._ignored_paths = self._read_ignored_paths()

    def _maybe_raise(self, s: str):
        if self._ignore_errors:
            self._logger.error(s)
        else:
            raise RuntimeError(s)

    def _read_ignored_paths(self) -> Set[Path]:
        """
        Read the ignored paths file `.stowignore` from the dotfiles dir,
        and return a set of all paths which should be excluded from any operations.
        """
        if not self.IGNORED_PATHS_FILE.is_file():
            return set()
        else:
            return {
                (self.IGNORED_PATHS_FILE.parent / Path(x.strip())).resolve().absolute()
                for x in self.IGNORED_PATHS_FILE.read_text().split('\n')
                if len(x.strip())
            }

    def _maybe_lns_relatively(self, src: Path, dst: Path):
        """
        If the target does not yet exist, create a symlink from
        the dotfiles dir to the destination. This will skip over
        already installed files but will raise upon finding a link
        which does not point to the dotfiles dir.

        :param src: the path in the dotfiles dir
        :param dst: the path in the target destination
        """
        commonpath = Path(os.path.commonpath([src, dst]))
        n_above_dst = list(dst.parents).index(commonpath)
        dst_dots = '/'.join(['..'] * n_above_dst)
        src_without_relhead = '/'.join(src.parts[len(commonpath.parts) :])
        src_relpath = Path(dst_dots) / src_without_relhead

        if dst.exists():
            if dst.resolve().absolute() == src.absolute():
                self._logger.warning(f'Skipping existing destination: {dst}')
                return
            else:
                self._maybe_raise(
                    f'Destination already exists but doesn\'t link to dotfiles: {dst} -> {dst.resolve()}'
                )
        else:
            self._logger.info(f'ln -s {src_relpath} {dst}')
            if not self._dry_run:
                dst.symlink_to(src_relpath)

    def _maybe_rmlink(self, src: Path, dst: Path):
        """
        If the target exists and points to the dotfiles dir, remove that link.
        This will ignore already missing links, but will raise upon finding a link
        which does not point to the dotfiles dir.

        :param src: the path in the dotfiles dir
        :param dst: the path in the target destination
        """
        if dst.exists():
            if dst.resolve().absolute() == src.absolute():
                self._logger.info(f'rm {dst}')
                if not self._dry_run:
                    dst.unlink()
            else:
                self._maybe_raise(
                    f'Destination doesn\'t link to dotfiles: {dst} -> {dst.resolve()}'
                )
        else:
            self._logger.warning(f'Skipping non-existing destination: {dst}')

    def _perform_op(self, src: Path, dst: Path, op: str):
        """
        Attempt to install or remove a symlink.

        :param src: the path in the dotfiles dir
        :param dst: the path in the target destination
        :param op: 'install' or 'uninstall'
        """
        if src.resolve().absolute() in self._read_ignored_paths():
            self._logger.info(f'Skipping ignored destination: {dst}')
            return
        if op == 'install':
            self._maybe_lns_relatively(src=src, dst=dst)
        elif op == 'uninstall':
            self._maybe_rmlink(src=src, dst=dst)

    def _maybe_mkdir(self, dst: Path):
        """
        Create an essential (XDG spec) base directory if it doesn't exist.

        :param dst: the directory to ensure it exists.
        """
        if not dst.exists():
            self._logger.info(f'mkdir {dst}')
            if not self._dry_run:
                dst.mkdir()

    def _operate_path_recursively(self, src: Path, pkg_path: Path, op: str):
        """
        Walk the tree of the passed source path until encountering either a file,
        or a directory which is not an essential XDG-spec base directory
        (which are automatically and silently created).
        Perform the desired operation on that path.

        :param src: the path in the dotfiles dir
        :param dst: the path in the target destination
        :param op: 'install' or 'uninstall'
        """
        dst = self._relative_base / src.relative_to(pkg_path)
        if src.is_file():
            self._perform_op(src, dst, op=op)
        elif src.is_dir():
            if dst in self.SUBDIRS_TO_CREATE:
                if op == 'install':
                    self._maybe_mkdir(dst)
                for component in src.iterdir():
                    self._operate_path_recursively(component, pkg_path, op=op)
            elif dst.is_dir() and not dst.is_symlink():
                self._maybe_raise(f'Destination already exists but is not managed: {dst}')
            elif dst.exists() and not dst.is_symlink():
                self._maybe_raise(f'Destination already exists but is not a dir: {dst}')
            else:
                self._perform_op(src, dst, op=op)

    def operate_pkg(self, pkg: str, op: str):
        """
        Perform the desired operation on the dotfiles package with the given name.

        :param pkg: The directory name of the package to operate on.
        :param op: 'install' or 'uninstall'
        """
        pkg_path = self.DOTFILES_DIR / pkg
        if not pkg_path.is_dir():
            raise RuntimeError(f'Package not found: {pkg_path}')
        if pkg_path.resolve().absolute() in self._read_ignored_paths():
            self._logger.info(f'Skipping ignored package: {pkg_path}')
            return

        op_verb = op.title() + 'ing'
        self._logger.info(f'{op_verb} package {pkg_path} relative to {self._relative_base}')
        for component in pkg_path.iterdir():
            self._operate_path_recursively(component, pkg_path, op=op)

    def get_all_pkgs(self):
        """
        Returns all package names for packages which exist in the dotfiles dir.

        :returns: A list of package names for packages in the dotfiles dir.
        """
        all_pkgs = [x.name for x in self.DOTFILES_DIR.iterdir() if x.is_dir()]
        return all_pkgs


if __name__ == '__main__':
    args = get_args()
    stow = Stow(verbose=args.verbose, dry_run=args.dry_run, relative_base=Path(args.relative_base))
    if args.pkg == 'all':
        for pkg in stow.get_all_pkgs():
            stow.operate_pkg(pkg, op=args.op)
    else:
        stow.operate_pkg(args.pkg, op=args.op)
