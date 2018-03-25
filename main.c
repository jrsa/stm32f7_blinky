#include <stm32f7xx_hal.h>

GPIO_InitTypeDef led_gpio_init;
UART_HandleTypeDef vcp_uart;

int main(int argc, char* argv[])
{
    HAL_Init();
    __HAL_RCC_GPIOJ_CLK_ENABLE();

    led_gpio_init.Pin = GPIO_PIN_5 | GPIO_PIN_13;
    led_gpio_init.Mode = GPIO_MODE_OUTPUT_PP;
    led_gpio_init.Pull = GPIO_NOPULL;
    led_gpio_init.Speed = GPIO_SPEED_LOW;
    HAL_GPIO_Init(GPIOJ, &led_gpio_init);

    vcp_uart.Instance = USART1;
    vcp_uart.Init.BaudRate = 115200;
    vcp_uart.Init.WordLength = UART_WORDLENGTH_8B;
    vcp_uart.Init.StopBits = UART_STOPBITS_1;
    vcp_uart.Init.Parity = UART_PARITY_NONE;
    vcp_uart.Init.Mode = UART_MODE_TX;
    vcp_uart.Init.HwFlowCtl = UART_HWCONTROL_NONE;
    vcp_uart.Init.OverSampling = UART_OVERSAMPLING_16;
    HAL_UART_Init(&vcp_uart);

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

uint8_t *data = (uint8_t*)"Hello\n";
void SysTick_Handler(void)
{
    HAL_IncTick();

    // send greeting once per second
    if (!(HAL_GetTick() % 1000)) {
        HAL_UART_Transmit(&vcp_uart, data, 6, HAL_MAX_DELAY);
    }
}

// "callback" from inside HAL_UART_Init, this is where we set up the IO for the UART
void HAL_UART_MspInit(UART_HandleTypeDef* huart)
{
    GPIO_InitTypeDef gpioa_init;
    if (huart->Instance == USART1) {
        __HAL_RCC_USART1_CLK_ENABLE();
        __HAL_RCC_GPIOA_CLK_ENABLE();

        gpioa_init.Pin = GPIO_PIN_9 | GPIO_PIN_10;
        gpioa_init.Mode = GPIO_MODE_AF_PP;
        gpioa_init.Pull = GPIO_NOPULL;
        gpioa_init.Speed = GPIO_SPEED_LOW;
        gpioa_init.Alternate = GPIO_AF7_USART1;
        HAL_GPIO_Init(GPIOA, &gpioa_init);
    }
}
