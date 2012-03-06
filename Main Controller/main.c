#include <p30F4012.h>
#include <math.h>
#include <dsp.h>
#include "main.h"

_FOSC(XT_PLL16 & PRI & CSW_FSCM_OFF); // External primary oscillator with 16x PLL. Gives 29.5 MIPS. Clock Switching disabled.
_FWDT(WDT_OFF);                       // Watchdog timer turned off
_FBORPOR(PWRT_OFF & PBOR_OFF & MCLR_EN); // POR timer off, No brownout reset, Master clear enabled
_FGS(GWRP_OFF & CODE_PROT_OFF); // General code segment write protect off, general segment code protection off

#define BLOCK_LENGTH	128
#define	START			1
#define STOP			0
#define raiseVoltage	'r' // command to raise the voltage by 10 mVpp
#define lowerVoltage	'l' // command to lower the voltage by 10 mVpp
#define emergencyLower 	'e' // emergency command to drop the voltage by 100 mVpp
#define voltageOn		'n' // command to turn the function generator on 
#define voltageOff		'a' // command to turn the function generator off
#define sendCommand		-1  // identifier to signal the next byte is a command
#define sendData		-5  // identifier to signal the next 4 bytes are a "long"

void SPI_Init(void);
void Controller_Init(void);
void UART_Init(void);
void ProcessUart(void);
void Timer1_Init(void);
long SignalRMS(volatile long*);
long AverageRMS(volatile long*, volatile int);

volatile long upperThreshold = 0;
volatile long recLong = 0;
volatile long spiIn[128];
volatile long holdPows[128]; // array holding the values of vecPow for a .5 second sonication
volatile long runningRmsAverage = 0;
volatile long runningHoldAverage = 0;
volatile long cycleRmsAverage = 0;
volatile int  holdIndex = 0;

volatile int forCount;
volatile int spiIndex = 0;
volatile int uartIndex = 0;

volatile int startFlag = 0; // flag to determine when data should be sampled
volatile char readyFlag = 0; // flag to determine when the MCU is ready to start normal operation
volatile char rmsToSend; // specifies which byte of the 32-bit vecPow to send

volatile char rmsUpper; // upper byte of vecPow
volatile char rmsUpMid; // upper middle byte of vecPow
volatile char rmsLowMid; // lower middle byte of vecPow
volatile char rmsLow; // lower byte of vecPow
volatile long TimerCount = 0;
volatile int rmsFlag = 0;
volatile long vecPow;
volatile long signalMean = 0;
volatile long signalTemp = 0;
volatile long intermTemp = 0; 
volatile long sumTemp = 0;
volatile int tempindex = 0;
volatile char recCom;
volatile char allClear = 1;
volatile char allOn = 0;
volatile char receiveCount = 0; // when doing initial handshaking with computer,
								// keeps track of the number of bytes received
volatile char receivingThreshold = 0; // flag to keep track of when the threshold
									// voltage is being received from computer
volatile char firstCycle = 1; // flag to tell when the first sonication is done

long upperRmsBound = 0;
int cycleCount = 0; // counts the number of cycles that have passed without
					// the RMS threshold being reached

volatile long delayCount = 0;
volatile char waitForVoltageConfirm = 0; // flag for confirming when the function
										 // generator has been turned on or off
volatile char lowerFlag = 0; // flag to signal when the function generator voltage has been lowered
volatile char dataReceived = 0; // flag to signal when data has been received via UART when receiving
								// upperRmsBound from the computer

void main(void)
{	
	SPI_Init();
	Controller_Init();
	UART_Init();
	Timer1_Init();	

	while(readyFlag == 0)// wait for first command from computer before starting
	{
		if(dataReceived == 1)
		{
			if(receivingThreshold == 1)
			{
				recLong = 0;
				recLong = recCom;
				if(receiveCount == 0)
				{
					recLong = recLong << 24;
					upperThreshold += (recLong & 0xFF000000);
					while(U1STAbits.TRMT == 0){}
					U1TXREG = 'k';
				}
				else if(receiveCount == 1)
				{
					recLong = recLong << 16;
					upperThreshold += (recLong & 0x00FF0000);
					while(U1STAbits.TRMT == 0){}
					U1TXREG = 'k';
				}
				else if(receiveCount == 2)
				{
					recLong = recLong << 8;
					upperThreshold += (recLong & 0x0000FF00);
					while(U1STAbits.TRMT == 0){}
					U1TXREG = 'k';
				}
				else
				{
					upperThreshold += (recLong & 0x000000FF);
					while(U1STAbits.TRMT == 0){}
					U1TXREG = 'k';
					receivingThreshold = 0;
					receiveCount = 0;
				}
				receiveCount++;
			}
		dataReceived = 0;
		}
	} 
	T1CONbits.TON = 1;

	while(1)
	{
		//while(waitForVoltageConfirm == 1){}; // waiting for confirmation that function 
											 // generator was turned on/off
		if(startFlag == STOP)
		{
			if(allClear == 0)
			{
				allOn = 0;
				spiIndex = 0;	
				SPI1STATbits.SPIEN = 0; // disable SPI module
				tempindex = SPI1BUF; // clear the SPI buffer
				SPI1BUF = 0;
				//*
				while(U1STAbits.TRMT == 0){}
				U1TXREG = sendCommand; // let the computer know the next byte is a command
				while(U1STAbits.TRMT == 0){}
				U1TXREG = voltageOff; // turn function generator off
				waitForVoltageConfirm = 1;	
				allClear = 1;
				while(waitForVoltageConfirm == 1){}		
				//*/
				cycleCount++;
				if(cycleCount > 10)
				{
					while(U1STAbits.TRMT == 0){}
					U1TXREG = sendCommand; // let the computer know the next byte is a command
					while(U1STAbits.TRMT == 0){} // more than 10 cycles have passed without a threshold
					U1TXREG = raiseVoltage;  // being reached. Increase voltage
					cycleCount = 0;
				}
				cycleRmsAverage = runningHoldAverage;// AverageRMS(&holdPows[0], holdIndex);
				/*
				cycleRmsAverage = 1000;//holdPows[0];//runningHoldAverage;
				for(forCount = 2; forCount < BLOCK_LENGTH-1; forCount++)
				{
					if(holdPows[forCount] != 8464){cycleRmsAverage = holdPows[forCount];}
				}//*/
				if(cycleRmsAverage < 0){cycleRmsAverage = 0;}
				holdIndex = 0;
				rmsUpper = (cycleRmsAverage >> 24)&0x000000FF;
				rmsUpMid = (cycleRmsAverage >> 16)&0x000000FF;
				rmsLowMid = (cycleRmsAverage >> 8)&0x000000FF;
				rmsLow = cycleRmsAverage;

				while(U1STAbits.TRMT == 0){}
				U1TXREG = sendData; // let the computer know the next four bytes are data
				for(delayCount = 0; delayCount < 20; delayCount++){asm("nop");}

				while(U1STAbits.TRMT == 0){}
				U1TXREG = rmsLow;
				for(delayCount = 0; delayCount < 20; delayCount++){asm("nop");}

				while(U1STAbits.TRMT == 0){}
				U1TXREG = rmsLowMid;
				for(delayCount = 0; delayCount < 20; delayCount++){asm("nop");}

				while(U1STAbits.TRMT == 0){}			
				U1TXREG = rmsUpMid;
				for(delayCount = 0; delayCount < 20; delayCount++){asm("nop");}

				while(U1STAbits.TRMT == 0){}			
				U1TXREG = rmsUpper;
			}			
		}

		else if(startFlag == START) // if the RMS needs calculated and the transducer is on
		{
			if(allOn == 0)
			{
				allClear = 0;
				allOn = 1;
				holdIndex = 0;
				//*
				while(U1STAbits.TRMT == 0){}
				U1TXREG = sendCommand; // let the computer know the next byte is a command
				while(U1STAbits.TRMT == 0){}
			    U1TXREG = voltageOn; // turn function generator on
				waitForVoltageConfirm = 1;
				while(waitForVoltageConfirm == 1){}
				//*/
			}

			if(rmsFlag == 1)	
			{
				rmsFlag = 0;
				LATBbits.LATB1 = 1;
				vecPow = SignalRMS(&spiIn[0]);
	
				if(vecPow >= upperThreshold)
				{
					while(U1STAbits.TRMT == 0){}
					U1TXREG = sendCommand; // let the computer know the next byte is a command
					while(U1STAbits.TRMT == 0){}
					U1TXREG = lowerVoltage; // turn function generator off		
					lowerFlag = 1;
					cycleCount = 0;
				}						
	
				rmsUpper = (vecPow >> 24)&0x000000FF;
				rmsUpMid = (vecPow >> 16)&0x000000FF;
				rmsLowMid = (vecPow >> 8)&0x000000FF;
				rmsLow = (vecPow)&0x000000FF;
				/*
				if(holdIndex < BLOCK_LENGTH)
				{
					holdPows[holdIndex] = vecPow;
					holdIndex++;
				}//*/

				//*
				if(holdIndex < BLOCK_LENGTH)
				{
					if(holdIndex > 1)
					{
						if(holdIndex == 2)
						{
							runningRmsAverage = runningRmsAverage - holdPows[127];
						}
						else
						{
							runningRmsAverage = runningRmsAverage - holdPows[holdIndex];
						}
						holdPows[holdIndex] = vecPow;
						runningRmsAverage = runningRmsAverage + holdPows[holdIndex];
						runningHoldAverage = (runningRmsAverage/126);
					}
					holdIndex++;
				}
				if(runningHoldAverage >= upperThreshold)
				{
					if(lowerFlag == 0)
					{
						while(U1STAbits.TRMT == 0){}
						U1TXREG = sendCommand; // let the computer know the next byte is a command
						while(U1STAbits.TRMT == 0){}
						U1TXREG = lowerVoltage; // turn function generator off		
					}
				}
				//*/

				LATBbits.LATB1 = 0;
				lowerFlag = 0;
			}	

		}
			
	}
}

void __attribute__((__interrupt__,no_auto_psv)) _T1Interrupt(void)
{	
	// gives half second on, half second off
	IFS0bits.T1IF = 0; // clear timer1 interrupt flag
	TimerCount++;
	if(TimerCount >= 28)
	{
		TimerCount = 0;
		if(startFlag == STOP)
		{
			startFlag = START; 
			allOn = 0;
		}
		else
		{
			startFlag = STOP; 
			allClear = 0;
		}
	}
	return;
}

void __attribute__((__interrupt__,no_auto_psv)) _INT1Interrupt(void)
{
	LATEbits.LATE2 = 1;
	IFS1bits.INT1IF = 0; // clear interrupt flag
	SPI1STATbits.SPIEN = 0;
	asm("nop");
	SPI1STATbits.SPIEN = 1;// enable SPI module
	tempindex = SPI1BUF; // ensure the SPI buffer is cleared
	SPI1BUF = 0;
	LATEbits.LATE2 = 0;
	return;
}

// while the U1TX interrupt is not used, code is placed at the interrupt vector
// just in case the interrupt is accidentally accessed
void __attribute__((__interrupt__,no_auto_psv)) _U1TXInterrupt(void)
{
	IFS0bits.U1TXIF = 0; // clear the interrupt flag
	IEC0bits.U1TXIE = 0; // disable the U1TX interrupt
	return;
}

void __attribute__((__interrupt__,no_auto_psv)) _U1RXInterrupt(void)
{
	IFS0bits.U1RXIF = 0; // clear the U1RX interrupt flag
	recCom = U1RXREG;
	if(receivingThreshold == 1){dataReceived = 1;}
	else
	{
		switch(recCom)
		{
			case 's': // received command to stop sampling
				startFlag = 0;
				allClear = 0;
				break;
			case 'g': // received command to start sampling ("go")
				readyFlag = 1;
				allOn = 0;
				break;
			case 'c': // Computer ready. Get ready to receive threshold from computer ("long")
				receivingThreshold = 1;
				receiveCount = 0;
				while(U1STAbits.TRMT == 0){}
				U1TXREG = 'c';
				break;
			case 'q': // confirmation of reception of "stop function generator" command
				LATBbits.LATB3 = STOP;
				waitForVoltageConfirm = 0;
				break;
			case 'p': // confirmation of receptiong of "start function generator" command
				LATBbits.LATB3 = START;
				waitForVoltageConfirm = 0;
				//LATBbits.LATB0 = 1;
				break;
			case 'r':
				LATBbits.LATB0 = 1;
			default:  // unknown command received
				break;
		}
	}
	
	return;
}

void __attribute__((__interrupt__,no_auto_psv)) _SPI1Interrupt(void)
{
	SPI1STATbits.SPIEN = 0; // disable SPI module
	IFS0bits.SPI1IF = 0; // clear the SPI interrupt flag
	LATEbits.LATE0 = 1;
	tempindex = SPI1BUF;
	spiIn[spiIndex] = 0;
	spiIn[spiIndex] = spiIn[spiIndex]+ (long)tempindex;	
	spiIndex++;
	if(spiIndex >= 128)
	{
	    spiIndex = 0;
		rmsFlag = 1;
	}
	LATEbits.LATE0 = 0;

	//*
	if(startFlag == 0)
	{
		if(allClear == 1)
		{
			LATBbits.LATB3 = STOP;
		}
	}
	else if(startFlag == 1)
	{
		if(allOn == 1)
		{
			LATBbits.LATB3 = START;
		}
	}
	//*/
	return;
}

long SignalRMS(volatile long *signalArray)
{
	int i = 0;
	signalMean = 0;
	sumTemp = 0;
	for(i = 2; i < BLOCK_LENGTH; i++)
	{
		signalTemp = signalArray[i];
		intermTemp = signalTemp*signalTemp;
		sumTemp = sumTemp + intermTemp;
		if(i == 2){sumTemp = sumTemp + intermTemp;}
		if(i == 3){sumTemp = sumTemp + intermTemp;}
	}

	signalMean = (sumTemp/128); // dividing by 128, same as right-shifting 7 bit places
	
	return signalMean;
}

long AverageRMS(volatile long *vecArray, volatile int upperBound)
{
	int i = 0;
	runningRmsAverage = 0;
	for(i = 0; i < BLOCK_LENGTH; i++)
	{
		runningRmsAverage = runningRmsAverage + vecArray[i];
	}

	cycleRmsAverage = (runningRmsAverage/128); // dividing by 128, same as right-shifting 7 bits

	return cycleRmsAverage;
}
