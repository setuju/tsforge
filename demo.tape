# ============================================================
#  demo.tape — VHS demo for tsforge (CI-safe)
#  Author  : Jack
#  GitHub  : https://github.com/setuju
#  Website : https://saturumah.net
# ============================================================

Output demo.gif
Set Shell "bash"
Set FontFamily "JetBrains Mono, Fira Code, DejaVu Sans Mono, monospace"
Set FontSize 16
Set Width 1200
Set Height 600
Set Padding 20
Set Theme "Dracula"
Set TypingSpeed 50ms
Set Framerate 30
Set CursorBlink false

# ---------------------------------------------------------------------------
# Scene 1: Show the problem — using a temporary project
# ---------------------------------------------------------------------------
Type "# Create a temporary TypeScript project"
Enter
Sleep 300ms

Type "mkdir -p /tmp/demo && cd /tmp/demo"
Enter
Sleep 300ms

Type "printf '{\"compilerOptions\":{\"strict\":true,\"noEmit\":true}}' > tsconfig.json"
Enter
Sleep 300ms

Type "echo 'export const hello: string = \"world\";' > index.ts"
Enter
Sleep 300ms

Type "# The problem: npx tsc --noEmit feels slow"
Enter
Sleep 500ms

Type "time npx tsc --noEmit"
Enter
Sleep 2s

# ---------------------------------------------------------------------------
# Scene 2: Load tsforge from the repository
# ---------------------------------------------------------------------------
Hide
Type "clear"
Enter
Show

Type "# The solution: tsforge"
Enter
Sleep 500ms

Type "source ./tsforge.sh"
Enter
Sleep 500ms

Type "tsforge-help | head -15"
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
# Scene 7: Native compiler
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

Sleep 1s
