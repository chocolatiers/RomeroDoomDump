doomprint : doomprint.o doomload.o cmdlib.o idfunctions.o
	cc -arch hppa -arch i386 -arch m68k -o doomprint doomprint.o doomload.o idfunctions.o cmdlib.o -lNeXT_s -lsys_s
	
.c.o:
	cc -arch hppa -arch i386 -arch m68k -Wall -g -c $<

.m.o:
	cc -arch hppa -arch i386 -arch m68k -Wall -g -c $<
