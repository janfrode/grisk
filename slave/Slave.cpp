/*
 * This is the glue between java and fortran. It gets some data from the
 * java program, passes it on to the fortran part, and returns the results
 * back to java.
 *
 * Copyright 1999 Jan-Frode Myklebust <janfrode@ii.uib.no>
 *
 * $Id: Slave.cpp,v 1.16 1999/11/18 11:27:01 janfrode Exp $
 *
 */

#include <stdlib.h>
#include <string>
#include <iostream>
using namespace std;
#include <jni.h>
#include "jistributed_JistributedClient.h"


// Be nice...
#include <unistd.h>

// Need a pointer to a 8 byte integer, java provides this easily
#ifndef JLONGP
#define JLONGP const jlong*
#endif
// and a normal java-integer pointer..
#ifndef JINTP
#define JINTP const jint*
#endif


extern "C" {

  extern void slave_program_(JINTP jndelta, JINTP jnhope, JINTP jnmax, 
  					JINTP jindex, JINTP jmatr1, JINTP jmatr2, JINTP jmatr3, 
					JINTP jmatr4, JINTP jmatr5, JLONGP jstat1, JLONGP jstat2, 
					JINTP jstat3, JINTP jstat4, JINTP jstat5, JINTP jstat6, 
					JINTP jstat7, JINTP jstat8, JINTP jstat9, JINTP jstat10, 
					JINTP jstat11);
}

JNIEXPORT jstring JNICALL Java_jistributed_JistributedClient_calculateNative
(JNIEnv *env, jclass, jint niceness, jint ndelta, jint nhope, jint nmax, jint index)
{
	/* Check nicelevel, and adjust (doesn't work correctly on linux, it's
	 * beeing too nice) */

	int nicelevel = nice(0);
	if (nicelevel < niceness ) {
		nicelevel = nice(niceness - nicelevel);
		//cout<< "Nicet til " << nicelevel << "\n";
		//cout.flush();
	}
	

	jint stat3, stat4, stat5, stat6, stat7, stat8, stat9, stat10, stat11;
	jlong stat1, stat2;
	jint matr1, matr2, matr3, matr4, matr5;
	
	cout<< "Calling fortran routine...\n";
	cout.flush();
	slave_program_(&ndelta, &nhope, &nmax, &index, &matr1, &matr2,
				   &matr3, &matr4, &matr5, &stat1, &stat2, &stat3, &stat4, &stat5, &stat6, 
				   &stat7, &stat8, &stat9, &stat10, &stat11);
	
	cout<< "done. CPU-seconds to complete task: " << stat11 << "\n";
//	cout<<stat1 << "\n";
	cout.flush();
	
	/* Build return string (probably very stupid way to do it) */
	char *tempString = new char[18]; /* Make room for 8 byte integers */
	sprintf(tempString, "%d", (int) index);
	std::string returnString = tempString;
	returnString += "\n ";
	sprintf(tempString, "%d", (int) ndelta);
	returnString += tempString;
	returnString += " ";
	sprintf(tempString, "%d", (int) nhope);
	returnString += tempString;
	returnString += " ";
	sprintf(tempString, "%d", (int) nmax);
	returnString += tempString;
	returnString += "\n ";
	sprintf(tempString, "%d", (int) matr1);
	returnString += tempString;
	returnString += "\t";
	sprintf(tempString, "%d", (int) matr2);
	returnString += tempString;
	returnString += "\t";
	sprintf(tempString, "%d", (int) matr3);
	returnString += tempString;
	returnString += "\t";
	sprintf(tempString, "%d", (int) matr4);
	returnString += tempString;
	returnString += "\t";
	sprintf(tempString, "%d", (int) matr5);
	returnString += tempString;
	returnString += "\n";

	std::string buildString;
	buildString = "";
	if (stat1 > 0) {
		while (stat1 > 0) {
			int i = stat1 % 10;
			stat1 = stat1/10;
			sprintf(tempString, "%d", i);
			buildString = tempString + buildString;
		}
	} else { 
		sprintf(tempString, "%d", (int)stat1);
		buildString = tempString + buildString;
	}
	returnString += buildString;
	returnString += "\n";
	buildString = "";
	if (stat2 > 0) {
		while (stat2 > 0) {
			int i = stat2 % 10;
			stat2 = stat2/10;
			sprintf(tempString, "%d", i);
			buildString = tempString + buildString;
		}
	} else {
		sprintf(tempString, "%d", (int)stat2);
		buildString = tempString + buildString;
	}
	returnString += buildString;
	// buildString = NULL;
	returnString += "\n";

	sprintf(tempString, "%d", (int) stat3);
	returnString += tempString;
	returnString += "\t";
	sprintf(tempString, "%d", (int) stat4);
	returnString += tempString;
	returnString += "\n";
	sprintf(tempString, "%d", (int) stat5);
	returnString += tempString;
	returnString += "\t";
	sprintf(tempString, "%d", (int) stat6);
	returnString += tempString;
	returnString += "\n";
	sprintf(tempString, "%d", (int) stat7);
	returnString += tempString;
	returnString += "\t";
	sprintf(tempString, "%d", (int) stat8);
	returnString += tempString;
	returnString += "\n";
	sprintf(tempString, "%d", (int) stat9);
	returnString += tempString;
	returnString += "\t";
	sprintf(tempString, "%d", (int) stat10);
	returnString += tempString;
	returnString += "\n";
	sprintf(tempString, "%d", (int) stat11);
	returnString += tempString;
	returnString += "\n";

	delete[] tempString;

	return env->NewStringUTF (returnString.c_str());
}
