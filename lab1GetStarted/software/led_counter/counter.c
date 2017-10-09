/*
 * counter.c
 *
 *  Created on: Sep 27, 2017
 *      Author: user
 */

#include <stdio.h>
#include "io.h"
#include "system.h"
#define DELAY 1000000
int main(void) {
	int counter = 0;
	unsigned int wait;
	printf("Lets start counting \n");
	IOWR_8DIRECT(LED_BASE, 0, 0);
	while (1) {
		counter++;
		printf("counter = %d \n", counter);
		IOWR_8DIRECT(LED_BASE, 0, counter); // silly busy wait
		for (wait = 0; wait < DELAY; wait++)
			asm volatile ("nop");
	}
}
