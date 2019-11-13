	.file	"program.cpp"
	.text
	.local	_ZStL8__ioinit
	.comm	_ZStL8__ioinit,1,1
	.globl	old_esp_pointer
	.bss
	.align 8
	.type	old_esp_pointer, @object
	.size	old_esp_pointer, 8
old_esp_pointer:
	.zero	8
	.globl	new_stack
	.align 8
	.type	new_stack, @object
	.size	new_stack, 8
new_stack:
	.zero	8
	.globl	new_stack_top
	.align 8
	.type	new_stack_top, @object
	.size	new_stack_top, 8
new_stack_top:
	.zero	8
	.globl	new_stack_size
	.align 8
	.type	new_stack_size, @object
	.size	new_stack_size, 8
new_stack_size:
	.zero	8
	.globl	main_argc
	.align 4
	.type	main_argc, @object
	.size	main_argc, 4
main_argc:
	.zero	4
	.globl	main_argv
	.align 8
	.type	main_argv, @object
	.size	main_argv, 8
main_argv:
	.zero	8
	.section	.rodata
.LC0:
	.string	"Failed allocate stack\n"
.LC1:
	.string	"Running on "
.LC2:
	.string	"__x86_x64__"
.LC3:
	.string	"Old ESP: %#011x\n"
.LC4:
	.string	"Restored ESP: %#011x\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB1795:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$24, %rsp
	.cfi_offset 3, -24
	movl	%edi, -20(%rbp)
	movq	%rsi, -32(%rbp)
	movl	-20(%rbp), %eax
	movl	%eax, main_argc(%rip)
	movq	-32(%rbp), %rax
	movq	%rax, main_argv(%rip)
	movq	$1048576, new_stack_size(%rip)
	movq	new_stack_size(%rip), %rax
	movq	%rax, %rdi
	call	malloc@PLT
	movq	%rax, new_stack(%rip)
	movq	new_stack(%rip), %rax
	testq	%rax, %rax
	jne	.L2
	movq	stderr(%rip), %rax
	movq	%rax, %rcx
	movl	$22, %edx
	movl	$1, %esi
	leaq	.LC0(%rip), %rdi
	call	fwrite@PLT
	movl	$1, %edi
	call	exit@PLT
.L2:
	movq	new_stack(%rip), %rax
	movq	new_stack_size(%rip), %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	%rax, new_stack_top(%rip)
	leaq	new_stack_top(%rip), %rax
	addq	$4, %rax
	movq	%rax, old_esp_pointer(%rip)
	leaq	.LC1(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	leaq	.LC2(%rip), %rdi
	call	puts@PLT
	movq	old_esp_pointer(%rip), %rax
	movq	%rax, %rsi
	leaq	.LC3(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	new_stack_top(%rip), %rax
	movq	%rax, %rbx
#APP
# 80 "program.cpp" 1
	mov %rsp, %rax
mov %rbx, %rsp
# 0 "" 2
#NO_APP
	movq	%rax, old_esp_pointer(%rip)
	call	_Z9wrap_mainv
	movq	old_esp_pointer(%rip), %rax
#APP
# 108 "program.cpp" 1
	mov %rax, %rsp
# 0 "" 2
#NO_APP
	movq	%rax, old_esp_pointer(%rip)
	movq	old_esp_pointer(%rip), %rax
	movq	%rax, %rsi
	leaq	.LC4(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	new_stack(%rip), %rax
	movq	%rax, %rdi
	call	free@PLT
	movl	$0, %eax
	addq	$24, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1795:
	.size	main, .-main
	.globl	stack_call_counter
	.bss
	.align 4
	.type	stack_call_counter, @object
	.size	stack_call_counter, 4
stack_call_counter:
	.zero	4
	.section	.rodata
	.align 8
.LC5:
	.string	"Caught segfault at address %p\n"
.LC6:
	.string	"Counter value at exit %d\n"
	.text
	.globl	_Z18segfault_sigactioniP9siginfo_tPv
	.type	_Z18segfault_sigactioniP9siginfo_tPv, @function
_Z18segfault_sigactioniP9siginfo_tPv:
.LFB1796:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movl	%edi, -4(%rbp)
	movq	%rsi, -16(%rbp)
	movq	%rdx, -24(%rbp)
	movq	-16(%rbp), %rax
	movq	16(%rax), %rax
	movq	%rax, %rsi
	leaq	.LC5(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	stack_call_counter(%rip), %eax
	movl	%eax, %esi
	leaq	.LC6(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	new_stack(%rip), %rax
	movq	%rax, %rdi
	call	free@PLT
	movl	$0, %edi
	call	exit@PLT
	.cfi_endproc
.LFE1796:
	.size	_Z18segfault_sigactioniP9siginfo_tPv, .-_Z18segfault_sigactioniP9siginfo_tPv
	.globl	_Z9recursionv
	.type	_Z9recursionv, @function
_Z9recursionv:
.LFB1797:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	stack_call_counter(%rip), %eax
	addl	$1, %eax
	movl	%eax, stack_call_counter(%rip)
	call	_Z9recursionv
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1797:
	.size	_Z9recursionv, .-_Z9recursionv
	.globl	_Z9wrap_mainv
	.type	_Z9wrap_mainv, @function
_Z9wrap_mainv:
.LFB1798:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1798:
	.size	_Z9wrap_mainv, .-_Z9wrap_mainv
	.type	_Z41__static_initialization_and_destruction_0ii, @function
_Z41__static_initialization_and_destruction_0ii:
.LFB2299:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movl	%edi, -4(%rbp)
	movl	%esi, -8(%rbp)
	cmpl	$1, -4(%rbp)
	jne	.L9
	cmpl	$65535, -8(%rbp)
	jne	.L9
	leaq	_ZStL8__ioinit(%rip), %rdi
	call	_ZNSt8ios_base4InitC1Ev@PLT
	leaq	__dso_handle(%rip), %rdx
	leaq	_ZStL8__ioinit(%rip), %rsi
	movq	_ZNSt8ios_base4InitD1Ev@GOTPCREL(%rip), %rax
	movq	%rax, %rdi
	call	__cxa_atexit@PLT
.L9:
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2299:
	.size	_Z41__static_initialization_and_destruction_0ii, .-_Z41__static_initialization_and_destruction_0ii
	.type	_GLOBAL__sub_I_old_esp_pointer, @function
_GLOBAL__sub_I_old_esp_pointer:
.LFB2300:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$65535, %esi
	movl	$1, %edi
	call	_Z41__static_initialization_and_destruction_0ii
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2300:
	.size	_GLOBAL__sub_I_old_esp_pointer, .-_GLOBAL__sub_I_old_esp_pointer
	.section	.init_array,"aw"
	.align 8
	.quad	_GLOBAL__sub_I_old_esp_pointer
	.hidden	__dso_handle
	.ident	"GCC: (Ubuntu 7.4.0-1ubuntu1~18.04.1) 7.4.0"
	.section	.note.GNU-stack,"",@progbits
