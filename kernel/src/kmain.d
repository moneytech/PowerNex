module kmain;

import io.log;
import io.textmode;
import cpu.gdt;
import cpu.idt;
import multiboot;
import memory.paging;
import memory.frameallocator;
import linker;
import data.address;

alias scr = GetScreen;
alias gdt = GDT;
alias idt = IDT;

immutable uint major = __VERSION__ / 1000;
immutable uint minor = __VERSION__ % 1000;

extern (C) int kmain(uint magic, ulong info) {
	scr.Clear();
	gdt.Init();
	idt.Init();
	log.Init();
	Multiboot.ParseHeader(magic, info);
	FrameAllocator.Init();

	scr.Writeln("Welcome to PowerNex!");
	scr.Writeln("\tThe number one D kernel!");
	scr.Writeln("Compiled using '", __VENDOR__, "', D version ", major, ".", minor, "\n");

	log.Info("Welcome to PowerNex's serial console!");
	log.Info("Init paging");
	Paging* kernelPaging = GetKernelPaging;
	log.Info("Installing paging");
	kernelPaging.Install();

	scr.Writeln();
	scr.Writeln();

	scr.color.Foreground = Colors.Green;
	log.Info("Testing mapping");
	kernelPaging.Map(VirtAddress(0xA_0000_0000), PhysAddress(0x0), MapMode.DefaultUser);
	kernelPaging.Unmap(VirtAddress(0xA_0000_0000));

	log.Info("Testing MapFreeMemory");
	kernelPaging.MapFreeMemory(VirtAddress(0xB_0000_0000), MapMode.DefaultUser);
	int* test = cast(int*)0xB_0000_0000;
	*test = 0xDEAD_BEEF;
	kernelPaging.Unmap(VirtAddress(0xB_0000_0000));

	asm {
	forever:
		hlt;
		jmp forever;
	}
	return 0;
}
