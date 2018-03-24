#include <stm32f7xx.h>

int main(int argc, char* argv[])
{
    // gpio clock for led
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOJEN;
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;

    // led gpio pins as output
    GPIOJ->MODER |= (1 << (13 << 1));
    GPIOJ->MODER |= (1 << (5 << 1));
    GPIOA->MODER |= (1 << (12 << 1));
 
    // led gpio max speed
    GPIOJ->OSPEEDR |= (3 << (13 << 1));
    GPIOJ->OSPEEDR |= (3 << (5 << 1));
    GPIOA->OSPEEDR |= (3 << (12 << 1));
    
    int t = 0, bbval = 0, shift = 0;

    while(1)
    {
        t++; // hello old friend
        int bbval = ((t << 1) ^ ((t << 1) + (t >> 7) & t >> 12)) | t >> (4 - (1 ^ 7 & (t >> 15))) | t >> 7;

        // PA0 is blue button on discovery board
        // this is really bad, if this is done in an interrupt there will only be one update per button press
        shift = (shift + (GPIOA->IDR & 1)) % 4;

        GPIOJ->ODR = (((bbval >> shift) << 13) | ((bbval >> (shift + 3)) << 5));
        GPIOA->ODR = ((bbval >> (shift + 1)) << 12);

        for(volatile int i = 0; i < 10000; i++)
            ;
    }
}