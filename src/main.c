#include <stdint.h>
#include <stm32f103x6.h>
#include <sys/types.h>

#if !defined(__SOFT_FP__) && defined(__ARM_FP)
  #warning "FPU is not initialized, but the project is compiling for an FPU. Please initialize the FPU before use."
#endif

// startup_stm32f103xb.s:146
// startup_stm32f103xb.s:202
// startup_stm32f103xb.s:232
void SysTick_Handler(void) {
  GPIOC->ODR ^=  0x00002000;
}

int main(void)
{
  volatile u_int32_t i;
  
	// RM0008
    // Low-, medium-, high- and XL-density reset and clock control (RCC)
    // 7.3.6 AHB peripheral clock enable register (RCC_AHBENR)
	// Enable LED GPIOC 13
    RCC->APB2ENR |= 0x00000010;

    // RM0008
    // General-purpose and alternate-function I/Os (GPIOs and AFIOs)
    // 9.2.2 Port configuration register high (GPIOx_CRH) (x=A..G)
    // Set PORT C 13 to Output
    GPIOC->CRH   |= 0x00200000;

    // core_cm3.h: 706
    // https://developer.arm.com/documentation/dui0552/a/cortex-m3-peripherals/system-timer--systick/systick-control-and-status-register?lang=en
	// Enable systick clock source, interrupt and counter
    SysTick->CTRL = 7;
    SysTick->LOAD = 16777216 >> 2; // 2^24 = 16777216

    while (1) {
      
          /* Blink LED, if enable here is good idea disable systick interrupt [ SysTick->CTRL = 5;] and comment  __WFI();
			// RM0008
			// General-purpose and alternate-function I/Os (GPIOs and AFIOs)
			// 9.2.4 Port output data register (GPIOx_ODR) (x=A..G)
			GPIOC->ODR |=  0x00002000;
			for (i = 0; i < 15000; i++)
				;

			GPIOC->ODR &= ~0x00002000;
			for (i = 0; i < 15000; i++)
                    ;
          */

          
		// cmsis_gc.h:234
          __WFI();
	}
}

