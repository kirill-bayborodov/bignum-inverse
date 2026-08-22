; @file bignum_inverse.asm
; @brief Optimized x86-64 YASM implementation generated from the C11 reference algorithm.
; @version 1.0.0
; @details SysV AMD64 ABI; no global mutable state; transactional output contract.
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
.L4:
	mov	rcx, QWORD [r9+rax*8]
	mov	rdi, QWORD [r10+rax*8]
	test	rsi, rsi
	jne	.L7
	xor	esi, esi
	cmp	rcx, rdi
	setb	sil
.L31:
	sub	rcx, rdi
	mov	QWORD [r8+rax*8], rcx
	add	rax, 1
	cmp	rax, r11
	jb	.L4
	cmp	rax, rdx
	jnb	.L6
.L5:
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
	jb	.L5
	test	rdx, rdx
	jne	.L35
.L2:
	xor	edx, edx
	jmp	.L14
.L16:
	mov	rdx, rax
.L6:
	test	rdx, rdx
	je	.L2
.L35:
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
.L36:
	mov	rcx, QWORD [r9+rax*8]
.L12:
	mov	QWORD [r8+rax*8], rcx
	add	rax, 1
	cmp	rax, rdx
	jb	.L36
	jmp	.L6
.L3:
	mov	rcx, QWORD [rsi]
	jmp	.L12
.L7:
	xor	esi, esi
	cmp	rdi, rcx
	setnb	sil
	sub	rcx, 1
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
	jne	.L83
	mov	rax, QWORD [rsp+528]
	mov	rdx, QWORD [rsp+800]
	cmp	rax, rdx
	je	.L63
	cmp	rdx, rax
	jnb	.L66
.L64:
	mov	ecx, 34
	xor	eax, eax
	mov	rdi, rbx
	mov	rdx, r9
	rep stosq
	mov	rsi, r10
	mov	rdi, rbx
	call	inverse_sub_raw
.L65:
	mov	rdx, QWORD [rbx+256]
	mov	eax, 32
	mov	DWORD [rbx+264], ebp
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L69
.L85:
	cmp	QWORD [rbx-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L84
	mov	rdx, rax
.L69:
	test	rdx, rdx
	jne	.L85
	mov	ecx, 32
	mov	rdi, rbx
	mov	rax, rdx
	rep stosq
	mov	QWORD [rbx+256], 0
	mov	DWORD [rbx+264], 0
.L37:
	add	rsp, 824
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	ret
.L67:
	sub	rax, 1
	mov	rdx, QWORD [r10+rax*8]
	mov	rcx, QWORD [r9+rax*8]
	cmp	rdx, rcx
	jne	.L86
.L63:
	test	rax, rax
	jne	.L67
	jmp	.L64
.L83:
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
	je	.L39
	xor	edx, edx
	test	r12, r12
	jne	.L50
	xor	eax, eax
.L56:
	cmp	rax, r11
	jnb	.L51
.L89:
	add	rdx, QWORD [r9+rax*8]
	mov	QWORD [rsi+rax*8], rdx
	setc	dl
	add	rax, 1
	movzx	edx, dl
	cmp	rax, r8
	jb	.L56
.L55:
	mov	QWORD [rdi], rdx
	mov	ecx, 34
	xor	eax, eax
	mov	rdi, rbx
	rep stosq
	add	r8, rdx
	cmp	r8, 32
	ja	.L37
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
.L71:
	mov	DWORD [rbx+264], ebp
	jmp	.L60
.L88:
	cmp	QWORD [rbx-8+r8*8], 0
	lea	rax, [r8-1]
	jne	.L87
	mov	r8, rax
.L60:
	test	r8, r8
	jne	.L88
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
.L41:
	add	rcx, rdx
	setc	dl
	mov	QWORD [rsi+rax*8], rcx
	add	rax, 1
	movzx	edx, dl
	cmp	rax, r12
	jnb	.L47
.L50:
	mov	rcx, QWORD [r10+rax*8]
	cmp	rax, r11
	jnb	.L41
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
	jb	.L50
.L47:
	cmp	rax, r8
	jnb	.L55
	cmp	rax, r11
	jb	.L89
.L51:
	mov	QWORD [rsi+rax*8], rdx
	add	rax, 1
	xor	edx, edx
	cmp	rax, r8
	jb	.L56
	jmp	.L55
.L84:
	cmp	rdx, 32
	je	.L81
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
.L86:
	cmp	rcx, rdx
	jb	.L64
.L66:
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
	jmp	.L65
.L81:
	mov	QWORD [rbx+256], 32
	jmp	.L37
.L87:
	cmp	r8, 32
	je	.L81
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
	jmp	.L37
.L39:
	mov	QWORD [rdi], 0
	mov	ecx, 34
	mov	rdi, rbx
	mov	rax, r8
	rep stosq
	jmp	.L71
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
	mov	QWORD [rsp+8], rax
	test	rax, rax
	je	.L92
.L91:
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
.L93:
	mov	rcx, QWORD [rax]
	add	rax, 8
	lea	rdx, [rcx+rcx]
	or	rdx, rsi
	mov	rsi, rcx
	mov	QWORD [rax-8], rdx
	shr	rsi, 63
	cmp	r14, rax
	jne	.L93
	mov	edx, 32
.L94:
	mov	rax, rdx
	sub	rdx, 1
	cmp	QWORD [r15+rdx*8], 0
	jne	.L122
	test	rdx, rdx
	jne	.L94
.L95:
	mov	eax, 32
	lea	r10, [r15+rdx*8]
	sub	rax, rdx
	mov	rdi, r10
	sal	rax, 3
	mov	ecx, eax
	sub	eax, 1
	mov	QWORD [r10-8+rcx], 0
	shr	eax, 3
	mov	ecx, eax
	xor	eax, eax
	rep stosq
.L100:
	mov	QWORD [rsp+288], rdx
	test	rsi, rsi
	jne	.L98
	mov	rax, QWORD [r13+256]
	cmp	rdx, rax
	je	.L101
	cmp	rax, rdx
	jnb	.L102
.L98:
	lea	rbp, [rsp+304]
	mov	rsi, r15
	mov	rdx, r13
	mov	rdi, rbp
	call	inverse_sub_raw
	mov	ecx, 33
	mov	rdi, r15
	mov	rsi, rbp
	rep movsq
.L102:
	test	r12d, r12d
	jne	.L104
	cmp	QWORD [rsp+8], 0
	jne	.L91
.L92:
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
.L101:
	test	rax, rax
	je	.L98
	sub	rax, 1
	mov	rdx, QWORD [r15+rax*8]
	mov	rcx, QWORD [r13+0+rax*8]
	cmp	rdx, rcx
	je	.L101
	cmp	rcx, rdx
	jb	.L98
	jmp	.L102
.L122:
	mov	rdx, rax
	cmp	rax, 32
	jne	.L95
	jmp	.L100
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
	jne	.L124
	cmp	QWORD [rbx+256], 0
	jne	.L125
.L130:
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L126
.L214:
	cmp	QWORD [rbp-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L213
	mov	rdx, rax
.L126:
	test	rdx, rdx
	jne	.L214
.L131:
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
.L135:
	mov	QWORD [rbp+256], rdx
	mov	rdx, QWORD [rbx+256]
	test	rdx, rdx
	je	.L134
	lea	rcx, [rbx-8+rdx*8]
	xor	eax, eax
.L137:
	mov	rsi, QWORD [rcx]
	mov	rdi, rcx
	sub	rcx, 8
	shld	rax, rsi, 63
	mov	QWORD [rcx+8], rax
	mov	rax, rsi
	and	eax, 1
	cmp	rbx, rdi
	jne	.L137
.L134:
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L136
.L216:
	cmp	QWORD [rbx-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L215
	mov	rdx, rax
.L136:
	test	rdx, rdx
	jne	.L216
.L138:
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
.L141:
	mov	QWORD [rbx+256], rdx
	mov	rdx, QWORD [rbp+256]
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L140
.L218:
	cmp	QWORD [rbp-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L217
	mov	rdx, rax
.L140:
	test	rdx, rdx
	jne	.L218
	mov	ecx, 32
	mov	rdi, rbp
	mov	rax, rdx
	rep stosq
	mov	QWORD [rbp+256], 0
	mov	DWORD [rbp+264], 0
.L172:
	mov	rdx, QWORD [rbx+256]
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L145
.L220:
	cmp	QWORD [rbx-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L219
	mov	rdx, rax
.L145:
	test	rdx, rdx
	jne	.L220
	mov	ecx, 32
	mov	rdi, rbx
	mov	rax, rdx
	rep stosq
	mov	QWORD [rbx+256], 0
	mov	DWORD [rbx+264], 0
.L147:
	mov	ecx, 1
.L123:
	add	rsp, 1088
	mov	eax, ecx
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	pop	r14
	ret
.L124:
	mov	rax, QWORD [rdi]
	and	eax, 1
	je	.L221
.L127:
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
	jne	.L148
	mov	rsi, QWORD [rsp+1072]
	test	rsi, rsi
	jne	.L222
	xor	r8d, r8d
.L149:
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L156
.L224:
	cmp	QWORD [r13-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L223
	mov	rdx, rax
.L156:
	test	rdx, rdx
	jne	.L224
.L155:
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
.L160:
	lea	rcx, [r12+rsi*8]
	xor	eax, eax
	test	rsi, rsi
	je	.L161
.L162:
	mov	rsi, QWORD [rcx-8]
	sub	rcx, 8
	shld	rax, rsi, 63
	mov	QWORD [rcx], rax
	mov	rax, rsi
	and	eax, 1
	cmp	r12, rcx
	jne	.L162
	test	r8, r8
	je	.L163
.L226:
	cmp	QWORD [r12-8+r8*8], 0
	lea	rax, [r8-1]
	jne	.L225
	mov	r8, rax
.L161:
	test	r8, r8
	jne	.L226
.L163:
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
	jmp	.L165
.L228:
	cmp	QWORD [r13-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L227
	mov	rdx, rax
.L165:
	test	rdx, rdx
	jne	.L228
	mov	ecx, 32
	mov	rdi, r13
	mov	rax, rdx
	mov	QWORD [rsp+800], 0
	rep stosq
	mov	DWORD [rsp+808], 0
	jmp	.L170
.L230:
	cmp	QWORD [r12-8+r8*8], 0
	lea	rax, [r8-1]
	jne	.L229
	mov	r8, rax
.L170:
	test	r8, r8
	jne	.L230
	mov	ecx, 32
	mov	rdi, r12
	mov	rax, r8
	rep stosq
	mov	QWORD [rsp+1072], 0
	mov	DWORD [rsp+1080], 0
.L173:
	mov	ecx, 34
	mov	rdi, rbp
	mov	rsi, r13
	rep movsq
	mov	ecx, 34
	mov	rdi, rbx
	mov	rsi, r12
	rep movsq
	jmp	.L147
.L125:
	test	BYTE [rbx], 1
	jne	.L127
	jmp	.L130
.L221:
	cmp	QWORD [rbx+256], 0
	jne	.L231
.L128:
	lea	rcx, [rbp-8+rdx*8]
.L129:
	mov	rsi, QWORD [rcx]
	mov	rdi, rcx
	sub	rcx, 8
	shld	rax, rsi, 63
	mov	QWORD [rcx+8], rax
	mov	rax, rsi
	and	eax, 1
	cmp	rbp, rdi
	jne	.L129
	jmp	.L130
.L217:
	cmp	rdx, 32
	je	.L232
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
	jmp	.L172
.L215:
	cmp	rdx, 32
	jne	.L138
	jmp	.L141
.L213:
	cmp	rdx, 32
	jne	.L131
	jmp	.L135
.L219:
	cmp	rdx, 32
	je	.L233
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
	jmp	.L147
.L148:
	mov	rax, QWORD [rsp+544]
	xor	ecx, ecx
	and	eax, 1
	jne	.L123
	mov	rsi, QWORD [rsp+1072]
	test	rsi, rsi
	jne	.L152
	xor	r8d, r8d
.L154:
	lea	rcx, [r13+0+rdx*8]
.L153:
	mov	rdi, QWORD [rcx-8]
	sub	rcx, 8
	shld	rax, rdi, 63
	mov	QWORD [rcx], rax
	mov	rax, rdi
	and	eax, 1
	cmp	rcx, r13
	jne	.L153
	jmp	.L149
.L231:
	test	BYTE [rbx], 1
	je	.L128
	jmp	.L127
.L222:
	xor	ecx, ecx
	test	BYTE [rsp+816], 1
	jne	.L123
	mov	r8d, 32
	cmp	rsi, r8
	cmovbe	r8, rsi
	jmp	.L149
.L233:
	mov	QWORD [rbx+256], 32
	jmp	.L147
.L232:
	mov	QWORD [rbp+256], 32
	jmp	.L172
.L223:
	cmp	rdx, 32
	jne	.L155
	jmp	.L160
.L225:
	cmp	r8, 32
	jne	.L163
	jmp	.L165
.L227:
	cmp	rdx, 32
	je	.L234
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
	jmp	.L170
.L229:
	cmp	r8, 32
	je	.L235
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
	jmp	.L173
.L152:
	test	BYTE [rsp+816], 1
	jne	.L123
	mov	r8d, 32
	cmp	rsi, r8
	cmovbe	r8, rsi
	jmp	.L154
.L235:
	mov	QWORD [rsp+1072], 32
	jmp	.L173
.L234:
	mov	QWORD [rsp+800], 32
	jmp	.L170
global bignum_inverse
bignum_inverse:
	endbr64
	push	r15
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
	jne	.L295
	mov	r8, rdi
	test	rdi, rdi
	je	.L295
	cmp	rdi, rsi
	jb	.L365
	mov	rdx, rdi
	xor	r12d, r12d
	sub	rdx, rsi
	cmp	rdx, 263
	setbe	r12b
.L239:
	test	r12d, r12d
	jne	.L308
	cmp	r8, rax
	jnb	.L240
	mov	rdx, rax
	sub	rdx, r8
	cmp	rdx, 263
	jbe	.L308
.L241:
	mov	rdx, QWORD [rsi+256]
	cmp	rdx, 32
	ja	.L299
	mov	r15, QWORD [rax+256]
	cmp	r15, 32
	ja	.L299
	lea	rbx, [rsp+32]
	lea	rbp, [rsp+304]
	mov	ecx, 33
	mov	rdi, rbx
	rep movsq
	mov	ecx, 33
	mov	rdi, rbp
	mov	rsi, rax
	rep movsq
	jmp	.L243
.L367:
	cmp	QWORD [rbx-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L366
	mov	rdx, rax
.L243:
	test	rdx, rdx
	jne	.L367
.L242:
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
.L246:
	mov	QWORD [rsp+288], rdx
	jmp	.L245
.L369:
	cmp	QWORD [rbp-8+r15*8], 0
	lea	rax, [r15-1]
	jne	.L368
	mov	r15, rax
.L245:
	test	r15, r15
	jne	.L369
	mov	r12d, -4
.L236:
	add	rsp, 3032
	mov	eax, r12d
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	ret
.L365:
	mov	rdx, rsi
	xor	r12d, r12d
	sub	rdx, rdi
	cmp	rdx, 263
	setbe	r12b
	jmp	.L239
.L240:
	mov	rdx, r8
	sub	rdx, rax
	cmp	rdx, 263
	ja	.L241
.L308:
	mov	r12d, -3
	jmp	.L236
.L368:
	cmp	r15, 32
	je	.L370
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
	jne	.L249
	cmp	QWORD [rsp+304], 1
	ja	.L249
.L250:
	mov	r12d, -5
	jmp	.L236
.L370:
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
.L249:
	mov	rdx, r13
	mov	rsi, rbx
	mov	rdi, rbx
	mov	QWORD [rsp+24], r8
	call	inverse_reduce
	mov	r14, QWORD [rsp+288]
	test	r14, r14
	je	.L250
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
.L251:
	cmp	r15, 1
	jne	.L277
	cmp	QWORD [rsp+32], 1
	jne	.L277
	mov	r15, QWORD [rsp+8]
	mov	r12d, DWORD [rsp+20]
	mov	r8, QWORD [rsp+24]
.L278:
	cmp	QWORD [rsp+32], 1
	lea	rbx, [rsp+1664]
	jne	.L275
.L280:
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
	je	.L281
	cmp	QWORD [rsp+3008], 0
	jne	.L371
.L281:
	mov	ecx, 33
	mov	rdi, rbx
	mov	rsi, rbp
	rep movsq
.L282:
	mov	rdx, QWORD [rsp+1648]
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L284
.L373:
	cmp	QWORD [rbx-8+rdx*8], 0
	lea	r9, [rdx-1]
	jne	.L372
	mov	rdx, r9
.L284:
	test	rdx, rdx
	jne	.L373
	mov	ecx, 32
	mov	rdi, rbx
	mov	rax, rdx
	rep stosq
	mov	QWORD [rsp+1648], 0
.L290:
	mov	ecx, 33
	mov	rdi, r8
	mov	rsi, rbx
	rep movsq
	jmp	.L236
.L277:
	cmp	r12, 1
	jne	.L279
	cmp	QWORD [rsp+304], 1
	jne	.L279
.L276:
	mov	r14, r15
	mov	r12d, DWORD [rsp+20]
	mov	r15, QWORD [rsp+8]
	mov	r8, QWORD [rsp+24]
	cmp	r14, 1
	je	.L278
.L275:
	cmp	QWORD [rsp+560], 1
	jne	.L250
	cmp	QWORD [rsp+304], 1
	jne	.L250
	lea	rbx, [rsp+1936]
	jmp	.L280
.L366:
	cmp	rdx, 32
	jne	.L242
	jmp	.L246
.L279:
	mov	r14d, 32
	test	r15, r15
	jne	.L257
.L259:
	mov	eax, 32
	cmp	r15, rax
	cmova	r15, rax
	jmp	.L254
.L375:
	cmp	QWORD [rbx-8+r15*8], 0
	lea	rax, [r15-1]
	jne	.L374
	mov	r15, rax
.L254:
	test	r15, r15
	jne	.L375
.L253:
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
	je	.L250
	test	r15, r15
	je	.L259
.L257:
	mov	rax, QWORD [rsp+32]
	and	eax, 1
	jne	.L268
	lea	rdx, [rbx+r15*8]
.L252:
	mov	rcx, QWORD [rdx-8]
	sub	rdx, 8
	shld	rax, rcx, 63
	mov	QWORD [rdx], rax
	mov	rax, rcx
	and	eax, 1
	cmp	rdx, rbx
	jne	.L252
	jmp	.L259
.L266:
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
	je	.L250
.L268:
	test	r12, r12
	jne	.L261
.L265:
	mov	eax, 32
	cmp	r12, rax
	cmova	r12, rax
	jmp	.L262
.L377:
	cmp	QWORD [rbp-8+r12*8], 0
	lea	rax, [r12-1]
	jne	.L376
	mov	r12, rax
.L262:
	test	r12, r12
	jne	.L377
	jmp	.L266
.L376:
	cmp	r12, 32
	jne	.L266
	mov	rcx, r13
	lea	rdx, [rsp+1120]
	lea	rsi, [rsp+2480]
	mov	QWORD [rsp+560], 32
	lea	rdi, [rsp+1936]
	call	inverse_pair_half
	test	eax, eax
	je	.L250
.L261:
	mov	rax, QWORD [rsp+304]
	and	eax, 1
	jne	.L263
	lea	rdx, [rbp+0+r12*8]
.L264:
	mov	rcx, QWORD [rdx-8]
	sub	rdx, 8
	shld	rax, rcx, 63
	mov	QWORD [rdx], rax
	mov	rax, rcx
	and	eax, 1
	cmp	rdx, rbp
	jne	.L264
	jmp	.L265
.L374:
	cmp	r15, 32
	jne	.L253
	mov	rcx, r13
	lea	rdx, [rsp+1120]
	lea	rsi, [rsp+2208]
	mov	QWORD [rsp+288], 32
	lea	rdi, [rsp+1664]
	call	inverse_pair_half
	test	eax, eax
	jne	.L257
	jmp	.L250
.L263:
	cmp	r12, r15
	jne	.L362
	mov	rax, r15
.L270:
	sub	rax, 1
	mov	rdx, QWORD [rbx+rax*8]
	mov	rcx, QWORD [rbp+0+rax*8]
	cmp	rdx, rcx
	jne	.L378
	test	rax, rax
	jne	.L270
.L271:
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
	je	.L379
.L274:
	mov	r12, QWORD [rsp+560]
	test	r12, r12
	jne	.L251
	jmp	.L276
.L378:
	cmp	rcx, rdx
.L362:
	jb	.L271
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
	jmp	.L274
.L372:
	cmp	rdx, 32
	je	.L380
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
	je	.L292
	jmp	.L363
.L382:
	sub	r9, 1
.L292:
	mov	rax, QWORD [rbx+r9*8]
	mov	rdx, QWORD [r13+0+r9*8]
	cmp	rax, rdx
	jne	.L381
	test	r9, r9
	jne	.L382
.L289:
	mov	r12d, -6
	jmp	.L236
.L381:
	cmp	rdx, rax
.L363:
	jb	.L289
	jmp	.L290
.L371:
	mov	rdx, rbp
	mov	rsi, r13
	mov	rdi, rbx
	call	inverse_sub_raw
	mov	r8, QWORD [rsp+8]
	jmp	.L282
.L299:
	mov	r12d, -2
	jmp	.L236
.L380:
	mov	QWORD [rsp+1648], 32
	cmp	r15, 32
	je	.L292
	jmp	.L289
.L295:
	mov	r12d, -1
	jmp	.L236
.L379:
	mov	r15, QWORD [rsp+8]
	mov	r12d, DWORD [rsp+20]
	mov	r8, QWORD [rsp+24]
	jmp	.L275
section .note.GNU-stack noalloc noexec nowrite progbits
