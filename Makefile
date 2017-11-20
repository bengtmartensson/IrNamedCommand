# Makefile for creating stuff on host.
# Not used for "normal" build of the software for the Arduino.
# Use Arduino IDE (https://www.arduino.cc/en/Main/Software) for that.

ifneq ($(ARDUINO),)
$(error This Makefile is not for compiling target code, for that, use the Arduino IDE.)
endif

# External programs, change if necessary or desired.
CXX=g++
BROWSER=firefox
DOXYGEN := doxygen
XSLTPROC := xsltproc

DEBUGFLAGS=-g
WARNINGFLAGS=-Wall -Wextra
BOARD=nano

DOXYFILE := tools/keywords_txt_generator.doxy
TRANSFORMATION := tools/doxygen2keywords.xsl

# Should poiint to the directory where the Infrared4Arduino
# (https://github.com/bengtmartensson/Infrared4Arduino)
# sources are located. Only used for SIL test.
INFRARED4ARDUINO_DIR=../Infrared4Arduino

# Get VERSION from the version in library.properties
VERSION=$(subst version=,,$(shell grep version= library.properties))
all: keywords api-doc/index.html test
keywords: keywords.txt

keywords.txt: xml/index.xml
	$(XSLTPROC) $(TRANSFORMATION) $< > $@

xml/index.xml: $(DOXYFILE)
	$(DOXYGEN) $(DOXYFILE)

lib: libIrNamedCommand.a

INCLUDES=-I$(INFRARED4ARDUINO_DIR)/src -Isrc/config
VPATH=src src/GirsLib src/IrNamedCommand
OBJS=IrNamedRemote.o IrNamedRemoteSet.o

libIrNamedCommand.a: $(OBJS)
	$(AR) rs $@ $(OBJS)

%.o: %.cpp
	$(CXX) -std=c++11 $(INCLUDES) $(BOARDDEFINES) $(WARNINGFLAGS) $(OPTIMIZEFLAGS) $(DEBUGFLAGS) -c $<

test%: test%.o libIrNamedCommand.a
	$(CXX) -o $@ $< -L. -lIrNamedCommand -L$(INFRARED4ARDUINO)/Arduino/libraries/Infrared -lInfrared
	./$@

doc: api-doc/index.html
	$(BROWSER) $<
	
api-doc/index.html:
	$(DOXYGEN)
	
clean:
	rm -rf *.a *.o *.hex *.zip xml test1 $(FLASHER)
	
distclean: clean
	rm -rf api-doc

# Remove all products. Do not use before commit.
spotless: distclean
	rm -f keywords.txt

build-tests:

test: lib

.PHONY: clean distclean spotless keywords lib
