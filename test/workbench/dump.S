
start.elf:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <_start>:
   0:	00000093          	li	ra,0
   4:	00000113          	li	sp,0
   8:	00000193          	li	gp,0
   c:	00000213          	li	tp,0
  10:	00000293          	li	t0,0
  14:	00000313          	li	t1,0
  18:	00000393          	li	t2,0
  1c:	00000413          	li	s0,0
  20:	00000493          	li	s1,0
  24:	00000513          	li	a0,0
  28:	00000593          	li	a1,0
  2c:	00000613          	li	a2,0
  30:	00000693          	li	a3,0
  34:	00000713          	li	a4,0
  38:	00000793          	li	a5,0
  3c:	00000813          	li	a6,0
  40:	00000893          	li	a7,0
  44:	00000913          	li	s2,0
  48:	00000993          	li	s3,0
  4c:	00000a13          	li	s4,0
  50:	00000a93          	li	s5,0
  54:	00000b13          	li	s6,0
  58:	00000b93          	li	s7,0
  5c:	00000c13          	li	s8,0
  60:	00000c93          	li	s9,0
  64:	00000d13          	li	s10,0
  68:	00000d93          	li	s11,0
  6c:	00000e13          	li	t3,0
  70:	00000e93          	li	t4,0
  74:	00000f13          	li	t5,0
  78:	00000f93          	li	t6,0
  7c:	00001117          	auipc	sp,0x1
  80:	b8410113          	addi	sp,sp,-1148 # c00 <bootstacktop>
  84:	090000ef          	jal	ra,114 <cmain>

0000000000000088 <poweroff>:
  88:	00000063          	beqz	zero,88 <poweroff>

000000000000008c <uart_put_c>:
  8c:	fe010113          	addi	sp,sp,-32
  90:	00813c23          	sd	s0,24(sp)
  94:	02010413          	addi	s0,sp,32
  98:	00050793          	mv	a5,a0
  9c:	fef407a3          	sb	a5,-17(s0)
  a0:	600007b7          	lui	a5,0x60000
  a4:	fef44703          	lbu	a4,-17(s0)
  a8:	00e78023          	sb	a4,0(a5) # 60000000 <bootstacktop+0x5ffff400>
  ac:	00000013          	nop
  b0:	01813403          	ld	s0,24(sp)
  b4:	02010113          	addi	sp,sp,32
  b8:	00008067          	ret

00000000000000bc <print_s>:
  bc:	fe010113          	addi	sp,sp,-32
  c0:	00113c23          	sd	ra,24(sp)
  c4:	00813823          	sd	s0,16(sp)
  c8:	02010413          	addi	s0,sp,32
  cc:	fea43423          	sd	a0,-24(s0)
  d0:	0200006f          	j	f0 <print_s+0x34>
  d4:	fe843783          	ld	a5,-24(s0)
  d8:	0007c783          	lbu	a5,0(a5)
  dc:	00078513          	mv	a0,a5
  e0:	fadff0ef          	jal	ra,8c <uart_put_c>
  e4:	fe843783          	ld	a5,-24(s0)
  e8:	00178793          	addi	a5,a5,1
  ec:	fef43423          	sd	a5,-24(s0)
  f0:	fe843783          	ld	a5,-24(s0)
  f4:	0007c783          	lbu	a5,0(a5)
  f8:	fc079ee3          	bnez	a5,d4 <print_s+0x18>
  fc:	00000013          	nop
 100:	00000013          	nop
 104:	01813083          	ld	ra,24(sp)
 108:	01013403          	ld	s0,16(sp)
 10c:	02010113          	addi	sp,sp,32
 110:	00008067          	ret

0000000000000114 <cmain>:
 114:	fd010113          	addi	sp,sp,-48
 118:	02113423          	sd	ra,40(sp)
 11c:	02813023          	sd	s0,32(sp)
 120:	03010413          	addi	s0,sp,48
 124:	04800793          	li	a5,72
 128:	fcf40c23          	sb	a5,-40(s0)
 12c:	06500793          	li	a5,101
 130:	fcf40ca3          	sb	a5,-39(s0)
 134:	06c00793          	li	a5,108
 138:	fcf40d23          	sb	a5,-38(s0)
 13c:	06c00793          	li	a5,108
 140:	fcf40da3          	sb	a5,-37(s0)
 144:	06f00793          	li	a5,111
 148:	fcf40e23          	sb	a5,-36(s0)
 14c:	02000793          	li	a5,32
 150:	fcf40ea3          	sb	a5,-35(s0)
 154:	07700793          	li	a5,119
 158:	fcf40f23          	sb	a5,-34(s0)
 15c:	06f00793          	li	a5,111
 160:	fcf40fa3          	sb	a5,-33(s0)
 164:	07200793          	li	a5,114
 168:	fef40023          	sb	a5,-32(s0)
 16c:	06c00793          	li	a5,108
 170:	fef400a3          	sb	a5,-31(s0)
 174:	06400793          	li	a5,100
 178:	fef40123          	sb	a5,-30(s0)
 17c:	02100793          	li	a5,33
 180:	fef401a3          	sb	a5,-29(s0)
 184:	00a00793          	li	a5,10
 188:	fef40223          	sb	a5,-28(s0)
 18c:	fe0402a3          	sb	zero,-27(s0)
 190:	fd840793          	addi	a5,s0,-40
 194:	00078513          	mv	a0,a5
 198:	f25ff0ef          	jal	ra,bc <print_s>
 19c:	00000793          	li	a5,0
 1a0:	00078513          	mv	a0,a5
 1a4:	02813083          	ld	ra,40(sp)
 1a8:	02013403          	ld	s0,32(sp)
 1ac:	03010113          	addi	sp,sp,48
 1b0:	00008067          	ret

Disassembly of section .data:

0000000000000800 <bootstack>:
	...

0000000000000c00 <bootstacktop>:
	...

Disassembly of section .comment:

0000000000000000 <.comment>:
   0:	3a434347          	fmsub.d	ft6,ft6,ft4,ft7,rmm
   4:	2820                	fld	fs0,80(s0)
   6:	29554e47          	fmsub.s	ft8,fa0,fs5,ft5,rmm
   a:	3120                	fld	fs0,96(a0)
   c:	2e31                	addiw	t3,t3,12
   e:	2e31                	addiw	t3,t3,12
  10:	0030                	addi	a2,sp,8
