/*
 * main.c
 *
 *  Created on: Sep 30, 2017
 *      Author: silvan
 */

#include <stdio.h>
#include <stdbool.h>
#include "io.h"
#include "system.h"
#include "tuxAnimation_1.h"

#include "alt_types.h"
#include "sys/alt_irq.h"
#include "priv/alt_legacy_irq.h"
#include "altera_avalon_timer_regs.h"
#include "altera_avalon_performance_counter.h"

#define COUNT_MAX 1000
#define CLEAR_IRQ 0x0000
#define PERFORMANCE_COUNTER_SEG_A 1
#define PERFORMANCE_COUNTER_SEG_ISR 1
#define PERFORMANCE_COUNTER_SEG_BUTTON 2

#define LCD_CTRL_OFFSET 0x02
#define LCD_DATA_OFFSET 0x00
// offset in 8bit size...
#define MANDELBROT 0
#define MEGESORT 1

typedef struct Counter {
	alt_u32 value;
	bool isNew;
} Counter;

static void handle_timerIRQ(void* context, alt_u32 id) __attribute__ ((section (".exceptions")));
//static void handle_timerIRQ(void* context, alt_u32 id);

//static void handle_buttonIRQ(void* context, alt_u32 id) __attribute__ ((section (".exceptions")));

void LCD_Write_Command(int command);
void LCD_Write_Data(int data);
void init_LCD(void);

void mandelbrot(float zre, float zim, float cre, float cim, float* rre,
		float* rim);

void mergeSort(int* a, int*b, int l, int r);
void merge(int* a, int* b, int l, int m, int r);

int getMax(int arr[], int n);
void countSort(int arr[], int n, int exp);
void radixsort(int arr[], int n);

int main(void) {
	/* Main application */
	/* Initialize the interrupt controller first! */
	/*
	 Counter downTimer = {.value=0, .isNew = false};
	 Counter userCounter = {.value=0, .isNew = false};
	 alt_irq_context statusISR;

	 puts("Reset performance counter");
	 PERF_RESET(PERFORMANCE_COUNTER_BASE);

	 puts("Disable IRQs");
	 statusISR = alt_irq_disable_all();

	 puts("Register timer IRQ handler...");
	 alt_irq_register(TIMER_IRQ, &downTimer, (alt_isr_func)handle_timerIRQ);

	 puts("Clear pending timer IRQs...");
	 IOWR_16DIRECT(TIMER_BASE, ALTERA_AVALON_TIMER_STATUS_REG, CLEAR_IRQ);

	 puts("Configure custom gpio block");
	 IOWR_8DIRECT(GPIO_0_BASE, 0, 255);
	 puts("Clear all outputs");
	 IOWR_8DIRECT(GPIO_0_BASE, 7, 255);

	 puts("GPIO 1 as input with interrupts");
	 IOWR_8DIRECT(GPIO_1_BASE, 0, 0);
	 IOWR_8DIRECT(GPIO_1_BASE, 1, 255);

	 puts("Configure Timer");
	 IOWR_16DIRECT(TIMER_BASE, ALTERA_AVALON_TIMER_CONTROL_REG,
	 ALTERA_AVALON_TIMER_CONTROL_ITO_MSK  | // enable IRQ
	 ALTERA_AVALON_TIMER_CONTROL_CONT_MSK | // continuous count
	 ALTERA_AVALON_TIMER_CONTROL_START_MSK); // start

	 puts("Start measuring with performance counter");
	 PERF_START_MEASURING(PERFORMANCE_COUNTER_BASE); // start global counter

	 puts("Timer initialized and started\n");

	 alt_irq_enable_all(statusISR);
	 puts("Enabled all IRQs\n");

	 while(downTimer.value <= COUNT_MAX) {
	 if (downTimer.isNew)
	 printf("New count value = %lu\n", (alt_u32)(downTimer.isNew=false, downTimer.value));
	 if (userCounter.isNew)
	 printf("New count value = %lu\n", (alt_u32)(userCounter.isNew=false, userCounter.value));
	 asm volatile ("nop");
	 }

	 printf("Sequence end, userCntr = %lu\n", userCounter.value);
	 puts("Stop measuring with performance counter");
	 PERF_STOP_MEASURING(PERFORMANCE_COUNTER_BASE);

	 perf_print_formatted_report(PERFORMANCE_COUNTER_BASE, alt_get_cpu_freq(), 1, "ISR");

	 */
	IOWR_16DIRECT(LCD_8080_SLAVE_0_BASE,LCD_CTRL_OFFSET,0x08);
	printf("%d",IORD_16DIRECT(LCD_8080_SLAVE_0_BASE,LCD_CTRL_OFFSET));
	puts("Init display");
	while (IORD_16DIRECT(LCD_8080_SLAVE_0_BASE,LCD_CTRL_OFFSET) & 0x0004);
	init_LCD();

	LCD_Write_Command(0x002C);

	for (int i = 0; i < 320; i++) {
		for (int j = 0; j < 240; j++) {
			alt_u16 data = (((alt_u16) picture_array_mario_1[i][2 * j]) << 8)
					| ((alt_u16) picture_array_mario_1[i][(2 * j + 1)]);
			alt_u16 green = (0b0000011111100000 & data) >> 5;
			alt_u16 red = (0b1111100000000000 & data) >> 11;
			alt_u16 blue = (0b0000000000011111 & data);
			LCD_Write_Data((blue << 11) | (green << 5 | red));
//			for (int i=0; i < 1000 ;i++);
		}
	}

#if MANDELBROT == 1
	LCD_Write_Command(0x002C);

	float re, im, cre, cim;
	int value;

	for (int i=0; i < 320;i++) {
		for (int j=0; j< 240;j++) {
			re = 0.0;
			im = 0.0;

			cre = (3.*i)/(320) - 2;
			cim = (2.*j)/(240) - 1;

			value = 65535;

			for (int k=0; k<100;k++) {
				PERF_BEGIN(PERFORMANCE_COUNTER_BASE, PERFORMANCE_COUNTER_SEG_A);
				mandelbrot(re, im, cre, cim, &re, &im);
				if (re*re+im*im>=4) {
					value = k*655;
					break;
				}
				PERF_END(PERFORMANCE_COUNTER_BASE, PERFORMANCE_COUNTER_SEG_A);
			}

			LCD_Write_Data(value);
		}
	}
#endif

#if MEGESORT == 1
	int a[160] = { 98, 202, 164, 104, 55, 74, 187, 149, 106, 66, 77, 182, 126,
			2, 134, 143, 233, 203, 78, 49, 124, 121, 52, 232, 185, 230, 115,
			113, 35, 172, 95, 3, 184, 123, 110, 61, 212, 87, 146, 211, 31, 174,
			142, 19, 199, 119, 12, 145, 112, 163, 73, 176, 140, 200, 131, 14,
			175, 169, 43, 206, 82, 197, 204, 198, 208, 44, 135, 8, 158, 178,
			171, 20, 157, 207, 224, 180, 152, 89, 136, 24, 133, 85, 223, 196,
			173, 75, 101, 53, 193, 201, 238, 221, 114, 127, 63, 96, 151, 216,
			148, 28, 99, 86, 195, 67, 154, 226, 56, 138, 18, 27, 227, 218, 107,
			125, 103, 81, 153, 105, 68, 34, 64, 144, 84, 41, 188, 220, 239, 25,
			166, 228, 165, 209, 229, 141, 59, 76, 194, 190, 181, 16, 93, 217,
			205, 132, 21, 236, 179, 39, 94, 48, 10, 62, 139, 46, 36, 225, 33,
			210, 155, 69 };
	;
	int b[160];

	// write to display
	LCD_Write_Command(0x002C);
	for (int i = 0; i < 160; i++) {
		for (int k = 0; k < 2; k++) {
			for (int j = 0; j < *(a + i); j++) {
				LCD_Write_Data(0x0000);
			}
			for (int j = *(a + i) + 1; j <= 240; j++) {
				LCD_Write_Data(0xFFFF);
			}
			//write each line twice
		}
	}
	puts("Reset performance counter");
	PERF_RESET(PERFORMANCE_COUNTER_BASE);

	puts("Start measuring with performance counter");
	PERF_START_MEASURING(PERFORMANCE_COUNTER_BASE); // start global counter
	//radixsort(a, 160);
	mergeSort((int*)&a,(int*)&b,0,159);
	puts("Stop measuring with performance counter");
	PERF_STOP_MEASURING(PERFORMANCE_COUNTER_BASE);
	for (int i = 0; i < 320; i++) {
		for (int j = 0; j < 240; j++) {
			alt_u16 data = (((alt_u16) picture_array_mario_1[i][2 * j]) << 8)
					| ((alt_u16) picture_array_mario_1[i][(2 * j + 1)]);
			alt_u16 green = (0b0000011111100000 & data) >> 5;
			alt_u16 red = (0b1111100000000000 & data) >> 11;
			alt_u16 blue = (0b0000000000011111 & data);
			LCD_Write_Data((blue << 11) | (green << 5 | red));
//			for (int i=0; i < 1000 ;i++);
		}
	}

#endif
	perf_print_formatted_report(PERFORMANCE_COUNTER_BASE, alt_get_cpu_freq(), 1,
			"ISR");
	IOWR_16DIRECT(LCD_8080_SLAVE_0_BASE,LCD_CTRL_OFFSET,0x08);

}

void mandelbrot(float zre, float zim, float cre, float cim, float* rre,
		float* rim) {
	float re = zre * zre - zim * zim;
	float im = 2 * zre * zim;
	*rre = re + cre;
	*rim = im + cim;
}

static void handle_timerIRQ(void* context, alt_u32 id) {
	/* start timing a code section */
	PERF_BEGIN(PERFORMANCE_COUNTER_BASE, PERFORMANCE_COUNTER_SEG_ISR);

	Counter* data_ptr = (Counter*) context;
	++(data_ptr->value);
	data_ptr->isNew = true;

	/* write counter value to LED */
	IOWR_8DIRECT(LEDS_BASE, 1, data_ptr->value);
	/* clear IRQ */
	IOWR_16DIRECT(TIMER_BASE, ALTERA_AVALON_TIMER_STATUS_REG, CLEAR_IRQ);

	/* stop timing a code section */
	PERF_END(PERFORMANCE_COUNTER_BASE, PERFORMANCE_COUNTER_SEG_ISR);
}

void LCD_Write_Command(int command) {
	IOWR_16DIRECT(LCD_8080_SLAVE_0_BASE, LCD_DATA_OFFSET, command);
	IOWR_16DIRECT(LCD_8080_SLAVE_0_BASE, LCD_CTRL_OFFSET, 0x0001);
}

void LCD_Write_Data(int data) {
	IOWR_16DIRECT(LCD_8080_SLAVE_0_BASE, LCD_DATA_OFFSET, data);
	IOWR_16DIRECT(LCD_8080_SLAVE_0_BASE, LCD_CTRL_OFFSET, 0x002);
}

void init_LCD() {
	LCD_Write_Command(0x0001); // software reset

	LCD_Write_Command(0x0028);     //display OFF
	LCD_Write_Command(0x0011);     //exit SLEEP mode
	LCD_Write_Data(0x0000);

	LCD_Write_Command(0x00CB);     //Power Control A
	LCD_Write_Data(0x0039);     //always 0x39
	LCD_Write_Data(0x002C);     //always 0x2C
	LCD_Write_Data(0x0000);     //always 0x00
	LCD_Write_Data(0x0034);     //Vcore = 1.6V
	LCD_Write_Data(0x0002);     //DDVDH = 5.6V

	LCD_Write_Command(0x00CF);     //Power Control B
	LCD_Write_Data(0x0000);     //always 0x00
	LCD_Write_Data(0x0081);     //PCEQ off
	LCD_Write_Data(0x0030);     //ESD protection

	LCD_Write_Command(0x00E8);     //Driver timing control A
	LCD_Write_Data(0x0085);     //non - overlap
	LCD_Write_Data(0x0001);     //EQ timing
	LCD_Write_Data(0x0079);     //Pre-chargetiming
	LCD_Write_Command(0x00EA);     //Driver timing control B
	LCD_Write_Data(0x0000);        //Gate driver timing
	LCD_Write_Data(0x0000);        //always 0x00

	LCD_Write_Data(0x0064);        //soft start
	LCD_Write_Data(0x0003);        //power on sequence
	LCD_Write_Data(0x0012);        //power on sequence
	LCD_Write_Data(0x0081);        //DDVDH enhance on

	LCD_Write_Command(0x00F7);     //Pump ratio control
	LCD_Write_Data(0x0020);     //DDVDH=2xVCI

	LCD_Write_Command(0x00C0);    //power control 1
	LCD_Write_Data(0x0026);
	LCD_Write_Data(0x0004);  //second parameter for ILI9340 (ignored by ILI9341)

	LCD_Write_Command(0x00C1);     //power control 2
	LCD_Write_Data(0x0011);

	LCD_Write_Command(0x00C5);     //VCOM control 1
	LCD_Write_Data(0x0035);
	LCD_Write_Data(0x003E);

	LCD_Write_Command(0x00C7);     //VCOM control 2
	LCD_Write_Data(0x00BE);

	LCD_Write_Command(0x00B1);     //frame rate control
	LCD_Write_Data(0x0000);
	LCD_Write_Data(0x0010);

	LCD_Write_Command(0x003A);    //pixel format = 16 bit per pixel
	LCD_Write_Data(0x0055);

	LCD_Write_Command(0x00B6);     //display function control
	LCD_Write_Data(0x000A);
	LCD_Write_Data(0x00A2);

	LCD_Write_Command(0x00F2);     //3G Gamma control
	LCD_Write_Data(0x0002);         //off

	LCD_Write_Command(0x0026);     //Gamma curve 3
	LCD_Write_Data(0x0001);

	LCD_Write_Command(0x0036);     //memory access control = BGR
	LCD_Write_Data(0x0000);

	LCD_Write_Command(0x002A);     //column address set
	LCD_Write_Data(0x0000);
	LCD_Write_Data(0x0000);        //start 0x0000
	LCD_Write_Data(0x0000);
	LCD_Write_Data(0x00EF);        //end 0x00EF

	LCD_Write_Command(0x002B);    //page address set
	LCD_Write_Data(0x0000);
	LCD_Write_Data(0x0000);        //start 0x0000
	LCD_Write_Data(0x0001);
	LCD_Write_Data(0x003F);        //end 0x013F

	LCD_Write_Command(0x0029);  //display ON

}

void mergeSort(int* a, int*b, int l, int r) {
	if (l < r) {
		int m = l + (r - l) / 2;
		mergeSort(a, b, l, m);
		mergeSort(a, b, m + 1, r);
		merge(a, b, l, m, r);
	}
}

void merge(int* a, int* b, int l, int m, int r) {
	int i = l, j = m + 1, k = l;
	//merge until middle is reached (if it is reached, all other elements must be greater than the others)
	while (i <= m && j <= r) {
		if (*(a + i) <= *(a + j)) {
			*(b + k) = *(a + i);
			i++;
		} else {
			*(b + k) = *(a + j);
			j++;
		}
		k++;
	}
	//descide wheter upper or lower array is bigger
	if (i > m) {
		for (int h = j; h <= r; h++) {
			*(b + k + h - j) = *(a + h);
		}
	} else {
		for (int h = i; h <= m; h++) {
			*(b + k + h - i) = *(a + h);
		}
	}
	for (int h = l; h <= r; h++) {
		*(a + h) = *(b + h);
	}
	PERF_BEGIN(PERFORMANCE_COUNTER_BASE, PERFORMANCE_COUNTER_SEG_A);
	// write to display
	LCD_Write_Command(0x002C);
	for (int i = 0; i < 160; i++) {
		for (int k = 0; k < 2; k++) {
			for (int j = 0; j < *(a + i); j++) {
				LCD_Write_Data(0x0000);
			}
			for (int j = *(a + i) + 1; j <= 240; j++) {
				LCD_Write_Data(0xFFFF);
			}
			//write each line twice
		}
	}
	PERF_END(PERFORMANCE_COUNTER_BASE, PERFORMANCE_COUNTER_SEG_A);
}

// A utility function to get maximum value in arr[]
int getMax(int arr[], int n) {
	int mx = arr[0];
	for (int i = 1; i < n; i++)
		if (arr[i] > mx)
			mx = arr[i];
	return mx;
}

// A function to do counting sort of arr[] according to
// the digit represented by exp.
void countSort(int arr[], int n, int exp) {
	int output[n]; // output array
	int i, count[10] = { 0 };

	// Store count of occurrences in count[]
	for (i = 0; i < n; i++)
		count[(arr[i] / exp) % 10]++;

	// Change count[i] so that count[i] now contains actual
	//  position of this digit in output[]
	for (i = 1; i < 10; i++)
		count[i] += count[i - 1];

	// Build the output array
	for (i = n - 1; i >= 0; i--) {
		output[count[(arr[i] / exp) % 10] - 1] = arr[i];
		count[(arr[i] / exp) % 10]--;
	}

	// Copy the output array to arr[], so that arr[] now
	// contains sorted numbers according to current digit
	for (i = 0; i < n; i++) {
		arr[i] = output[i];
		LCD_Write_Command(0x002C);
		for (int i = 0; i < 160; i++) {
			for (int k = 0; k < 2; k++) {
				for (int j = 0; j < *(arr + i); j++) {
					LCD_Write_Data(0x0000);
				}
				for (int j = *(arr + i) + 1; j <= 240; j++) {
					LCD_Write_Data(0xFFFF);
				}
				//write each line twice
			}
		}
	}
}

// The main function to that sorts arr[] of size n using
// Radix Sort
void radixsort(int arr[], int n) {
	// Find the maximum number to know number of digits
	int m = getMax(arr, n);

	// Do counting sort for every digit. Note that instead
	// of passing digit number, exp is passed. exp is 10^i
	// where i is current digit number
	for (int exp = 1; m / exp > 0; exp *= 10) {
		countSort(arr, n, exp);
	}

}
