#
# CMPUT 229 Student Submission License
# Version 1.0
#
# Copyright 2021 <Ke Li>
#
# Redistribution is forbidden in all circumstances. Use of this
# software without explicit authorization from the author or CMPUT 229
# Teaching Staff is prohibited.
#
# This software was produced as a solution for an assignment in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada. This solution is confidential and remains confidential 
# after it is submitted for grading.
#
# Copying any part of this solution without including this copyright notice
# is illegal.
#
# If any portion of this software is included in a solution submitted for
# grading at an educational institution, the submitter will be subject to
# the sanctions for plagiarism at that institution.
#
# If this software is found in any public website or public repository, the
# person finding it is kindly requested to immediately report, including 
# the URL or other repository locating information, to the following email
# address:
#
#          cmput229@ualberta.ca
#
#---------------------------------------------------------------
# CCID:                 <  kli1  >
# Lecture Section:      <  A1  >
# Instructor:           <  Jose Nelson Amaral  >
# Lab Section:          <  D04  >
# Teaching Assistant:   <  Soodarshan Gajadhur  >
#---------------------------------------------------------------
# 

.include "common.s"

#----------------------------------
#        STUDENT SOLUTION
#----------------------------------
 

#-------------------------------------------------------------------------------------------------------------------------
# RISCVtoARM_ALU
# This function translates RISC-V code that is stored in memory at address found in a0 into ARM code and stores that 
# ARM code into the memory address found in a1.
# Arguments:
# a0: pointer to memory containing a RISC-V function. The end of the RISC-V instructions is marked by the sentinel 
# word 0xFFFFFFFF.
# a1: a pointer to pre-allocated memory where you will have to write ARM instructions.
# Return Values:
# a0: number of bytes that the instructions generated by RISCVtoARM_ALU occupy.
#-------------------------------------------------------------------------------------------------------------------------
RISCVtoARM_ALU:
	
	# Block description:
	# create space for the stack and store all the registers
	addi	sp, sp, -36	# create space for the stack
	sw	ra, 0(sp)	# store all the register
	sw	s0, 4(sp)	# Pointer to the RISC-V Function
	sw	s1, 8(sp)	# Number of byte that instructions generated 
	sw	s2, 12(sp)
	sw	s3, 16(sp)
	sw	s4, 20(sp)
	sw	s5, 24(sp)
	sw	s6, 28(sp)
	sw	a0, 32(sp)
	
	# load the register that will use later on
	mv	s0, a0		# set s0 to the address of a0
	mv	s6, a1 		# s6 <-- a1
	
	li	t0, 0xFFFFFFFF	# t0 = -1
	bne	s0, t0, Transfer	# goto Transfer if s0 != -1
	j	QuitRToA	# jump to QuitRToA
	
	Transfer:
		# This is the main loop that 
		# used for translate riscv instructions to arm instructions
		lw	a0, 0(s0)	# a0 = 0(s0)
		jal	ra, translateALU	# jump to translateALU
		mv	s2, a0		# Content of transfered
		sw	s2, 0(a1)	# store s2 into 0(a1)
		addi	a1, a1, 4	# append a1 by 4
		addi	s0, s0, 4	# append s0 by 4
		addi	s1, s1, 4	# append s1 by 4
		lw	t2, 0(s0)	# load t2 = 0(s0)
		li	t0, 0xFFFFFFFF	# load t0 = -1
		bne  	t2, t0, Transfer	# jump back to the begining of the loop of t2 != -1
		j	QuitRToA	# jump to quit
	
	QuitRToA:
		# This block move the result into a0 
		# And restore all the registers before quit the function
		mv	a0, s1		# set a0 to the Number of byte that instructions generated 
		lw	ra, 0(sp)	# restore all the register that used
		lw	s0, 4(sp)
		lw	s1, 8(sp)
		lw	s2, 12(sp)
		lw	s3, 16(sp)
		lw	s4, 20(sp)
		lw	s5, 24(sp)
		lw	s6, 28(sp)
		lw	s7, 32(sp)
		addi	sp, sp, 36	
		jalr	zero, ra, 0	# return





#-------------------------------------------------------------------------------------------------------------------------
# translateALU
# This function translates a single ALU R-type or I-type instruction into an ARM instruction.
# Arguments:
# a0: untranslated RISC-V instruction
# Return Values:
# a0: translated ARM instruction.
#-------------------------------------------------------------------------------------------------------------------------

translateALU:

	# Block description:
	# create space for the stack and store all the registers
	addi	sp, sp, -36	# create space for the stack
	sw	ra, 0(sp)	# store all the register that used
	sw	s0, 4(sp)
	sw	a0, 8(sp)
	sw	s1, 12(sp)
	sw	s2, 16(sp)	# register that store the transfer instructions -->> Arm Instructions
	sw	s3, 20(sp)
	sw	s4, 24(sp)
	sw	s5, 28(sp)
	sw	s6, 32(sp)
	
	mv	s1, a0  	# set s1 = a0
	
	# scratch 3 bits(fun3)
	slli	t1, s1, 19	# line 133, 134 get the 12th bit to t1
	srli	t1, t1, 31	
	slli	t2, s1, 18	# line 135, 136 get the 13th bit to t2
	srli	t2, t2, 31
	slli	t3, s1, 17	# line 137, 138 get the 14th bit tp t3
	srli	t3, t3, 31
	
	# Load immediate value
	li	t4, 0		# load t4 = 0
	li	t5, 1		# load t5 = 1
	
	
	# block description:
	# The following block is to get
	# to the branch to the specific riscv instruction
	# by using fun3 (3 bits) and the 5th , 30th bits
	beq	t1, t5, FirstBitOne	# jump to the branch if fun3 == xx1
	beq	t1, t4, FirstBitZero	# jump to the branch if fun3 == xx0
	
	FirstBitOne:
		# jump to this branch if fun3 == xx1
		beq	t2, t5, FirOneSecOne	# jump to the branch if fun3 == x11
		beq	t2, t4, FirOneSecZero	# jump to the branch if fun3 == x01
		FirOneSecOne:
		# jump to this branch if fun3 == x11
			beq	t3, t5, FirOneSecOneThiOne	# jump to the branch if fun3 == 111
			FirOneSecOneThiOne:
				# jump to this branch if fun3 ==111
				slli	t6, s1, 26		# line 155, 156 get the 5th bit to t6
				srli	t6, t6, 31
				beq	t6, t5, AND		# goto AND if t6 == 1
				j	ANDI			# goto ANDI if t6 == 0
				
				
		FirOneSecZero:
			# jump to this branch if fun3 == x01
			beq	t3, t5, FirOneSecZeroThiOne	# jump to the branch if fun3 == 101
			beq	t3, t4, FirOneSecZeroThiZero	# jump to the branch if fun3 == 001
			FirOneSecZeroThiOne:
				# jump to this branch if fun3 == 101
				slli	t6, s1, 26		# line 167, 168 get the 5th bit to t6
				srli	t6, t6, 31
				beq	t6, t5, SRInstructions		# goto SRInstructions if t6 == 1
				beq	t6, t4, SRIIIIInstructions	# goto SRIIIIInstructions
				SRInstructions:
					# the 5th bit == 1
					slli	t6, s1, 1		# line 173, 174 get the 30th bit to t6
					srli	t6, t6, 31
					beq	t6, t5, SRA		# goto SRA if t6 == 1
					j	SRL			# goto SRL
				SRIIIIInstructions:
					# the 5th bit == 0
					slli	t6, s1, 1		# line 179, 180 get the 30th bit to t6
					srli	t6, t6, 31
					beq	t6, t5, SRAI		# goto SRAI if t6 == 1
					j	SRLI			# goto SRLI
			FirOneSecZeroThiZero:
				# jump to this branch if fun3 == 001
				slli	t6, s1, 26		# line 185, 186 get the 5th bit to t6
				srli	t6, t6, 31
				beq	t6, t5, SLL		# goto SLL if t6 == 1
				j	SLLI			# goto SLLI
				
	FirstBitZero:	
		# jump to this branch if fun3 == xx0
		beq	t2, t5, FirZeroSecOne	# jump to the branch if fun3 == x10
		beq	t2, t4, FirZeroSecZero	# jump to the branch if fun3 == x00
		FirZeroSecOne:
			# jump to this branch if fun3 == x10
			beq	t3, t5, FirZeroSecOneThiOne	# jump to the branch if fun3 == 110
			FirZeroSecOneThiOne:
				# jump to this branch if fun3 == 110
				slli	t6, s1, 26		# line 199, 200 get the 5th bit to t6
				srli	t6, t6, 31
				beq	t6, t5, OR		# goto OR if t6 == 1
				j	ORI			# goto ORI
		FirZeroSecZero:
			# jump to this branch if fun3 == x00
			beq	t3, t4, FirZeroSecZeroThiZero	# jump to the branch if fun3 == 000
			FirZeroSecZeroThiZero:
				# jump to the branch if fun3 == 000
				slli	t6, s1, 26		# line 208, 209 get the 5th bit to t6
				srli	t6, t6, 31
				beq	t6, t4, ADDI		# goto ADDI if t6 == 0
				slli	s4, s1, 1		# line 211, 212 get the 30th bit to s4
				srli	s4, s4, 31
				beq	s4, t4, ADD		# goto ADD if s4 == 0
				beq	s4, t5, SUB		# goto SUB if s4 == 1
				
	AND:
	# This block is used for transfer and RISCV instruction
	
	
		
		li	t1, 0xE0000000		# Set the conditions(31-28), (27-26)
		mv	s2, t1			# set s2 = t1
		
		#--------------------------
		# This block transfer the RISCV d register into ARM Rd register
		mv	t2, s1
		slli	t2, t2, 20		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s3, a0			# set s3 to the RISCV d register ---> the arm register Rd
		#--------------------------
		# This block transfer the RISCV s register into ARM Rn register
		mv	t2, s1
		slli	t2, t2, 12		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s4, a0			# set s4 to the RISCV s register ---> the arm register Rn 
		#--------------------------
		# This block transfer the RISCV t register into ARM Rm register
		mv	t2, s1
		slli	t2, t2, 7		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s5, a0			# set s5 to the RISCV t register ---> the arm register Rm
		#--------------------------
		# This block assemble all the transfered bits into s2 
		slli	s3, s3, 12		# set the transformed register into the proper bits from s3 to the instruction
		or	s2, s2, s3
		slli	s4, s4, 16		# set the transformed register into the proper bits from s4 to the instruction
		or	s2, s2, s4
		or	s2, s2, s5		# set the transformed register into the proper bits from s5 to the instruction
		
		
		j	QuittranslateALU	# jump to QuittranslateALU
		
	ANDI:
	# This block is used for transfer andi RISCV instruction
	
	
		
		li	t1, 0xE2000000		# Set the conditions(31-28), (27-26)
		mv	s2, t1
		
		#--------------------------
		# This block transfer the RISCV d register into ARM Rd register
		mv	t2, s1
		slli	t2, t2, 20		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s3, a0			# set s3 to the RISCV d register ---> the arm register Rd
		#--------------------------
		# This block transfer the RISCV s register into ARM Rn register
		mv	t2, s1
		slli	t2, t2, 12		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister	
		mv	s4, a0			# set s4 to the RISCV s register ---> the arm register Rn 
		#--------------------------
		# This block assemble part of the transfered bits into s2 
		slli	s3, s3, 12		# # set the transformed register into the proper bits from s3 to the instruction
		or	s2, s2, s3
		slli	s4, s4, 16		# set the transformed register into the proper bits from s4 to the instruction
		or	s2, s2, s4		
		#--------------------------
		# This block transfer the immediate value form riecv to arm
		mv	t3, s1
		srli	t3, t3, 20		# The instruction get the value of the immediate from the riscv instruction to t3
		mv	a0, t3
		jal	ra, computeRotation	# goto computeRotation
		mv	s6, a0
		or	s2, s2, s6		# set the transformed rotation value into the proper bits from s6 to the instruction
		
		
		j	QuittranslateALU	# jump to QuittranslateALU
		
	OR:
	# This block is used for transfer or RISCV instruction
	
	
		
		li	t1, 0xE1800000		# Set the conditions(31-28), (27-26)
		mv	s2, t1
		
		#--------------------------
		# This block transfer the RISCV d register into ARM Rd register
		mv	t2, s1
		slli	t2, t2, 20		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s3, a0			# set s3 to the RISCV d register ---> the arm register Rd
		#--------------------------
		# This block transfer the RISCV s register into ARM Rn register
		mv	t2, s1
		slli	t2, t2, 12		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s4, a0			# set s4 to the RISCV s register ---> the arm register Rn 
		#--------------------------
		# This block transfer the RISCV t register into ARM Rm register
		mv	t2, s1
		slli	t2, t2, 7		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s5, a0			# set s5 to the RISCV t register ---> the arm register Rm
		#--------------------------
		# This block assemble all the transfered bits into s2 
		slli	s3, s3, 12		# set the transformed register into the proper bits from s3 to the instruction
		or	s2, s2, s3
		slli	s4, s4, 16		# set the transformed register into the proper bits from s4 to the instruction
		or	s2, s2, s4
		or	s2, s2, s5		# set the transformed register into the proper bits from s5 to the instruction
		
		
		j	QuittranslateALU	# jump to QuittranslateALU
		
	ORI:
	# This block is used for transfer ori RISCV instruction
	
	
		
		li	t1, 0xE3800000		# Set the conditions(31-28), (27-26)
		mv	s2, t1
		
		#--------------------------
		# This block transfer the RISCV d register into ARM Rd register
		mv	t2, s1
		slli	t2, t2, 20		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s3, a0			# set s3 to the RISCV d register ---> the arm register Rd
		#--------------------------
		# This block transfer the RISCV s register into ARM Rn register
		mv	t2, s1
		slli	t2, t2, 12		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s4, a0			# set s4 to the RISCV s register ---> the arm register Rn 
		#--------------------------
		# This block assemble part of the transfered bits into s2 
		slli	s3, s3, 12		# set the transformed register into the proper bits from s3 to the instruction
		or	s2, s2, s3
		slli	s4, s4, 16		# set the transformed register into the proper bits from s4 to the instruction
		or	s2, s2, s4		
		#--------------------------
		# This block transfer the immediate value from riscv to arm
		mv	t3, s1
		srli	t3, t3, 20		# This instruction get the value of the value of the immediate from the riscv instruction to t3
		mv	a0, t3
		jal	ra, computeRotation	# goto computeRotation
		mv	s6, a0
		or	s2, s2, s6		# set the transformed rotation value into the proper bits from s6 to the instruction
		
		
		j	QuittranslateALU	# jump to QuittranslateALU
		
	SRA:
	# This block is used for transfer sra RISCV instruction
	
		
		
		li	t1, 0xE1A00050		# Set the conditions(31-28), (27-26)
		mv	s2, t1
		
		#--------------------------
		# This block transfer the RISCV d register into ARM Rd register
		mv	t2, s1
		slli	t2, t2, 20		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s3, a0			# set s3 to the RISCV d register ---> the arm register Rd
		#--------------------------
		# This block transfer the RISCV s register into ARM Rs register
		mv	t2, s1
		slli	t2, t2, 12		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s4, a0			# set s4 to the RISCV s register ---> the arm register Rs 
		#--------------------------
		# This block transfer the RISCV t register into ARM Rm register
		mv	t2, s1
		slli	t2, t2, 7		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s5, a0			# set s5 to the RISCV t register ---> the arm register Rm
		#--------------------------
		# This block assemble all the transfered bits into s2 
		slli	s3, s3, 12		# set the transformed register into the proper bits from s3 to the instruction
		or	s2, s2, s3
		slli	s5, s5, 8		# set the transformed register into the proper bits from s5 to the instruction
		or	s2, s2, s5
		or	s2, s2, s4		# set the transformed register into the proper bits from s4 to the instruction
		#--------------------------
		
		
		j	QuittranslateALU	# jump to QuittranslateALU
	
	SRL:
	# This block is used for transfer srl RISCV instruction
	
	
		
		li	t1, 0xE1A00030		# Set the conditions(31-28), (27-26)
		mv	s2, t1
		
		#--------------------------
		# This block transfer the RISCV d register into ARM Rd register
		mv	t2, s1
		slli	t2, t2, 20		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s3, a0			# set s3 to the RISCV d register ---> the arm register Rd
		#--------------------------
		# This block transfer the RISCV s register into ARM Rs register
		mv	t2, s1
		slli	t2, t2, 12		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s4, a0			# set s4 to the RISCV s register ---> the arm register Rs 
		#--------------------------
		# This block transfer the RISCV t register into ARM Rm register
		mv	t2, s1
		slli	t2, t2, 7		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s5, a0			# set s5 to the RISCV t register ---> the arm register Rm
		#--------------------------
		# This block assemble all the transfered bits into s2 
		slli	s3, s3, 12		# set the transformed register into the proper bits from s3 to the instruction
		or	s2, s2, s3
		slli	s5, s5, 8
		or	s2, s2, s5		# set the transformed register into the proper bits from s5 to the instruction
		or	s2, s2, s4		# set the transformed register into the proper bits from s4 to the instruction
		#--------------------------
		
		
		j	QuittranslateALU	# jump to QuittranslateALU
		
	SRAI:
	# This block is used for transfer srai RISCV instruction
	
		
		
		li	t1, 0xE1A00040		# Set the conditions(31-28), (27-26)
		mv	s2, t1
		
		#--------------------------
		# This block transfer the RISCV d register into ARM Rd register
		mv	t2, s1
		slli	t2, t2, 20		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s3, a0			# set s3 to the RISCV d register ---> the arm register Rd
		#--------------------------
		# This block transfer the immediate from riscv to arm
		mv	t2, s1
		slli	t2, t2, 7
		srli	t2, t2, 27
		mv	s4, t2			# set s4 to the immediate number
		#--------------------------
		# This block transfer the RISCV t register into ARM Rm register
		mv	t2, s1
		slli	t2, t2, 12		# The following 2 instructions get the value of the immediate from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s5, a0			# set s5 to the RISCV t register ---> the arm register Rm
		#--------------------------
		# This block assemble all the transfered bits into s2 
		slli	s3, s3, 12		# set the transformed register into the proper bits from s3 to the instruction
		or	s2, s2, s3
		slli	s4, s4, 7		# set the transformed immediate value into the proper bits to the instruction
		or	s2, s2, s4
		or	s2, s2, s5		# set the transformed register into the proper bits from s5 to the instruction
		#--------------------------
		
		
		j	QuittranslateALU	# jump to QuittranslateALU
		
	SRLI:
	# This block is used for transfer srli RISCV instruction
	
		
		
		li	t1, 0xE1A00020		# Set the conditions(31-28), (27-26)
		mv	s2, t1
		
		#--------------------------
		# This block transfer the RISCV d register into ARM Rd register
		mv	t2, s1
		slli	t2, t2, 20		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s3, a0			# set s3 to the RISCV d register ---> the arm register Rd
		#--------------------------
		# This block transfer the immediate value from riscv to arm
		mv	t2, s1
		slli	t2, t2, 7		# The following 2 instructions get the value of the immediate value from the riscv instruction to t2
		srli	t2, t2, 27
		mv	s4, t2			# set s4 to the immediate number
		#--------------------------
		# This block transfer the RISCV t register into ARM Rm register
		mv	t2, s1
		slli	t2, t2, 12		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s5, a0			# set s5 to the RISCV t register ---> the arm register Rm
		#--------------------------
		# This block assemble all the transfered bits into s2 
		slli	s3, s3, 12		# set the transformed register into the proper bits from s3 to the instruction
		or	s2, s2, s3
		slli	s4, s4, 7		# set the transformed register into the proper bits from s4 to the instruction
		or	s2, s2, s4
		or	s2, s2, s5		# set the transformed register into the proper bits from s5 to the instruction
		#--------------------------
		
		
		j	QuittranslateALU	# jump to QuittranslateALU
		
	SLL:
	# This block is used for transfer sll RISCV instruction
	
	
		
		li	t1, 0xE1A00010		# Set the conditions(31-28), (27-26) SRL 0xE1A00030
		mv	s2, t1
		
		#--------------------------
		# This block transfer the RISCV d register into ARM Rd register
		mv	t2, s1
		slli	t2, t2, 20		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s3, a0			# set s3 to the RISCV d register ---> the arm register Rd
		#--------------------------
		# This block transfer the RISCV s register into ARM Rs register
		mv	t2, s1
		slli	t2, t2, 12		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s4, a0			# set s4 to the RISCV s register ---> the arm register Rs 
		#--------------------------
		# This block transfer the RISCV t register into ARM Rm register
		mv	t2, s1
		slli	t2, t2, 7		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s5, a0			# set s5 to the RISCV t register ---> the arm register Rm
		#--------------------------
		# This block assemble all the transfered bits into s2 
		slli	s3, s3, 12		# set the transformed register into the proper bits from s3 to the instruction
		or	s2, s2, s3
		slli	s5, s5, 8		# set the transformed register into the proper bits from s4 to the instruction
		or	s2, s2, s5
		or	s2, s2, s4		# set the transformed register into the proper bits from s5 to the instruction
		#--------------------------
		
		
		j	QuittranslateALU	# jump to QuittranslateALU
		
	SLLI:
	# This block is used for transfer slli RISCV instruction
	
	
		
		li	t1, 0xE1A00000		# Set the conditions(31-28), (27-26)
		mv	s2, t1
		
		#--------------------------
		# This block transfer the RISCV d register into ARM Rd register
		mv	t2, s1
		slli	t2, t2, 20		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s3, a0			# set s3 to the RISCV d register ---> the arm register Rd
		#--------------------------
		# This block transfer the immediate value from riscv to arm
		mv	t2, s1
		slli	t2, t2, 7		# The following 2 instructions get the value of the immediate from the riscv instruction to t2
		srli	t2, t2, 27
		mv	s4, t2			# set s4 to the immediate number
		#--------------------------
		# This block transfer the RISCV t register into ARM Rm register
		mv	t2, s1
		slli	t2, t2, 12		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s5, a0			# set s5 to the RISCV t register ---> the arm register Rm
		#--------------------------
		# This block assemble all the transfered bits into s2 
		slli	s3, s3, 12		# set the transformed register into the proper bits from s3 to the instruction
		or	s2, s2, s3
		slli	s4, s4, 7		# set the transformed register into the proper bits from s4 to the instruction
		or	s2, s2, s4
		or	s2, s2, s5		# set the transformed register into the proper bits from s5 to the instruction
		#--------------------------
		
		
		j	QuittranslateALU	# jump to QuittranslateALU
		
	ADDI:
	# This block is used for transfer addi RISCV instruction
	
	
		
		li	t1, 0xE2800000		# Set the conditions(31-28), (27-26)
		mv	s2, t1			# set s2 = t1
		
		#--------------------------
		mv	t3, s1
		srai	t3, t3, 20		# The instruction get the value of the immediate from the riscv instruction to t3
		mv	a0, t3
		srli	t4, t3, 11
		bnez 	t4, addiChangeToSub	# if t4 == 1 then the immediate is a negative num, goto addiChangeToSub
		addiCont:
		jal	ra, computeRotation
		mv	s6, a0			# set s6 = a0
		or	s2, s2, s6		# set the transformed rotation value into the proper bits to the instruction
		#--------------------------
		# This block transfer the RISCV d register into ARM Rd register
		mv	t2, s1
		slli	t2, t2, 20		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s3, a0			# set s3 to the RISCV d register ---> the arm register Rd
		#--------------------------
		# This block transfer the RISCV s register into ARM Rn register
		mv	t2, s1
		slli	t2, t2, 12		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s4, a0			# set s4 to the RISCV s register ---> the arm register Rn 
		
		#--------------------------
		# This block assemble all the transfered bits into s2 
		slli	s3, s3, 12		# set the transformed register into the proper bits from s3 to the instruction
		or	s2, s2, s3
		slli	s4, s4, 16		# set the transformed register into the proper bits from s4 to the instruction
		or	s2, s2, s4		
		#--------------------------
		
		j	QuittranslateALU	# jump to QuittranslateALU
		
		addiChangeToSub:
		# This block transfered the add arm instruction into sub arm instruction
		
		li	t1, 0xE2400000		# Set the conditions(31-28), (27-26)
		mv	s2, t1			# set s2 = t1
		li	t6, -1			# load t6 = -1
		mul	t3, t6, t3 		# t3 = t6 * t3
		mv	a0, t3			# set a0 = t3
		j	addiCont		# jump back to addiCout
		
	ADD:
	# This block is used for transfer add RISCV instruction
	
		
		
		li	t1, 0xE0800000		# Set the conditions(31-28), (27-26)
		mv	s2, t1
		
		#--------------------------
		# This block transfer the RISCV d register into ARM Rd register
		mv	t2, s1
		slli	t2, t2, 20		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s3, a0			# set s3 to the RISCV d register ---> the arm register Rd
		#--------------------------
		# This block transfer the RISCV s register into ARM Rn register
		mv	t2, s1
		slli	t2, t2, 12		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s4, a0			# set s4 to the RISCV s register ---> the arm register Rn 
		#--------------------------
		# This block transfer the RISCV t register into ARM Rm register
		mv	t2, s1
		slli	t2, t2, 7		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s5, a0			# set s5 to the RISCV t register ---> the arm register Rm
		#--------------------------
		# This block assemble all the transfered bits into s2 
		slli	s3, s3, 12		# set the transformed register into the proper bits from s3 to the instruction
		or	s2, s2, s3
		slli	s4, s4, 16		# set the transformed register into the proper bits from s4 to the instruction
		or	s2, s2, s4
		or	s2, s2, s5		# set the transformed register into the proper bits from s5 to the instruction
		
		j	QuittranslateALU	# jump to QuittranslateALU
	
	SUB:
	# This block is used for transfer sub RISCV instruction
	
		
		
		li	t1, 0xE0400000		# Set the conditions(31-28), (27-26)
		mv	s2, t1
		
		#--------------------------
		# This block transfer the RISCV d register into ARM Rd register
		mv	t2, s1
		slli	t2, t2, 20		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s3, a0			# set s3 to the RISCV d register ---> the arm register Rd
		#--------------------------
		# This block transfer the RISCV s register into ARM Rn register
		mv	t2, s1
		slli	t2, t2, 12		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s4, a0			# set s4 to the RISCV s register ---> the arm register Rn 
		#--------------------------
		# This block transfer the RISCV t register into ARM Rm register
		mv	t2, s1
		slli	t2, t2, 7		# The following 2 instructions get the value of the register from the riscv instruction to t2
		srli	t2, t2, 27
		mv	a0, t2
		jal	ra, translateRegister
		mv	s5, a0			# set s5 to the RISCV t register ---> the arm register Rm
		#--------------------------
		# This block assemble all the transfered bits into s2 
		slli	s3, s3, 12		# set the transformed register into the proper bits from s3 to the instruction
		or	s2, s2, s3
		slli	s4, s4, 16		# set the transformed register into the proper bits from s4 to the instruction
		or	s2, s2, s4
		or	s2, s2, s5		# set the transformed register into the proper bits from s5 to the instruction
		
		
		j	QuittranslateALU	# jump to QuittranslateALU
	
	QuittranslateALU:
		# This block restore all the register
		# And move the result into a0 befor quit the function
		mv	a0, s2 		# set a0 = s2
		lw	ra, 0(sp)	# restore all the reigsters
		lw	s0, 4(sp)
		lw	s1, 12(sp)
		lw	s2, 16(sp)
		addi	sp, sp, 36	
		jalr	zero, ra, 0	# return

#-------------------------------------------------------------------------------------------------------------------------
# translateRegister
# This function converts the number of a RISC-V register passed in a0 into the number of a corresponding ARM register.
# Arguments:
# a0: RISC-V register to translate.
# Return Values:
# a0: translated ARM register.
#-------------------------------------------------------------------------------------------------------------------------

translateRegister:
	addi	sp, sp, -12	# create space for the stack
	sw	ra, 0(sp)	# store all the registers 
	sw	a0, 4(sp)
	sw	s0, 8(sp)	# set s0 to the transformed ARM register
	
	mv	t0, a0 		# set t0 = a0
	
	# This block get the 4th bit 
	# and use 4th bit to find out the 
	# the value of the register is greater or less than 15
	srli	t2, t0, 4	
	li	t3, 1
	beq	t2, t3, Over15
	j	Under15
	Over15:
		# the value of the register is over 15
		
		# This block jump to the branch to transfer the
		# value of the register.
		li	t4, 18
		beq	t4, t0, R5
		li	t4, 19
		beq	t4, t0, R6
		li	t4, 20
		beq	t4, t0, R7
		li	t4, 21
		beq	t4, t0, R8
		li	t4, 22
		beq	t4, t0, R9
		R5:
		# tranfer to R5
			li	t4, 5
			mv	a0, t4
			j	QuittranslateRegister	# jump to QuittranslateRegister
		R6:
		# tranfer to R6
			li	t4, 6
			mv	a0, t4
			j	QuittranslateRegister	# jump to QuittranslateRegister
		R7:
		# tranfer to R7
			li	t4, 7
			mv	a0, t4
			j	QuittranslateRegister	# jump to QuittranslateRegister
		R8:
		# tranfer to R8
			li	t4, 8
			mv	a0, t4
			j	QuittranslateRegister	# jump to QuittranslateRegister
		R9:
		# tranfer to R9
			li	t4, 9
			mv	a0, t4
			j	QuittranslateRegister	# jump to QuittranslateRegister
			
	Under15:
		# the value of the register is less than 15
		
		# This block jump to the branch to transfer the
		# value of the register.
		li	t4, 1
		beq	t4, t0, R14
		li	t4, 2
		beq	t4, t0, R13
		li	t4, 10
		beq	t4, t0, R10
		li	t4, 11
		beq	t4, t0, R11
		li	t4, 12
		beq	t4, t0, R12
		li	t4, 5
		beq	t4, t0, R0
		li	t4, 6
		beq	t4, t0, R1
		li	t4, 7
		beq	t4, t0, R2
		li	t4, 8
		beq	t4, t0, R3
		li	t4, 9
		beq	t4, t0, R4
		R14:
		# tranfer to R14
			li	t4, 14
			mv	a0, t4
			j	QuittranslateRegister	# jump to QuittranslateRegister
		R13:
		# tranfer to R13
			li	t4, 13
			mv	a0, t4
			j	QuittranslateRegister	# jump to QuittranslateRegister
		R10:
		# tranfer to R10
			li	t4, 10
			mv	a0, t4
			j	QuittranslateRegister	# jump to QuittranslateRegister
		R11:
		# tranfer to R11
			li	t4, 11
			mv	a0, t4
			j	QuittranslateRegister	# jump to QuittranslateRegister
		R12:
		# tranfer to R12
			li	t4, 12
			mv	a0, t4
			j	QuittranslateRegister	# jump to QuittranslateRegister
		R0:
		# tranfer to R0
			li	t4, 0
			mv	a0, t4
			j	QuittranslateRegister	# jump to QuittranslateRegister
		R1:
		# tranfer to R1
			li	t4, 1
			mv	a0, t4
			j	QuittranslateRegister	# jump to QuittranslateRegister
		R2:
		# tranfer to R2
			li	t4, 2
			mv	a0, t4
			j	QuittranslateRegister	# jump to QuittranslateRegister
		R3:
		# tranfer to R3
			li	t4, 3
			mv	a0, t4
			j	QuittranslateRegister	# jump to QuittranslateRegister
		R4:
		# tranfer to R4
			li	t4, 4
			mv	a0, t4
			j	QuittranslateRegister	# jump to QuittranslateRegister
	
			
		
	QuittranslateRegister:
		# This block restore all the register 
		# before quit the function
		
		lw	ra, 0(sp)	# restore all the registers that used
		lw	s0, 8(sp)
		addi	sp, sp, 12
		jalr	zero, ra, 0	# return 
		
	
	

#-------------------------------------------------------------------------------------------------------------------------
# computeRotation
# This function uses the immediate passed in a0 to generate rotate and immediate fields for an ARM immediate instruction. 
# The function treats the immediate as an unsigned number.
# Arguments:
# a0: RISC-V immediate in the bottom 20 bits.
# Return Values:
# a0: rotate in bits 11 to 8 and immediate in bits 7 to 0, with all other bits 0.
#-------------------------------------------------------------------------------------------------------------------------

computeRotation:
	addi	sp, sp, -36	# create space for the stack
	sw	ra, 0(sp)	# store all the registers
	sw	s0, 4(sp)
	sw	s1, 8(sp)
	sw	s2, 12(sp)
	sw	s3, 16(sp)
	sw	s4, 20(sp)
	sw	s5, 24(sp)
	sw	s6, 28(sp)	# s6 => the factor
	sw	s7, 32(sp)	# store the number of dividing by 2
	
	# This block store all the value that will use later on
	li	t1, 0		# set t1 = 0
	mv	s0, a0		# move the value in a0 to s0
	li	t0, 255		# load t0 = 255
	bgt	t0, s0, QuitComputeRotation	# goto QuitComputeRotation if s0 <= 255
	
	li	t2, 30		# load t2 = 30
	li	t3, 2		# load t3 = 2
	
	computeloop:
	# This loop interation get the result
	# of the division and the power of 2
	mv	s6, t2		# set s6 = t2
	div	s1, s0, t2	# get the result of s0/ t2 to s1
	rem	s2, s0, t2	# get the reminder of s0/ t2 to s2
	beqz	s2, computepowerloop	# jump to computepowerloop if s2 == 0
	sub	t2, t2, t3		# t2 = t2 - t3
	j	computeloop	# jump to computeloop
	
	computepowerloop:
	# This loop interation calculate the rotation number 
	li	t3, 2		# load t3 = 2
	li	t4, 1		# load t4 = 1
	div	s6, s6, t3	# s6 is the reult of s6/ t3
	addi	s7, s7, 1	# s7 += 1
	bne 	s6, t4, computepowerloop	# goto computepowerloop if s6 != t4
	j	signValue	# jump to signValue
	
	signValue:
	# store the transfered bits into a0
	li	t3, 32		# load t3 = 32
	sub	t2, t3, s7	# t2 = t3 - s7
	slli	s4, t2, 7	# left logic shift by 7 to set the rotation number in the proper position
	or	s0, s4, s1	# set the rotaion number into the proper bits
	mv	a0, s0
	j	QuitComputeRotation	# goto QuitComputeRotation
	
	QuitComputeRotation:
	# This block restore all the registers before quit the function
	lw	ra, 0(sp)	# restore all the registers that used.
	lw	s0, 4(sp)
	lw	s1, 8(sp)
	lw	s2, 12(sp)
	lw	s3, 16(sp)
	lw	s4, 20(sp)
	lw	s5, 24(sp)
	lw	s6, 28(sp)
	lw	s7, 32(sp)
	addi	sp, sp, 36
	jalr	zero, ra, 0	# return
