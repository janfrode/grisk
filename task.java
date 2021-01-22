/*
 * Task objekt for jistributed data.
 * Copyright 1999 Jan-Frode Myklebust <janfrode@ii.uib.no>
 *
 * $Id: task.java,v 1.6 1999/05/30 19:33:27 janfrode Exp $
 */

package jistributed;             

class task implements java.io.Serializable {

	int NBest = -2; // -2 = task ikke ferdig, -1 = ingen løsning, annen
				   // integer er gyldig løsning.
	int ndelta, nhope, nmax;
	int index; // Byttes med task_number?
	//int [] found; 
	String slave_stdout;
	String slave_stats;
}
