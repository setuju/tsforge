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

Type "mkdir -p /tmp/tsforge-demo && cd /tmp/tsforge-demo"
Enter
Sleep 400ms

Type "npx tsc --init --strict --noEmit"
Enter
Sleep 3s

Type "touch index.ts"
Enter
Sleep 300ms

Hide
Type "clear"
Enter
Show

Type "# The problem: npx tsc --noEmit feels slow"
Enter
Sleep 500ms

Type "time npx tsc --noEmit"
Enter
Sleep 3s

Hide
Type "clear"
Enter
Show

Type "# The solution: tsforge"
Enter
Sleep 500ms

Type "source /home/jack/saturumah/tsforge/tsforge.sh"
Enter
Sleep 800ms

Type "tsforge-help | head -15"
Enter
Sleep 2s

Hide
Type "clear"
Enter
Show

Type "tsc-where"
Enter
Sleep 2s

Hide
Type "clear"
Enter
Show

Type "tsc-optimize"
Enter
Sleep 2s

Hide
Type "clear"
Enter
Show

Type "tsc-fast"
Enter
Sleep 3s

Hide
Type "clear"
Enter
Show

Type "tsc-diagx | head -25"
Enter
Sleep 3s

Hide
Type "clear"
Enter
Show

Type "tsgo-fast"
Enter
Sleep 3s

Hide
Type "clear"
Enter
Show

Type "# tsforge - TypeScript, faster."
Enter
Sleep 500ms

Type "# https://github.com/setuju/tsforge"
Enter
Sleep 2s

Sleep 1s
