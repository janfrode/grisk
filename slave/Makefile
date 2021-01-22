#
# Machine Specific Compile/Link Parameters
#
# linux/g++ %  g++ -O -shared -fPIC -o libSlaveCalc.so
# -I/usr/local/jdk1.2/include -I/usr/local/jdk1.2/include/linux 
# slave_main_routine.o slave.o fast_hnf.o fast_find.o kjlist.o 
# minors.o entire_hnf.o Slave.cpp  -lg2c 

# Sjekk ~kjellp/src/makefile for dependencies
#MKDEP		= /usr/bin/X11/makedepend

#CC          = /usr/local/gcc-2.95.1-sparc-sun-solaris2.6/bin/g++
#FCOMPILER   = /usr/local/gcc-2.95.1-sparc-sun-solaris2.6/bin/g77
#CC          = CC
#FCOMPILER   = f77
CC          = g++  -shared
FCOMPILER   = gfortran 
#FLINKER     = $(FCOMPILER)
LIB_PATH    = 
#LIB_LIST    = -lftn
LIB_LIST	= #-lg2c	# For gcc
#
JINCLUDE_DIR = -I/etc/alternatives/java_sdk/include/ -I/etc/alternatives/java_sdk/include/linux
#FFLAGS  = -O3 -i8 -mips4 -64
#FFLAGS  = -O3 -static -C #-mips4
FFLAGS  = -fno-second-underscore -O3 -std=legacy -Wline-truncation -ffixed-line-length-132 -fPIC

### End User configurable options ###

CCLAGS = $(INCLUDE_DIR) $(OPTFLAGS)
LIBS = $(LIB_PATH) $(LIB_LIST)

FFS =   slave_main_routine.o slave.o fast_hnf.o fast_find.o \
        kjlist.o minors.o entire_hnf.o


#
# Dependencies on include files
#

#master:        $(FFM)
#	$(FLINKER) -o master $(FFLAGS) $(FFM) $(LIBS)

#slave:		$(FFS)
#	$(FLINKER) -o slave $(FFLAGS) $(FFS) $(LIBS)

all:	libSlaveCalc.so

libSlaveCalc.so:	$(FFS) Slave.cpp
	$(CC) -O -fPIC -o libSlaveCalc.so $(JINCLUDE_DIR) $(FFS) Slave.cpp $(LIBS) -lgfortran

.f.o:
	$(FCOMPILER) -c $(FFLAGS) $*.f

clean:
	rm -f $(FFS) libSlaveCalc.so
# DO NOT DELETE
