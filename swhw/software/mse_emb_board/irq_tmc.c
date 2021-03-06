#include <stdio.h>
#include <stdbool.h>
#include "io.h"
#include "system.h"
#include "alt_types.h"
#include "sys/alt_irq.h"
#include "priv/alt_legacy_irq.h"
#include "altera_avalon_timer_regs.h"
#include "altera_avalon_performance_counter.h"
#define COUNT_MAX 1000
#define CLEAR_IRQ 0x0000
#define PERFORMANCE_COUNTER_SEG_ISR 1

#define enable 0
#if enable == 1

typedef struct Counter {
	alt_u32 value;
	bool isNew;
} Counter;
static void handle_timerIRQ(void* context, alt_u32 id)__attribute__ ((section(".exceptions")));
static alt_u8 a = 1;
static alt_u8 dir = 1;

int main(void) {
	Counter downTimer = { .value = 0, .isNew = false };
	alt_irq_context statusISR;
	puts("Reset performance counter");
	PERF_RESET(PERFORMANCE_COUNTER_BASE);

	//setup LEDs
	IOWR_8DIRECT(LEDS_BASE, 0, 0xFF); //all outputs

	puts("Disable IRQs");
	statusISR = alt_irq_disable_all();
	puts("Register timer IRQ handler...");
	alt_irq_register(TIMER_IRQ, &downTimer, (alt_isr_func) handle_timerIRQ);
	puts("Clear pending timer IRQs...");
	IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_BASE, CLEAR_IRQ);
	puts("Configure Timer");
	IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_BASE,
			ALTERA_AVALON_TIMER_CONTROL_ITO_MSK | ALTERA_AVALON_TIMER_CONTROL_CONT_MSK | ALTERA_AVALON_TIMER_CONTROL_START_MSK);
	puts("Start measuring with performance counter");
	PERF_START_MEASURING(PERFORMANCE_COUNTER_BASE);
	puts("Timer initialized and started\n");
	alt_irq_enable_all(statusISR);
	puts("Enabled all IRQs\n");
	while (downTimer.value <= COUNT_MAX) {
		if (downTimer.isNew) {
			printf("New count value = %lu\n", (alt_u32) (downTimer.isNew =
			false, downTimer.value));
			printf("LEDS Value %lu\n", (alt_u32) IORD_8DIRECT(LEDS_BASE, 1));
		}
		asm volatile ("nop");
	}
	puts("Stop measuring with performance counter");
	PERF_STOP_MEASURING(PERFORMANCE_COUNTER_BASE);
	perf_print_formatted_report(PERFORMANCE_COUNTER_BASE, alt_get_cpu_freq(),
	PERFORMANCE_COUNTER_SEG_ISR, "ISR");
}

static void handle_timerIRQ(void* context, alt_u32 id) {
	PERF_BEGIN(PERFORMANCE_COUNTER_BASE, PERFORMANCE_COUNTER_SEG_ISR); //first section
	Counter* data_ptr = (Counter*) context;
	++(data_ptr->value);
	data_ptr->isNew = true;
	if ((data_ptr->value % 10) == 0) {
		IOWR_8DIRECT(LEDS_BASE, 2, a);
		if (dir > 0) {
			a = a << 1;
			if (a == 0b10000000) {
				dir = 0;
			}
		} else {
			a = a >> 1;
			if (a == 1) {
				dir = 1;
			}
		}
	}
	IOWR_16DIRECT(TIMER_BASE, ALTERA_AVALON_TIMER_STATUS_REG, CLEAR_IRQ);
	PERF_END(PERFORMANCE_COUNTER_BASE, PERFORMANCE_COUNTER_SEG_ISR); //first section
}

#endif
