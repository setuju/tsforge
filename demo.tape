# ============================================================
#  demo.tape — VHS demo for tsforge
#  Author  : Jack
#  GitHub  : https://github.com/setuju
#  Website : https://saturumah.net
#
#  Generate the GIF:
#    vhs demo.tape
#
#  Prerequisites:
#    brew install vhs ttyd ffmpeg
#    # or: nix-shell (uses the shell.nix in this repo)
# ============================================================

# ---------------------------------------------------------------------------
# Output settings
# ---------------------------------------------------------------------------
Output demo.gif
Set Shell "bash"
Set FontFamily "JetBrains Mono"
Set FontSize 16
Set Width 1200
Set Height 600
Set Padding 20
Set Theme "Dracula"
Set TypingSpeed 50ms
Set Framerate 30
Set PlaybackSpeed 1.0
Set CursorBlink false

# ---------------------------------------------------------------------------
# Scene 1: Intro — show the problem
# ---------------------------------------------------------------------------
Type "# The problem: npx tsc --noEmit feels slow"
Enter
Sleep 500ms

Type "cd /home/jack/saturumah/SHALA-V"
Enter
Sleep 300ms

Type "time npx tsc --noEmit"
Enter
Sleep 2s

# ---------------------------------------------------------------------------
# Scene 2: Load tsforge
# ---------------------------------------------------------------------------
Hide
Type "clear"
Enter
Show

Type "# The solution: tsforge"
Enter
Sleep 500ms

Type "source ~/tsforge.sh"
Enter
Sleep 500ms

Type "tsc-help | head -20"
Enter
Sleep 2s

# ---------------------------------------------------------------------------
# Scene 3: Environment check
# ---------------------------------------------------------------------------
Hide
Type "clear"
Enter
Show

Type "tsc-where"
Enter
Sleep 2s

# ---------------------------------------------------------------------------
# Scene 4: Optimize tsconfig
# ---------------------------------------------------------------------------
Hide
Type "clear"
Enter
Show

Type "tsc-optimize"
Enter
Sleep 2s

# ---------------------------------------------------------------------------
# Scene 5: Fast type-check
# ---------------------------------------------------------------------------
Hide
Type "clear"
Enter
Show

Type "tsc-fast"
Enter
Sleep 3s

# ---------------------------------------------------------------------------
# Scene 6: Diagnostics
# ---------------------------------------------------------------------------
Hide
Type "clear"
Enter
Show

Type "tsc-diagx | head -30"
Enter
Sleep 3s

# ---------------------------------------------------------------------------
# Scene 7: Native compiler (tsgo)
# ---------------------------------------------------------------------------
Hide
Type "clear"
Enter
Show

Type "tsgo-fast"
Enter
Sleep 3s

# ---------------------------------------------------------------------------
# Scene 8: Outro
# ---------------------------------------------------------------------------
Hide
Type "clear"
Enter
Show

Type "# tsforge — TypeScript, faster."
Enter
Sleep 500ms

Type "# https://github.com/setuju/tsforge"
Enter
Sleep 2s

# Done
Sleep 1s