OBJECTS = beebattle.o
HEADERS =
CC = gcc
OUTPUT = 
DEBUG = -Wall
LINKING_OPTIONS = -lobjc
CFLAGS = $(shell allegro-config --cflags)
LDFLAGS = $(shell allegro-config --libs)
WIN_CC = wine c:\\MinGW\\bin\\gcc.exe
WIN_OUTPUT = beebattle.exe

beebattle: $(OBJECTS)
	 $(CC) $(DEBUG) $(LINKING_OPTIONS) -o beebattle $(OBJECTS) $(LDFLAGS)

beebattle.o: beebattle.m $(HEADERS)
	 $(CC) $(DEBUG) -c beebattle.m $(CFLAGS)

clean:
	 rm -f $(OBJECTS)

win:
	 $(WIN_CC) $(DEBUG) *.m -o $(WIN_OUTPUT) -lobjc -lalleg

