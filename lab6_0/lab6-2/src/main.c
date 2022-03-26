#include "stm32l476xx.h"
#define SET_REG(REG,SELECT,VAL) {((REG)=((REG)&(~(SELECT)))|(VAL));}
// set LEN bits, starting from OFFSET-th bit, to value
#define SET_REG_SEG(REG,LEN,OFFSET,VAL) {((REG)=(((REG)&(~((((1)<<(LEN))-(1))<<(OFFSET))))|((VAL)<<(OFFSET))));}
#define TIME_SEC 694.20

void MAX7219Init();
void show_value(int val);
//void delay();
void TIMInit();
void read_input_start();
void MAX7219Send(int addr, int data);
void MAX7219SendHalf(int addr, int data);

void GPIOInit(){

	SET_REG(RCC->AHB2ENR, 5, 5); // enable GPIOA, GPIOC
	GPIOC->MODER = 0;
	SET_REG(GPIOA->MODER, 0xF0F, 0x505);//PA0,1,4,5 out
	SET_REG(GPIOC->MODER, 0xC000000, 0x0);//PC13 in
}

void MAX7219Init(){

	// turn on MAX7219
	MAX7219Send(0xC,1);
	// decode mode
	MAX7219Send(0x9,0xFF);
	// clear digits
	for(int i=1;i<=8;i++){
		MAX7219SendHalf(i,0xF);
	}
	// intensity
	MAX7219Send(0xA,0xF);

	// show 0.00 initially
	MAX7219SendHalf(0xB,2);
	MAX7219Send(1,0x0);
	MAX7219Send(2,0x0);
	MAX7219Send(3,0x80);

}

void TIMInit(){
	RCC->APB1ENR1 |= RCC_APB1ENR1_TIM6EN;//timer1 clock enable
	TIM6->PSC = (uint32_t)99;//Prescalser
	TIM6->ARR = (uint32_t)3999;//Reload value
	TIM6->EGR = TIM_EGR_UG;//Reinitialize the counter. CNT takes the auto-reload value.
	TIM6->CR1 |= TIM_CR1_CEN;//start timer
}

int main(){
	GPIOInit();
	MAX7219Init();
	int time = TIME_SEC * 100;
	read_input_start();
	// PLLSRC = 0b10(HSI16)
	// M = 4 (fVCOIn = 4MHz)
	// N = 20 (fVCOOut = 80MHz)
	// R = 0b00(/2 -> fSYSCLKIn = 40MHz)
	// AHB prescaler = 0b0000(/1 -> fSYSCLK = 40MHZ)

	SET_REG(RCC->CR,1<<8,1<<8);
	SET_REG_SEG(RCC->PLLCFGR,2,0,0b10);
	SET_REG_SEG(RCC->PLLCFGR,3,4,3);
	SET_REG_SEG(RCC->PLLCFGR,7,8,20);
	SET_REG_SEG(RCC->PLLCFGR,2,25,0b00);
	SET_REG_SEG(RCC->CFGR,4,4,0b0000);

	// turn on PLL
	SET_REG(RCC->CR,1<<24,1<<24);
	SET_REG(RCC->PLLCFGR,1<<24,1<<24);
	// set PLL as SYSCLK input
	SET_REG(RCC->CFGR,0xF3,0x03);

	TIMInit();
	for(int i=0;i<=time;i++){
		while((TIM6->SR & 1) == 0){
			;//wait
		}
		SET_REG(TIM6->SR,1,0);
		show_value(i);
		//delay();
	}

}
