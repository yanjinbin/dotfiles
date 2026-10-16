# Herdr fonts

Binary snapshots of the fonts installed on the source Mac on 2026-10-16. These files preserve the exact patched faces used by Otty and Herdr.app. Family names, versions, original paths, sizes, and SHA-256 hashes are recorded in [manifest.json](manifest.json).

| Family | File | Purpose |
| --- | --- | --- |
| MesloLGS NF Herdr | [MesloLGSNFHerdr-Regular.ttf](herdr/MesloLGSNFHerdr-Regular.ttf) | Patched terminal text face with 30 Herdr icons |
| MesloLGS NF Herdr Fit | [MesloLGSNFHerdrFit-Regular.ttf](herdr/MesloLGSNFHerdrFit-Regular.ttf) | Installed Fit variant, selected in Herdr.app |
| JetBrains Mono Herdr | [JetBrainsMonoHerdr-Regular.ttf](herdr/JetBrainsMonoHerdr-Regular.ttf) | Patched UI text face with 30 Herdr icons |
| Herdr Agent Icons Max | [HerdrAgentIconsMax-7526f2a2.ttf](herdr/HerdrAgentIconsMax-7526f2a2.ttf) | 30-icon face matching the installed Radar distribution |
| Herdr Agent Icons Max | [HerdrAgentIconsMax-d77910ea.ttf](../.config/otty/fonts/HerdrAgentIconsMax-d77910ea.ttf) | Earlier 29-icon face already stored for Otty; no duplicate copy |
| JetBrains Mono | [JetBrainsMono-Regular.ttf](base/JetBrainsMono-Regular.ttf) | Unpatched face used by Herdr.app tabs |
| MesloLGL Nerd Font | [MesloLGLNerdFont-Regular.ttf](base/MesloLGLNerdFont-Regular.ttf) | Unpatched face used by Herdr.app sidebar |

Only the installed Regular styles listed above are archived. The two icon files share the same family, PostScript name, and version string but have different glyph sets and hashes. A family name alone does not identify the binary.

## Restore on macOS

From the repository root, verify all seven archived files:

```bash
shasum -a 256 -c fonts/SHA256SUMS
```

Install the six files under `fonts/` for the current user. Existing files are left in place:

```bash
mkdir -p "$HOME/Library/Fonts"
cp -n fonts/herdr/*.ttf fonts/base/*.ttf "$HOME/Library/Fonts/"
```

Compare existing files if `cp -n` skips them; this command does not prove that an existing font matches the snapshot. Reopen the application or its font picker and select the exact family names above. Use Font Book to inspect duplicate registrations if a different binary with the same family name is already installed.

The earlier icon file remains in Otty's managed font directory. The system-font restore command installs the 30-icon version only. This archive does not change current font registrations or add system fonts to the configuration symlink list.

## Provenance and notices

- All font binaries were copied byte for byte from `~/Library/Fonts/`. FontTools parsed every table; all three patched text faces contain the 30 codepoints in the newer icon face.
- The JetBrains Mono Herdr and newer icon binaries also match the existing Radar plugin's `dist/` files by SHA-256. See the copied [Radar MIT license](licenses/Herdr-Radar-MIT.txt) and [third-party notices](licenses/Herdr-Radar-THIRD-PARTY-NOTICES.md).
- Both JetBrains text faces retain their embedded copyright and SIL OFL records. The [JetBrains Mono OFL](licenses/JetBrains-Mono-OFL.txt) is copied from Radar's distribution.
- The Meslo NF notice is copied from [powerlevel10k-media](https://github.com/romkatv/powerlevel10k-media/blob/master/MesloLGS%20NF%20License.txt) into [MesloLGS-NF.txt](licenses/MesloLGS-NF.txt). The [Meslo Nerd Font notice](licenses/Meslo-Nerd-Font.txt) comes from the installed Homebrew font package, version 3.5.1. The [Apache 2.0 text](licenses/Apache-2.0.txt) is included alongside these notices. Embedded copyright records are preserved in the fonts and manifest.
- The local build recipe for the two patched Meslo faces was not recovered. This archive preserves their exact binaries; it does not claim a reproducible source build. The original copyright and third-party icon notices continue to apply.
