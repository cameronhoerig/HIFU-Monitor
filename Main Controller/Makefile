# MPLAB IDE generated this makefile for use with GNU make.
# Project: Main_Rev_1.mcp
# Date: Mon Feb 27 15:18:29 2012

AS = pic30-as.exe
CC = pic30-gcc.exe
LD = pic30-ld.exe
AR = pic30-ar.exe
HX = pic30-bin2hex.exe
RM = rm

Main_Rev_1.hex : Main_Rev_1.cof
	$(HX) "Main_Rev_1.cof"

Main_Rev_1.cof : main.o vpow.o
	$(CC) -mcpu=30F4012 "main.o" "vpow.o" -o"Main_Rev_1.cof" -Wl,-Tp30F4012.gld,--defsym=__MPLAB_BUILD=1,--defsym=__MPLAB_DEBUG=1,-Map="Main_Rev_1.map",--report-mem

main.o : main.h ../../../../../../../../microchip/c30/include/stddef.h ../../../../../../../../microchip/c30/include/stdlib.h ../../../../../../../../microchip/c30/support/generic/h/dsp.h ../../../../../../../../microchip/c30/include/math.h ../../../../../../../../microchip/c30/support/dsPIC30F/h/p30F4012.h main.c
	$(CC) -mcpu=30F4012 -x c -c "main.c" -o"main.o" -D__DEBUG -g -Wall -fno-schedule-insns -fno-schedule-insns2

vpow.o : dspcommon.inc vpow.s
	$(CC) -mcpu=30F4012 -c -D__DEBUG "vpow.s" -o"vpow.o" -Wa,--defsym=__DEBUG=1,-g

clean : 
	$(RM) "main.o" "vpow.o" "Main_Rev_1.cof" "Main_Rev_1.hex"

