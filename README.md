# RISCV_ARM_Transition

### Project Overview: RISC-V to ARM Instruction Set Translator

**Author:** Ke Li

**Institution:** University of Alberta

**Course:**  Computer Organization and Architecture I

**Instructors:** Jose Nelson Amaral

**Project Description:**
This project involves the development of an assembly language program that efficiently translates RISC-V instructions into equivalent ARM instructions. The primary objective is to create a software bridge enabling the execution of RISC-V code on ARM-based architectures, broadening the applicability of RISC-V programs.

**Key Features:**
1. **Instruction Translation:** The core functionality of the project is to convert RISC-V instructions (both ALU and control instructions) into their ARM counterparts. This involves a detailed understanding of the instruction sets of both architectures and precise mapping between them.

2. **Memory Mapping:** The program makes use of memory spaces allocated for tables like the RISCTOARMTable and BranchTable. These tables are crucial in managing the conversion process, especially for managing instruction addresses and offsets.

3. **Two-Pass Translation Process:** 
    - **First Pass:** Translates basic instructions and stores addresses in the mapping tables.
    - **Second Pass:** Handles branch instructions where offsets need to be recalculated and adjusted according to ARM architecture.

4. **Modular Design:** The translation process is broken down into functions, each handling specific types of instructions. For example, `translateALU` deals with Arithmetic Logic Unit instructions, while `translateControl` handles control flow instructions like branches and jumps.

5. **Register Conversion:** A crucial aspect of the translation is converting RISC-V register references to corresponding ARM registers, handled by the `translateRegister` function.

6. **Error Handling and Edge Cases:** The code includes checks and balances to handle unforeseen inputs, such as invalid instruction formats or out-of-bounds memory access.

**Challenges and Learning Outcomes:**
- Deepened understanding of two major instruction set architectures (ISA) - RISC-V and ARM.
- Gained practical experience in low-level programming and assembly language nuances.
- Developed problem-solving skills in mapping and translating between different ISAs.
- Enhanced knowledge in handling memory and register operations at the assembly level.

**Usage Scenario:**
This translator can be integrated into development environments or used as a standalone tool for developers working on cross-platform applications, especially those transitioning from RISC-V to ARM platforms.


**Future Scope:**
- Extending the translator to cover more complex and nuanced instructions and addressing modes.
- Optimizing the translation process for speed and memory efficiency.
- Exploring automated testing frameworks to validate translated ARM instructions against their RISC-V counterparts.
