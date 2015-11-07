module kmain;

import io.textmode;

alias scr = GetScreen;

immutable uint major = __VERSION__ / 1000;
immutable uint minor = __VERSION__ % 1000;

void main() {
	scr.Clear();
	scr.Writeln("Welcome to PowerNex!");
	scr.Writeln("\tThe number one D kernel!");
	scr.Write("Compiled using '", __VENDOR__, "', D version ", major, ".", minor, "\n");

	asm {
		forever:
			hlt;
			jmp forever;
	}
}