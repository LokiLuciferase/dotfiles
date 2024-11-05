#!/usr/bin/env python3
import os
import logging
import hashlib
import argparse
from pathlib import Path
from concurrent.futures import ProcessPoolExecutor


logging.basicConfig(format='%(levelname)s - %(message)s', level=logging.INFO)


def _get_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        description='Deduplicates files in the passed directory using one of several strategies.',
    )
    parser.add_argument('dir', metavar='DIR', nargs=1, help='The directory to process')
    parser.add_argument(
        '-m',
        '--method',
        choices=['symlink', 'hardlink', 'delete'],
        default='symlink',
        help="""How to resolve duplicates. 'symlink': all duplicates become symlinks to the first one.
        'hardlink': all duplicates become hardlinks to the first one. May fail if directory spans different disks.
        'delete': delete all duplicates.
    """,
    )
    parser.add_argument(
        '-p',
        '--pick-principal-by',
        choices=['newest', 'oldest', 'lexical', 'highest', 'lowest'],
        default=('oldest',),
        nargs='+',
        help="""How to choose which file is to be the principal while others get modified.
        'newest': Sort by age ascending.
        'oldest': Sort by age descending.
        'lexical': Sort by lexical ordering.
        'highest': Sort by height in tree ascending.
        'lowest': Sort by height in tree descending.""",
    )
    parser.add_argument(
        '-d', '--dry-run', action='store_true', help='Simulate changes. No file system changes will occur.'
    )
    parser.add_argument(
        '-a', '--all', action='store_true', help='Include directories prefixed with a dot in processing.'
    )
    return parser.parse_args()


def _get_hash_if_file(p: Path) -> str | None:
    if p.is_file() and not p.is_symlink():
        with open(p, 'rb') as fin:
            file_hash = hashlib.blake2b()
            while chunk := fin.read(8192):
                file_hash.update(chunk)
        return file_hash.hexdigest()
    else:
        return None


def _sort_files(files: list[Path], sort_by: list[str]) -> list[Path]:
    files = files[:]
    for s in sort_by:
        if s == 'oldest':
            files = sorted(files, key=lambda x: x.stat().st_ctime)
        elif s == 'newest':
            files = sorted(files, key=lambda x: x.stat().st_ctime, reverse=True)
        elif s == 'lexical':
            files = sorted(files)
        elif s == 'highest':
            files = sorted(files, key=lambda x: len(x.parts))
        elif s == 'lowest':
            files = sorted(files, key=lambda x: len(x.parts), reverse=True)
    return files


def _link_dup(dup: tuple[str, list[Path]], dry_run: bool = True, hard=False) -> None:
    principal = dup[1][0]
    others = dup[1][1:]
    for p in others:
        principal_relpath = os.path.relpath(principal, p.parent)
        logging.info(f'ln -f{"" if hard else "s"} "{principal_relpath}" "{str(p)}" {"(dryrun)" if dry_run else ""}')
        if dry_run:
            continue
        else:
            p.unlink()
            if hard:
                p.hardlink_to(principal_relpath)
            else:
                p.symlink_to(principal_relpath)


def _delete_dup(dup: tuple[str, list[Path]], dry_run: bool = True) -> None:
    others = dup[1][1:]
    for p in others:
        logging.info(f'rm {str(p)}')
        if dry_run:
            continue
        p.unlink()


def _find_dups(p: Path, sort_by: list[str], all_: bool) -> dict[str, list[Path]]:
    ret = {}
    with ProcessPoolExecutor(max_workers=os.cpu_count()) as executor:
        pps = list(p.rglob('*'))
        hashes = executor.map(_get_hash_if_file, pps)
        for pp, hash_ in zip(pps, hashes):
            if hash_ is None:
                continue
            if not all_ and any(x.startswith('.') for x in pp.parts):
                continue
            ret.setdefault(hash_, []).append(pp)
    ret = {k: _sort_files(v, sort_by=sort_by) for k, v in ret.items() if len(v) > 1}
    return ret


def _resolve_dups(dups: dict[str, list[Path]], method: str, dry_run: bool = True) -> None:
    methmap = {
        'symlink': lambda dup, dry_run: _link_dup(dup, dry_run=dry_run, hard=False),
        'hardlink': lambda dup, dry_run: _link_dup(dup, dry_run=dry_run, hard=True),
        'delete': _delete_dup,
    }
    [methmap[method](dup=x, dry_run=dry_run) for x in dups.items()]


def main():
    args = _get_args()
    dups = _find_dups(Path(args.dir[0]), sort_by=args.pick_principal_by, all_=args.all)
    _resolve_dups(dups, method=args.method, dry_run=args.dry_run)


if __name__ == '__main__':
    main()
