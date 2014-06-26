#perfseek makefile
all: perfseek

perfseek:
	g++ -c main.cpp inih/INIReader.cpp ini.c
	gfortran -c -ffree-form -std=f2003 levelspeed.f03
	g++ -lgfortran main.o levelspeed.o ini.o INIReader.o -o perfseek

clean:
	rm -rf *.o
	rm perfseek