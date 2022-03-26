#include "stm32l476xx.h"
#define SET_REG(REG,SELECT,VAL) {((REG)=((REG)&(~(SELECT)))|(VAL));}
// mask excessive bits in val
#define SET_REG_MASK(REG,SELECT,VAL) {((REG)=((REG)&(~(SELECT)))|((VAL)&(SELECT)));}
// set LEN bits, starting from OFFSET-th bit, to value
#define SET_REG_SEG(REG,LEN,OFFSET,VAL) {((REG)=(((REG)&(~((((1)<<(LEN))-(1))<<(OFFSET))))|((VAL)<<(OFFSET))));}
// set LEN bits, starting from OFFSET-th bit, to value (with mask)
#define SET_REG_SEG_MASK(REG,LEN,OFFSET,VAL) {((REG)=(((REG)&(~((((1)<<(LEN))-(1))<<(OFFSET))))|(((VAL)&(SELECT))<<(OFFSET))));}

void show_value(int val);
void MAX7219Send(int addr, int data);
void MAX7219SendHalf(int addr, int data);


int table[4][4]=	{
					{ 1,  2,  3, 10},
					{ 4,  5,  6, 11},
					{ 7,  8,  9, 12},
					{15,  0, 14, 13}
					};

int freq[4][4]=	{
				{ 2616, 2937, 3296,   -1},
				{ 3492, 3920, 4400,   -1},
				{ 4939, 5233, 5874, 6223},
				{ 6592,   -1,   -1,   -1}
				};

int pressed[4][4] = {{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}};

void TIM2Init(){
	// input clock is 40MHz
	// enable TIM2
	SET_REG(RCC->APB1ENR1,1,1);
	TIM2->PSC = (uint32_t)399;// counts once every 0.0001 seconds
	// enable TIM2_CH2 as output compare
	SET_REG(TIM2->CCER,0x10,0x10);
	// set TIM2_CC output mode to PWM1
	SET_REG_SEG(TIM2->CCMR1,3,12,0b110);
	TIM2->EGR = 1;
}

void setDuty(int duty){// (% of duty / 5)

	int period = 200;// period in # of clock cycles

	SET_REG(RCC->APB1ENR1,1,1);
	TIM2->ARR = period;
	TIM2->CCR2 =duty*10;
	TIM2->EGR = 1;
	SET_REG(TIM2->CR1,1,1);

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



}

void GPIOInit(){

	SET_REG(RCC->AHB2ENR, 7, 7); // enable GPIOA-C
	GPIOC->MODER = 0;
	SET_REG(GPIOA->MODER, 0x000FFF0F, 0x00055505);//PA0,1,4-9 out
	// OTYPE: PA0,1,4,5 push-pull PA6-9 open-drain
	SET_REG(GPIOA->OTYPER, 0x03C0, 0x03C0);
	// PA6-9's ODR is always 1, but OTYPE will change for column selection
	// one column on 1 others on Hi-Z
	SET_REG(GPIOA->ODR, 0x03C0, 0x03C0);

	SET_REG(GPIOB->MODER, 0x0FF000C0, 0x00000080);//PB10-13 in, PB3 AF
	SET_REG(GPIOB->AFR[0],0xF000,0x1000)// AF1 for PB3 (TIM2-CH2)
	SET_REG(GPIOB->PUPDR, 0x0FF000C0, 0x0AA00080);//pull-down for PB3,10-13
	SET_REG(GPIOB->OSPEEDR, 0x000000C0, 0x0AA000C0);// very high speed for PB3
	SET_REG(GPIOC->MODER, 0x0C000000, 0x00000000);//PC13 in

}

void keypadRead(){

	for(int col=0;col<4;col++){
		// change OTYPE PA(i+6) to push-pull and others to open-drain
		SET_REG_MASK(GPIOA->OTYPER, 0x03C0, 0b1110111<<(col+3));
		for(int row=0;row<4;row++){
			if( ((GPIOB->IDR >> (10+row)) & 1) == 1){
				++pressed[row][col];
			}
			else{
				pressed[row][col]=0;
			}
		}

	}

}

int main(){


	GPIOInit();
	MAX7219Init();
	TIM2Init();

	show_value(10);
	int value = 0;
	int new_value = 0;
	int duty=2;
	setDuty(duty);

	while(1){
		keypadRead();
		new_value = 0;
		for(int col=0;col<4;col++){
			for(int row=0;row<4;row++){
				if(pressed[row][col] >= 100){// debounce says yes
					new_value = table[row][col];
				}
			}
		}

		if(value!=new_value){

			value = new_value;
			if((value==2) && (duty<18)){// increase duty
				++duty;
			}
			else if((value==1) && (duty>2)){// decrease duty
				--duty;
			}
			else{// do nothing
				;
			}

			setDuty(duty);
			show_value(duty*5);

		}


	}

}





