# modules/fonts.nix
#
# Fonts for GUI apps forwarded to Windows via WSLg (see
# modules/wsl.nix) and for terminal emulators that want icon/glyph
# support (see modules/packages/terminals.nix). JetBrainsMono Nerd Font
# is a patched version of the JetBrains Mono monospace font with the
# extra glyphs Starship, Nushell, and many terminal prompts/plugins
# expect (https://www.nerdfonts.com/).
{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    fontconfig.enable = true;
  };

  # Point your terminal emulator (kitty, Konsole, or Windows Terminal if
  # you're using that instead) at "JetBrainsMono Nerd Font" to actually
  # see the icons/glyphs -- installing the font alone doesn't change any
  # app's configured font.
}
