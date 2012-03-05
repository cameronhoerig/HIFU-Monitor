void SPI_Init(void)
{
	SPI1STATbits.SPIEN = 0; // disable SPI module during initialization
	SPI1STATbits.SPISIDL = 0; // continue module operation in idle mode

	SPI1CONbits.FRMEN = 0; // framed SPI support disabled
	SPI1CONbits.SPIFSD = 1; // frame sync pulse input (slave)
	SPI1CONbits.DISSDO = 1; // SDO pin is not used by module. Release control to TRIS register
	SPI1CONbits.MODE16 = 1; // communication is word-wide(16 bit)
	SPI1CONbits.SMP = 0; // must be cleared in slave mode
	SPI1CONbits.SSEN = 1; // SS' used for slave mode
	SPI1CONbits.CKP = 0; // idle state for clock is low level
	SPI1CONbits.MSTEN = 0; // in slave mode

	//SPI1STATbits.SPIEN = 1; // initialization done. Enable SPI module

	return;
}

void Controller_Init(void)
{
	INTCON1bits.NSTDIS = 1; // interrupt nesting is disabled
    INTCON2bits.ALTIVT = 0; // use default vector table

	INTCON2bits.INT1EP = 0; // INT1 interrupts on positive edge
	IEC1bits.INT1IE = 1; // enable INT1 interrupt
	IPC4bits.INT1IP = 7; // INT1 set to highest priority

    IEC0bits.SPI1IE = 1; // SPI1 interrupts enabled
	IEC0bits.U1RXIE = 1; // U1 Receive interrupts enabled
	IEC0bits.U1TXIE = 1; // Timer1 interrupt enabled
	IPC2bits.SPI1IP = 7; // SPI interrupt is at next highest priority
	IPC2bits.U1RXIP = 6; // UART receive interrupt is at highest priority
	IPC0bits.T1IP = 6; // Timer1 interrupt is at priority 6
    TRISB = 0x00; // PORTB all output
	TRISE = 0x00; // PORTE all output
	TRISBbits.TRISB2 = 1; // SS' is an input
	TRISFbits.TRISF2 = 1; // SDI is an input
	TRISFbits.TRISF3 = 0; // SDO is output
	TRISCbits.TRISC14 = 1; // U1ARX is input
	TRISCbits.TRISC13 = 0; // U1ATX is output
	TRISDbits.TRISD0 = 1; // INT1 is an input
	
	LATBbits.LATB0 = 0;
	LATBbits.LATB3 = 0;
	return;
}

void UART_Init(void)
{
	U1MODEbits.UARTEN = 1; // enable UART module after configuration
	U1MODEbits.USIDL = 0; // continue	 UART operation if in IDLE mode
	U1MODEbits.ALTIO = 1; // use ATx and ARx pins
	U1MODEbits.WAKE = 1; // wake-up enabled
	U1MODEbits.LPBACK = 0; // disable loopback mode
	U1MODEbits.ABAUD = 0; // disable auto baud
	U1MODEbits.PDSEL0 = 0; // 8-bit data, no parity
	U1MODEbits.PDSEL1 = 0;
	U1MODEbits.STSEL = 0; // 1 stop bit

	IEC0bits.U1RXIE = 1; // enable uart receive interrupts
	IEC0bits.U1TXIE = 0; // disable uart transmit interrupts
	IFS0bits.U1RXIF = 0; // clear receive interrupt flag
	IFS0bits.U1TXIF = 0; // clear transmit interrupt flag

	U1STAbits.UTXISEL = 0; // interrupt up transfer to Transmit Shift Register
	U1STAbits.UTXBRK = 0; // TX pin operates normally
	U1STAbits.UTXEN = 0; // enable UART after configuration, not active until UARTEN is set
	U1STAbits.URXISEL0 = 0; // interrupt is set when character is received
	U1STAbits.URXISEL1 = 0;
	U1STAbits.ADDEN = 0; // address detect mode is disabled

	U1BRG = 1; // set baud rate to 921875 bps

	U1MODEbits.UARTEN = 1; // enable UART module
	U1STAbits.UTXEN = 1; // enable UART

	return;
}

void	Timer1_Init(void)
{
	T1CON = 0; // put the timer in reset state
	T1CONbits.TON = 0; // turn timer1 off while initializing
	T1CONbits.TSIDL = 0; // continue timer operation in idle mode
	T1CONbits.TGATE = 0; // gated time accumulation disabled
	T1CONbits.TCKPS = 1; // 1:32 prescaling
	T1CONbits.TSYNC = 0; // do not sync external clock input
	T1CONbits.TCS = 0; // internal clock (Fosc/4)
	
	IFS0bits.T1IF = 0; // clear timer1 interrupt flag
	IEC0bits.T1IE = 1; // enable timer1 interrupts

	//T1CONbits.TON = 1; // timer1 on
	
	return;
}
