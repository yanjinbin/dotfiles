"""Exercise file replacement and private-config handling without touching HOME."""

import importlib.util
import json
from pathlib import Path
import tempfile
import tomllib
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location(
    "sync", Path(__file__).resolve().parents[1] / "scripts/sync.py")
sync = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sync)


class SyncTest(unittest.TestCase):
    def test_codex_split_preserves_nested_values_and_private_paths(self):
        original = '''model = "test-model"
notify = ["/private/client", "turn-ended"]
[projects."/private/client-work"]
trust_level = "trusted"
[tui]
status_line = ["current-dir"]
[tui.model_availability_nux]
seen = 4
[mcp_servers.node_repl.env]
LOCAL_PATH = "/private/runtime"
[plugins.example]
enabled = true
[hooks.state."private-hook"]
trusted_hash = "sha256:test"
'''
        public, private = sync.split_codex(original)
        self.assertNotIn("/private", public)
        self.assertNotIn("trusted_hash", public)
        self.assertIn("status_line", public)
        self.assertEqual(tomllib.loads(sync.combine_codex(public, private)),
                         tomllib.loads(original))

    def test_unknown_notify_layout_fails_before_data_is_written(self):
        with self.assertRaises(tomllib.TOMLDecodeError):
            sync.split_codex('notify = [\n  "client",\n]\nmodel = "test"\n')

    def test_links_preserve_originals_and_repeat_without_changes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source, target, backup = root / "source", root / "target", root / "backup"
            source.write_text("new")
            target.write_text("old")
            backup.mkdir()
            sync.install([(source, target)], backup)
            self.assertTrue(target.is_symlink())
            self.assertEqual(target.read_text(), "new")
            self.assertEqual((backup / "0").read_text(), "old")
            second = root / "second"
            second.mkdir()
            sync.install([(source, target)], second)
            self.assertFalse((second / "0").exists())

    def test_failed_link_restores_regular_file_and_original_symlink(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source, first, second = root / "source", root / "first", root / "second"
            source.write_text("new")
            first.write_text("old")
            second.symlink_to("missing-original")
            backup = root / "backup"
            backup.mkdir()
            symlink_to = Path.symlink_to

            def fail(path, destination, **kwargs):
                if path == second:
                    raise OSError("Simulated failure")
                return symlink_to(path, destination, **kwargs)

            with patch.object(Path, "symlink_to", fail), self.assertRaises(OSError):
                sync.install([(source, first), (source, second)], backup)
            self.assertFalse(first.is_symlink())
            self.assertEqual(first.read_text(), "old")
            self.assertEqual(second.readlink(), Path("missing-original"))

    def test_xdg_mapping_and_path_escape_rejection(self):
        self.assertEqual(sync.destination(".config/otty/config.toml", Path("/home/user"),
                                          Path("/xdg")), Path("/xdg/otty/config.toml"))
        for name in ("/etc/profile", "../outside"):
            with self.assertRaises(ValueError):
                sync.destination(name, Path("/home/user"), Path("/xdg"))

    def test_apply_refuses_unreviewed_changes_then_preserves_private_state(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            repo, home = root / "repo", root / "home"
            (repo / "agents/codex").mkdir(parents=True)
            (home / ".codex").mkdir(parents=True)
            (repo / ".zshrc").write_text("new\n")
            (home / ".zshrc").write_text("old\n")
            original = 'model = "test"\n[projects."/private/job"]\ntrust_level = "trusted"\n'
            (home / ".codex/config.toml").write_text(original)
            (home / ".codex/auth.json").write_text("private credentials")
            (repo / "agents/codex/config.toml").write_text('model = "test"\n')
            (repo / "symlinks.json").write_text(json.dumps({"files": {
                ".zshrc": ".zshrc", ".codex/config.toml": ".local/codex/config.toml",
            }, "trees": {}}))
            with patch.object(sync, "REPO", repo), patch.object(Path, "home", return_value=home), \
                    patch.dict(sync.os.environ, {"XDG_CONFIG_HOME": str(home / ".config"),
                                                 "XDG_STATE_HOME": str(home / ".local/state")}):
                with patch("sys.argv", ["sync.py", "--apply"]), self.assertRaises(ValueError):
                    sync.main()
                self.assertEqual((home / ".zshrc").read_text(), "old\n")
                self.assertFalse((repo / ".local/codex/config.toml").exists())
                with patch("sys.argv", ["sync.py", "--apply", "--replace"]):
                    sync.main()
                with patch("sys.argv", ["sync.py", "--check"]):
                    sync.main()
            self.assertEqual(tomllib.loads((home / ".codex/config.toml").read_text()),
                             tomllib.loads(original))
            self.assertEqual((home / ".codex/auth.json").read_text(), "private credentials")
            self.assertNotIn("/private/job", (repo / "agents/codex/config.toml").read_text())


if __name__ == "__main__":
    unittest.main()
