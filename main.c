#include <stm32f7xx_hal.h>

int main(int argc, char* argv[])
{
    GPIO_InitTypeDef led_gpio_init;

    HAL_Init();
    __HAL_RCC_GPIOJ_CLK_ENABLE();

    led_gpio_init.Pin = GPIO_PIN_5 | GPIO_PIN_13;
    led_gpio_init.Mode = GPIO_MODE_OUTPUT_PP;
    led_gpio_init.Pull = GPIO_NOPULL;
    led_gpio_init.Speed = GPIO_SPEED_LOW;
    HAL_GPIO_Init(GPIOJ, &led_gpio_init);

    uint32_t t = 0;

    while (1) {
        t = HAL_GetTick();
        if (!(t % 400)) {
            HAL_GPIO_TogglePin(GPIOJ, GPIO_PIN_13);
        }
        if (!(t % 700)) {
            HAL_GPIO_TogglePin(GPIOJ, GPIO_PIN_5);
        }
    }
}

void SysTick_Handler(void)
{
    HAL_IncTick();
}
