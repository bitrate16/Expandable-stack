#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <csignal>
#include <cstring>
#include <cstdint>

// Detect compilation environment
#if defined(__x86_64__)
#define type_int uint64_t
#endif
#if defined(__i386__)
#define type_int uint32_t
#endif

// Pre-defined values (For example - 1Mb)
#define ALLOCATE_STACK_SIZE 1 * 1024 * 1024
#define SEGV_STACK_SIZE    16 * 1024

// Old ESP value (For safe restoration)
type_int old_esp_pointer = 0;
// Pointer to new stack area
type_int *new_stack = NULL;
type_int new_stack_top = 0;
// New stack size
type_int new_stack_size = 0;

// Address of main args
int main_argc = 0;
char** main_argv = NULL;

// Wrapper for main function should be called on new stack
void wrap_main(int stack_size, int argc, char** argv);

// Default main ( -O3 will give endless loop )
// Run with:
//  mkdir -p bin && g++ --std=c++17 program.cpp -o bin/program && ./bin/program
// Debug with:
//  mkdir -p bin && g++ --std=c++17 -w -g program.cpp -o bin/program && valgrind ./bin/program
// ASM output:
//  mkdir -p bin && g++ --std=c++17 -S program.cpp -o bin/program.asm
int main(int argc, char** argv) {
	// Copy main() arguments
	main_argc = argc;
	main_argv = argv;
	
	// Allocate memory for new stack
	new_stack_size = ALLOCATE_STACK_SIZE;
	new_stack = (type_int*) malloc((size_t) new_stack_size);
	
	if (!new_stack) {
		fprintf(stderr, "Failed allocate stack\n");
		exit(1);
	}
	
	// Pointer to new stack top
	new_stack_top   = (type_int) (uintptr_t) new_stack + new_stack_size;
	new_stack_size -= new_stack_top & 0xf;
	// Align stack by 16
	new_stack_top  &= ~0xf;
	
	// Save old ESP value
	old_esp_pointer = (type_int) (uintptr_t) &new_stack_top + sizeof(int); // bug here?
	
	// Debug Running platform & int sizes
	printf("Running on ");
#if defined(__x86_64__)
	printf("__x86_x64__\n");
#endif
#if defined(__i386__)
	printf("__i386__\n");
#endif
	
	// Print debug info
	printf("Old ESP: %#011x\n", old_esp_pointer);

    // Save SP and set SP to our newly created stack frame
#if defined(__x86_64__)
    __asm__ ( 
          "mov %%rsp, %%rax\n"
		  "mov %%rbx, %%rsp\n"
        : "=a"(old_esp_pointer)
		: "b"(new_stack_top)
        );
#endif
#if defined(__i386__)
    __asm__ ( 
          "mov %%esp, %%eax\n"
		  "mov %%ebx, %%esp\n"
        : "=a"(old_esp_pointer)
		: "b"(new_stack_top)
        );
#endif
	
	// Print debug info
	printf("New ESP: %#011x\n", new_stack_top);
	printf("Min ESP: %#011x\n", (type_int) new_stack);
	
    // Call wrap_main here
	//  Important note:
	//  When program handles signal from outer and 
	//   need to safety finish it's work, it have to return 
	//   from wrap_main and dispose new_stack pointer manually
	wrap_main(new_stack_size, main_argc, main_argv);

    // Restore old SP so we can return to OS
#if defined(__x86_64__)
    __asm__(
          "mov %%rax, %%rsp"
		: "=a"(old_esp_pointer)
		: "a"(old_esp_pointer)
		);
#endif
#if defined(__i386__)
    __asm__(
          "mov %%eax, %%esp"
		: "=a"(old_esp_pointer)
		: "a"(old_esp_pointer)
		);
#endif

	printf("Restored ESP: %#011x\n", old_esp_pointer);
	
	// Free allocated stack here
    free(new_stack);
	
    return 0;
}

// Counter for recursive calls
int stack_call_counter = 0;
type_int *segfault_stack = NULL;

// Handling SIGSEGV to determine stack overflow
void segfault_sigaction(int signal, siginfo_t *si, void *arg) {
    printf("Caught segfault at address %p\n", si->si_addr);
    printf("Counter value at exit %d\n", stack_call_counter);
	
	// free(new_stack);
	// new_stack = NULL;
	// free(segfault_stack);
	// segfault_stack = NULL;
    exit(1);
}

// Self-calling recursive function
void recursion() {
	++stack_call_counter;
	recursion();
};

// Demo of wrap_main here, calling recursive function 
//  and trying to count amount of calls.
// Expectedly, program will throw Segmentation Fault, 
//  but try to havndle it with SIGSEGV sigaction
void wrap_main(int stack_size, int argc, char** argv) {
	// Print stack size
	printf("Stack size: %d\n", stack_size);
	
	// Print arguments
	printf("Arguments:\n");
	for (int i = 0; i < argc; ++i)
		printf("argv[%d] = \"%s\"\n", i, argv[i]);
	
	// Reserve stack for SIGSEGV
	stack_t segv_stack;
	segv_stack.ss_sp = valloc(SEGV_STACK_SIZE);
	segv_stack.ss_flags = 0;
	segv_stack.ss_size = SEGV_STACK_SIZE;
	sigaltstack(&segv_stack, NULL);
	
	// Reserve stack for SIGSEGV & set handler
	segfault_stack = (type_int*) valloc(SEGV_STACK_SIZE);
    stack_t ss;
	ss.ss_size = SEGV_STACK_SIZE;
	ss.ss_sp   = segfault_stack;
	
    struct sigaction sa;
	sa.sa_sigaction = segfault_sigaction;
	sa.sa_flags = SA_SIGINFO | SA_ONSTACK;

    sigaltstack(&ss, 0);
    sigfillset(&sa.sa_mask);
    sigaction(SIGSEGV, &sa, 0);
	
	// Call recursive
	recursion();
};