#!/usr/bin/env python3
"""Link reviewed dotfiles. Keep private Codex state out of version control."""

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import tempfile
import tomllib


REPO = Path(__file__).resolve().parents[1]
TABLE = re.compile(r"(?m)^\[([^\n]+)\]\s*$")
PRIVATE_TABLES = (
    "projects", "hooks", "mcp_servers.node_repl", "mcp_servers.computer-use",
    'mcp_servers."node_repl"', 'mcp_servers."computer-use"',
    "marketplaces.openai-bundled", "marketplaces.openai-primary-runtime",
    'marketplaces."openai-bundled"', 'marketplaces."openai-primary-runtime"',
    "tui.model_availability_nux",
)


def split_codex(text):
    """Keep machine paths and approval history in a private TOML fragment."""
    tomllib.loads(text)
    matches = list(TABLE.finditer(text))
    root = text[:matches[0].start()] if matches else text
    public = []
    private = []
    # The installed config stores notify on one line. Refuse unknown layouts.
    for line in root.splitlines(keepends=True):
        (private if re.match(r"^notify\s*=", line) else public).append(line)
    for index, match in enumerate(matches):
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        name = match[1]
        hidden = any(name == key or name.startswith(key + ".") for key in PRIVATE_TABLES)
        (private if hidden else public).append(text[match.start():end])
    public, private = "".join(public), "".join(private)
    tomllib.loads(public)
    tomllib.loads(private)
    return public, private


def combine_codex(public, private):
    roots, tables = [], []
    for text in (public, private):
        match = TABLE.search(text)
        roots.append(text[:match.start()] if match else text)
        tables.append(text[match.start():] if match else "")
    result = "\n".join(roots + tables)
    tomllib.loads(result)
    return result


def destination(name, home, config):
    path = Path(name)
    if path.is_absolute() or ".." in path.parts:
        raise ValueError(f"Invalid destination: {name}")
    return config / path.relative_to(".config") if path.parts[0] == ".config" else home / path


def mappings(repo, home, config):
    manifest = json.loads((repo / "symlinks.json").read_text())
    pairs = [(repo / source, destination(target, home, config))
             for target, source in manifest["files"].items()]
    for target, source in manifest["trees"].items():
        root = repo / source
        for path in sorted(root.rglob("*")):
            if path.is_file():
                pairs.append((path, destination(target, home, config) / path.relative_to(root)))
    targets = [target for _, target in pairs]
    if len(targets) != len(set(targets)):
        raise ValueError("Duplicate link destinations")
    return pairs


def same_link(source, target):
    return target.is_symlink() and target.resolve() == source.resolve()


def install(pairs, backup_root):
    """Replace files with links. Restore all changed entries if an action fails."""
    changed = []
    try:
        for index, (source, target) in enumerate(pairs):
            if same_link(source, target):
                continue
            target.parent.mkdir(parents=True, exist_ok=True)
            backup = None
            if target.exists() or target.is_symlink():
                backup = backup_root / str(index)
                shutil.move(str(target), str(backup))
            changed.append((target, backup))
            target.symlink_to(source)
        (backup_root / "links.json").write_text(json.dumps([
            {"target": str(target), "backup": str(backup) if backup else None}
            for target, backup in changed
        ], indent=2) + "\n")
    except BaseException:
        for target, backup in reversed(changed):
            if target.is_symlink():
                target.unlink()
            if backup:
                shutil.move(str(backup), str(target))
        raise


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true", help="Back up and create links")
    parser.add_argument("--replace", action="store_true", help="Replace reviewed differing files")
    parser.add_argument("--check", action="store_true", help="Check links and generated Codex config")
    parser.add_argument("--capture-codex", action="store_true", help="Import current Codex preferences")
    args = parser.parse_args()
    if args.apply and args.check:
        parser.error("Use --apply or --check, not both")
    if args.capture_codex and (args.apply or args.check):
        parser.error("Use --capture-codex separately")
    home = Path.home()
    config = Path(os.environ.get("XDG_CONFIG_HOME", str(home / ".config")))
    pairs = mappings(REPO, home, config)
    public = (REPO / "agents/codex/config.toml").read_text()
    current = home / ".codex/config.toml"
    private_path = REPO / ".local/codex/private.toml"
    if args.capture_codex:
        public, private = split_codex(current.read_text())
        state = Path(os.environ.get("XDG_STATE_HOME", str(home / ".local/state")))
        backup_base = state / "dotfiles-backups"
        backup_base.mkdir(parents=True, exist_ok=True)
        backup = Path(tempfile.mkdtemp(prefix="codex-", dir=backup_base))
        shutil.copy2(REPO / "agents/codex/config.toml", backup / "config.toml")
        if private_path.exists():
            shutil.copy2(private_path, backup / "private.toml")
        private_path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        private_path.write_text(private)
        private_path.chmod(0o600)
        (REPO / "agents/codex/config.toml").write_text(public)
        print(f"Captured Codex preferences. Review the diff before committing. Backups: {backup}")
        return
    private = private_path.read_text() if private_path.exists() else ""
    if current.exists():
        current_public, private = split_codex(current.read_text())
        codex_differs = tomllib.loads(current_public) != tomllib.loads(public)
    else:
        codex_differs = False
    generated = REPO / ".local/codex/config.toml"
    rendered = combine_codex(public, private)
    conflicts = []
    missing = []
    for source, target in pairs:
        if source != generated and not source.is_file():
            raise ValueError(f"Missing source: {source}")
        if target.is_dir():
            raise ValueError(f"Expected a file: {target}")
        if not same_link(source, target):
            missing.append(str(target))
        if target.exists() and source != generated and target.read_bytes() != source.read_bytes():
            conflicts.append(str(target))
    if codex_differs:
        conflicts.append(str(current))
    if args.check:
        if missing or codex_differs or not generated.exists():
            raise ValueError("Sync required: " + ", ".join(missing + conflicts))
        print(f"Verified {len(pairs)} links and Codex settings.")
        return
    print(f"Links: {len(pairs)}; pending: {len(missing)}; differing files: {len(conflicts)}")
    for path in conflicts:
        print(f"Review: {path}")
    if not args.apply:
        print("Dry run. Review differences, then run --apply [--replace].")
        return
    if conflicts and not args.replace:
        raise ValueError("Differing files require review and --replace")
    state = Path(os.environ.get("XDG_STATE_HOME", str(home / ".local/state")))
    backup_base = state / "dotfiles-backups"
    backup_base.mkdir(parents=True, exist_ok=True)
    backup = Path(tempfile.mkdtemp(prefix="links-", dir=backup_base))
    # Back up generated files before writing through an existing live link.
    previous = {}
    for path in (private_path, generated):
        previous[path] = path.read_bytes() if path.exists() else None
        if path.exists():
            shutil.copy2(path, backup / path.name)
    try:
        generated.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        private_path.write_text(private)
        generated.write_text(rendered)
        private_path.chmod(0o600)
        generated.chmod(0o600)
        install(pairs, backup)
    except BaseException:
        for path, content in previous.items():
            if content is None:
                path.unlink(missing_ok=True)
            else:
                path.write_bytes(content)
        raise
    print(f"Linked {len(pairs)} files. Backups: {backup}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as error:
        raise SystemExit(str(error))
