/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'CPU' in SOPC Builder design 'sopc_config'
 * SOPC Builder design path: ../../sopc_config.sopcinfo
 *
 * Generated: Sat Oct 21 21:43:15 CEST 2017
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2_gen2"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x02003820
#define ALT_CPU_CPU_ARCH_NIOS2_R1
#define ALT_CPU_CPU_FREQ 50000000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x00000000
#define ALT_CPU_CPU_IMPLEMENTATION "fast"
#define ALT_CPU_DATA_ADDR_WIDTH 0x1a
#define ALT_CPU_DCACHE_BYPASS_MASK 0x80000000
#define ALT_CPU_DCACHE_LINE_SIZE 32
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_DCACHE_SIZE 2048
#define ALT_CPU_EXCEPTION_ADDR 0x02002020
#define ALT_CPU_FLASH_ACCELERATOR_LINES 0
#define ALT_CPU_FLASH_ACCELERATOR_LINE_SIZE 0
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 50000000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 1
#define ALT_CPU_HARDWARE_MULX_PRESENT 0
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_EXTRA_EXCEPTION_INFO
#define ALT_CPU_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 32
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_ICACHE_SIZE 4096
#define ALT_CPU_INITDA_SUPPORTED
#define ALT_CPU_INST_ADDR_WIDTH 0x1a
#define ALT_CPU_NAME "CPU"
#define ALT_CPU_NUM_OF_SHADOW_REG_SETS 0
#define ALT_CPU_OCI_VERSION 1
#define ALT_CPU_RESET_ADDR 0x01000000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x02003820
#define NIOS2_CPU_ARCH_NIOS2_R1
#define NIOS2_CPU_FREQ 50000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x00000000
#define NIOS2_CPU_IMPLEMENTATION "fast"
#define NIOS2_DATA_ADDR_WIDTH 0x1a
#define NIOS2_DCACHE_BYPASS_MASK 0x80000000
#define NIOS2_DCACHE_LINE_SIZE 32
#define NIOS2_DCACHE_LINE_SIZE_LOG2 5
#define NIOS2_DCACHE_SIZE 2048
#define NIOS2_EXCEPTION_ADDR 0x02002020
#define NIOS2_FLASH_ACCELERATOR_LINES 0
#define NIOS2_FLASH_ACCELERATOR_LINE_SIZE 0
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 1
#define NIOS2_HARDWARE_MULX_PRESENT 0
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_EXTRA_EXCEPTION_INFO
#define NIOS2_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 32
#define NIOS2_ICACHE_LINE_SIZE_LOG2 5
#define NIOS2_ICACHE_SIZE 4096
#define NIOS2_INITDA_SUPPORTED
#define NIOS2_INST_ADDR_WIDTH 0x1a
#define NIOS2_NUM_OF_SHADOW_REG_SETS 0
#define NIOS2_OCI_VERSION 1
#define NIOS2_RESET_ADDR 0x01000000


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_NEW_SDRAM_CONTROLLER
#define __ALTERA_AVALON_ONCHIP_MEMORY2
#define __ALTERA_AVALON_PERFORMANCE_COUNTER
#define __ALTERA_AVALON_SYSID_QSYS
#define __ALTERA_AVALON_TIMER
#define __ALTERA_NIOS2_GEN2
#define __ALTPLL
#define __LCD_8080_SLAVE
#define __PIO_IP


/*
 * LCD_8080_Slave_0 configuration
 *
 */

#define ALT_MODULE_CLASS_LCD_8080_Slave_0 LCD_8080_Slave
#define LCD_8080_SLAVE_0_BASE 0x2004078
#define LCD_8080_SLAVE_0_IRQ -1
#define LCD_8080_SLAVE_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define LCD_8080_SLAVE_0_NAME "/dev/LCD_8080_Slave_0"
#define LCD_8080_SLAVE_0_SPAN 8
#define LCD_8080_SLAVE_0_TYPE "LCD_8080_Slave"


/*
 * LEDS configuration
 *
 */

#define ALT_MODULE_CLASS_LEDS PIO_IP
#define LEDS_BASE 0x2004088
#define LEDS_IRQ -1
#define LEDS_IRQ_INTERRUPT_CONTROLLER_ID -1
#define LEDS_NAME "/dev/LEDS"
#define LEDS_SPAN 8
#define LEDS_TYPE "PIO_IP"


/*
 * PLL configuration
 *
 */

#define ALT_MODULE_CLASS_PLL altpll
#define PLL_BASE 0x2004060
#define PLL_IRQ -1
#define PLL_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PLL_NAME "/dev/PLL"
#define PLL_SPAN 16
#define PLL_TYPE "altpll"


/*
 * SDRAM_ctrl configuration
 *
 */

#define ALT_MODULE_CLASS_SDRAM_ctrl altera_avalon_new_sdram_controller
#define SDRAM_CTRL_BASE 0x1000000
#define SDRAM_CTRL_CAS_LATENCY 3
#define SDRAM_CTRL_CONTENTS_INFO
#define SDRAM_CTRL_INIT_NOP_DELAY 0.0
#define SDRAM_CTRL_INIT_REFRESH_COMMANDS 2
#define SDRAM_CTRL_IRQ -1
#define SDRAM_CTRL_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SDRAM_CTRL_IS_INITIALIZED 1
#define SDRAM_CTRL_NAME "/dev/SDRAM_ctrl"
#define SDRAM_CTRL_POWERUP_DELAY 100.0
#define SDRAM_CTRL_REFRESH_PERIOD 15.625
#define SDRAM_CTRL_REGISTER_DATA_IN 1
#define SDRAM_CTRL_SDRAM_ADDR_WIDTH 0x17
#define SDRAM_CTRL_SDRAM_BANK_WIDTH 2
#define SDRAM_CTRL_SDRAM_COL_WIDTH 9
#define SDRAM_CTRL_SDRAM_DATA_WIDTH 16
#define SDRAM_CTRL_SDRAM_NUM_BANKS 4
#define SDRAM_CTRL_SDRAM_NUM_CHIPSELECTS 1
#define SDRAM_CTRL_SDRAM_ROW_WIDTH 12
#define SDRAM_CTRL_SHARED_DATA 0
#define SDRAM_CTRL_SIM_MODEL_BASE 0
#define SDRAM_CTRL_SPAN 16777216
#define SDRAM_CTRL_STARVATION_INDICATOR 0
#define SDRAM_CTRL_TRISTATE_BRIDGE_SLAVE ""
#define SDRAM_CTRL_TYPE "altera_avalon_new_sdram_controller"
#define SDRAM_CTRL_T_AC 5.5
#define SDRAM_CTRL_T_MRD 3
#define SDRAM_CTRL_T_RCD 20.0
#define SDRAM_CTRL_T_RFC 70.0
#define SDRAM_CTRL_T_RP 20.0
#define SDRAM_CTRL_T_WR 14.0


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "Cyclone IV E"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/jtag_uart"
#define ALT_STDERR_BASE 0x2004090
#define ALT_STDERR_DEV jtag_uart
#define ALT_STDERR_IS_JTAG_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_jtag_uart"
#define ALT_STDIN "/dev/jtag_uart"
#define ALT_STDIN_BASE 0x2004090
#define ALT_STDIN_DEV jtag_uart
#define ALT_STDIN_IS_JTAG_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_jtag_uart"
#define ALT_STDOUT "/dev/jtag_uart"
#define ALT_STDOUT_BASE 0x2004090
#define ALT_STDOUT_DEV jtag_uart
#define ALT_STDOUT_IS_JTAG_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_jtag_uart"
#define ALT_SYSTEM_NAME "sopc_config"


/*
 * hal configuration
 *
 */

#define ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
#define ALT_MAX_FD 32
#define ALT_SYS_CLK TIMER
#define ALT_TIMESTAMP_CLK none


/*
 * jtag_uart configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_uart altera_avalon_jtag_uart
#define JTAG_UART_BASE 0x2004090
#define JTAG_UART_IRQ 0
#define JTAG_UART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JTAG_UART_NAME "/dev/jtag_uart"
#define JTAG_UART_READ_DEPTH 64
#define JTAG_UART_READ_THRESHOLD 8
#define JTAG_UART_SPAN 8
#define JTAG_UART_TYPE "altera_avalon_jtag_uart"
#define JTAG_UART_WRITE_DEPTH 64
#define JTAG_UART_WRITE_THRESHOLD 8


/*
 * performance_counter configuration
 *
 */

#define ALT_MODULE_CLASS_performance_counter altera_avalon_performance_counter
#define PERFORMANCE_COUNTER_BASE 0x2004000
#define PERFORMANCE_COUNTER_HOW_MANY_SECTIONS 3
#define PERFORMANCE_COUNTER_IRQ -1
#define PERFORMANCE_COUNTER_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PERFORMANCE_COUNTER_NAME "/dev/performance_counter"
#define PERFORMANCE_COUNTER_SPAN 64
#define PERFORMANCE_COUNTER_TYPE "altera_avalon_performance_counter"


/*
 * sysid configuration
 *
 */

#define ALT_MODULE_CLASS_sysid altera_avalon_sysid_qsys
#define SYSID_BASE 0x2004080
#define SYSID_ID 12213764
#define SYSID_IRQ -1
#define SYSID_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SYSID_NAME "/dev/sysid"
#define SYSID_SPAN 8
#define SYSID_TIMESTAMP 1508614532
#define SYSID_TYPE "altera_avalon_sysid_qsys"


/*
 * tightly_coupled_data_memory configuration
 *
 */

#define ALT_MODULE_CLASS_tightly_coupled_data_memory altera_avalon_onchip_memory2
#define TIGHTLY_COUPLED_DATA_MEMORY_ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR 0
#define TIGHTLY_COUPLED_DATA_MEMORY_ALLOW_MRAM_SIM_CONTENTS_ONLY_FILE 0
#define TIGHTLY_COUPLED_DATA_MEMORY_BASE 0x2000000
#define TIGHTLY_COUPLED_DATA_MEMORY_CONTENTS_INFO ""
#define TIGHTLY_COUPLED_DATA_MEMORY_DUAL_PORT 0
#define TIGHTLY_COUPLED_DATA_MEMORY_GUI_RAM_BLOCK_TYPE "AUTO"
#define TIGHTLY_COUPLED_DATA_MEMORY_INIT_CONTENTS_FILE "sopc_config_tightly_coupled_data_memory"
#define TIGHTLY_COUPLED_DATA_MEMORY_INIT_MEM_CONTENT 0
#define TIGHTLY_COUPLED_DATA_MEMORY_INSTANCE_ID "NONE"
#define TIGHTLY_COUPLED_DATA_MEMORY_IRQ -1
#define TIGHTLY_COUPLED_DATA_MEMORY_IRQ_INTERRUPT_CONTROLLER_ID -1
#define TIGHTLY_COUPLED_DATA_MEMORY_NAME "/dev/tightly_coupled_data_memory"
#define TIGHTLY_COUPLED_DATA_MEMORY_NON_DEFAULT_INIT_FILE_ENABLED 0
#define TIGHTLY_COUPLED_DATA_MEMORY_RAM_BLOCK_TYPE "AUTO"
#define TIGHTLY_COUPLED_DATA_MEMORY_READ_DURING_WRITE_MODE "DONT_CARE"
#define TIGHTLY_COUPLED_DATA_MEMORY_SINGLE_CLOCK_OP 0
#define TIGHTLY_COUPLED_DATA_MEMORY_SIZE_MULTIPLE 1
#define TIGHTLY_COUPLED_DATA_MEMORY_SIZE_VALUE 8192
#define TIGHTLY_COUPLED_DATA_MEMORY_SPAN 8192
#define TIGHTLY_COUPLED_DATA_MEMORY_TYPE "altera_avalon_onchip_memory2"
#define TIGHTLY_COUPLED_DATA_MEMORY_WRITABLE 1


/*
 * tightly_coupled_instruction_memory configuration
 *
 */

#define ALT_MODULE_CLASS_tightly_coupled_instruction_memory altera_avalon_onchip_memory2
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR 0
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_ALLOW_MRAM_SIM_CONTENTS_ONLY_FILE 0
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_BASE 0x2002000
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_CONTENTS_INFO ""
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_DUAL_PORT 1
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_GUI_RAM_BLOCK_TYPE "AUTO"
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_INIT_CONTENTS_FILE "sopc_config_tightly_coupled_instruction_memory"
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_INIT_MEM_CONTENT 1
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_INSTANCE_ID "NONE"
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_IRQ -1
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_IRQ_INTERRUPT_CONTROLLER_ID -1
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_NAME "/dev/tightly_coupled_instruction_memory"
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_NON_DEFAULT_INIT_FILE_ENABLED 0
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_RAM_BLOCK_TYPE "AUTO"
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_READ_DURING_WRITE_MODE "DONT_CARE"
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_SINGLE_CLOCK_OP 0
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_SIZE_MULTIPLE 1
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_SIZE_VALUE 4096
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_SPAN 4096
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_TYPE "altera_avalon_onchip_memory2"
#define TIGHTLY_COUPLED_INSTRUCTION_MEMORY_WRITABLE 1


/*
 * timer configuration
 *
 */

#define ALT_MODULE_CLASS_timer altera_avalon_timer
#define TIMER_ALWAYS_RUN 0
#define TIMER_BASE 0x2004040
#define TIMER_COUNTER_SIZE 32
#define TIMER_FIXED_PERIOD 1
#define TIMER_FREQ 50000000
#define TIMER_IRQ 1
#define TIMER_IRQ_INTERRUPT_CONTROLLER_ID 0
#define TIMER_LOAD_VALUE 499999
#define TIMER_MULT 0.001
#define TIMER_NAME "/dev/timer"
#define TIMER_PERIOD 10
#define TIMER_PERIOD_UNITS "ms"
#define TIMER_RESET_OUTPUT 0
#define TIMER_SNAPSHOT 1
#define TIMER_SPAN 32
#define TIMER_TICKS_PER_SEC 100
#define TIMER_TIMEOUT_PULSE_OUTPUT 0
#define TIMER_TYPE "altera_avalon_timer"

#endif /* __SYSTEM_H_ */