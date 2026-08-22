; @file bignum_inverse.asm
; @brief Optimized x86-64 YASM implementation of modular multiplicative inverse.
; @version 0.1.0
; @details SysV AMD64 ABI: rdi=result, rsi=a, rdx=modulus; caller-saved rax/rcx/r8-r11 may be clobbered; callee-saved registers are preserved. The destination is written only on SUCCESS, and all records use bignum_t {words[32], len} with 64-bit little-endian words.
BITS 64
default rel
section .text
inverse_sub_raw:
	mov	ecx, 33
	xor	eax, eax
	mov	r8, rdi
	mov	r10, rdx
	rep stosq
	mov	r9, rsi
	mov	rdx, QWORD [rsi+256]
	mov	QWORD [r8+256], rdx
	test	rdx, rdx
	je	.L2
	mov	rax, QWORD [r10+256]
	test	rax, rax
	je	.L3
	cmp	rdx, rax
	cmovbe	rax, rdx
	xor	esi, esi
	mov	r11, rax
	xor	eax, eax
.L7:
	mov	rcx, QWORD [r9+rax*8]
	mov	rdi, QWORD [r10+rax*8]
	test	rsi, rsi
	je	.L4
	xor	esi, esi
	cmp	rdi, rcx
	setnb	sil
	sub	rcx, 1
.L31:
	sub	rcx, rdi
	mov	QWORD [r8+rax*8], rcx
	add	rax, 1
	cmp	rax, r11
	jb	.L7
	cmp	rax, rdx
	jnb	.L9
.L8:
	mov	rcx, QWORD [r9+rax*8]
	test	rsi, rsi
	je	.L12
	xor	esi, esi
	test	rcx, rcx
	sete	sil
	sub	rcx, 1
	mov	QWORD [r8+rax*8], rcx
	add	rax, 1
	cmp	rax, rdx
	jb	.L8
	test	rdx, rdx
	jne	.L34
.L2:
	xor	edx, edx
	jmp	.L14
.L16:
	mov	rdx, rax
.L9:
	test	rdx, rdx
	je	.L2
.L34:
	cmp	QWORD [r8-8+rdx*8], 0
	lea	rax, [rdx-1]
	je	.L16
	cmp	rdx, 32
	je	.L15
.L14:
	mov	ecx, 32
	lea	rsi, [r8+rdx*8]
	sub	rcx, rdx
	mov	rdi, rsi
	sal	rcx, 3
	mov	eax, ecx
	sub	ecx, 1
	mov	QWORD [rsi-8+rax], 0
	shr	ecx, 3
	xor	eax, eax
	rep stosq
.L15:
	mov	QWORD [r8+256], rdx
	ret
.L35:
	mov	rcx, QWORD [r9+rax*8]
.L12:
	mov	QWORD [r8+rax*8], rcx
	add	rax, 1
	cmp	rax, rdx
	jb	.L35
	jmp	.L9
.L3:
	mov	rcx, QWORD [rsi]
	jmp	.L12
.L4:
	xor	esi, esi
	cmp	rcx, rdi
	setb	sil
	jmp	.L31
inverse_signed_sub:
	push	r13
	mov	eax, 34
	push	r12
	mov	rcx, rax
	push	rbp
	push	rbx
	mov	rbx, rdi
	sub	rsp, 824
	lea	r10, [rsp+272]
	lea	r9, [rsp+544]
	mov	rdi, r10
	rep movsq
	mov	rdi, r9
	mov	rsi, rdx
	mov	ebp, DWORD [rsp+536]
	mov	rax, rcx
	mov	ecx, 34
	rep movsq
	cmp	ebp, DWORD [rsp+808]
	jne	.L82
	mov	rax, QWORD [rsp+528]
	mov	rdx, QWORD [rsp+800]
	cmp	rax, rdx
	je	.L62
	cmp	rdx, rax
	jnb	.L65
.L63:
	mov	ecx, 34
	xor	eax, eax
	mov	rdi, rbx
	mov	rdx, r9
	rep stosq
	mov	rsi, r10
	mov	rdi, rbx
	call	inverse_sub_raw
.L64:
	mov	rdx, QWORD [rbx+256]
	mov	eax, 32
	mov	DWORD [rbx+264], ebp
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L68
.L84:
	cmp	QWORD [rbx-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L83
	mov	rdx, rax
.L68:
	test	rdx, rdx
	jne	.L84
	mov	ecx, 32
	mov	rdi, rbx
	mov	rax, rdx
	rep stosq
	mov	QWORD [rbx+256], 0
	mov	DWORD [rbx+264], 0
.L36:
	add	rsp, 824
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	ret
.L66:
	sub	rax, 1
	mov	rdx, QWORD [r10+rax*8]
	mov	rcx, QWORD [r9+rax*8]
	cmp	rdx, rcx
	jne	.L85
.L62:
	test	rax, rax
	jne	.L66
	jmp	.L63
.L82:
	mov	r11, QWORD [rsp+800]
	mov	r12, QWORD [rsp+528]
	mov	rsi, rsp
	mov	ecx, 33
	mov	rdi, rsi
	rep stosq
	cmp	r11, r12
	mov	r8, r12
	cmovnb	r8, r11
	lea	rdi, [rsi+r8*8]
	test	r8, r8
	je	.L38
	xor	edx, edx
	test	r12, r12
	jne	.L49
	xor	eax, eax
.L55:
	cmp	rax, r11
	jnb	.L50
.L88:
	add	rdx, QWORD [r9+rax*8]
	mov	QWORD [rsi+rax*8], rdx
	setc	dl
	add	rax, 1
	movzx	edx, dl
	cmp	rax, r8
	jb	.L55
.L54:
	mov	QWORD [rdi], rdx
	mov	ecx, 34
	xor	eax, eax
	mov	rdi, rbx
	rep stosq
	add	r8, rdx
	cmp	r8, 32
	ja	.L36
	lea	rax, [0+r8*8]
	mov	rdi, rbx
	mov	edx, eax
	mov	rcx, QWORD [rsi-8+rdx]
	mov	QWORD [rbx-8+rdx], rcx
	lea	ecx, [rax-1]
	mov	eax, ecx
	shr	eax, 3
	mov	ecx, eax
	rep movsq
.L70:
	mov	DWORD [rbx+264], ebp
	jmp	.L59
.L87:
	cmp	QWORD [rbx-8+r8*8], 0
	lea	rax, [r8-1]
	jne	.L86
	mov	r8, rax
.L59:
	test	r8, r8
	jne	.L87
	mov	rdi, rbx
	mov	ecx, 32
	mov	rax, r8
	rep stosq
	mov	QWORD [rbx+256], 0
	mov	DWORD [rbx+264], 0
	add	rsp, 824
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	ret
.L40:
	add	rcx, rdx
	setc	dl
	mov	QWORD [rsi+rax*8], rcx
	add	rax, 1
	movzx	edx, dl
	cmp	rax, r12
	jnb	.L46
.L49:
	mov	rcx, QWORD [r10+rax*8]
	cmp	rax, r11
	jnb	.L40
	xor	r13d, r13d
	add	rcx, QWORD [r9+rax*8]
	setc	r13b
	add	rdx, rcx
	mov	QWORD [rsi+rax*8], rdx
	setc	dl
	add	rax, 1
	movzx	edx, dl
	or	rdx, r13
	cmp	rax, r12
	jb	.L49
.L46:
	cmp	rax, r8
	jnb	.L54
	cmp	rax, r11
	jb	.L88
.L50:
	mov	QWORD [rsi+rax*8], rdx
	add	rax, 1
	xor	edx, edx
	cmp	rax, r8
	jb	.L55
	jmp	.L54
.L83:
	cmp	rdx, 32
	je	.L80
	mov	eax, 32
	lea	rsi, [rbx+rdx*8]
	sub	rax, rdx
	mov	rdi, rsi
	sal	rax, 3
	mov	ecx, eax
	mov	QWORD [rsi-8+rcx], 0
	lea	ecx, [rax-1]
	mov	eax, ecx
	shr	eax, 3
	mov	ecx, eax
	xor	eax, eax
	rep stosq
	mov	QWORD [rbx+256], rdx
	add	rsp, 824
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	ret
.L85:
	cmp	rcx, rdx
	jb	.L63
.L65:
	xor	eax, eax
	mov	ecx, 34
	mov	rdi, rbx
	mov	rdx, r10
	rep stosq
	mov	rsi, r9
	mov	rdi, rbx
	call	inverse_sub_raw
	test	ebp, ebp
	sete	bpl
	movzx	ebp, bpl
	jmp	.L64
.L80:
	mov	QWORD [rbx+256], 32
	jmp	.L36
.L86:
	cmp	r8, 32
	je	.L80
	mov	eax, 32
	lea	rdx, [rbx+r8*8]
	sub	rax, r8
	mov	rdi, rdx
	sal	rax, 3
	mov	ecx, eax
	mov	QWORD [rdx-8+rcx], 0
	lea	ecx, [rax-1]
	mov	eax, ecx
	shr	eax, 3
	mov	ecx, eax
	xor	eax, eax
	rep stosq
	mov	QWORD [rbx+256], r8
	jmp	.L36
.L38:
	mov	QWORD [rdi], 0
	mov	ecx, 34
	mov	rdi, rbx
	mov	rax, r8
	rep stosq
	jmp	.L70
inverse_reduce:
	push	r15
	xor	eax, eax
	mov	ecx, 33
	push	r14
	push	r13
	mov	r13, rdx
	push	r12
	push	rbp
	push	rbx
	sub	rsp, 584
	lea	r15, [rsp+32]
	mov	QWORD [rsp+16], rdi
	lea	r14, [rsp+288]
	mov	rdi, r15
	mov	QWORD [rsp+24], rsi
	rep stosq
	mov	rax, QWORD [rsi+256]
	xor	edi, edi
	mov	QWORD [rsp+8], rax
	test	rax, rax
	je	.L91
.L90:
	sub	QWORD [rsp+8], 1
	mov	rbx, QWORD [rsp+24]
	mov	r12d, 64
	mov	rax, QWORD [rsp+8]
	mov	rbx, QWORD [rbx+rax*8]
.L104:
	sub	r12d, 1
	mov	rsi, rbx
	mov	rax, r15
	mov	ecx, r12d
	shr	rsi, cl
	and	esi, 1
	jmp	.L93
.L122:
	mov	rdi, QWORD [rax]
.L93:
	lea	rdx, [rdi+rdi]
	add	rax, 8
	or	rdx, rsi
	mov	rsi, rdi
	mov	QWORD [rax-8], rdx
	shr	rsi, 63
	cmp	r14, rax
	jne	.L122
	mov	edx, 32
.L92:
	mov	rax, rdx
	sub	rdx, 1
	cmp	QWORD [r15+rdx*8], 0
	jne	.L123
	test	rdx, rdx
	jne	.L92
.L94:
	mov	eax, 32
	lea	r10, [r15+rdx*8]
	sub	rax, rdx
	mov	rdi, r10
	sal	rax, 3
	mov	ecx, eax
	mov	QWORD [r10-8+rcx], 0
	lea	ecx, [rax-1]
	mov	eax, ecx
	shr	eax, 3
	mov	ecx, eax
	xor	eax, eax
	rep stosq
.L99:
	mov	QWORD [rsp+288], rdx
	test	rsi, rsi
	jne	.L97
	mov	rax, QWORD [r13+256]
	cmp	rax, rdx
	je	.L100
.L121:
	jnb	.L101
.L97:
	lea	rbp, [rsp+304]
	mov	rsi, r15
	mov	rdx, r13
	mov	rdi, rbp
	call	inverse_sub_raw
	mov	ecx, 33
	mov	rdi, r15
	mov	rsi, rbp
	rep movsq
.L101:
	test	r12d, r12d
	je	.L124
	mov	rdi, QWORD [rsp+32]
	jmp	.L104
.L102:
	sub	rax, 1
	mov	rdx, QWORD [r15+rax*8]
	mov	rcx, QWORD [r13+0+rax*8]
	cmp	rdx, rcx
	jne	.L125
.L100:
	test	rax, rax
	jne	.L102
	jmp	.L97
.L123:
	mov	rdx, rax
	cmp	rax, 32
	jne	.L94
	jmp	.L99
.L125:
	cmp	rcx, rdx
	jmp	.L121
.L124:
	cmp	QWORD [rsp+8], 0
	je	.L91
	mov	rdi, QWORD [rsp+32]
	jmp	.L90
.L91:
	mov	rdi, QWORD [rsp+16]
	mov	rsi, r15
	mov	ecx, 33
	rep movsq
	add	rsp, 584
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	ret
inverse_pair_half:
	push	r14
	mov	r8, rdx
	push	r13
	push	r12
	push	rbp
	mov	rbp, rdi
	push	rbx
	mov	rbx, rsi
	mov	rsi, rcx
	sub	rsp, 1088
	mov	rdx, QWORD [rdi+256]
	test	rdx, rdx
	jne	.L127
	cmp	QWORD [rbx+256], 0
	jne	.L128
.L133:
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L129
.L217:
	cmp	QWORD [rbp-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L216
	mov	rdx, rax
.L129:
	test	rdx, rdx
	jne	.L217
.L134:
	mov	ecx, 32
	lea	rsi, [rbp+0+rdx*8]
	sub	rcx, rdx
	mov	rdi, rsi
	sal	rcx, 3
	mov	eax, ecx
	sub	ecx, 1
	mov	QWORD [rsi-8+rax], 0
	shr	ecx, 3
	xor	eax, eax
	rep stosq
.L138:
	mov	QWORD [rbp+256], rdx
	mov	rdx, QWORD [rbx+256]
	test	rdx, rdx
	je	.L137
	lea	rcx, [rbx-8+rdx*8]
	xor	eax, eax
.L140:
	mov	rsi, QWORD [rcx]
	mov	rdi, rcx
	sub	rcx, 8
	shld	rax, rsi, 63
	mov	QWORD [rcx+8], rax
	mov	rax, rsi
	and	eax, 1
	cmp	rbx, rdi
	jne	.L140
.L137:
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L139
.L219:
	cmp	QWORD [rbx-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L218
	mov	rdx, rax
.L139:
	test	rdx, rdx
	jne	.L219
.L141:
	mov	ecx, 32
	lea	rsi, [rbx+rdx*8]
	sub	rcx, rdx
	mov	rdi, rsi
	sal	rcx, 3
	mov	eax, ecx
	sub	ecx, 1
	mov	QWORD [rsi-8+rax], 0
	shr	ecx, 3
	xor	eax, eax
	rep stosq
.L144:
	mov	QWORD [rbx+256], rdx
	mov	rdx, QWORD [rbp+256]
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L143
.L221:
	cmp	QWORD [rbp-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L220
	mov	rdx, rax
.L143:
	test	rdx, rdx
	jne	.L221
	mov	ecx, 32
	mov	rdi, rbp
	mov	rax, rdx
	rep stosq
	mov	QWORD [rbp+256], 0
	mov	DWORD [rbp+264], 0
.L175:
	mov	rdx, QWORD [rbx+256]
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L148
.L223:
	cmp	QWORD [rbx-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L222
	mov	rdx, rax
.L148:
	test	rdx, rdx
	jne	.L223
	mov	ecx, 32
	mov	rdi, rbx
	mov	rax, rdx
	rep stosq
	mov	QWORD [rbx+256], 0
	mov	DWORD [rbx+264], 0
.L150:
	mov	ecx, 1
.L126:
	add	rsp, 1088
	mov	eax, ecx
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	pop	r14
	ret
.L127:
	mov	rax, QWORD [rdi]
	and	eax, 1
	je	.L224
.L130:
	mov	rdx, rsp
	xor	eax, eax
	mov	ecx, 34
	mov	rdi, rdx
	lea	r14, [rsp+272]
	lea	r12, [rsp+816]
	rep stosq
	mov	rdi, rdx
	mov	ecx, 33
	lea	r13, [rsp+544]
	rep movsq
	mov	ecx, 34
	mov	rdi, r14
	mov	rsi, r8
	rep stosq
	mov	ecx, 33
	mov	rdi, r14
	rep movsq
	mov	rsi, rdx
	mov	ecx, 34
	mov	rdx, r12
	lea	rdi, [rsp+816]
	rep movsq
	mov	rsi, rbp
	mov	rdi, r13
	mov	DWORD [rsp+1080], 1
	call	inverse_signed_sub
	mov	rdx, r14
	mov	rsi, rbx
	mov	rdi, r12
	call	inverse_signed_sub
	mov	rdx, QWORD [rsp+800]
	test	rdx, rdx
	jne	.L151
	mov	rsi, QWORD [rsp+1072]
	test	rsi, rsi
	jne	.L225
	xor	r8d, r8d
.L152:
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L159
.L227:
	cmp	QWORD [r13-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L226
	mov	rdx, rax
.L159:
	test	rdx, rdx
	jne	.L227
.L158:
	mov	eax, 32
	lea	r9, [r13+0+rdx*8]
	sub	rax, rdx
	mov	rdi, r9
	sal	rax, 3
	mov	ecx, eax
	mov	QWORD [r9-8+rcx], 0
	lea	ecx, [rax-1]
	mov	eax, ecx
	shr	eax, 3
	mov	ecx, eax
	xor	eax, eax
	rep stosq
.L163:
	lea	rcx, [r12+rsi*8]
	xor	eax, eax
	test	rsi, rsi
	je	.L164
.L165:
	mov	rsi, QWORD [rcx-8]
	sub	rcx, 8
	shld	rax, rsi, 63
	mov	QWORD [rcx], rax
	mov	rax, rsi
	and	eax, 1
	cmp	r12, rcx
	jne	.L165
	test	r8, r8
	je	.L166
.L229:
	cmp	QWORD [r12-8+r8*8], 0
	lea	rax, [r8-1]
	jne	.L228
	mov	r8, rax
.L164:
	test	r8, r8
	jne	.L229
.L166:
	mov	eax, 32
	lea	rsi, [r12+r8*8]
	sub	rax, r8
	mov	rdi, rsi
	sal	rax, 3
	mov	ecx, eax
	mov	QWORD [rsi-8+rcx], 0
	lea	ecx, [rax-1]
	mov	eax, ecx
	shr	eax, 3
	mov	ecx, eax
	xor	eax, eax
	rep stosq
	jmp	.L168
.L231:
	cmp	QWORD [r13-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L230
	mov	rdx, rax
.L168:
	test	rdx, rdx
	jne	.L231
	mov	ecx, 32
	mov	rdi, r13
	mov	rax, rdx
	mov	QWORD [rsp+800], 0
	rep stosq
	mov	DWORD [rsp+808], 0
	jmp	.L173
.L233:
	cmp	QWORD [r12-8+r8*8], 0
	lea	rax, [r8-1]
	jne	.L232
	mov	r8, rax
.L173:
	test	r8, r8
	jne	.L233
	mov	ecx, 32
	mov	rdi, r12
	mov	rax, r8
	rep stosq
	mov	QWORD [rsp+1072], 0
	mov	DWORD [rsp+1080], 0
.L176:
	mov	ecx, 34
	mov	rdi, rbp
	mov	rsi, r13
	rep movsq
	mov	ecx, 34
	mov	rdi, rbx
	mov	rsi, r12
	rep movsq
	jmp	.L150
.L128:
	test	BYTE [rbx], 1
	jne	.L130
	jmp	.L133
.L224:
	cmp	QWORD [rbx+256], 0
	jne	.L234
.L131:
	lea	rcx, [rbp-8+rdx*8]
.L132:
	mov	rsi, QWORD [rcx]
	mov	rdi, rcx
	sub	rcx, 8
	shld	rax, rsi, 63
	mov	QWORD [rcx+8], rax
	mov	rax, rsi
	and	eax, 1
	cmp	rbp, rdi
	jne	.L132
	jmp	.L133
.L220:
	cmp	rdx, 32
	je	.L235
	mov	eax, 32
	lea	rsi, [rbp+0+rdx*8]
	sub	rax, rdx
	mov	rdi, rsi
	sal	rax, 3
	mov	ecx, eax
	mov	QWORD [rsi-8+rcx], 0
	lea	ecx, [rax-1]
	mov	eax, ecx
	shr	eax, 3
	mov	ecx, eax
	xor	eax, eax
	rep stosq
	mov	QWORD [rbp+256], rdx
	jmp	.L175
.L218:
	cmp	rdx, 32
	jne	.L141
	jmp	.L144
.L216:
	cmp	rdx, 32
	jne	.L134
	jmp	.L138
.L222:
	cmp	rdx, 32
	je	.L236
	mov	eax, 32
	lea	rsi, [rbx+rdx*8]
	sub	rax, rdx
	mov	rdi, rsi
	sal	rax, 3
	mov	ecx, eax
	mov	QWORD [rsi-8+rcx], 0
	lea	ecx, [rax-1]
	mov	eax, ecx
	shr	eax, 3
	mov	ecx, eax
	xor	eax, eax
	rep stosq
	mov	QWORD [rbx+256], rdx
	jmp	.L150
.L151:
	mov	rax, QWORD [rsp+544]
	xor	ecx, ecx
	and	eax, 1
	jne	.L126
	mov	rsi, QWORD [rsp+1072]
	test	rsi, rsi
	jne	.L155
	xor	r8d, r8d
.L157:
	lea	rcx, [r13+0+rdx*8]
.L156:
	mov	rdi, QWORD [rcx-8]
	sub	rcx, 8
	shld	rax, rdi, 63
	mov	QWORD [rcx], rax
	mov	rax, rdi
	and	eax, 1
	cmp	rcx, r13
	jne	.L156
	jmp	.L152
.L234:
	test	BYTE [rbx], 1
	je	.L131
	jmp	.L130
.L225:
	xor	ecx, ecx
	test	BYTE [rsp+816], 1
	jne	.L126
	mov	r8d, 32
	cmp	rsi, r8
	cmovbe	r8, rsi
	jmp	.L152
.L236:
	mov	QWORD [rbx+256], 32
	jmp	.L150
.L235:
	mov	QWORD [rbp+256], 32
	jmp	.L175
.L226:
	cmp	rdx, 32
	jne	.L158
	jmp	.L163
.L228:
	cmp	r8, 32
	jne	.L166
	jmp	.L168
.L230:
	cmp	rdx, 32
	je	.L237
	mov	eax, 32
	lea	rsi, [r13+0+rdx*8]
	sub	rax, rdx
	mov	rdi, rsi
	sal	rax, 3
	mov	ecx, eax
	sub	eax, 1
	mov	QWORD [rsi-8+rcx], 0
	shr	eax, 3
	mov	ecx, eax
	xor	eax, eax
	rep stosq
	mov	QWORD [rsp+800], rdx
	jmp	.L173
.L232:
	cmp	r8, 32
	je	.L238
	mov	eax, 32
	lea	rdx, [r12+r8*8]
	sub	rax, r8
	mov	rdi, rdx
	sal	rax, 3
	mov	ecx, eax
	sub	eax, 1
	mov	QWORD [rdx-8+rcx], 0
	shr	eax, 3
	mov	ecx, eax
	xor	eax, eax
	rep stosq
	mov	QWORD [rsp+1072], r8
	jmp	.L176
.L155:
	test	BYTE [rsp+816], 1
	jne	.L126
	mov	r8d, 32
	cmp	rsi, r8
	cmovbe	r8, rsi
	jmp	.L157
.L238:
	mov	QWORD [rsp+1072], 32
	jmp	.L176
.L237:
	mov	QWORD [rsp+800], 32
	jmp	.L173
global bignum_inverse
bignum_inverse:
    ; Fast path: one-word odd modulus. SysV args remain rdi=result, rsi=a, rdx=modulus.
    test rdi, rdi
    jz .generic_entry
    test rsi, rsi
    jz .generic_entry
    test rdx, rdx
    jz .generic_entry
    mov rax, rdi
    sub rax, rsi
    cmp rax, 263
    jbe .generic_entry
    mov rax, rdi
    sub rax, rdx
    cmp rax, 263
    jbe .generic_entry
    cmp qword [rsi+256], 1
    jne .generic_entry
    cmp qword [rdx+256], 1
    jne .generic_entry
    mov r8, qword [rdx]
    cmp r8, 3
    jb .generic_entry
    test r8, 1
    jz .generic_entry
    push r12
    push r13
    push r14
    push r15
    mov r9, qword [rsi]
    xor r10d, r10d
    mov r11, 1
    ; Reduce a modulo m. The hot EEA itself remains binary; DIV is only input reduction.
    xor edx, edx
    mov rax, r9
    div r8
    mov r9, rdx
    test r9, r9
    jz .fast_no_inverse
    xor edx, edx
    mov rax, r8
    mov r12, r8
    xor r13d, r13d
    xor r14d, r14d
    mov r15, r11
    ; u=r9, v=r8, x_u=r11, x_v=0; r12..r15 hold coefficient helpers.
.fast_loop:
    test r9, r9
    jz .fast_no_inverse
    test r8, r8
    jz .fast_no_inverse
    cmp r9, 1
    je .fast_success_u
    cmp r8, 1
    je .fast_success_v
    test r9, 1
    jnz .fast_u_odd
    shr r9, 1
    test r11, 1
    jz .fast_u_half_even
    add r11, r12
    rcr r11, 1
    jmp .fast_loop
.fast_u_half_even:
    shr r11, 1
    jmp .fast_loop
.fast_u_odd:
    test r8, 1
    jnz .fast_both_odd
    ; v is even: halve it and its coefficient x_v (x_v is kept in r13).
    shr r8, 1
    test r13, 1
    jz .fast_v_half_even
    add r13, r12
    rcr r13, 1
    jmp .fast_loop
.fast_v_half_even:
    shr r13, 1
    jmp .fast_loop
.fast_both_odd:
    cmp r9, r8
    jae .fast_sub_v
    sub r8, r9
    ; x_v = x_v - x_u modulo m.
    mov rax, r13
    sub rax, r11
    jnc .fast_store_v
    add rax, r12
.fast_store_v:
    mov r13, rax
    jmp .fast_loop
.fast_sub_v:
    sub r9, r8
    ; x_u = x_u - x_v modulo m.
    mov rax, r11
    sub rax, r13
    jnc .fast_store_u
    add rax, r12
.fast_store_u:
    mov r11, rax
    jmp .fast_loop
.fast_success_u:
    mov rax, r11
    jmp .fast_publish
.fast_success_v:
    mov rax, r13
.fast_publish:
    mov qword [rdi], rax
    mov qword [rdi+256], 1
    lea rdi, [rdi+8]
    mov ecx, 31
    xor eax, eax
    rep stosq
    pop r15
    pop r14
    pop r13
    pop r12
    xor eax, eax
    ret
.fast_no_inverse:
    pop r15
    pop r14
    pop r13
    pop r12
    mov eax, -5
    ret
.generic_entry:
    endbr64
    push r15

	mov	rax, rdx
	push	r14
	push	r13
	push	r12
	push	rbp
	push	rbx
	sub	rsp, 3032
	test	rsi, rsi
	sete	dl
	test	rax, rax
	sete	cl
	or	dl, cl
	jne	.L298
	mov	r8, rdi
	test	rdi, rdi
	je	.L298
	cmp	rdi, rsi
	jb	.L368
	mov	rdx, rdi
	xor	r12d, r12d
	sub	rdx, rsi
	cmp	rdx, 263
	setbe	r12b
.L242:
	test	r12d, r12d
	jne	.L311
	cmp	r8, rax
	jnb	.L243
	mov	rdx, rax
	sub	rdx, r8
	cmp	rdx, 263
	jbe	.L311
.L244:
	mov	rdx, QWORD [rsi+256]
	cmp	rdx, 32
	ja	.L302
	mov	r15, QWORD [rax+256]
	cmp	r15, 32
	ja	.L302
	lea	rbx, [rsp+32]
	lea	rbp, [rsp+304]
	mov	ecx, 33
	mov	rdi, rbx
	rep movsq
	mov	ecx, 33
	mov	rdi, rbp
	mov	rsi, rax
	rep movsq
	jmp	.L246
.L370:
	cmp	QWORD [rbx-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L369
	mov	rdx, rax
.L246:
	test	rdx, rdx
	jne	.L370
.L245:
	mov	eax, 32
	lea	rsi, [rbx+rdx*8]
	sub	rax, rdx
	mov	rdi, rsi
	sal	rax, 3
	mov	ecx, eax
	mov	QWORD [rsi-8+rcx], 0
	lea	ecx, [rax-1]
	mov	eax, ecx
	shr	eax, 3
	mov	ecx, eax
	xor	eax, eax
	rep stosq
.L249:
	mov	QWORD [rsp+288], rdx
	jmp	.L248
.L372:
	cmp	QWORD [rbp-8+r15*8], 0
	lea	rax, [r15-1]
	jne	.L371
	mov	r15, rax
.L248:
	test	r15, r15
	jne	.L372
	mov	r12d, -4
.L239:
	add	rsp, 3032
	mov	eax, r12d
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	ret
.L368:
	mov	rdx, rsi
	xor	r12d, r12d
	sub	rdx, rdi
	cmp	rdx, 263
	setbe	r12b
	jmp	.L242
.L243:
	mov	rdx, r8
	sub	rdx, rax
	cmp	rdx, 263
	ja	.L244
.L311:
	mov	r12d, -3
	jmp	.L239
.L371:
	cmp	r15, 32
	je	.L373
	mov	edx, 32
	lea	rsi, [rbp+0+r15*8]
	xor	eax, eax
	sub	rdx, r15
	mov	rdi, rsi
	lea	r13, [rsp+576]
	sal	rdx, 3
	mov	ecx, edx
	mov	QWORD [rsi-8+rcx], 0
	lea	ecx, [rdx-1]
	mov	rsi, rbp
	lea	rdx, [rsp+848]
	shr	ecx, 3
	rep stosq
	mov	QWORD [rsp+560], r15
	mov	ecx, 33
	mov	rdi, r13
	rep movsq
	mov	ecx, 33
	mov	rdi, rdx
	rep stosq
	mov	QWORD [rsp+1104], 1
	mov	QWORD [rsp+848], 1
	cmp	r15, 1
	jne	.L252
	cmp	QWORD [rsp+304], 1
	ja	.L252
.L253:
	mov	r12d, -5
	jmp	.L239
.L373:
	mov	eax, 33
	lea	r13, [rsp+576]
	mov	rsi, rbp
	mov	QWORD [rsp+560], 32
	mov	rcx, rax
	mov	rdi, r13
	lea	rdx, [rsp+848]
	rep movsq
	mov	rdi, rdx
	mov	rax, rcx
	mov	ecx, 33
	rep stosq
	mov	QWORD [rsp+1104], 1
	mov	QWORD [rsp+848], 1
.L252:
	mov	rdx, r13
	mov	rsi, rbx
	mov	rdi, rbx
	mov	QWORD [rsp+24], r8
	call	inverse_reduce
	mov	r14, QWORD [rsp+288]
	test	r14, r14
	je	.L253
	mov	eax, 33
	mov	rsi, rbx
	mov	r10, r15
	mov	QWORD [rsp+8], r15
	mov	rcx, rax
	lea	rdi, [rsp+1120]
	mov	DWORD [rsp+20], r12d
	mov	r15, r14
	rep movsq
	lea	rdi, [rsp+1664]
	mov	r12, r10
	mov	rax, rcx
	mov	ecx, 34
	rep stosq
	mov	ecx, 34
	lea	rdi, [rsp+1936]
	mov	QWORD [rsp+1920], 1
	rep stosq
	mov	ecx, 34
	lea	rdi, [rsp+2208]
	mov	QWORD [rsp+1664], 1
	rep stosq
	mov	ecx, 34
	lea	rdi, [rsp+2480]
	rep stosq
	mov	QWORD [rsp+2736], 1
	mov	QWORD [rsp+2480], 1
.L254:
	cmp	r15, 1
	jne	.L280
	cmp	QWORD [rsp+32], 1
	jne	.L280
	mov	r15, QWORD [rsp+8]
	mov	r12d, DWORD [rsp+20]
	mov	r8, QWORD [rsp+24]
.L281:
	cmp	QWORD [rsp+32], 1
	lea	rbx, [rsp+1664]
	jne	.L278
.L283:
	lea	rbp, [rsp+2752]
	mov	rsi, rbx
	mov	rdx, r13
	mov	QWORD [rsp+8], r8
	mov	rdi, rbp
	call	inverse_reduce
	mov	eax, DWORD [rbx+264]
	mov	r8, QWORD [rsp+8]
	lea	rbx, [rsp+1392]
	test	eax, eax
	je	.L284
	cmp	QWORD [rsp+3008], 0
	jne	.L374
.L284:
	mov	ecx, 33
	mov	rdi, rbx
	mov	rsi, rbp
	rep movsq
.L285:
	mov	rdx, QWORD [rsp+1648]
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L287
.L376:
	cmp	QWORD [rbx-8+rdx*8], 0
	lea	r9, [rdx-1]
	jne	.L375
	mov	rdx, r9
.L287:
	test	rdx, rdx
	jne	.L376
	mov	ecx, 32
	mov	rdi, rbx
	mov	rax, rdx
	rep stosq
	mov	QWORD [rsp+1648], 0
.L293:
	mov	ecx, 33
	mov	rdi, r8
	mov	rsi, rbx
	rep movsq
	jmp	.L239
.L280:
	cmp	r12, 1
	jne	.L282
	cmp	QWORD [rsp+304], 1
	jne	.L282
.L279:
	mov	r14, r15
	mov	r12d, DWORD [rsp+20]
	mov	r15, QWORD [rsp+8]
	mov	r8, QWORD [rsp+24]
	cmp	r14, 1
	je	.L281
.L278:
	cmp	QWORD [rsp+560], 1
	jne	.L253
	cmp	QWORD [rsp+304], 1
	jne	.L253
	lea	rbx, [rsp+1936]
	jmp	.L283
.L369:
	cmp	rdx, 32
	jne	.L245
	jmp	.L249
.L282:
	mov	r14d, 32
	test	r15, r15
	jne	.L260
.L262:
	mov	eax, 32
	cmp	r15, rax
	cmova	r15, rax
	jmp	.L257
.L378:
	cmp	QWORD [rbx-8+r15*8], 0
	lea	rax, [r15-1]
	jne	.L377
	mov	r15, rax
.L257:
	test	r15, r15
	jne	.L378
.L256:
	mov	rcx, r14
	lea	rdx, [rbx+r15*8]
	lea	rsi, [rsp+2208]
	sub	rcx, r15
	mov	rdi, rdx
	sal	rcx, 3
	mov	eax, ecx
	sub	ecx, 1
	mov	QWORD [rdx-8+rax], 0
	shr	ecx, 3
	xor	eax, eax
	lea	rdx, [rsp+1120]
	rep stosq
	mov	rcx, r13
	lea	rdi, [rsp+1664]
	mov	QWORD [rsp+288], r15
	call	inverse_pair_half
	test	eax, eax
	je	.L253
	test	r15, r15
	je	.L262
.L260:
	mov	rax, QWORD [rsp+32]
	and	eax, 1
	jne	.L271
	lea	rdx, [rbx+r15*8]
.L255:
	mov	rcx, QWORD [rdx-8]
	sub	rdx, 8
	shld	rax, rcx, 63
	mov	QWORD [rdx], rax
	mov	rax, rcx
	and	eax, 1
	cmp	rdx, rbx
	jne	.L255
	jmp	.L262
.L269:
	mov	ecx, 32
	lea	rdx, [rbp+0+r12*8]
	lea	rsi, [rsp+2480]
	sub	rcx, r12
	mov	rdi, rdx
	sal	rcx, 3
	mov	eax, ecx
	sub	ecx, 1
	mov	QWORD [rdx-8+rax], 0
	shr	ecx, 3
	xor	eax, eax
	lea	rdx, [rsp+1120]
	rep stosq
	mov	rcx, r13
	lea	rdi, [rsp+1936]
	mov	QWORD [rsp+560], r12
	call	inverse_pair_half
	test	eax, eax
	je	.L253
.L271:
	test	r12, r12
	jne	.L264
.L268:
	mov	eax, 32
	cmp	r12, rax
	cmova	r12, rax
	jmp	.L265
.L380:
	cmp	QWORD [rbp-8+r12*8], 0
	lea	rax, [r12-1]
	jne	.L379
	mov	r12, rax
.L265:
	test	r12, r12
	jne	.L380
	jmp	.L269
.L379:
	cmp	r12, 32
	jne	.L269
	mov	rcx, r13
	lea	rdx, [rsp+1120]
	lea	rsi, [rsp+2480]
	mov	QWORD [rsp+560], 32
	lea	rdi, [rsp+1936]
	call	inverse_pair_half
	test	eax, eax
	je	.L253
.L264:
	mov	rax, QWORD [rsp+304]
	and	eax, 1
	jne	.L266
	lea	rdx, [rbp+0+r12*8]
.L267:
	mov	rcx, QWORD [rdx-8]
	sub	rdx, 8
	shld	rax, rcx, 63
	mov	QWORD [rdx], rax
	mov	rax, rcx
	and	eax, 1
	cmp	rdx, rbp
	jne	.L267
	jmp	.L268
.L377:
	cmp	r15, 32
	jne	.L256
	mov	rcx, r13
	lea	rdx, [rsp+1120]
	lea	rsi, [rsp+2208]
	mov	QWORD [rsp+288], 32
	lea	rdi, [rsp+1664]
	call	inverse_pair_half
	test	eax, eax
	jne	.L260
	jmp	.L253
.L266:
	cmp	r12, r15
	jne	.L365
	mov	rax, r15
.L273:
	sub	rax, 1
	mov	rdx, QWORD [rbx+rax*8]
	mov	rcx, QWORD [rbp+0+rax*8]
	cmp	rdx, rcx
	jne	.L381
	test	rax, rax
	jne	.L273
.L274:
	lea	r14, [rsp+1392]
	mov	rdx, rbp
	mov	rsi, rbx
	mov	rdi, r14
	call	inverse_sub_raw
	mov	rsi, r14
	mov	ecx, 33
	mov	rdi, rbx
	lea	r14, [rsp+2752]
	lea	rdx, [rsp+1936]
	rep movsq
	lea	rsi, [rsp+1664]
	mov	rdi, r14
	call	inverse_signed_sub
	mov	ecx, 34
	mov	rsi, r14
	lea	rdi, [rsp+1664]
	rep movsq
	lea	rdx, [rsp+2480]
	lea	rsi, [rsp+2208]
	mov	rdi, r14
	call	inverse_signed_sub
	mov	r15, QWORD [rsp+288]
	mov	ecx, 34
	mov	rsi, r14
	lea	rdi, [rsp+2208]
	rep movsq
	test	r15, r15
	je	.L382
.L277:
	mov	r12, QWORD [rsp+560]
	test	r12, r12
	jne	.L254
	jmp	.L279
.L381:
	cmp	rcx, rdx
.L365:
	jb	.L274
	lea	r14, [rsp+1392]
	mov	rdx, rbx
	mov	rsi, rbp
	mov	rdi, r14
	call	inverse_sub_raw
	mov	rsi, r14
	mov	ecx, 33
	mov	rdi, rbp
	lea	r14, [rsp+2752]
	lea	rdx, [rsp+1664]
	rep movsq
	lea	rsi, [rsp+1936]
	mov	rdi, r14
	call	inverse_signed_sub
	mov	ecx, 34
	mov	rsi, r14
	lea	rdi, [rsp+1936]
	rep movsq
	lea	rdx, [rsp+2208]
	lea	rsi, [rsp+2480]
	mov	rdi, r14
	call	inverse_signed_sub
	mov	ecx, 34
	lea	rdi, [rsp+2480]
	mov	rsi, r14
	rep movsq
	jmp	.L277
.L375:
	cmp	rdx, 32
	je	.L383
	mov	eax, 32
	lea	rsi, [rbx+rdx*8]
	sub	rax, rdx
	mov	rdi, rsi
	sal	rax, 3
	mov	ecx, eax
	sub	eax, 1
	mov	QWORD [rsi-8+rcx], 0
	shr	eax, 3
	mov	ecx, eax
	xor	eax, eax
	rep stosq
	mov	QWORD [rsp+1648], rdx
	cmp	r15, rdx
	je	.L295
	jmp	.L366
.L385:
	sub	r9, 1
.L295:
	mov	rax, QWORD [rbx+r9*8]
	mov	rdx, QWORD [r13+0+r9*8]
	cmp	rax, rdx
	jne	.L384
	test	r9, r9
	jne	.L385
.L292:
	mov	r12d, -6
	jmp	.L239
.L384:
	cmp	rdx, rax
.L366:
	jb	.L292
	jmp	.L293
.L374:
	mov	rdx, rbp
	mov	rsi, r13
	mov	rdi, rbx
	call	inverse_sub_raw
	mov	r8, QWORD [rsp+8]
	jmp	.L285
.L302:
	mov	r12d, -2
	jmp	.L239
.L383:
	mov	QWORD [rsp+1648], 32
	cmp	r15, 32
	je	.L295
	jmp	.L292
.L298:
	mov	r12d, -1
	jmp	.L239
.L382:
	mov	r15, QWORD [rsp+8]
	mov	r12d, DWORD [rsp+20]
	mov	r8, QWORD [rsp+24]
	jmp	.L278
section .note.GNU-stack noalloc noexec nowrite progbits
