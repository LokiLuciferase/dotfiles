#!/usr/bin/env python3
# /// script
# requires-python = ">3.10"
# ///

import argparse
import logging
import os
import shutil
from pathlib import Path
from typing import Set, Tuple


logging.basicConfig(format='%(levelname)s - %(message)s')


def get_args():
    parser = argparse.ArgumentParser(
        description='Stow dotfiles from a directory to the home directory.',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    subparsers = parser.add_subparsers(dest='op')
    install = subparsers.add_parser('install', help='Install a dotfiles package.')
    uninstall = subparsers.add_parser('uninstall', help='Uninstall a dotfiles package.')
    for p, op_verb in zip((install, uninstall), ('install', 'uninstall')):
        p.add_argument(
            'pkg',
            help=f'The dotfiles package name to {op_verb}. If "all", {op_verb} all dotfiles packages instead.',
        )
        p.add_argument(
            '-r',
            '--relative-base',
            metavar='PATH',
            default=str(Path.home()),
            help=f'The directory relative to which to {op_verb} the dotfiles package.',
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
        p.add_argument(
            '-s',
            '--shove',
            default=False,
            action='store_true',
            help='Whether to move existing files and directories out of the way '
            'when introducing symlinks (instead of throwing an error)',
        )
        p.add_argument(
            '--dotfiles_dir',
            metavar='PATH',
            default=str(Path.home() / '.dotfiles'),
            help='The directory containing the dotfiles packages.',
        )
    return parser.parse_args()


class Stow:
    def __init__(
        self,
        verbose: bool = True,
        dry_run: bool = True,
        shove: bool = False,
        ignore_errors: bool = False,
        relative_base: Path = Path.home(),
        dotfiles_dir: Path = Path.home() / '.dotfiles',
    ) -> None:
        self._logger = logging.getLogger('stow')
        self._logger.setLevel((logging.INFO if verbose else logging.WARNING))
        self._dry_run = dry_run
        self._shove = shove
        self._ignore_errors = ignore_errors
        self._relative_base = relative_base.absolute()
        self._dotfiles_dir = dotfiles_dir
        self._ignored_paths, self._ensure_present_paths = self._read_ignored_paths(
            self._dotfiles_dir / '.stowignore'
        )

    def _maybe_raise(self, s: str):
        if self._ignore_errors:
            self._logger.error(s)
        else:
            raise RuntimeError(s)

    def _read_ignored_paths(self, ignored_paths_file: Path) -> Tuple[Set[Path], Set[Path]]:
        """
        Read the ignored paths file `.stowignore` from the dotfiles dir,
        and return a set of all paths which should be excluded from any operations, as well as
        a set of all directories which, if queried, should be ensured to exist (denoted by a
        leading `!` in the path).
        """
        ignored_paths = {ignored_paths_file.parent / '.git'}
        ensure_present_paths = {
            (Path.home() / x).resolve().absolute()
            for x in ['.config', '.local', '.local/share', '.local/bin', '.local/lib', '.cache']
        }

        if ignored_paths_file.is_file():
            ignored_paths = ignored_paths.union(
                {
                    (ignored_paths_file.parent / Path(x.strip())).resolve().absolute()
                    for x in ignored_paths_file.read_text().split('\n')
                    if len(x.strip())
                    and not x.strip().startswith('!')  # ignore negated paths
                    and not x.strip().startswith('#')  # ignore comments
                }
            )
            ensure_present_paths = ensure_present_paths.union(
                {
                    (Path(x.strip()[1:])).expanduser().resolve().absolute()
                    for x in ignored_paths_file.read_text().split('\n')
                    if len(x.strip())
                    and x.strip().startswith('!')  # only include negated paths
                    and not x.strip().startswith('#')  # ignore comments
                }
            )
        return ignored_paths, ensure_present_paths

    def _maybe_shove(self, dst: Path, shove_suffix: str = '.bak') -> bool:
        """
        Move an existing file or directory out of the way to make space for the
        to-be-introduced symlink into the dotfiles.
        Fail if the target already exists.
        """
        dst = str(dst.absolute())
        dst_shoved = dst + shove_suffix
        if Path(dst_shoved).exists():
            self._maybe_raise(f'Cannot shove destination out of the way: {dst_shoved} exists')
            return False
        else:
            self._logger.info(f'mv {dst} {dst_shoved}')
            if not self._dry_run:
                shutil.move(src=dst, dst=dst_shoved)
            return True

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
            if dst.resolve().absolute() == src.resolve().absolute():
                self._logger.warning(f'Skipping already managed destination: {dst}')
                return
            else:
                if dst.is_file() or dst.is_dir() or dst.is_symlink():
                    if self._shove:
                        if self._maybe_shove(dst):
                            self._logger.info(f'ln -s {src_relpath} {dst}')
                            if not self._dry_run:
                                dst.symlink_to(src_relpath)
                        else:
                            return
                    else:
                        self._maybe_raise(f'Destination already exists but is not managed: {dst}')
                else:
                    self._maybe_raise(
                        f'Destination already exists but is not a file, dir or symlink: {dst}'
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
        if src.resolve().absolute() in self._ignored_paths:
            self._logger.warning(f'Skipping ignored destination: {dst}')
            return
        if op == 'install':
            self._maybe_lns_relatively(src=src, dst=dst)
        elif op == 'uninstall':
            self._maybe_rmlink(src=src, dst=dst)

    def _maybe_mkdir(self, dst: Path):
        """
        Create a directory if it doesn't exist.

        :param dst: the directory to ensure it exists.
        """
        if not dst.exists():
            self._logger.info(f'mkdir {dst}')
            if not self._dry_run:
                dst.mkdir()

    def _operate_path_recursively(self, src: Path, pkg_path: Path, op: str):
        """
        Walk the tree of the passed source path until encountering either a file,
        or a directory which is not an essential directory
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
            if dst.resolve().absolute() in self._ensure_present_paths:
                if op == 'install':
                    self._maybe_mkdir(dst)
                for component in src.iterdir():
                    self._operate_path_recursively(component, pkg_path, op=op)
            else:
                self._perform_op(src, dst, op=op)

    def operate_pkg(self, pkg: str, op: str):
        """
        Perform the desired operation on the dotfiles package with the given name.

        :param pkg: The directory name of the dotfiles package to operate on.
        :param op: 'install' or 'uninstall'
        """
        pkg_path = self._dotfiles_dir / pkg
        if not pkg_path.is_dir():
            raise RuntimeError(f'Dotfiles package not found: {pkg_path}')

        op_verb = op.title() + 'ing'
        self._logger.info(f'{op_verb} {pkg_path} relative to {self._relative_base}')
        for component in pkg_path.iterdir():
            self._operate_path_recursively(component, pkg_path, op=op)

    def get_all_pkgs(self):
        """
        Returns all dotfiles packages which exist in the dotfiles dir.

        :returns: A list of dotfiles package names in the dotfiles dir.
        """
        all_pkgs = [
            x.name
            for x in self._dotfiles_dir.iterdir()
            if x.is_dir()
            and (self._dotfiles_dir / x).resolve().absolute() not in self._ignored_paths
        ]
        return all_pkgs

    def operate_all_pkg(self, op: str):
        """
        Perform the desired operation on all dotfile packages apart from those explicitly
        excluded by the stowignore file.

        :param op: 'install' or 'uninstall'
        """
        for pkg in self.get_all_pkgs():
            self.operate_pkg(pkg, op=op)


if __name__ == '__main__':
    args = get_args()
    stow = Stow(
        verbose=args.verbose,
        dry_run=args.dry_run,
        shove=args.shove,
        relative_base=Path(args.relative_base),
        dotfiles_dir=Path(args.dotfiles_dir),
    )
    if args.pkg == 'all':
        stow.operate_all_pkg(op=args.op)
    else:
        stow.operate_pkg(args.pkg, op=args.op)
