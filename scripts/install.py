"""Install into the detected Forever client, backing up any existing addon edits."""
import argparse
import csv
from datetime import datetime, timezone
import os
from pathlib import Path
import shutil
import tempfile

from toolbox import addon_info


def detect_client(wow_root, client=None):
    wow_root = Path(wow_root)
    if client is None:
        info = wow_root / '.build.info'
        if not info.is_file():
            raise ValueError('Missing .build.info; specify --client explicitly')
        with info.open(encoding='utf-8-sig', newline='') as stream:
            rows = csv.reader(stream, delimiter='|')
            fields = [field.split('!')[0] for field in next(rows, [])]
            builds = [dict(zip(fields, row)) for row in rows]
        if not any(row.get('Product') == 'wowf' and row.get('Active') == '1' for row in builds):
            raise ValueError('No active wowf product found; specify --client for a historical beta installation')
        client = '_forever_'
    if client not in ('_forever_', '_classic_beta_'):
        raise ValueError('Unsupported Forever client folder')
    folder = wow_root / client
    if not folder.is_dir() or folder.is_symlink():
        raise ValueError(f'Client folder not found or unsafe: {folder}')
    return folder


def install_files(source, destination, backup_root):
    source, destination = Path(source), Path(destination)
    paths = sorted(source.rglob('*'))
    if source.is_symlink() or destination.is_symlink() or any(p.is_symlink() for p in paths):
        raise ValueError('Addon install paths cannot contain symlinks')
    files = [p for p in paths if p.is_file()]
    if not files:
        raise ValueError('Addon source contains no files')
    existing = list(destination.rglob('*')) if destination.exists() else []
    if any(p.is_symlink() for p in existing):
        raise ValueError('Existing addon contains a symlink; installation stopped')
    # Back up before overwriting, including extra files. Never touch WTF files.
    changed = destination.exists() and (
        any(not (destination / p.relative_to(source)).is_file()
            or (destination / p.relative_to(source)).read_bytes() != p.read_bytes() for p in files)
        or any(p.is_file() and not (source / p.relative_to(destination)).is_file() for p in existing))
    backup = None
    if changed:
        backup_root = Path(backup_root)
        backup_root.mkdir(parents=True, exist_ok=True)
        prefix = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ-')
        backup = Path(tempfile.mkdtemp(prefix=prefix, dir=backup_root)) / destination.name
        shutil.copytree(destination, backup)
    destination.mkdir(parents=True, exist_ok=True)
    for path in files:
        target = destination / path.relative_to(source)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, target)
    if any((destination / p.relative_to(source)).read_bytes() != p.read_bytes() for p in files):
        raise RuntimeError('Installed addon bytes do not match source')
    return backup, len(files)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('addon', nargs='?', default='ForeverUtilities')
    parser.add_argument('--wow-root', type=Path, default=Path('F:/World of Warcraft') if os.name == 'nt'
                        else Path('/mnt/f/World of Warcraft'))
    parser.add_argument('--client', choices=['_forever_', '_classic_beta_'])
    args = parser.parse_args()
    source, version, _ = addon_info(args.addon)
    client = detect_client(args.wow_root, args.client)
    destination = client / 'Interface' / 'AddOns' / args.addon
    backup, count = install_files(source, destination, args.wow_root / 'ClassmateBackups')
    print(f'Installed {args.addon} {version}: {destination} ({count} files verified)')
    if backup:
        print(f'Previous addon backed up to: {backup}')


if __name__ == '__main__':
    main()
