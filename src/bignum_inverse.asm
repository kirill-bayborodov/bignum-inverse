; @file bignum_inverse.asm
; @brief Standalone x86-64 YASM correctness implementation synchronized with C11 variant B.
; @version 0.2.2
; @details SysV AMD64 ABI; no global mutable state; transactional output contract.
; @revision 0.2.1 Generated Variant B correctness parity baseline.
; @revision 0.2.2 P1 caller-saved register-only one-word odd-modulus fast path;
;            generated Variant B remains the generic fallback for all other inputs.
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
inverse_mod2_mul_low:
	push	r14
	mov	eax, 33
	mov	r9, rsi
	mov	r8, rdi
	push	r13
	mov	rcx, rax
	push	r12
	push	rbp
	push	rbx
	xor	ebx, ebx
	sub	rsp, 424
	mov	r13, QWORD [rdx+256]
	mov	r12, QWORD [r9+256]
	lea	rbp, [rsp-120]
	lea	r9, [rsp+152]
	mov	rdi, rbp
	lea	r10, [r13-1]
	mov	r14, r13
	rep movsq
	mov	rdi, r9
	mov	rsi, rdx
	mov	rax, rcx
	mov	ecx, 33
	rep movsq
	mov	ecx, 33
	mov	rdi, r8
	rep stosq
	test	r12, r12
	je	.L39
.L44:
	test	r13, r13
	je	.L47
	mov	r11, QWORD [rbp+0+rbx*8]
	mov	rcx, rbx
	xor	esi, esi
	xor	edi, edi
	jmp	.L41
.L74:
	add	rcx, 1
	cmp	rcx, 32
	je	.L40
.L41:
	mov	rax, r11
	mul	QWORD [r9+rcx*8]
	add	rax, QWORD [r8+rcx*8]
	adc	rdx, 0
	add	rsi, rax
	adc	rdi, rdx
	mov	QWORD [r8+rcx*8], rsi
	mov	rsi, rdi
	xor	edi, edi
	cmp	rcx, r10
	jne	.L74
.L40:
	mov	rax, rsi
	or	rax, rdi
	je	.L47
	cmp	r14, 31
	ja	.L47
	mov	rcx, r14
.L42:
	mov	rax, rsi
	mov	rdx, rdi
	add	rax, QWORD [r8+rcx*8]
	mov	esi, 1
	adc	rdx, 0
	mov	QWORD [r8+rcx*8], rax
	xor	edi, edi
	add	rcx, 1
	test	dl, 1
	je	.L47
	cmp	rcx, 31
	jbe	.L42
.L47:
	add	rbx, 1
	add	r14, 1
	sub	r9, 8
	add	r10, 1
	cmp	rbx, r12
	jnb	.L39
	cmp	rbx, 32
	jne	.L44
.L39:
	mov	edx, 32
.L49:
	mov	rax, rdx
	sub	rdx, 1
	cmp	QWORD [r8+rdx*8], 0
	jne	.L75
	test	rdx, rdx
	jne	.L49
.L50:
	mov	eax, 32
	lea	rsi, [r8+rdx*8]
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
.L53:
	mov	QWORD [r8+256], rdx
	add	rsp, 424
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	pop	r14
	ret
.L75:
	mov	rdx, rax
	cmp	rax, 32
	jne	.L50
	jmp	.L53
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
	je	.L78
.L77:
	sub	QWORD [rsp+8], 1
	mov	rbx, QWORD [rsp+24]
	mov	r12d, 64
	mov	rax, QWORD [rsp+8]
	mov	rbx, QWORD [rbx+rax*8]
.L90:
	sub	r12d, 1
	mov	rsi, rbx
	mov	rax, r15
	mov	ecx, r12d
	shr	rsi, cl
	and	esi, 1
.L79:
	mov	rcx, QWORD [rax]
	add	rax, 8
	lea	rdx, [rcx+rcx]
	or	rdx, rsi
	mov	rsi, rcx
	mov	QWORD [rax-8], rdx
	shr	rsi, 63
	cmp	r14, rax
	jne	.L79
	mov	edx, 32
.L80:
	mov	rax, rdx
	sub	rdx, 1
	cmp	QWORD [r15+rdx*8], 0
	jne	.L108
	test	rdx, rdx
	jne	.L80
.L81:
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
.L86:
	mov	QWORD [rsp+288], rdx
	test	rsi, rsi
	jne	.L84
	mov	rax, QWORD [r13+256]
	cmp	rdx, rax
	je	.L87
	cmp	rax, rdx
	jnb	.L88
.L84:
	lea	rbp, [rsp+304]
	mov	rsi, r15
	mov	rdx, r13
	mov	rdi, rbp
	call	inverse_sub_raw
	mov	ecx, 33
	mov	rdi, r15
	mov	rsi, rbp
	rep movsq
.L88:
	test	r12d, r12d
	jne	.L90
	cmp	QWORD [rsp+8], 0
	jne	.L77
.L78:
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
.L87:
	test	rax, rax
	je	.L84
	sub	rax, 1
	mov	rdx, QWORD [r15+rax*8]
	mov	rcx, QWORD [r13+0+rax*8]
	cmp	rdx, rcx
	je	.L87
	cmp	rcx, rdx
	jb	.L84
	jmp	.L88
.L108:
	mov	rdx, rax
	cmp	rax, 32
	jne	.L81
	jmp	.L86
inverse_mod2_mask:
	lea	rax, [rsi+63]
	mov	r8, rdi
	mov	rcx, rsi
	mov	rdx, rax
	shr	rdx, 6
	cmp	rax, 63
	jbe	.L126
	and	ecx, 63
	jne	.L127
.L112:
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
.L113:
	mov	rax, rdx
	sub	rdx, 1
	cmp	QWORD [r8+rdx*8], 0
	jne	.L128
	test	rdx, rdx
	jne	.L113
.L114:
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
	mov	QWORD [r8+256], rdx
	ret
.L127:
	mov	rax, -1
	sal	rax, cl
	not	rax
	and	QWORD [rdi-8+rdx*8], rax
	jmp	.L112
.L128:
	mov	rdx, rax
	cmp	rax, 32
	jne	.L114
	mov	QWORD [r8+256], rdx
	ret
.L126:
	mov	ecx, 33
	xor	eax, eax
	rep stosq
	ret
inverse_mod2_newton.part.0:
	push	r15
	mov	ecx, 33
	xor	eax, eax
	push	r14
	push	r13
	push	r12
	push	rbp
	push	rbx
	sub	rsp, 1112
	lea	rbp, [rsp+16]
	mov	QWORD [rsp+8], rdi
	mov	rdi, rbp
	rep stosq
	mov	QWORD [rsp+272], 1
	mov	QWORD [rsp+16], 1
	cmp	rdx, 1
	jbe	.L130
	mov	r15, rsi
	mov	r12, rdx
	mov	ebx, 1
	xor	r13d, r13d
	lea	r14, [rsp+832]
.L141:
	add	rbx, rbx
	mov	rdx, rbp
	mov	rsi, r15
	cmp	rbx, r12
	lea	rdi, [rsp+288]
	cmova	rbx, r12
	call	inverse_mod2_mul_low
	lea	rdi, [rsp+288]
	mov	rsi, rbx
	call	inverse_mod2_mask
	mov	rax, r13
	mov	ecx, 33
	lea	rdi, [rsp+560]
	rep stosq
	lea	rsi, [rbx+63]
	mov	ecx, 33
	mov	rdi, r14
	rep stosq
	shr	rsi, 6
	mov	QWORD [rsp+816], 1
	mov	QWORD [rsp+560], 2
	je	.L131
	mov	rax, QWORD [rsp+544]
	test	rax, rax
	je	.L143
	cmp	rsi, rax
	cmovbe	rax, rsi
	mov	rdi, rax
	xor	eax, eax
.L136:
	xor	edx, edx
	test	rax, rax
	mov	r9, QWORD [rsp+288+rax*8]
	sete	dl
	add	rdx, rdx
	test	rcx, rcx
	jne	.L133
	xor	ecx, ecx
	cmp	rdx, r9
	setb	cl
.L158:
	sub	rdx, r9
	mov	QWORD [r14+rax*8], rdx
	add	rax, 1
	cmp	rax, rdi
	jb	.L136
	cmp	rax, rsi
	jnb	.L138
	test	rcx, rcx
	je	.L139
	mov	rdx, rax
	mov	QWORD [r14+rax*8], -1
	add	rax, 1
	not	rdx
	add	rdx, rsi
	and	edx, 1
	cmp	rax, rsi
	jnb	.L138
	test	rdx, rdx
	je	.L137
	mov	QWORD [r14+rax*8], -1
	add	rax, 1
	cmp	rax, rsi
	jnb	.L138
.L137:
	mov	QWORD [r14+rax*8], -1
	mov	QWORD [r14+8+rax*8], -1
	add	rax, 2
	cmp	rax, rsi
	jb	.L137
.L138:
	mov	QWORD [rsp+1088], rsi
	mov	rdi, r14
	mov	rsi, rbx
	call	inverse_mod2_mask
	mov	rsi, rbp
	mov	rdi, rbp
	mov	rdx, r14
	call	inverse_mod2_mul_low
	mov	rsi, rbx
	mov	rdi, rbp
	call	inverse_mod2_mask
	cmp	rbx, r12
	jb	.L141
.L130:
	mov	rdi, QWORD [rsp+8]
	mov	rsi, rbp
	mov	ecx, 33
	mov	eax, 1
	rep movsq
	add	rsp, 1112
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	ret
.L143:
	mov	ecx, 2
.L139:
	mov	QWORD [r14+rax*8], rcx
	add	rax, 1
	xor	ecx, ecx
	cmp	rax, rsi
	jnb	.L138
	mov	QWORD [r14+rax*8], rcx
	add	rax, 1
	xor	ecx, ecx
	cmp	rax, rsi
	jb	.L139
	jmp	.L138
.L133:
	xor	ecx, ecx
	cmp	r9, rdx
	setnb	cl
	add	r9, 1
	jmp	.L158
.L131:
	xor	esi, esi
	mov	rdi, r14
	mov	QWORD [rsp+1088], 0
	call	inverse_mod2_mask
	mov	rsi, rbp
	mov	rdi, rbp
	mov	rdx, r14
	call	inverse_mod2_mul_low
	xor	esi, esi
	mov	rdi, rbp
	call	inverse_mod2_mask
	jmp	.L141
inverse_mod_sub.part.0:
	push	r12
	mov	r12, rsi
	mov	rsi, rcx
	push	rbp
	mov	rbp, rcx
	push	rbx
	mov	rbx, rdi
	sub	rsp, 816
	mov	rdi, rsp
	call	inverse_sub_raw
	mov	r8, QWORD [r12+256]
	mov	ecx, 33
	mov	r10, QWORD [rsp+256]
	lea	rsi, [rsp+272]
	cmp	r8, r10
	mov	r9, r10
	mov	rdi, rsi
	cmovnb	r9, r8
	xor	eax, eax
	rep stosq
	test	r9, r9
	je	.L161
	xor	edx, edx
	test	r10, r10
	je	.L188
.L172:
	mov	rcx, QWORD [rsp+rax*8]
	cmp	rax, r8
	jnb	.L163
	xor	edi, edi
	add	rcx, QWORD [r12+rax*8]
	setc	dil
	add	rdx, rcx
	mov	QWORD [rsi+rax*8], rdx
	setc	dl
	add	rax, 1
	movzx	edx, dl
	or	rdx, rdi
	cmp	rax, r10
	jb	.L172
.L169:
	cmp	rax, r9
	jnb	.L177
.L178:
	cmp	rax, r8
	jnb	.L173
	add	rdx, QWORD [r12+rax*8]
	mov	QWORD [rsi+rax*8], rdx
	setc	dl
	add	rax, 1
	movzx	edx, dl
	cmp	rax, r9
	jb	.L178
.L177:
	mov	QWORD [rsp+272+r9*8], rdx
	add	rdx, r9
	mov	r9d, 32
	xor	eax, eax
	cmp	rdx, r9
	lea	r8, [rsp+544]
	mov	ecx, 33
	cmovbe	r9, rdx
	mov	rdi, r8
	rep stosq
	mov	rdi, r8
	mov	rcx, r9
	mov	QWORD [rsp+800], r9
	and	ecx, 536870911
	rep movsq
	cmp	rdx, 32
	ja	.L185
	mov	rax, QWORD [rbp+256]
	cmp	r9, rax
	jne	.L193
.L184:
	test	rax, rax
	je	.L185
	sub	rax, 1
	mov	rdx, QWORD [r8+rax*8]
	mov	rcx, QWORD [rbp+0+rax*8]
	cmp	rdx, rcx
	je	.L184
	cmp	rcx, rdx
	jnb	.L186
.L185:
	mov	rdx, rbp
	mov	rdi, rbx
	mov	rsi, r8
	call	inverse_sub_raw
	add	rsp, 816
	pop	rbx
	pop	rbp
	pop	r12
	ret
.L163:
	add	rdx, rcx
	mov	QWORD [rsi+rax*8], rdx
	setc	dl
	add	rax, 1
	movzx	edx, dl
	cmp	rax, r10
	jnb	.L169
	jmp	.L172
.L173:
	mov	QWORD [rsi+rax*8], rdx
	add	rax, 1
	xor	edx, edx
	cmp	rax, r9
	jb	.L178
	jmp	.L177
.L188:
	xor	eax, eax
	jmp	.L178
.L193:
	cmp	rax, r9
	jb	.L185
.L186:
	mov	rdi, rbx
	mov	ecx, 33
	mov	rsi, r8
	rep movsq
	add	rsp, 816
	pop	rbx
	pop	rbp
	pop	r12
	ret
.L161:
	lea	r8, [rsp+544]
	mov	ecx, 33
	mov	rax, r9
	cmp	QWORD [rbp+256], 0
	mov	rdi, r8
	rep stosq
	jne	.L186
	jmp	.L185
inverse_mod_half.part.0:
	push	rbp
	mov	r8, rdi
	mov	eax, 33
	mov	r9, rsi
	push	rbx
	mov	rcx, rax
	mov	rsi, r8
	sub	rsp, 432
	mov	rbx, QWORD [r8+256]
	mov	r10, QWORD [r9+256]
	lea	r11, [rsp+152]
	mov	rdi, r11
	cmp	r10, rbx
	mov	rdx, rbx
	rep movsq
	cmovnb	rdx, r10
	lea	rsi, [rsp-120]
	mov	rdi, rsi
	mov	rax, rcx
	mov	ecx, 33
	rep stosq
	test	rdx, rdx
	je	.L195
	test	rbx, rbx
	je	.L219
.L206:
	mov	rdi, QWORD [r11+rax*8]
	cmp	rax, r10
	jnb	.L197
	xor	ebp, ebp
	add	rdi, QWORD [r9+rax*8]
	setc	bpl
	add	rcx, rdi
	mov	QWORD [rsi+rax*8], rcx
	setc	cl
	add	rax, 1
	movzx	ecx, cl
	or	rcx, rbp
	cmp	rax, rbx
	jb	.L206
.L203:
	cmp	rax, rdx
	jnb	.L211
.L212:
	cmp	rax, r10
	jnb	.L207
	add	rcx, QWORD [r9+rax*8]
	mov	QWORD [rsi+rax*8], rcx
	setc	cl
	add	rax, 1
	movzx	ecx, cl
	cmp	rax, rdx
	jb	.L212
.L211:
	mov	QWORD [rsp-120+rdx*8], rcx
	add	rdx, rcx
	xor	eax, eax
	lea	rcx, [rsi+rdx*8]
.L214:
	mov	rdi, QWORD [rcx-8]
	sub	rcx, 8
	shld	rax, rdi, 63
	mov	QWORD [rcx], rax
	mov	rax, rdi
	and	eax, 1
	cmp	rsi, rcx
	jne	.L214
	xor	eax, eax
	mov	ecx, 33
	mov	rdi, r8
	rep stosq
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	lea	rcx, [0+rdx*8]
	mov	eax, ecx
	sub	ecx, 1
	mov	rdi, QWORD [rsi-8+rax]
	shr	ecx, 3
	mov	QWORD [r8-8+rax], rdi
	mov	rdi, r8
	rep movsq
	jmp	.L215
.L221:
	mov	rdx, rax
.L215:
	test	rdx, rdx
	je	.L213
	cmp	QWORD [r8-8+rdx*8], 0
	lea	rax, [rdx-1]
	je	.L221
	cmp	rdx, 32
	je	.L218
.L217:
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
.L218:
	mov	QWORD [r8+256], rdx
	add	rsp, 432
	pop	rbx
	pop	rbp
	ret
.L197:
	add	rdi, rcx
	setc	cl
	mov	QWORD [rsi+rax*8], rdi
	add	rax, 1
	movzx	ecx, cl
	cmp	rax, rbx
	jnb	.L203
	jmp	.L206
.L207:
	mov	QWORD [rsi+rax*8], rcx
	add	rax, 1
	xor	ecx, ecx
	cmp	rax, rdx
	jb	.L212
	jmp	.L211
.L219:
	xor	ecx, ecx
	xor	eax, eax
	jmp	.L212
.L195:
	mov	ecx, 33
	mov	rdi, r8
	mov	rax, rdx
	rep stosq
.L213:
	xor	edx, edx
	jmp	.L217
inverse_mod_odd:
	push	r15
	mov	eax, 33
	mov	r11d, 32
	push	r14
	mov	rcx, rax
	push	r13
	push	r12
	push	rbp
	push	rbx
	sub	rsp, 1400
	lea	r13, [rsp+32]
	mov	QWORD [rsp+8], rdi
	lea	r8, [rsp+304]
	mov	rdi, r13
	lea	r15, [rsp+576]
	mov	QWORD [rsp+16], rdx
	lea	r14, [rsp+848]
	rep movsq
	mov	rdi, r8
	mov	rsi, rdx
	mov	rbx, QWORD [rsp+288]
	mov	rax, rcx
	mov	ecx, 33
	rep movsq
	mov	ecx, 33
	mov	rdi, r15
	rep stosq
	mov	ecx, 33
	mov	rdi, r14
	mov	QWORD [rsp+832], 1
	rep stosq
	mov	QWORD [rsp+576], 1
	test	rbx, rbx
	je	.L346
.L230:
	mov	rdx, QWORD [rsp+560]
	test	rdx, rdx
	je	.L282
	cmp	rbx, 1
	jne	.L283
	cmp	QWORD [rsp+32], 1
	jne	.L283
	mov	ecx, 33
	xor	eax, eax
	lea	rdi, [rsp+1120]
	rep stosq
	mov	QWORD [rsp+1376], 1
	mov	QWORD [rsp+1120], 1
.L293:
	cmp	QWORD [rsp+32], 1
	jne	.L231
	mov	rdi, QWORD [rsp+8]
	mov	ecx, 33
	mov	rsi, r15
	rep movsq
.L287:
	mov	rax, QWORD [rsp+8]
	mov	rdx, QWORD [rax+256]
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L290
.L352:
	mov	rdi, QWORD [rsp+8]
	lea	rax, [rdx-1]
	cmp	QWORD [rdi-8+rdx*8], 0
	jne	.L351
	mov	rdx, rax
.L290:
	test	rdx, rdx
	jne	.L352
.L289:
	mov	eax, 32
	mov	rdi, QWORD [rsp+8]
	sub	rax, rdx
	sal	rax, 3
	lea	rsi, [rdi+rdx*8]
	mov	ecx, eax
	sub	eax, 1
	mov	rdi, rsi
	mov	QWORD [rsi-8+rcx], 0
	shr	eax, 3
	mov	ecx, eax
	xor	eax, eax
	rep stosq
.L292:
	mov	rax, QWORD [rsp+8]
	mov	QWORD [rax+256], rdx
	mov	eax, 1
.L229:
	add	rsp, 1400
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	ret
.L283:
	cmp	rdx, 1
	jne	.L285
	cmp	QWORD [rsp+304], 1
	jne	.L285
.L282:
	mov	ecx, 33
	xor	eax, eax
	lea	rdi, [rsp+1120]
	rep stosq
	mov	QWORD [rsp+1376], 1
	mov	QWORD [rsp+1120], 1
	cmp	rbx, 1
	je	.L293
.L231:
	xor	eax, eax
	cmp	QWORD [rsp+560], 1
	jne	.L229
	cmp	QWORD [rsp+304], 1
	jne	.L229
	mov	rdi, QWORD [rsp+8]
	mov	ecx, 33
	mov	rsi, r14
	rep movsq
	jmp	.L287
.L285:
	mov	rbp, QWORD [rsp+832]
.L286:
	test	rbx, rbx
	je	.L246
	mov	rax, QWORD [rsp+32]
	and	eax, 1
	je	.L247
	mov	r12, QWORD [rsp+1104]
.L248:
	test	rdx, rdx
	je	.L253
	mov	rax, QWORD [rsp+304]
	and	eax, 1
	jne	.L251
	lea	rcx, [r8+rdx*8]
.L252:
	mov	rsi, QWORD [rcx-8]
	sub	rcx, 8
	shld	rax, rsi, 63
	mov	QWORD [rcx], rax
	mov	rax, rsi
	and	eax, 1
	cmp	r8, rcx
	jne	.L252
.L253:
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L250
.L354:
	cmp	QWORD [r8-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L353
	mov	rdx, rax
.L250:
	test	rdx, rdx
	jne	.L354
.L254:
	mov	rcx, r11
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
.L258:
	mov	QWORD [rsp+560], rdx
	test	r12, r12
	je	.L256
	mov	rax, QWORD [rsp+848]
	and	eax, 1
	je	.L260
	mov	rsi, QWORD [rsp+16]
	mov	rdi, r14
	mov	QWORD [rsp+24], rdx
	call	inverse_mod_half.part.0
	mov	rdx, QWORD [rsp+24]
	mov	r12, QWORD [rsp+1104]
	lea	r8, [rsp+304]
	mov	r11d, 32
	jmp	.L248
.L247:
	lea	rcx, [r13+0+rbx*8]
.L232:
	mov	rsi, QWORD [rcx-8]
	sub	rcx, 8
	shld	rax, rsi, 63
	mov	QWORD [rcx], rax
	mov	rax, rsi
	and	eax, 1
	cmp	r13, rcx
	jne	.L232
.L246:
	mov	eax, 32
	cmp	rbx, rax
	cmova	rbx, rax
	jmp	.L234
.L356:
	cmp	QWORD [r13-8+rbx*8], 0
	lea	rax, [rbx-1]
	jne	.L355
	mov	rbx, rax
.L234:
	test	rbx, rbx
	jne	.L356
.L233:
	mov	rcx, r11
	lea	rsi, [r13+0+rbx*8]
	sub	rcx, rbx
	mov	rdi, rsi
	sal	rcx, 3
	mov	eax, ecx
	sub	ecx, 1
	mov	QWORD [rsi-8+rax], 0
	shr	ecx, 3
	xor	eax, eax
	rep stosq
.L238:
	mov	QWORD [rsp+288], rbx
	test	rbp, rbp
	je	.L236
	mov	rax, QWORD [rsp+576]
	and	eax, 1
	je	.L240
	mov	rsi, QWORD [rsp+16]
	mov	rdi, r15
	mov	QWORD [rsp+24], rdx
	call	inverse_mod_half.part.0
	mov	rdx, QWORD [rsp+24]
	mov	rbp, QWORD [rsp+832]
	lea	r8, [rsp+304]
	mov	r11d, 32
	jmp	.L286
.L260:
	lea	rcx, [r14+r12*8]
.L262:
	mov	rsi, QWORD [rcx-8]
	sub	rcx, 8
	shld	rax, rsi, 63
	mov	QWORD [rcx], rax
	mov	rax, rsi
	and	eax, 1
	cmp	r14, rcx
	jne	.L262
.L256:
	mov	eax, 32
	cmp	r12, rax
	cmova	r12, rax
	jmp	.L259
.L358:
	cmp	QWORD [r14-8+r12*8], 0
	lea	rax, [r12-1]
	jne	.L357
	mov	r12, rax
.L259:
	test	r12, r12
	jne	.L358
.L263:
	mov	rcx, r11
	lea	rsi, [r14+r12*8]
	sub	rcx, r12
	mov	rdi, rsi
	sal	rcx, 3
	mov	eax, ecx
	sub	ecx, 1
	mov	QWORD [rsi-8+rax], 0
	shr	ecx, 3
	xor	eax, eax
	rep stosq
.L265:
	mov	QWORD [rsp+1104], r12
	jmp	.L248
.L240:
	lea	rcx, [r15+rbp*8]
.L242:
	mov	rsi, QWORD [rcx-8]
	sub	rcx, 8
	shld	rax, rsi, 63
	mov	QWORD [rcx], rax
	mov	rax, rsi
	and	eax, 1
	cmp	r15, rcx
	jne	.L242
.L236:
	mov	eax, 32
	cmp	rbp, rax
	cmova	rbp, rax
	jmp	.L239
.L360:
	cmp	QWORD [r15-8+rbp*8], 0
	lea	rax, [rbp-1]
	jne	.L359
	mov	rbp, rax
.L239:
	test	rbp, rbp
	jne	.L360
.L243:
	mov	rcx, r11
	lea	rsi, [r15+rbp*8]
	sub	rcx, rbp
	mov	rdi, rsi
	sal	rcx, 3
	mov	eax, ecx
	sub	ecx, 1
	mov	QWORD [rsi-8+rax], 0
	shr	ecx, 3
	xor	eax, eax
	rep stosq
.L245:
	mov	QWORD [rsp+832], rbp
	jmp	.L286
.L355:
	cmp	rbx, 32
	jne	.L233
	jmp	.L238
.L353:
	cmp	rdx, 32
	jne	.L254
	jmp	.L258
.L357:
	cmp	r12, 32
	jne	.L263
	jmp	.L265
.L359:
	cmp	rbp, 32
	jne	.L243
	jmp	.L245
.L251:
	cmp	rdx, rbx
	jne	.L349
	mov	rax, rbx
.L266:
	sub	rax, 1
	mov	rdx, QWORD [r13+0+rax*8]
	mov	rcx, QWORD [r8+rax*8]
	cmp	rdx, rcx
	jne	.L361
	test	rax, rax
	jne	.L266
.L267:
	mov	rsi, r13
	lea	rdi, [rsp+1120]
	mov	rdx, r8
	call	inverse_sub_raw
	mov	ecx, 33
	mov	rdi, r13
	lea	rsi, [rsp+1120]
	rep movsq
	cmp	rbp, r12
	je	.L270
	cmp	r12, rbp
	jnb	.L272
.L271:
	mov	rdx, r14
	mov	rsi, r15
	lea	rdi, [rsp+1120]
	call	inverse_sub_raw
	lea	r8, [rsp+304]
	mov	r11d, 32
.L274:
	mov	rbx, QWORD [rsp+288]
	mov	ecx, 33
	mov	rdi, r15
	lea	rsi, [rsp+1120]
	rep movsq
	test	rbx, rbx
	jne	.L230
.L346:
	mov	ecx, 33
	lea	rdi, [rsp+1120]
	mov	rax, rbx
	rep stosq
	mov	QWORD [rsp+1376], 1
	mov	QWORD [rsp+1120], 1
	jmp	.L231
.L273:
	sub	rbp, 1
	mov	rax, QWORD [r15+rbp*8]
	mov	rdx, QWORD [r14+rbp*8]
	cmp	rax, rdx
	jne	.L362
.L270:
	test	rbp, rbp
	jne	.L273
	jmp	.L271
.L362:
	cmp	rdx, rax
	jb	.L271
.L272:
	mov	rcx, QWORD [rsp+16]
	mov	rdx, r14
	mov	rsi, r15
	lea	rdi, [rsp+1120]
	call	inverse_mod_sub.part.0
	mov	r11d, 32
	lea	r8, [rsp+304]
	jmp	.L274
.L361:
	cmp	rcx, rdx
.L349:
	jb	.L267
	mov	rsi, r8
	lea	rdi, [rsp+1120]
	mov	rdx, r13
	call	inverse_sub_raw
	lea	r8, [rsp+304]
	mov	ecx, 33
	lea	rsi, [rsp+1120]
	mov	rdi, r8
	rep movsq
	cmp	rbp, r12
	je	.L277
	jnb	.L363
.L278:
	mov	rdx, r15
	mov	rsi, r14
	lea	rdi, [rsp+1120]
	call	inverse_sub_raw
	lea	r8, [rsp+304]
	mov	r11d, 32
.L281:
	mov	ecx, 33
	mov	rdi, r14
	lea	rsi, [rsp+1120]
	rep movsq
	jmp	.L230
.L280:
	sub	r12, 1
	mov	rax, QWORD [r14+r12*8]
	mov	rdx, QWORD [r15+r12*8]
	cmp	rax, rdx
	jne	.L364
.L277:
	test	r12, r12
	jne	.L280
	jmp	.L278
.L363:
	mov	rcx, QWORD [rsp+16]
	mov	rdx, r15
	mov	rsi, r14
	lea	rdi, [rsp+1120]
	call	inverse_mod_sub.part.0
	mov	r11d, 32
	lea	r8, [rsp+304]
	jmp	.L281
.L351:
	cmp	rdx, 32
	jne	.L289
	jmp	.L292
.L364:
	cmp	rdx, rax
	jb	.L278
	jmp	.L363
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
	jne	.L411
	mov	rax, QWORD [rsp+528]
	mov	rdx, QWORD [rsp+800]
	cmp	rax, rdx
	je	.L391
	cmp	rdx, rax
	jnb	.L394
.L392:
	mov	ecx, 34
	xor	eax, eax
	mov	rdi, rbx
	mov	rdx, r9
	rep stosq
	mov	rsi, r10
	mov	rdi, rbx
	call	inverse_sub_raw
.L393:
	mov	rdx, QWORD [rbx+256]
	mov	eax, 32
	mov	DWORD [rbx+264], ebp
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L397
.L413:
	cmp	QWORD [rbx-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L412
	mov	rdx, rax
.L397:
	test	rdx, rdx
	jne	.L413
	mov	ecx, 32
	mov	rdi, rbx
	mov	rax, rdx
	rep stosq
	mov	QWORD [rbx+256], 0
	mov	DWORD [rbx+264], 0
.L365:
	add	rsp, 824
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	ret
.L395:
	sub	rax, 1
	mov	rdx, QWORD [r10+rax*8]
	mov	rcx, QWORD [r9+rax*8]
	cmp	rdx, rcx
	jne	.L414
.L391:
	test	rax, rax
	jne	.L395
	jmp	.L392
.L411:
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
	je	.L367
	xor	edx, edx
	test	r12, r12
	jne	.L378
	xor	eax, eax
.L384:
	cmp	rax, r11
	jnb	.L379
.L417:
	add	rdx, QWORD [r9+rax*8]
	mov	QWORD [rsi+rax*8], rdx
	setc	dl
	add	rax, 1
	movzx	edx, dl
	cmp	rax, r8
	jb	.L384
.L383:
	mov	QWORD [rdi], rdx
	mov	ecx, 34
	xor	eax, eax
	mov	rdi, rbx
	rep stosq
	add	r8, rdx
	cmp	r8, 32
	ja	.L365
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
.L399:
	mov	DWORD [rbx+264], ebp
	jmp	.L388
.L416:
	cmp	QWORD [rbx-8+r8*8], 0
	lea	rax, [r8-1]
	jne	.L415
	mov	r8, rax
.L388:
	test	r8, r8
	jne	.L416
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
.L369:
	add	rcx, rdx
	setc	dl
	mov	QWORD [rsi+rax*8], rcx
	add	rax, 1
	movzx	edx, dl
	cmp	rax, r12
	jnb	.L375
.L378:
	mov	rcx, QWORD [r10+rax*8]
	cmp	rax, r11
	jnb	.L369
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
	jb	.L378
.L375:
	cmp	rax, r8
	jnb	.L383
	cmp	rax, r11
	jb	.L417
.L379:
	mov	QWORD [rsi+rax*8], rdx
	add	rax, 1
	xor	edx, edx
	cmp	rax, r8
	jb	.L384
	jmp	.L383
.L412:
	cmp	rdx, 32
	je	.L409
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
.L414:
	cmp	rcx, rdx
	jb	.L392
.L394:
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
	jmp	.L393
.L409:
	mov	QWORD [rbx+256], 32
	jmp	.L365
.L415:
	cmp	r8, 32
	je	.L409
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
	jmp	.L365
.L367:
	mov	QWORD [rdi], 0
	mov	ecx, 34
	mov	rdi, rbx
	mov	rax, r8
	rep stosq
	jmp	.L399
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
	jne	.L419
	cmp	QWORD [rbx+256], 0
	jne	.L420
.L425:
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L421
.L509:
	cmp	QWORD [rbp-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L508
	mov	rdx, rax
.L421:
	test	rdx, rdx
	jne	.L509
.L426:
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
.L430:
	mov	QWORD [rbp+256], rdx
	mov	rdx, QWORD [rbx+256]
	test	rdx, rdx
	je	.L429
	lea	rcx, [rbx-8+rdx*8]
	xor	eax, eax
.L432:
	mov	rsi, QWORD [rcx]
	mov	rdi, rcx
	sub	rcx, 8
	shld	rax, rsi, 63
	mov	QWORD [rcx+8], rax
	mov	rax, rsi
	and	eax, 1
	cmp	rbx, rdi
	jne	.L432
.L429:
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L431
.L511:
	cmp	QWORD [rbx-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L510
	mov	rdx, rax
.L431:
	test	rdx, rdx
	jne	.L511
.L433:
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
.L436:
	mov	QWORD [rbx+256], rdx
	mov	rdx, QWORD [rbp+256]
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L435
.L513:
	cmp	QWORD [rbp-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L512
	mov	rdx, rax
.L435:
	test	rdx, rdx
	jne	.L513
	mov	ecx, 32
	mov	rdi, rbp
	mov	rax, rdx
	rep stosq
	mov	QWORD [rbp+256], 0
	mov	DWORD [rbp+264], 0
.L467:
	mov	rdx, QWORD [rbx+256]
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L440
.L515:
	cmp	QWORD [rbx-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L514
	mov	rdx, rax
.L440:
	test	rdx, rdx
	jne	.L515
	mov	ecx, 32
	mov	rdi, rbx
	mov	rax, rdx
	rep stosq
	mov	QWORD [rbx+256], 0
	mov	DWORD [rbx+264], 0
.L442:
	mov	ecx, 1
.L418:
	add	rsp, 1088
	mov	eax, ecx
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	pop	r14
	ret
.L419:
	mov	rax, QWORD [rdi]
	and	eax, 1
	je	.L516
.L422:
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
	jne	.L443
	mov	rsi, QWORD [rsp+1072]
	test	rsi, rsi
	jne	.L517
	xor	r8d, r8d
.L444:
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L451
.L519:
	cmp	QWORD [r13-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L518
	mov	rdx, rax
.L451:
	test	rdx, rdx
	jne	.L519
.L450:
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
.L455:
	lea	rcx, [r12+rsi*8]
	xor	eax, eax
	test	rsi, rsi
	je	.L456
.L457:
	mov	rsi, QWORD [rcx-8]
	sub	rcx, 8
	shld	rax, rsi, 63
	mov	QWORD [rcx], rax
	mov	rax, rsi
	and	eax, 1
	cmp	r12, rcx
	jne	.L457
	test	r8, r8
	je	.L458
.L521:
	cmp	QWORD [r12-8+r8*8], 0
	lea	rax, [r8-1]
	jne	.L520
	mov	r8, rax
.L456:
	test	r8, r8
	jne	.L521
.L458:
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
	jmp	.L460
.L523:
	cmp	QWORD [r13-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L522
	mov	rdx, rax
.L460:
	test	rdx, rdx
	jne	.L523
	mov	ecx, 32
	mov	rdi, r13
	mov	rax, rdx
	mov	QWORD [rsp+800], 0
	rep stosq
	mov	DWORD [rsp+808], 0
	jmp	.L465
.L525:
	cmp	QWORD [r12-8+r8*8], 0
	lea	rax, [r8-1]
	jne	.L524
	mov	r8, rax
.L465:
	test	r8, r8
	jne	.L525
	mov	ecx, 32
	mov	rdi, r12
	mov	rax, r8
	rep stosq
	mov	QWORD [rsp+1072], 0
	mov	DWORD [rsp+1080], 0
.L468:
	mov	ecx, 34
	mov	rdi, rbp
	mov	rsi, r13
	rep movsq
	mov	ecx, 34
	mov	rdi, rbx
	mov	rsi, r12
	rep movsq
	jmp	.L442
.L420:
	test	BYTE [rbx], 1
	jne	.L422
	jmp	.L425
.L516:
	cmp	QWORD [rbx+256], 0
	jne	.L526
.L423:
	lea	rcx, [rbp-8+rdx*8]
.L424:
	mov	rsi, QWORD [rcx]
	mov	rdi, rcx
	sub	rcx, 8
	shld	rax, rsi, 63
	mov	QWORD [rcx+8], rax
	mov	rax, rsi
	and	eax, 1
	cmp	rbp, rdi
	jne	.L424
	jmp	.L425
.L512:
	cmp	rdx, 32
	je	.L527
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
	jmp	.L467
.L510:
	cmp	rdx, 32
	jne	.L433
	jmp	.L436
.L508:
	cmp	rdx, 32
	jne	.L426
	jmp	.L430
.L514:
	cmp	rdx, 32
	je	.L528
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
	jmp	.L442
.L443:
	mov	rax, QWORD [rsp+544]
	xor	ecx, ecx
	and	eax, 1
	jne	.L418
	mov	rsi, QWORD [rsp+1072]
	test	rsi, rsi
	jne	.L447
	xor	r8d, r8d
.L449:
	lea	rcx, [r13+0+rdx*8]
.L448:
	mov	rdi, QWORD [rcx-8]
	sub	rcx, 8
	shld	rax, rdi, 63
	mov	QWORD [rcx], rax
	mov	rax, rdi
	and	eax, 1
	cmp	rcx, r13
	jne	.L448
	jmp	.L444
.L526:
	test	BYTE [rbx], 1
	je	.L423
	jmp	.L422
.L517:
	xor	ecx, ecx
	test	BYTE [rsp+816], 1
	jne	.L418
	mov	r8d, 32
	cmp	rsi, r8
	cmovbe	r8, rsi
	jmp	.L444
.L528:
	mov	QWORD [rbx+256], 32
	jmp	.L442
.L527:
	mov	QWORD [rbp+256], 32
	jmp	.L467
.L518:
	cmp	rdx, 32
	jne	.L450
	jmp	.L455
.L520:
	cmp	r8, 32
	jne	.L458
	jmp	.L460
.L522:
	cmp	rdx, 32
	je	.L529
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
	jmp	.L465
.L524:
	cmp	r8, 32
	je	.L530
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
	jmp	.L468
.L447:
	test	BYTE [rsp+816], 1
	jne	.L418
	mov	r8d, 32
	cmp	rsi, r8
	cmovbe	r8, rsi
	jmp	.L449
.L530:
	mov	QWORD [rsp+1072], 32
	jmp	.L468
.L529:
	mov	QWORD [rsp+800], 32
	jmp	.L465
global bignum_inverse
bignum_inverse:
    ; P1 fast dispatch: no stack frame, no callee-saved register traffic.
    test rdi, rdi
    jz .Lgeneric_entry
    test rsi, rsi
    jz .Lgeneric_entry
    test rdx, rdx
    jz .Lgeneric_entry
    cmp rdi, rsi
    jae .Lcheck_a_after
    mov rax, rsi
    sub rax, rdi
    cmp rax, 264
    jb .Lgeneric_entry
    jmp .Lcheck_mod_overlap
.Lcheck_a_after:
    mov rax, rdi
    sub rax, rsi
    cmp rax, 264
    jb .Lgeneric_entry
.Lcheck_mod_overlap:
    cmp rdi, rdx
    jae .Lcheck_mod_after
    mov rax, rdx
    sub rax, rdi
    cmp rax, 264
    jb .Lgeneric_entry
    jmp .Lcheck_lengths
.Lcheck_mod_after:
    mov rax, rdi
    sub rax, rdx
    cmp rax, 264
    jb .Lgeneric_entry
.Lcheck_lengths:
    ; Multiword special case: 2^{-1} mod m = (m+1)/2 for odd m.
    cmp qword [rsi+256], 1
    jne .Lcheck_oneword
    cmp qword [rsi], 2
    jne .Lcheck_oneword
    mov r10, [rdx+256]
    cmp r10, 2
    jb .Lcheck_oneword
    cmp r10, 32
    ja .Lgeneric_entry
    mov r9, [rdx+r10*8-8]
    test r9b, 1
    jz .Lcheck_oneword
    mov r8, rdi
    mov rsi, rdx
    mov rdi, r8
    mov rcx, r10
    rep movsq
    xor r11d, r11d
    mov r11b, 1
    xor eax, eax
.Lfast_add_one:
    add [r8+rax*8], r11
    setc r11b
    inc rax
    cmp rax, r10
    jb .Lfast_add_one
    mov rax, r10
    dec rax
    mov rcx, r11
.Lfast_shift_right:
    mov r11, [r8+rax*8]
    mov rdx, r11
    shrd r11, rcx, 1
    mov [r8+rax*8], r11
    mov rcx, rdx
    dec rax
    jns .Lfast_shift_right
    mov [r8+256], r10
    lea rdi, [r8+r10*8]
    mov rcx, 32
    sub rcx, r10
    xor eax, eax
    rep stosq
    xor eax, eax
    ret
.Lcheck_oneword:
    cmp qword [rsi+256], 1
    jne .Lgeneric_entry
    cmp qword [rdx+256], 1
    jne .Lgeneric_entry
    mov r9, [rdx]
    cmp r9, 3
    jb .Lgeneric_entry
    test r9b, 1
    jz .Lgeneric_entry
    mov r8, rdi
    mov rax, [rsi]
    xor edx, edx
    div r9
    mov r10, rdx
    mov r11, r9
    mov eax, 1
    xor ecx, ecx
.Lfast_loop:
    test r10, r10
    jz .Lfast_no_inverse
    test r11, r11
    jz .Lfast_no_inverse
    cmp r10, 1
    je .Lfast_u_one
    cmp r11, 1
    je .Lfast_v_one
.Lfast_half_u:
    test r10b, 1
    jnz .Lfast_half_v
    shr r10, 1
    test al, 1
    jnz .Lfast_half_x_odd
    shr rax, 1
    jmp .Lfast_half_u
.Lfast_half_x_odd:
    xor edx, edx
    add rax, r9
    adc rdx, 0
    shrd rax, rdx, 1
    shr rdx, 1
    xor edx, edx
    jmp .Lfast_half_u
.Lfast_half_v:
    test r11b, 1
    jnz .Lfast_compare
    shr r11, 1
    test cl, 1
    jnz .Lfast_half_y_odd
    shr rcx, 1
    jmp .Lfast_half_v
.Lfast_half_y_odd:
    xor edx, edx
    add rcx, r9
    adc rdx, 0
    shrd rcx, rdx, 1
    shr rdx, 1
    xor edx, edx
    jmp .Lfast_half_v
.Lfast_compare:
    cmp r10, r11
    jb .Lfast_v_minus_u
    sub r10, r11
    cmp rax, rcx
    jae .Lfast_x_minus_y
    sub rax, rcx
    add rax, r9
    jmp .Lfast_loop
.Lfast_x_minus_y:
    sub rax, rcx
    jmp .Lfast_loop
.Lfast_v_minus_u:
    sub r11, r10
    cmp rcx, rax
    jae .Lfast_y_minus_x
    sub rcx, rax
    add rcx, r9
    jmp .Lfast_loop
.Lfast_y_minus_x:
    sub rcx, rax
    jmp .Lfast_loop
.Lfast_u_one:
    ; x is already the output coefficient.
    jmp .Lfast_publish
.Lfast_v_one:
    mov rax, rcx
.Lfast_publish:
    xor edx, edx
    div r9
    mov [r8], rdx
    mov qword [r8+256], 1
    xor eax, eax
    ret
.Lfast_no_inverse:
    mov eax, -5
    ret
.Lgeneric_entry:
    jmp bignum_inverse_generic

global bignum_inverse_generic
bignum_inverse_generic:
	endbr64
	push	r15
	push	r14
	push	r13
	push	r12
	push	rbp
	push	rbx
	sub	rsp, 4096
	or	QWORD [rsp], 0
	sub	rsp, 856
	test	rsi, rsi
	sete	r9b
	test	rdx, rdx
	sete	al
	or	r9d, eax
	test	rdi, rdi
	sete	al
	or	r9b, al
	jne	.L686
	mov	r11, rdi
	mov	r8, rdx
	cmp	rdi, rsi
	jb	.L891
	mov	rax, rdi
	sub	rax, rsi
	cmp	rax, 263
	setbe	al
	movzx	eax, al
.L534:
	test	eax, eax
	jne	.L709
	cmp	r11, r8
	jnb	.L535
	mov	rax, r8
	xor	r12d, r12d
	sub	rax, r11
	cmp	rax, 263
	setbe	r12b
.L536:
	test	r12d, r12d
	jne	.L709
	mov	rdx, QWORD [rsi+256]
	cmp	rdx, 32
	ja	.L688
	mov	rax, QWORD [r8+256]
	mov	QWORD [rsp], rax
	cmp	rax, 32
	ja	.L688
	lea	r13, [rsp+64]
	lea	r15, [rsp+336]
	mov	ecx, 33
	mov	rdi, r13
	rep movsq
	mov	ecx, 33
	mov	rdi, r15
	mov	rsi, r8
	rep movsq
	jmp	.L538
.L893:
	cmp	QWORD [r13-8+rdx*8], 0
	lea	rax, [rdx-1]
	jne	.L892
	mov	rdx, rax
.L538:
	test	rdx, rdx
	jne	.L893
.L537:
	mov	ecx, 32
	lea	rsi, [r13+0+rdx*8]
	sub	rcx, rdx
	mov	rdi, rsi
	sal	rcx, 3
	mov	eax, ecx
	sub	ecx, 1
	mov	QWORD [rsi-8+rax], 0
	shr	ecx, 3
	xor	eax, eax
	rep stosq
.L541:
	mov	QWORD [rsp+320], rdx
	mov	rax, QWORD [rsp]
	jmp	.L540
.L895:
	cmp	QWORD [r15-8+rax*8], 0
	lea	rdx, [rax-1]
	jne	.L894
	mov	rax, rdx
.L540:
	test	rax, rax
	jne	.L895
	mov	r12d, -4
.L531:
	add	rsp, 4952
	mov	eax, r12d
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	ret
.L891:
	mov	rax, rsi
	sub	rax, rdi
	cmp	rax, 263
	setbe	al
	movzx	eax, al
	jmp	.L534
.L709:
	mov	r12d, -3
	jmp	.L531
.L535:
	mov	rax, r11
	xor	r12d, r12d
	sub	rax, r8
	cmp	rax, 263
	setbe	r12b
	jmp	.L536
.L894:
	mov	QWORD [rsp], rax
	cmp	rax, 32
	je	.L896
	mov	ecx, 32
	lea	rdx, [r15+rax*8]
	mov	r10, rax
	sub	rcx, rax
	mov	rdi, rdx
	xor	eax, eax
	sal	rcx, 3
	mov	esi, ecx
	sub	ecx, 1
	mov	QWORD [rdx-8+rsi], 0
	shr	ecx, 3
	mov	rsi, r15
	lea	rdx, [rsp+880]
	rep stosq
	lea	rdi, [rsp+608]
	mov	QWORD [rsp+592], r10
	mov	ecx, 33
	mov	QWORD [rsp+8], rdi
	rep movsq
	mov	ecx, 33
	mov	rdi, rdx
	rep stosq
	mov	QWORD [rsp+1136], 1
	mov	QWORD [rsp+880], 1
	cmp	r10, 1
	jne	.L680
	cmp	QWORD [rsp+336], 1
	ja	.L544
.L574:
	mov	r12d, -5
	jmp	.L531
.L896:
	lea	rdi, [rsp+608]
	mov	eax, 33
	mov	rsi, r15
	mov	QWORD [rsp+592], 32
	mov	rcx, rax
	mov	QWORD [rsp+8], rdi
	lea	rdx, [rsp+880]
	rep movsq
	mov	rdi, rdx
	mov	rax, rcx
	mov	ecx, 33
	rep stosq
	mov	QWORD [rsp+1136], 1
	mov	QWORD [rsp+880], 1
.L680:
	mov	rdx, QWORD [rsp+8]
	mov	rsi, r13
	mov	rdi, r13
	mov	QWORD [rsp+24], r11
	mov	BYTE [rsp+16], r9b
	call	inverse_reduce
	mov	r14, QWORD [rsp+320]
	test	r14, r14
	je	.L574
	mov	rax, QWORD [rsp]
	mov	ecx, 33
	mov	rsi, r13
	mov	r11, QWORD [rsp+24]
	lea	rdi, [rsp+1424]
	movzx	r9d, BYTE [rsp+16]
	cmp	rax, 7
	mov	QWORD [rsp+32], rdi
	rep movsq
	jbe	.L692
	pxor	xmm4, xmm4
	pxor	xmm5, xmm5
	shr	rax, 1
	movdqa	xmm6, oword [rel .LC1]
	movdqa	xmm0, xmm4
	movdqa	xmm3, xmm4
	movdqa	xmm2, oword [rel .LC0]
	pcmpeqd	xmm0, oword [rsp+608]
	pcmpeqd	xmm3, oword [rsp+624]
	pcmpeqd	xmm0, xmm5
	pcmpeqd	xmm3, xmm5
	pshufd	xmm1, xmm0, 177
	por	xmm1, xmm0
	pshufd	xmm0, xmm3, 177
	por	xmm0, xmm3
	movdqa	xmm3, oword [rel .LC3]
	pand	xmm6, xmm1
	pand	xmm2, xmm1
	movdqa	xmm7, xmm0
	pand	xmm1, oword [rel .LC2]
	psubq	xmm2, xmm0
	pand	xmm3, xmm0
	pandn	xmm7, xmm6
	movdqa	xmm6, xmm0
	pandn	xmm6, oword [rsp+608]
	por	xmm7, xmm3
	movdqa	xmm3, oword [rsp+624]
	pand	xmm3, xmm0
	por	xmm6, xmm3
	movdqa	xmm3, oword [rel .LC4]
	pand	xmm3, xmm0
	pandn	xmm0, xmm1
	movdqa	xmm1, xmm0
	por	xmm1, xmm3
	movdqa	xmm3, xmm4
	pcmpeqd	xmm3, oword [rsp+640]
	pcmpeqd	xmm3, xmm5
	pshufd	xmm0, xmm3, 177
	por	xmm0, xmm3
	movdqa	xmm3, oword [rel .LC5]
	movdqa	xmm8, xmm0
	psubq	xmm2, xmm0
	pandn	xmm8, xmm7
	pand	xmm3, xmm0
	movdqa	xmm7, xmm8
	movdqa	xmm8, xmm0
	por	xmm7, xmm3
	pandn	xmm8, xmm6
	movdqa	xmm3, oword [rsp+640]
	pand	xmm3, xmm0
	por	xmm8, xmm3
	movdqa	xmm3, oword [rel .LC6]
	pand	xmm3, xmm0
	pandn	xmm0, xmm1
	movdqa	xmm1, xmm0
	por	xmm1, xmm3
	movdqa	xmm3, xmm4
	pcmpeqd	xmm3, oword [rsp+656]
	pcmpeqd	xmm3, xmm5
	pshufd	xmm0, xmm3, 177
	por	xmm0, xmm3
	movdqa	xmm3, oword [rel .LC7]
	movdqa	xmm6, xmm0
	psubq	xmm2, xmm0
	pand	xmm3, xmm0
	pandn	xmm6, xmm7
	movdqa	xmm7, oword [rsp+656]
	por	xmm6, xmm3
	movdqa	xmm3, xmm0
	pand	xmm7, xmm0
	pandn	xmm3, xmm8
	por	xmm3, xmm7
	movdqa	xmm7, oword [rel .LC8]
	pand	xmm7, xmm0
	pandn	xmm0, xmm1
	por	xmm0, xmm7
	cmp	rax, 4
	je	.L547
	movdqa	xmm7, xmm4
	pcmpeqd	xmm7, oword [rsp+672]
	pcmpeqd	xmm7, xmm5
	pshufd	xmm1, xmm7, 177
	por	xmm1, xmm7
	movdqa	xmm7, oword [rel .LC9]
	movdqa	xmm8, xmm1
	psubq	xmm2, xmm1
	pandn	xmm8, xmm6
	pand	xmm7, xmm1
	movdqa	xmm6, xmm8
	movdqa	xmm8, xmm1
	por	xmm6, xmm7
	pandn	xmm8, xmm3
	movdqa	xmm7, oword [rsp+672]
	movdqa	xmm3, xmm8
	pand	xmm7, xmm1
	por	xmm3, xmm7
	movdqa	xmm7, oword [rel .LC10]
	pand	xmm7, xmm1
	pandn	xmm1, xmm0
	por	xmm1, xmm7
	movdqa	xmm0, xmm1
	cmp	rax, 5
	je	.L547
	movdqa	xmm7, xmm4
	pcmpeqd	xmm7, oword [rsp+688]
	pcmpeqd	xmm7, xmm5
	pshufd	xmm1, xmm7, 177
	por	xmm1, xmm7
	movdqa	xmm7, oword [rel .LC11]
	movdqa	xmm8, xmm1
	psubq	xmm2, xmm1
	pandn	xmm8, xmm6
	pand	xmm7, xmm1
	movdqa	xmm6, xmm8
	movdqa	xmm8, xmm1
	por	xmm6, xmm7
	pandn	xmm8, xmm3
	movdqa	xmm7, oword [rsp+688]
	movdqa	xmm3, xmm8
	pand	xmm7, xmm1
	por	xmm3, xmm7
	movdqa	xmm7, oword [rel .LC12]
	pand	xmm7, xmm1
	pandn	xmm1, xmm0
	por	xmm1, xmm7
	movdqa	xmm0, xmm1
	cmp	rax, 6
	je	.L547
	movdqa	xmm7, xmm4
	pcmpeqd	xmm7, oword [rsp+704]
	pcmpeqd	xmm7, xmm5
	pshufd	xmm1, xmm7, 177
	por	xmm1, xmm7
	movdqa	xmm7, oword [rel .LC13]
	movdqa	xmm8, xmm1
	psubq	xmm2, xmm1
	pandn	xmm8, xmm6
	pand	xmm7, xmm1
	movdqa	xmm6, xmm8
	movdqa	xmm8, xmm1
	por	xmm6, xmm7
	pandn	xmm8, xmm3
	movdqa	xmm7, oword [rsp+704]
	movdqa	xmm3, xmm8
	pand	xmm7, xmm1
	por	xmm3, xmm7
	movdqa	xmm7, oword [rel .LC14]
	pand	xmm7, xmm1
	pandn	xmm1, xmm0
	por	xmm1, xmm7
	movdqa	xmm0, xmm1
	cmp	rax, 7
	je	.L547
	movdqa	xmm7, xmm4
	pcmpeqd	xmm7, oword [rsp+720]
	pcmpeqd	xmm7, xmm5
	pshufd	xmm1, xmm7, 177
	por	xmm1, xmm7
	movdqa	xmm7, oword [rel .LC15]
	movdqa	xmm8, xmm1
	psubq	xmm2, xmm1
	pandn	xmm8, xmm6
	pand	xmm7, xmm1
	movdqa	xmm6, xmm8
	movdqa	xmm8, xmm1
	por	xmm6, xmm7
	pandn	xmm8, xmm3
	movdqa	xmm7, oword [rsp+720]
	movdqa	xmm3, xmm8
	pand	xmm7, xmm1
	por	xmm3, xmm7
	movdqa	xmm7, oword [rel .LC16]
	pand	xmm7, xmm1
	pandn	xmm1, xmm0
	por	xmm1, xmm7
	movdqa	xmm0, xmm1
	cmp	rax, 8
	je	.L547
	movdqa	xmm7, xmm4
	pcmpeqd	xmm7, oword [rsp+736]
	pcmpeqd	xmm7, xmm5
	pshufd	xmm1, xmm7, 177
	por	xmm1, xmm7
	movdqa	xmm7, oword [rel .LC17]
	movdqa	xmm8, xmm1
	psubq	xmm2, xmm1
	pandn	xmm8, xmm6
	pand	xmm7, xmm1
	movdqa	xmm6, xmm8
	movdqa	xmm8, xmm1
	por	xmm6, xmm7
	pandn	xmm8, xmm3
	movdqa	xmm7, oword [rsp+736]
	movdqa	xmm3, xmm8
	pand	xmm7, xmm1
	por	xmm3, xmm7
	movdqa	xmm7, oword [rel .LC18]
	pand	xmm7, xmm1
	pandn	xmm1, xmm0
	por	xmm1, xmm7
	movdqa	xmm0, xmm1
	cmp	rax, 9
	je	.L547
	movdqa	xmm7, xmm4
	pcmpeqd	xmm7, oword [rsp+752]
	pcmpeqd	xmm7, xmm5
	pshufd	xmm1, xmm7, 177
	por	xmm1, xmm7
	movdqa	xmm7, oword [rel .LC19]
	movdqa	xmm8, xmm1
	psubq	xmm2, xmm1
	pandn	xmm8, xmm6
	pand	xmm7, xmm1
	movdqa	xmm6, xmm8
	movdqa	xmm8, xmm1
	por	xmm6, xmm7
	pandn	xmm8, xmm3
	movdqa	xmm7, oword [rsp+752]
	movdqa	xmm3, xmm8
	pand	xmm7, xmm1
	por	xmm3, xmm7
	movdqa	xmm7, oword [rel .LC20]
	pand	xmm7, xmm1
	pandn	xmm1, xmm0
	por	xmm1, xmm7
	movdqa	xmm0, xmm1
	cmp	rax, 10
	je	.L547
	pcmpeqd	xmm4, oword [rsp+768]
	pcmpeqd	xmm4, xmm5
	pshufd	xmm1, xmm4, 177
	por	xmm1, xmm4
	movdqa	xmm4, oword [rel .LC21]
	movdqa	xmm5, xmm1
	psubq	xmm2, xmm1
	pand	xmm4, xmm1
	pandn	xmm5, xmm6
	por	xmm5, xmm4
	movdqa	xmm4, oword [rsp+768]
	movdqa	xmm6, xmm5
	movdqa	xmm5, xmm1
	pand	xmm4, xmm1
	pandn	xmm5, xmm3
	por	xmm5, xmm4
	movdqa	xmm4, oword [rel .LC22]
	movdqa	xmm3, xmm5
	pand	xmm4, xmm1
	pandn	xmm1, xmm0
	por	xmm1, xmm4
	movdqa	xmm0, xmm1
	cmp	rax, 11
	je	.L547
	pxor	xmm4, xmm4
	pxor	xmm5, xmm5
	movdqa	xmm7, xmm4
	pcmpeqd	xmm7, oword [rsp+784]
	pcmpeqd	xmm7, xmm5
	pshufd	xmm1, xmm7, 177
	por	xmm1, xmm7
	movdqa	xmm7, oword [rel .LC23]
	movdqa	xmm8, xmm1
	psubq	xmm2, xmm1
	pandn	xmm8, xmm6
	pand	xmm7, xmm1
	movdqa	xmm6, xmm8
	movdqa	xmm8, xmm1
	por	xmm6, xmm7
	pandn	xmm8, xmm3
	movdqa	xmm7, oword [rsp+784]
	movdqa	xmm3, xmm8
	pand	xmm7, xmm1
	por	xmm3, xmm7
	movdqa	xmm7, oword [rel .LC24]
	pand	xmm7, xmm1
	pandn	xmm1, xmm0
	por	xmm1, xmm7
	movdqa	xmm0, xmm1
	cmp	rax, 12
	je	.L547
	movdqa	xmm7, xmm4
	pcmpeqd	xmm7, oword [rsp+800]
	pcmpeqd	xmm7, xmm5
	pshufd	xmm1, xmm7, 177
	por	xmm1, xmm7
	movdqa	xmm7, oword [rel .LC25]
	movdqa	xmm8, xmm1
	psubq	xmm2, xmm1
	pandn	xmm8, xmm6
	pand	xmm7, xmm1
	movdqa	xmm6, xmm8
	movdqa	xmm8, xmm1
	por	xmm6, xmm7
	pandn	xmm8, xmm3
	movdqa	xmm7, oword [rsp+800]
	movdqa	xmm3, xmm8
	pand	xmm7, xmm1
	por	xmm3, xmm7
	movdqa	xmm7, oword [rel .LC26]
	pand	xmm7, xmm1
	pandn	xmm1, xmm0
	por	xmm1, xmm7
	movdqa	xmm0, xmm1
	cmp	rax, 13
	je	.L547
	movdqa	xmm7, xmm4
	pcmpeqd	xmm7, oword [rsp+816]
	pcmpeqd	xmm7, xmm5
	pshufd	xmm1, xmm7, 177
	por	xmm1, xmm7
	movdqa	xmm7, oword [rel .LC27]
	movdqa	xmm8, xmm1
	psubq	xmm2, xmm1
	pandn	xmm8, xmm6
	pand	xmm7, xmm1
	movdqa	xmm6, xmm8
	movdqa	xmm8, xmm1
	por	xmm6, xmm7
	pandn	xmm8, xmm3
	movdqa	xmm7, oword [rsp+816]
	movdqa	xmm3, xmm8
	pand	xmm7, xmm1
	por	xmm3, xmm7
	movdqa	xmm7, oword [rel .LC28]
	pand	xmm7, xmm1
	pandn	xmm1, xmm0
	por	xmm1, xmm7
	movdqa	xmm0, xmm1
	cmp	rax, 14
	je	.L547
	movdqa	xmm7, xmm4
	pcmpeqd	xmm7, oword [rsp+832]
	pcmpeqd	xmm7, xmm5
	pshufd	xmm1, xmm7, 177
	por	xmm1, xmm7
	movdqa	xmm7, oword [rel .LC29]
	movdqa	xmm8, xmm1
	psubq	xmm2, xmm1
	pandn	xmm8, xmm6
	pand	xmm7, xmm1
	movdqa	xmm6, xmm8
	movdqa	xmm8, xmm1
	por	xmm6, xmm7
	pandn	xmm8, xmm3
	movdqa	xmm7, oword [rsp+832]
	movdqa	xmm3, xmm8
	pand	xmm7, xmm1
	por	xmm3, xmm7
	movdqa	xmm7, oword [rel .LC30]
	pand	xmm7, xmm1
	pandn	xmm1, xmm0
	por	xmm1, xmm7
	movdqa	xmm0, xmm1
	cmp	rax, 16
	jne	.L547
	pcmpeqd	xmm4, oword [rsp+848]
	pcmpeqd	xmm4, xmm5
	pshufd	xmm1, xmm4, 177
	por	xmm1, xmm4
	movdqa	xmm4, oword [rel .LC31]
	movdqa	xmm5, xmm1
	psubq	xmm2, xmm1
	pand	xmm4, xmm1
	pandn	xmm5, xmm6
	por	xmm5, xmm4
	movdqa	xmm4, oword [rsp+848]
	movdqa	xmm6, xmm5
	movdqa	xmm5, xmm1
	pand	xmm4, xmm1
	pandn	xmm5, xmm3
	por	xmm5, xmm4
	movdqa	xmm4, oword [rel .LC32]
	movdqa	xmm3, xmm5
	pand	xmm4, xmm1
	pandn	xmm1, xmm0
	por	xmm1, xmm4
	movdqa	xmm0, xmm1
.L547:
	movhlps	xmm5, xmm0
	movq	rdx, xmm0
	movhlps	xmm4, xmm3
	mov	rsi, QWORD [rsp]
	movq	rax, xmm5
	movdqa	xmm0, xmm2
	movhlps	xmm5, xmm6
	cmp	rdx, rax
	psrldq	xmm0, 8
	movq	rax, xmm3
	setb	cl
	movq	rdx, xmm4
	paddq	xmm0, xmm2
	test	cl, cl
	movq	rcx, xmm5
	cmove	rdx, rax
	movq	rax, xmm6
	cmove	rcx, rax
	movq	rax, xmm0
	test	sil, 1
	je	.L548
	and	rsi, -2
.L546:
	mov	rdi, QWORD [rsp+608+rsi*8]
	test	rdi, rdi
	jne	.L897
.L549:
	mov	r8, QWORD [rsp]
	lea	rdi, [rsi+1]
	cmp	rdi, r8
	jnb	.L548
	mov	r8, QWORD [rsp+608+rdi*8]
	test	r8, r8
	jne	.L898
.L550:
	mov	r8, QWORD [rsp]
	lea	rdi, [rsi+2]
	cmp	rdi, r8
	jnb	.L548
	mov	r8, QWORD [rsp+608+rdi*8]
	test	r8, r8
	jne	.L899
.L551:
	mov	r8, QWORD [rsp]
	lea	rdi, [rsi+3]
	cmp	rdi, r8
	jnb	.L548
	mov	r8, QWORD [rsp+608+rdi*8]
	test	r8, r8
	jne	.L900
.L552:
	mov	r8, QWORD [rsp]
	lea	rdi, [rsi+4]
	cmp	rdi, r8
	jnb	.L548
	mov	r8, QWORD [rsp+608+rdi*8]
	test	r8, r8
	jne	.L901
.L553:
	mov	r8, QWORD [rsp]
	lea	rdi, [rsi+5]
	cmp	rdi, r8
	jnb	.L548
	mov	r8, QWORD [rsp+608+rdi*8]
	test	r8, r8
	je	.L554
	add	rax, 1
	mov	rdx, r8
	mov	rcx, rdi
.L554:
	mov	rdi, QWORD [rsp]
	add	rsi, 6
	cmp	rsi, rdi
	jnb	.L548
	mov	rdi, QWORD [rsp+608+rsi*8]
	test	rdi, rdi
	je	.L548
	add	rax, 1
	mov	rdx, rdi
	mov	rcx, rsi
.L548:
	cmp	rax, 1
	jne	.L557
	lea	rax, [rdx-1]
	test	rax, rdx
	jne	.L557
	shr	rdx, 1
	je	.L558
	bsr	rdx, rdx
	add	edx, 1
	movsxd rdx, edx
.L558:
	sal	rcx, 6
	add	rdx, rcx
	je	.L557
	mov	QWORD [rsp], r11
	test	BYTE [rsp+64], 1
	je	.L574
	lea	rax, [rdx-1]
	cmp	rax, 2047
	ja	.L574
	lea	rbp, [rsp+1152]
	mov	rsi, r13
	mov	rdi, rbp
	call	inverse_mod2_newton.part.0
	mov	r11, QWORD [rsp]
	test	eax, eax
	je	.L574
.L634:
	mov	ecx, 33
	mov	rdi, r11
	mov	rsi, rbp
	rep movsq
	jmp	.L531
.L557:
	test	BYTE [rsp+608], 1
	jne	.L902
	mov	rsi, QWORD [rsp+8]
	mov	ecx, 33
	xor	r10d, r10d
	xor	eax, eax
	lea	r8, [rsp+1696]
	mov	rdi, r8
	rep movsq
	mov	esi, 32
	mov	rbp, QWORD [rsp+1952]
	test	rbp, rbp
	je	.L562
.L561:
	mov	rdx, QWORD [rsp+1696]
	test	dl, 1
	jne	.L903
	shr	rdx, 1
	cmp	rbp, 1
	je	.L563
	lea	rcx, [rsp+1704]
	lea	r9, [r8+rbp*8]
	mov	rbx, rdx
.L564:
	mov	rdi, QWORD [rcx]
	add	rcx, 8
	mov	rdx, rdi
	sal	rdx, 63
	or	rdx, rbx
	mov	rbx, rdi
	mov	QWORD [rcx-16], rdx
	shr	rbx, 1
	cmp	rcx, r9
	jne	.L564
	mov	rdx, rbx
.L563:
	mov	QWORD [rsp+1688+rbp*8], rdx
	mov	rdx, rbp
.L679:
	mov	rbp, rdx
	lea	rdx, [rdx-1]
	cmp	QWORD [r8-8+rbp*8], 0
	jne	.L904
	test	rdx, rdx
	jne	.L679
	mov	ecx, 32
	mov	rdi, r8
	mov	rax, rdx
	mov	QWORD [rsp+1952], 0
	rep stosq
.L562:
	xor	eax, eax
	mov	ecx, 34
	mov	rbp, QWORD [rsp]
	mov	QWORD [rsp+56], r11
	lea	rdi, [rsp+3328]
	mov	rbx, QWORD [rsp+32]
	mov	DWORD [rsp+52], r12d
	mov	r12, r14
	rep stosq
	lea	rdi, [rsp+3600]
	mov	ecx, 34
	mov	r14, rbp
	mov	QWORD [rsp+24], rdi
	rep stosq
	lea	rdi, [rsp+3872]
	mov	ecx, 34
	mov	QWORD [rsp+3584], 1
	mov	QWORD [rsp+16], rdi
	rep stosq
	lea	rdi, [rsp+4144]
	mov	ecx, 34
	mov	QWORD [rsp+3328], 1
	mov	QWORD [rsp+40], rdi
	rep stosq
	mov	QWORD [rsp+4400], 1
	mov	QWORD [rsp+4144], 1
.L637:
	test	r14, r14
	je	.L662
	cmp	r12, 1
	jne	.L663
	cmp	QWORD [rsp+64], 1
	jne	.L663
	mov	r12d, DWORD [rsp+52]
	mov	r11, QWORD [rsp+56]
.L664:
	cmp	QWORD [rsp+64], 1
	lea	rbp, [rsp+3328]
	jne	.L661
.L666:
	mov	rdx, QWORD [rsp+8]
	lea	r13, [rsp+4416]
	mov	rsi, rbp
	mov	QWORD [rsp+16], r11
	mov	rdi, r13
	call	inverse_reduce
	mov	edx, DWORD [rbp+264]
	mov	r11, QWORD [rsp+16]
	lea	rbp, [rsp+1152]
	test	edx, edx
	je	.L667
	cmp	QWORD [rsp+4672], 0
	jne	.L905
.L667:
	mov	ecx, 33
	mov	rdi, rbp
	mov	rsi, r13
	rep movsq
.L668:
	mov	rdx, QWORD [rsp+1408]
	mov	eax, 32
	cmp	rdx, rax
	cmova	rdx, rax
	jmp	.L670
.L907:
	cmp	QWORD [rbp-8+rdx*8], 0
	lea	rsi, [rdx-1]
	jne	.L906
	mov	rdx, rsi
.L670:
	test	rdx, rdx
	jne	.L907
	mov	ecx, 32
	mov	rdi, rbp
	mov	rax, rdx
	mov	QWORD [rsp+1408], 0
	rep stosq
	jmp	.L634
.L892:
	cmp	rdx, 32
	jne	.L537
	jmp	.L541
.L897:
	add	rax, 1
	mov	rdx, rdi
	mov	rcx, rsi
	jmp	.L549
.L898:
	add	rax, 1
	mov	rdx, r8
	mov	rcx, rdi
	jmp	.L550
.L899:
	add	rax, 1
	mov	rdx, r8
	mov	rcx, rdi
	jmp	.L551
.L900:
	add	rax, 1
	mov	rdx, r8
	mov	rcx, rdi
	jmp	.L552
.L901:
	add	rax, 1
	mov	rdx, r8
	mov	rcx, rdi
	jmp	.L553
.L902:
	mov	rdx, QWORD [rsp+8]
	lea	rbp, [rsp+1152]
	mov	rsi, r13
	mov	QWORD [rsp], r11
	mov	rdi, rbp
	call	inverse_mod_odd
	mov	r11, QWORD [rsp]
	test	eax, eax
	jne	.L634
	jmp	.L574
.L663:
	cmp	r14, 1
	jne	.L665
	cmp	QWORD [rsp+336], 1
	jne	.L665
.L662:
	mov	r14, r12
	mov	r11, QWORD [rsp+56]
	mov	r12d, DWORD [rsp+52]
	cmp	r14, 1
	je	.L664
.L661:
	cmp	QWORD [rsp+592], 1
	jne	.L574
	cmp	QWORD [rsp+336], 1
	jne	.L574
	mov	rbp, QWORD [rsp+24]
	jmp	.L666
.L904:
	cmp	rbp, 32
	je	.L908
	mov	rdx, rsi
	lea	r9, [r8+rbp*8]
	add	r10, 1
	sub	rdx, rbp
	mov	rdi, r9
	sal	rdx, 3
	mov	ecx, edx
	mov	QWORD [r9-8+rcx], 0
	lea	ecx, [rdx-1]
	shr	ecx, 3
	rep stosq
.L681:
	mov	rbx, rbp
	mov	r9d, 1
	jmp	.L561
.L908:
	add	r10, 1
	jmp	.L681
.L665:
	mov	ebp, 32
	test	r12, r12
	jne	.L643
.L645:
	mov	eax, 32
	cmp	r12, rax
	cmova	r12, rax
	jmp	.L640
.L910:
	cmp	QWORD [r13-8+r12*8], 0
	lea	rax, [r12-1]
	jne	.L909
	mov	r12, rax
.L640:
	test	r12, r12
	jne	.L910
.L639:
	mov	rax, rbp
	lea	rdx, [r13+0+r12*8]
	sub	rax, r12
	mov	rdi, rdx
	sal	rax, 3
	mov	ecx, eax
	mov	QWORD [rdx-8+rcx], 0
	lea	ecx, [rax-1]
	mov	rdx, rbx
	mov	eax, ecx
	shr	eax, 3
	mov	ecx, eax
	xor	eax, eax
	rep stosq
	lea	rdi, [rsp+3328]
	mov	QWORD [rsp+320], r12
	mov	rcx, QWORD [rsp+8]
	mov	rsi, QWORD [rsp+16]
	call	inverse_pair_half
	test	eax, eax
	je	.L574
	test	r12, r12
	je	.L645
.L643:
	mov	rax, QWORD [rsp+64]
	and	eax, 1
	jne	.L654
	lea	rdx, [r13+0+r12*8]
.L638:
	mov	rcx, QWORD [rdx-8]
	sub	rdx, 8
	shld	rax, rcx, 63
	mov	QWORD [rdx], rax
	mov	rax, rcx
	and	eax, 1
	cmp	r13, rdx
	jne	.L638
	jmp	.L645
.L652:
	mov	eax, 32
	lea	rdx, [r15+r14*8]
	sub	rax, r14
	mov	rdi, rdx
	sal	rax, 3
	mov	ecx, eax
	mov	QWORD [rdx-8+rcx], 0
	lea	ecx, [rax-1]
	mov	rdx, rbx
	mov	eax, ecx
	shr	eax, 3
	mov	ecx, eax
	xor	eax, eax
	rep stosq
	mov	QWORD [rsp+592], r14
	mov	rcx, QWORD [rsp+8]
	mov	rsi, QWORD [rsp+40]
	mov	rdi, QWORD [rsp+24]
	call	inverse_pair_half
	test	eax, eax
	je	.L574
.L654:
	test	r14, r14
	jne	.L647
.L651:
	mov	eax, 32
	cmp	r14, rax
	cmova	r14, rax
	jmp	.L648
.L912:
	cmp	QWORD [r15-8+r14*8], 0
	lea	rax, [r14-1]
	jne	.L911
	mov	r14, rax
.L648:
	test	r14, r14
	jne	.L912
	jmp	.L652
.L911:
	cmp	r14, 32
	jne	.L652
	mov	rcx, QWORD [rsp+8]
	mov	rsi, QWORD [rsp+40]
	mov	rdx, rbx
	mov	QWORD [rsp+592], 32
	mov	rdi, QWORD [rsp+24]
	call	inverse_pair_half
	test	eax, eax
	je	.L574
.L647:
	mov	rax, QWORD [rsp+336]
	and	eax, 1
	jne	.L649
	lea	rdx, [r15+r14*8]
.L650:
	mov	rcx, QWORD [rdx-8]
	sub	rdx, 8
	shld	rax, rcx, 63
	mov	QWORD [rdx], rax
	mov	rax, rcx
	and	eax, 1
	cmp	rdx, r15
	jne	.L650
	jmp	.L651
.L909:
	cmp	r12, 32
	jne	.L639
	mov	rcx, QWORD [rsp+8]
	mov	rsi, QWORD [rsp+16]
	mov	rdx, rbx
	lea	rdi, [rsp+3328]
	mov	QWORD [rsp+320], 32
	call	inverse_pair_half
	test	eax, eax
	jne	.L643
	jmp	.L574
.L649:
	cmp	r14, r12
	jne	.L888
	mov	rax, r12
.L656:
	sub	rax, 1
	mov	rdx, QWORD [r13+0+rax*8]
	mov	rcx, QWORD [r15+rax*8]
	cmp	rdx, rcx
	jne	.L913
	test	rax, rax
	jne	.L656
.L657:
	lea	rbp, [rsp+3056]
	mov	rdx, r15
	mov	rsi, r13
	mov	rdi, rbp
	call	inverse_sub_raw
	mov	rdx, QWORD [rsp+24]
	mov	rsi, rbp
	mov	rdi, r13
	lea	rbp, [rsp+4416]
	mov	ecx, 33
	rep movsq
	lea	rsi, [rsp+3328]
	mov	rdi, rbp
	call	inverse_signed_sub
	mov	ecx, 34
	mov	rsi, rbp
	lea	rdi, [rsp+3328]
	rep movsq
	mov	r14, QWORD [rsp+16]
	mov	rdx, QWORD [rsp+40]
	mov	rdi, rbp
	mov	rsi, r14
	call	inverse_signed_sub
	mov	ecx, 34
	mov	rdi, r14
	mov	rsi, rbp
	rep movsq
	mov	r12, QWORD [rsp+320]
	test	r12, r12
	je	.L914
.L660:
	mov	r14, QWORD [rsp+592]
	jmp	.L637
.L913:
	cmp	rcx, rdx
.L888:
	jb	.L657
	lea	rbp, [rsp+3056]
	mov	rdx, r13
	mov	rsi, r15
	mov	rdi, rbp
	call	inverse_sub_raw
	mov	r14, QWORD [rsp+24]
	mov	rsi, rbp
	mov	rdi, r15
	lea	rbp, [rsp+4416]
	lea	rdx, [rsp+3328]
	mov	ecx, 33
	rep movsq
	mov	rsi, r14
	mov	rdi, rbp
	call	inverse_signed_sub
	mov	rdi, r14
	mov	ecx, 34
	mov	rsi, rbp
	rep movsq
	mov	r14, QWORD [rsp+40]
	mov	rdx, QWORD [rsp+16]
	mov	rdi, rbp
	mov	rsi, r14
	call	inverse_signed_sub
	mov	ecx, 34
	mov	rdi, r14
	mov	rsi, rbp
	rep movsq
	jmp	.L660
.L903:
	test	r9b, r9b
	je	.L571
	mov	QWORD [rsp+1952], rbx
.L571:
	test	r10, r10
	je	.L562
	test	BYTE [rsp+64], 1
	je	.L574
	mov	rdx, r8
	mov	rsi, r13
	mov	QWORD [rsp+24], r11
	lea	rdi, [rsp+1968]
	mov	QWORD [rsp+16], r10
	call	inverse_reduce
	lea	r8, [rsp+1696]
	lea	rsi, [rsp+1968]
	mov	rdx, r8
	lea	rdi, [rsp+2240]
	call	inverse_mod_odd
	test	eax, eax
	je	.L574
	mov	r10, QWORD [rsp+16]
	lea	rax, [r10-1]
	cmp	rax, 2047
	ja	.L675
	mov	rdx, r10
	mov	rsi, r13
	lea	rdi, [rsp+2512]
	call	inverse_mod2_newton.part.0
	test	eax, eax
	je	.L675
	lea	r8, [rsp+1696]
	mov	rdx, QWORD [rsp+16]
	lea	rdi, [rsp+2784]
	mov	rsi, r8
	call	inverse_mod2_newton.part.0
	test	eax, eax
	je	.L675
	lea	r9, [rsp+3056]
	xor	eax, eax
	mov	r10, QWORD [rsp+16]
	mov	ecx, 33
	mov	rdi, r9
	mov	r14, QWORD [rsp+2496]
	mov	r11, QWORD [rsp+24]
	rep stosq
	mov	rax, QWORD [rsp+2768]
	lea	rsi, [r10+63]
	shr	rsi, 6
	test	rax, rax
	je	.L694
	cmp	rsi, rax
	cmovbe	rax, rsi
	xor	edx, edx
	mov	rbx, rax
	xor	eax, eax
.L583:
	mov	rcx, QWORD [rsp+2512+rax*8]
	xor	edi, edi
	cmp	rax, r14
	jnb	.L579
	mov	rdi, QWORD [rsp+2240+rax*8]
.L579:
	test	rdx, rdx
	je	.L580
	xor	edx, edx
	cmp	rdi, rcx
	setnb	dl
	sub	rcx, 1
.L885:
	sub	rcx, rdi
	mov	QWORD [r9+rax*8], rcx
	add	rax, 1
	cmp	rax, rbx
	jb	.L583
	cmp	rax, rsi
	jnb	.L586
.L587:
	cmp	rax, r14
	jnb	.L584
.L915:
	mov	rcx, QWORD [rsp+2240+rax*8]
	mov	rdi, rcx
	or	rdi, rdx
	setne	dil
	add	rdx, rcx
	neg	rdx
	movzx	edi, dil
	mov	QWORD [r9+rax*8], rdx
	add	rax, 1
	cmp	rax, rsi
	jnb	.L586
	mov	rdx, rdi
	cmp	rax, r14
	jb	.L915
.L584:
	mov	rcx, rdx
	neg	rcx
	mov	QWORD [r9+rax*8], rcx
	add	rax, 1
	cmp	rax, rsi
	jb	.L587
.L586:
	mov	rdi, r9
	lea	r13, [rsp+3328]
	mov	QWORD [rsp+32], r11
	mov	QWORD [rsp+3312], rsi
	mov	rsi, r10
	mov	QWORD [rsp+16], r10
	call	inverse_mod2_mask
	mov	rsi, r9
	mov	rdi, r13
	lea	rdx, [rsp+2784]
	call	inverse_mod2_mul_low
	mov	rsi, QWORD [rsp+16]
	mov	rdi, r13
	xor	r10d, r10d
	call	inverse_mod2_mask
	mov	eax, 33
	lea	rdi, [rsp+3872]
	lea	r8, [rsp+1696]
	mov	rsi, r8
	mov	rcx, rax
	mov	QWORD [rsp+16], rdi
	mov	r9, QWORD [rsp+3584]
	rep movsq
	lea	rdi, [rsp+4144]
	mov	rsi, r13
	mov	QWORD [rsp+24], r14
	lea	r13, [rsp+4416]
	mov	rbx, rdi
	mov	r14d, r12d
	mov	r12, QWORD [rsp+32]
	mov	r8, r13
	mov	r15, r9
	mov	r11, rbx
	mov	rax, rcx
	mov	ecx, 33
	rep movsq
	mov	ecx, 65
	mov	rdi, r13
	rep stosq
.L588:
	test	r9, r9
	je	.L594
	mov	rax, QWORD [rsp+16]
	xor	esi, esi
	xor	ecx, ecx
	xor	ebx, ebx
	mov	rdi, QWORD [rax+r10*8]
.L589:
	mov	rax, rdi
	mul	QWORD [r11+rsi*8]
	add	rax, QWORD [r8+rsi*8]
	adc	rdx, 0
	add	rcx, rax
	adc	rbx, rdx
	mov	QWORD [r8+rsi*8], rcx
	add	rsi, 1
	mov	rcx, rbx
	xor	ebx, ebx
	cmp	r9, rsi
	jne	.L589
	cmp	r15, 64
	ja	.L594
	mov	rax, rcx
	or	rax, rbx
	je	.L594
	mov	rsi, r15
	jmp	.L590
.L916:
	cmp	rsi, 64
	ja	.L594
.L590:
	mov	rax, rcx
	mov	rdx, rbx
	add	rax, QWORD [r13+0+rsi*8]
	mov	ecx, 1
	adc	rdx, 0
	mov	QWORD [r13+0+rsi*8], rax
	xor	ebx, ebx
	add	rsi, 1
	test	dl, 1
	jne	.L916
.L594:
	add	r10, 1
	add	r15, 1
	add	r8, 8
	cmp	r10, rbp
	jb	.L588
	mov	r11, r12
	mov	eax, 65
	mov	r12d, r14d
	mov	r14, QWORD [rsp+24]
	jmp	.L592
.L597:
	test	rax, rax
	je	.L596
.L592:
	mov	rdx, rax
	sub	rax, 1
	cmp	QWORD [r13+0+rax*8], 0
	je	.L597
	cmp	rdx, 32
	ja	.L675
	xor	eax, eax
	lea	rdi, [rsp+3600]
	mov	ecx, 33
	mov	rsi, rdi
	mov	QWORD [rsp+24], rdi
	rep stosq
	mov	rcx, rdx
	mov	rdi, rsi
	mov	QWORD [rsp+3856], rdx
	and	ecx, 536870911
	mov	rsi, r13
	cmp	r14, rdx
	rep movsq
	mov	rsi, rdx
	mov	ecx, 33
	mov	rdi, r13
	rep stosq
	cmovnb	rsi, r14
	mov	rax, rdx
.L599:
	xor	edx, edx
	test	r14, r14
	je	.L621
	xor	edi, edi
.L615:
	mov	rcx, QWORD [rsp+2240+rdi*8]
	cmp	rdi, rax
	jnb	.L606
	mov	rbx, QWORD [rsp+24]
	xor	r8d, r8d
	add	rcx, QWORD [rbx+rdi*8]
	setc	r8b
	add	rcx, rdx
	setc	dl
	mov	QWORD [r13+0+rdi*8], rcx
	add	rdi, 1
	movzx	edx, dl
	or	rdx, r8
	cmp	r14, rdi
	jne	.L615
.L612:
	cmp	r14, rsi
	jnb	.L620
.L621:
	cmp	r14, rax
	jnb	.L616
	mov	rdi, QWORD [rsp+24]
	add	rdx, QWORD [rdi+r14*8]
	mov	QWORD [r13+0+r14*8], rdx
	setc	dl
	add	r14, 1
	movzx	edx, dl
	cmp	r14, rsi
	jb	.L621
	jmp	.L620
.L692:
	xor	edx, edx
	xor	ecx, ecx
	xor	eax, eax
	xor	esi, esi
	jmp	.L546
.L918:
	cmp	rdx, rax
.L883:
	jnb	.L634
.L675:
	mov	r12d, -6
	jmp	.L531
.L688:
	mov	r12d, -2
	jmp	.L531
.L906:
	cmp	rdx, 32
	je	.L917
	mov	eax, 32
	lea	r8, [rbp+0+rdx*8]
	sub	rax, rdx
	mov	rdi, r8
	sal	rax, 3
	mov	ecx, eax
	mov	QWORD [r8-8+rcx], 0
	lea	ecx, [rax-1]
	xor	eax, eax
	shr	ecx, 3
	rep stosq
	mov	QWORD [rsp+1408], rdx
	cmp	QWORD [rsp], rdx
	jne	.L883
.L880:
	mov	rcx, QWORD [rsp+8]
	jmp	.L678
.L919:
	sub	rsi, 1
.L678:
	mov	rax, QWORD [rbp+0+rsi*8]
	mov	rdx, QWORD [rcx+rsi*8]
	cmp	rax, rdx
	jne	.L918
	test	rsi, rsi
	jne	.L919
	jmp	.L675
.L686:
	mov	r12d, -1
	jmp	.L531
.L544:
	mov	rdx, QWORD [rsp+8]
	mov	rsi, r13
	mov	rdi, r13
	mov	QWORD [rsp+24], r11
	mov	BYTE [rsp+16], r9b
	call	inverse_reduce
	movzx	r9d, BYTE [rsp+16]
	mov	r11, QWORD [rsp+24]
	mov	r14, QWORD [rsp+320]
	test	r14, r14
	je	.L574
	lea	rdi, [rsp+1424]
	mov	rsi, r13
	xor	edx, edx
	xor	eax, eax
	mov	QWORD [rsp+32], rdi
	mov	ecx, 33
	rep movsq
	xor	esi, esi
	jmp	.L546
.L905:
	mov	rsi, QWORD [rsp+8]
	mov	rdx, r13
	mov	rdi, rbp
	call	inverse_sub_raw
	mov	r11, QWORD [rsp+16]
	jmp	.L668
.L616:
	mov	QWORD [r13+0+r14*8], rdx
	add	r14, 1
	xor	edx, edx
	cmp	r14, rsi
	jb	.L621
.L620:
	lea	r14, [rdx+rsi]
	mov	QWORD [rsp+4416+rsi*8], rdx
	cmp	r14, 32
	ja	.L675
	lea	rbp, [rsp+1152]
	mov	ecx, 33
	xor	eax, eax
	mov	rsi, r13
	mov	rdi, rbp
	rep stosq
	mov	rcx, r14
	mov	rdi, rbp
	and	ecx, 536870911
	rep movsq
	jmp	.L628
.L921:
	cmp	QWORD [rbp-8+r14*8], 0
	lea	rdx, [r14-1]
	jne	.L920
	mov	r14, rdx
.L628:
	test	r14, r14
	jne	.L921
	mov	rax, r14
	mov	ecx, 32
	mov	rdi, rbp
	rep stosq
	xor	eax, eax
	mov	QWORD [rsp+1408], rax
	jmp	.L634
.L580:
	xor	edx, edx
	cmp	rcx, rdi
	setb	dl
	jmp	.L885
.L917:
	cmp	QWORD [rsp], 32
	mov	QWORD [rsp+1408], 32
	je	.L880
	jmp	.L675
.L606:
	add	rdx, rcx
	mov	QWORD [r13+0+rdi*8], rdx
	setc	dl
	add	rdi, 1
	movzx	edx, dl
	cmp	r14, rdi
	je	.L612
	jmp	.L615
.L914:
	mov	r12d, DWORD [rsp+52]
	mov	r11, QWORD [rsp+56]
	jmp	.L661
.L694:
	xor	edx, edx
	jmp	.L587
.L596:
	lea	rdi, [rsp+3600]
	mov	ecx, 33
	mov	QWORD [rsp+24], rdi
	rep stosq
	mov	ecx, 33
	mov	rdi, r13
	rep stosq
	test	r14, r14
	jne	.L922
	lea	rbp, [rsp+1152]
	mov	ecx, 33
	mov	rax, r14
	mov	rdi, rbp
	rep stosq
	jmp	.L628
.L920:
	cmp	r14, 32
	je	.L923
	mov	eax, 32
	lea	rsi, [rbp+0+r14*8]
	sub	rax, r14
	mov	rdi, rsi
	lea	ecx, [0+rax*8]
	xor	eax, eax
	rep stosb
	mov	QWORD [rsp+1408], r14
	cmp	QWORD [rsp], r14
	jne	.L883
.L887:
	mov	rsi, QWORD [rsp+8]
	jmp	.L636
.L925:
	sub	rdx, 1
.L636:
	mov	rax, QWORD [rbp+0+rdx*8]
	mov	rcx, QWORD [rsi+rdx*8]
	cmp	rax, rcx
	jne	.L924
	test	rdx, rdx
	jne	.L925
	jmp	.L675
.L922:
	mov	rsi, r14
	jmp	.L599
.L924:
	cmp	rcx, rax
	jb	.L675
	jmp	.L634
.L923:
	cmp	QWORD [rsp], 32
	mov	QWORD [rsp+1408], 32
	jne	.L675
	jmp	.L887
section .rodata
align 16
.LC0:
dq 1
dq 1
align 16
.LC1:
dq 0
dq 1
align 16
.LC2:
dq 1
dq 2
align 16
.LC3:
dq 2
dq 3
align 16
.LC4:
dq 3
dq 4
align 16
.LC5:
dq 4
dq 5
align 16
.LC6:
dq 5
dq 6
align 16
.LC7:
dq 6
dq 7
align 16
.LC8:
dq 7
dq 8
align 16
.LC9:
dq 8
dq 9
align 16
.LC10:
dq 9
dq 10
align 16
.LC11:
dq 10
dq 11
align 16
.LC12:
dq 11
dq 12
align 16
.LC13:
dq 12
dq 13
align 16
.LC14:
dq 13
dq 14
align 16
.LC15:
dq 14
dq 15
align 16
.LC16:
dq 15
dq 16
align 16
.LC17:
dq 16
dq 17
align 16
.LC18:
dq 17
dq 18
align 16
.LC19:
dq 18
dq 19
align 16
.LC20:
dq 19
dq 20
align 16
.LC21:
dq 20
dq 21
align 16
.LC22:
dq 21
dq 22
align 16
.LC23:
dq 22
dq 23
align 16
.LC24:
dq 23
dq 24
align 16
.LC25:
dq 24
dq 25
align 16
.LC26:
dq 25
dq 26
align 16
.LC27:
dq 26
dq 27
align 16
.LC28:
dq 27
dq 28
align 16
.LC29:
dq 28
dq 29
align 16
.LC30:
dq 29
dq 30
align 16
.LC31:
dq 30
dq 31
align 16
.LC32:
dq 31
dq 32
section .note.GNU-stack noalloc noexec nowrite progbits
