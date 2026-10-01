"""Test shell shortcuts without calling an AI service or changing user settings."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


PLUGIN = Path(os.environ.get(
    "AI_CLI_PLUGIN",
    str(Path(__file__).resolve().parents[1]
        / ".oh-my-zsh/custom/plugins/perfect-little-angle/perfect-little-angle.plugin.zsh"),
))


class ShortcutTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="ai-cli-test-")
        self.addCleanup(self.temp.cleanup)
        root = Path(self.temp.name)
        self.config = root / "config"
        self.regions = self.config / "ai-cli/regions.conf"
        self.regions.parent.mkdir(parents=True)
        self.regions.write_text("cc=sg\ncx=la\nagy=la\n")
        bin_dir = root / "bin"
        bin_dir.mkdir()
        stub = f"#!{sys.executable}\n" + '''import json, os, sys
print("RUNNER:" + json.dumps({
    "args": sys.argv[1:],
    "env": {k: os.environ.get(k) for k in ["TZ", "LANG", "LC_ALL", "https_proxy"]},
}))
'''
        for cli in ("codex", "claude", "agy"):
            executable = bin_dir / cli
            executable.write_text(stub)
            executable.chmod(0o755)
        self.env = dict(os.environ, HOME=str(root), XDG_CONFIG_HOME=str(self.config),
                        PATH=str(bin_dir) + os.pathsep + os.environ["PATH"])
        for key in ("AI_CC_VERBOSE", "AI_CX_REASONING_SUMMARY", "AI_CC_MODEL", "AI_CX_MODEL"):
            self.env.pop(key, None)

    def shell(self, command, ok=True):
        result = subprocess.run(
            ["zsh", "-f", "-c", 'source "$1"\n' + command, "test", str(PLUGIN)],
            env=self.env, text=True, capture_output=True,
        )
        self.assertEqual(result.returncode == 0, ok, result.stdout + result.stderr)
        return result.stdout

    def call(self, command):
        output = self.shell(command)
        return json.loads(next(line[7:] for line in output.splitlines()
                               if line.startswith("RUNNER:")))

    def test_region_persists_between_shells_and_is_separate_per_cli(self):
        self.assertIn("cc 默认地区：sg", self.shell("cc region current"))
        self.shell("cc region set la")
        self.assertIn("cc 默认地区：la", self.shell("cc region current"))
        self.assertIn("cx 默认地区：la", self.shell("cx region current"))
        self.assertEqual(self.call("cc")["env"]["TZ"], "America/Los_Angeles")
        self.shell("cc region set sg")
        self.assertIn("cc 默认地区：sg", self.shell("cc region current"))
        self.assertEqual(self.regions.read_text(), "cc=sg\ncx=la\nagy=la\n")

    def test_config_is_the_only_source_and_is_read_on_each_call(self):
        legacy = self.config / "ai-cli/regions"
        legacy.mkdir()
        (legacy / "cx").write_text("tokyo\n")
        self.assertEqual(self.call("cx")["env"]["TZ"], "America/Los_Angeles")
        self.regions.write_text("cc=taipei\ncx=sg\nagy=kl\n")
        for cli, timezone, locale in (("cc", "Asia/Taipei", "zh_TW.UTF-8"),
                                      ("cx", "Asia/Singapore", "zh_CN.UTF-8"),
                                      ("agy", "Asia/Kuala_Lumpur", "en_US.UTF-8")):
            env = self.call(cli)["env"]
            self.assertEqual((env["TZ"], env["LANG"], env["LC_ALL"]),
                             (timezone, locale, locale))
        self.assertEqual((legacy / "cx").read_text(), "tokyo\n")
        output = self.shell('cx; printf "cc=sg\\ncx=tokyo\\nagy=la\\n" '
                            '> "$XDG_CONFIG_HOME/ai-cli/regions.conf"; cx')
        calls = [json.loads(line[7:]) for line in output.splitlines()
                 if line.startswith("RUNNER:")]
        self.assertEqual([call["env"]["TZ"] for call in calls],
                         ["Asia/Singapore", "Asia/Tokyo"])

    def test_missing_or_invalid_config_fails_without_hidden_defaults(self):
        self.regions.unlink()
        self.shell("cx", ok=False)
        self.assertIn("region current", self.shell("cx help"))
        for content in ("", "cc=sg\n", "cc=sg\ncx=la\nagy=invalid\n",
                        "cc=sg\ncx=la\nagy=la\ncx=tokyo\n",
                        "cc=sg\ncx=$(touch marker)\nagy=la\n"):
            self.regions.write_text(content)
            self.shell("cx", ok=False)
            self.shell("cc region set la", ok=False)
            self.assertEqual(self.regions.read_text(), content)

    def test_reset_does_not_restore_a_hidden_default(self):
        original = self.regions.read_text()
        self.shell("cx region reset", ok=False)
        self.assertEqual(self.regions.read_text(), original)

    def test_set_preserves_a_symlink_to_the_tracked_config(self):
        target = Path(self.temp.name) / "tracked-regions.conf"
        self.regions.rename(target)
        self.regions.symlink_to(target)
        self.shell("cc region set tokyo")
        self.assertTrue(self.regions.is_symlink())
        self.assertEqual(target.read_text(), "cc=tokyo\ncx=la\nagy=la\n")

    def test_region_shared_by_display_and_proxy_shortcuts(self):
        self.shell("cxd region set tokyo")
        for cli in ("cx", "cxa", "cxc", "cxd", "cxn", "cxp", "cxf", "cxpf"):
            self.assertEqual(self.call(cli)["env"]["TZ"], "Asia/Tokyo")
        self.shell("ccd region set taipei")
        for cli in ("cc", "ccn", "ccd", "ccp", "ccpn", "ccpd"):
            self.assertEqual(self.call(cli)["env"]["TZ"], "Asia/Taipei")
        self.shell("ag region set kl")
        self.assertIn("agy 默认地区：kl", self.shell("agy region current"))
        self.assertEqual(self.call("agyp")["env"]["TZ"], "Asia/Kuala_Lumpur")

    def test_overrides_do_not_change_saved_defaults(self):
        self.shell("cc region set la")
        env = self.call("cc sg")["env"]
        self.assertEqual((env["TZ"], env["LANG"]), ("Asia/Singapore", "zh_CN.UTF-8"))
        env = self.call("cc --timezone Asia/Shanghai --locale en_US.UTF-8")["env"]
        self.assertEqual((env["TZ"], env["LC_ALL"]), ("Asia/Shanghai", "en_US.UTF-8"))
        self.assertIn("cc 默认地区：la", self.shell("cc region current"))

    def test_invalid_region_commands_preserve_saved_value(self):
        self.shell("cc region set la")
        for args in ("set unknown", "set ../cc", "set", 'set ""', "set la extra",
                     "reset extra", "current extra", "unknown"):
            self.shell("cc region " + args, ok=False)
        self.assertIn("cc 默认地区：la", self.shell("cc region current"))

    def test_all_regions_and_write_failure(self):
        for region in ("sg", "la", "tokyo", "kl", "taipei"):
            self.shell("cc region set " + region)
            self.call("cc")
        blocked = Path(self.temp.name) / "blocked"
        blocked.write_text("not a directory")
        self.env["XDG_CONFIG_HOME"] = str(blocked)
        self.shell("cc region set la", ok=False)

    def test_codex_summary_modes_and_native_arguments(self):
        for cli, summary in (("cxa", "auto"), ("cxc", "concise"),
                             ("cxd", "detailed"), ("cxn", "none")):
            args = self.call(cli + " resume --last")["args"]
            self.assertIn('model_reasoning_summary="' + summary + '"', args)
            self.assertIn("hide_agent_reasoning=" + str(summary == "none").lower(), args)
            self.assertIn('model_reasoning_effort="high"', args)
            self.assertEqual(args[-2:], ["resume", "--last"])
        args = self.call("cxp -r a")["args"]
        self.assertIn('model_reasoning_summary="auto"', args)

    def test_codex_fast_shortcuts_preserve_region_proxy_and_arguments(self):
        for cli, tier in (("cx", "default"), ("cxp", "default"),
                          ("cxf", "fast"), ("cxpf", "fast")):
            result = self.call(cli + " resume --last")
            self.assertIn('service_tier="' + tier + '"', result["args"])
            self.assertEqual(result["args"][-2:], ["resume", "--last"])
            self.assertEqual(result["env"]["TZ"], "America/Los_Angeles")
            if "p" in cli:
                self.assertEqual(result["env"]["https_proxy"], "http://127.0.0.1:7890")

    def test_claude_display_modes_and_native_arguments(self):
        for cli in ("ccd", "ccpd"):
            result = self.call(cli + ' sg plan --continue "Keep spaces"')
            self.assertIn("--verbose", result["args"])
            self.assertIn("--permission-mode", result["args"])
            self.assertEqual(result["args"][-2:], ["--continue", "Keep spaces"])
            self.assertNotIn("--print", result["args"])
            self.assertNotIn("--effort", result["args"])
        for cli in ("ccn", "ccpn"):
            args = self.call(cli)["args"]
            settings = json.loads(args[args.index("--settings") + 1])
            self.assertEqual(settings, {"viewMode": "default", "verbose": False})
            self.assertNotIn("--verbose", args)
        self.assertNotIn("--settings", self.call("cc")["args"])
        self.assertNotIn("--verbose", self.call("cc")["args"])
        self.assertEqual(self.call("ccpd")["env"]["https_proxy"], "http://127.0.0.1:7890")

    def test_help_and_native_help(self):
        for cli in ("cx", "cxa", "cxd", "cc", "ccn", "ccd", "ccpd", "agy"):
            output = self.shell(cli + " help")
            self.assertNotIn("RUNNER:", output)
            for topic in ("region current", "region set la", "regions.conf"):
                self.assertIn(topic, output)
            self.assertEqual(output, self.shell(cli + " --env-help"))
        self.assertIn("--help", self.call("cc --help")["args"])
        self.assertEqual(self.call("cc -- region current")["args"][-2:], ["region", "current"])
        self.assertIn("ccn", self.shell("cc help"))
        self.assertIn("cxa", self.shell("cx help"))

    def test_parent_environment_is_unchanged(self):
        output = self.shell('export TZ=UTC LANG=C LC_ALL=C; ccd >/dev/null; '
                            'print -r -- "PARENT:$TZ:$LANG:$LC_ALL:${AI_CC_VERBOSE-unset}"')
        self.assertIn("PARENT:UTC:C:C:unset", output)


if __name__ == "__main__":
    unittest.main()
