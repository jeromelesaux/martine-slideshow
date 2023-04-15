CC=rasm
RM=rm
OPT= -eo
SRC=slideshow2.asm
DEBUG:=$(shell grep alias\ cpcec= ~/.bashrc | awk -F"\"" '{print $$2}')
TARGET=martine-slideshow.dsk

default: help


help: 
	@echo "help for building the project:"
	@echo "make compile will compile the source code"
	@echo "make clean will clean the project"
	@echo "make test launch and debug the project"

compile:
	@echo "compiling sources"
	${CC} ${SRC} ${OPT}

clean: 
	@echo "cleaning the project"

test: compile
	@echo "debugging the project"
	$(DEBUG) ${TARGET}