module System.Syscall;

import Data.Address;
import Data.String;
import Data.Register;
import Task.Scheduler : GetScheduler;

enum SyscallCategory {
	File,
	Memory,
	Task,
	HW
}

struct SyscallEntry {
	ulong id;
	string name;
	string description;
	SyscallCategory category;
}

@SyscallEntry(0, "Exit", "This terminates the current running process")
void Exit(long errorcode) {
	auto scheduler = GetScheduler;
	scheduler.Exit(errorcode);

	scheduler.CurrentProcess.syscallRegisters.RAX = 0;
}

@SyscallEntry(1, "Clone", "Start a new process")
void Clone(ulong function(void*) func, VirtAddress stack, void* userdata, string name) {
	auto scheduler = GetScheduler;
	GetScheduler.CurrentProcess.syscallRegisters.RAX = scheduler.Clone(func, stack, userdata, name);
}

@SyscallEntry(2, "Fork", "Start a new process")
void Fork() {
	auto scheduler = GetScheduler;

	scheduler.CurrentProcess.syscallRegisters.RAX = scheduler.Fork();
}

@SyscallEntry(3, "Yield", "Yield")
void Yield() {
	auto scheduler = GetScheduler;
	//Untill we have a Yield, lets use USleep
	scheduler.USleep(200);
	scheduler.CurrentProcess.syscallRegisters.RAX = 0;
}

@SyscallEntry(4, "Exec", "Replace current process with executable")
void Exec(string file) {
	import IO.Log : log;

	log.Warning("Called Exec: ", file);

	while (true) {
	}

	auto process = GetScheduler.CurrentProcess;
	process.syscallRegisters.RAX = 0xDEAD_C0DE;
}

@SyscallEntry(5, "Alloc", "Allocate memory")
void Alloc(ulong size) {
	auto process = GetScheduler.CurrentProcess;
	process.syscallRegisters.RAX = process.heap.Alloc(size).VirtAddress;
}

@SyscallEntry(6, "Free", "Free memory")
void Free(void* addr) {
	auto process = GetScheduler.CurrentProcess;
	process.heap.Free(addr);
	process.syscallRegisters.RAX = 0;
}

@SyscallEntry(7, "Realloc", "Reallocate memory")
void Realloc(void* addr, ulong newSize) {
	auto process = GetScheduler.CurrentProcess;
	process.syscallRegisters.RAX = process.heap.Realloc(addr, newSize).VirtAddress;
}

@SyscallEntry(15, "Print", "Print a string to the screen")
void Print(string str) {
	import Data.TextBuffer : scr = GetBootTTY;

	scr.Writeln(str);

	auto process = GetScheduler.CurrentProcess;
	process.syscallRegisters.RAX = 0;
}

@SyscallEntry(16, "PrintCStr", "Print a cstring to the screen")
void PrintCStr(const(char)* str) {
	import Data.TextBuffer : scr = GetBootTTY;

	scr.Writeln(str.fromStringz);

	auto process = GetScheduler.CurrentProcess;
	process.syscallRegisters.RAX = 0;
}