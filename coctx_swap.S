/*
* Tencent is pleased to support the open source community by making Libco available.

* Copyright (C) 2014 THL A29 Limited, a Tencent company. All rights reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License"); 
* you may not use this file except in compliance with the License. 
* You may obtain a copy of the License at
*
*	http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, 
* software distributed under the License is distributed on an "AS IS" BASIS, 
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
* See the License for the specific language governing permissions and 
* limitations under the License.
*/

.globl coctx_swap
#if !defined( __APPLE__ )
.type  coctx_swap, @function
#endif
coctx_swap:

#if defined(__i386__)
    movl 4(%esp), %eax
    movl %esp,  28(%eax)
    movl %ebp, 24(%eax)
    movl %esi, 20(%eax)
    movl %edi, 16(%eax)
    movl %edx, 12(%eax)
    movl %ecx, 8(%eax)
    movl %ebx, 4(%eax)


    movl 8(%esp), %eax
    movl 4(%eax), %ebx
    movl 8(%eax), %ecx
    movl 12(%eax), %edx
    movl 16(%eax), %edi
    movl 20(%eax), %esi
    movl 24(%eax), %ebp
    movl 28(%eax), %esp

	ret

#elif defined(__x86_64__)   ; 14个通用寄存器保存到ctx, r10,r11除外(r10 r11由调用者保护)
	leaq (%rsp),%rax         ; 栈顶指针存到到rax寄存器，leaq 指令只能用于计算地址，不能用于加载数据
    movq %rax, 104(%rdi)   ; rdi存的第一个参数coctx_t,将寄存器的值放到第一个参数coctx_t.regs
    movq %rbx, 96(%rdi)
    movq %rcx, 88(%rdi)
    movq %rdx, 80(%rdi)
	  movq 0(%rax), %rax   ; 将内存中 rax 寄存器所指向的地址处的 64 位数据加载到 rax 寄存器中
	  movq %rax, 72(%rdi)  ; 保存栈顶指针指向的数据
    movq %rsi, 64(%rdi)  ; rsi代表第二个参数，第二个参数(指针)放入到第一个参数的coctx_t.regs[8]
	  movq %rdi, 56(%rdi)  ; 将rdi寄存器数据(指针)放到coctx_t.regs[7],传入的参数也得记录下来
    movq %rbp, 48(%rdi)  ; 将rbp寄存器放到coctx_t.regs[6]
    movq %r8, 40(%rdi)
    movq %r9, 32(%rdi)
    movq %r12, 24(%rdi)
    movq %r13, 16(%rdi)
    movq %r14, 8(%rdi)
    movq %r15, (%rdi)
	  xorq %rax, %rax      ; 清零rax

    movq 48(%rsi), %rbp   ; 恢复传入ctx的rsp rbp
    movq 104(%rsi), %rsp
    movq (%rsi), %r15
    movq 8(%rsi), %r14
    movq 16(%rsi), %r13
    movq 24(%rsi), %r12
    movq 32(%rsi), %r9
    movq 40(%rsi), %r8
    movq 56(%rsi), %rdi
    movq 80(%rsi), %rdx
    movq 88(%rsi), %rcx
    movq 96(%rsi), %rbx
		leaq 8(%rsp), %rsp   ; 栈顶指针上移8
		pushq 72(%rsi)       ; 恢复栈顶指针指向的内容，函数返回地址 参考coctx.cpp 注释 

    movq 64(%rsi), %rsi
	ret                    ; pop函数返回地址并执行
#endif
