/* 
 * Client for distributed calculation.
 * Fetches data from the server, gives it to an external program, 
 * and returns the result to the server.
 *
 * Copyright 1999 Jan-Frode Myklebust <janfrode@ii.uib.no>
 *
 * $Id: JistributedClient.java,v 1.28 1999/07/07 14:55:50 janfrode Exp $
 * 
 */

package jistributed;

import java.rmi.*;
import java.lang.*;
import java.lang.Thread.*;
import java.io.*;
import java.util.*;
//import java.net.InetAddress;

public class JistributedClient extends Thread {

	public static void main(String arg[]) {
		ResourceBundle messages;
		messages = ResourceBundle.getBundle("MessagesBundle");
		
		System.out.println("$Id: JistributedClient.java,v 1.28 1999/07/07 14:55:50 janfrode Exp $ \n");
		
	   if ((arg.length == 1) && (arg[0].equals("-help"))){
			System.out.println(messages.getString("usage"));
	   }
	   if ((arg.length == 2) && (arg[0].equals("-status"))){
			statusInfo(arg[1]);
			System.exit(0);
	   }
	   if (arg.length == 0) {
			System.out.println(messages.getString("usage"));
			System.exit(1);
	   }

	   run(arg[0]);
	}

	public static void statusInfo(String serverName) {
		String statusinfo = new String();
		try {
			System.out.println("Querying server for status info..");
			Jistributed JS = (Jistributed)Naming.lookup("//" + serverName +
												":5060/JistributedServer");
			statusinfo = JS.statusInfo();
		} catch (Exception e) {
			System.out.println(e);
		}
		System.out.println(statusinfo);
	}
	
	public static task fetchTask(String serverName){
		task t;
		t = new task();
		try {
			System.out.print("Connecting to server... ");
			Jistributed JS = (Jistributed)Naming.lookup("//" + serverName +
												":5060/JistributedServer");
			System.out.print("Connected.\nFetching task from server...");
			t = JS.reqestTask();
			System.out.print("Got it!\n");
			} catch (Exception e) {
				System.out.println(e);
				System.out.println("Will retry in 60 seconds.");
				sov(60000);
			t = fetchTask(serverName);
			}
		return t;
		}
		
	public static void sov(int i){
		try {
			sleep(i);
		} catch (java.lang.InterruptedException interrupt_e) {
			System.out.println("InterruptedException: " + interrupt_e);
		}
	}

	public static task readSlaveOutput(task t) {
		String s;
		BufferedReader slaveOutputFile = null;
		try {
			slaveOutputFile = new BufferedReader(new FileReader("slave_output.dat"));
			if((s = slaveOutputFile.readLine())!=null){
				// Cut the string up in pieces, delimited by space or ','. This
				// way the first element will be NBest, or '-1'.
				StringTokenizer st = new StringTokenizer(s, " ,");
				s = st.nextToken();
				// Need the Integer class to convert a string to an int
				Integer integ = new Integer(s);
				t.NBest = integ.intValue();
				slaveOutputFile.close();
			} else { 
				System.out.println("Uhoh.. unable to read data from file");
				slaveOutputFile=null;
				sov(60000);
			}
		} catch (FileNotFoundException e) {
			System.out.println("slave_output.dat not found: " + e);
			sov(60000);
		} catch (IOException e) {
			slaveOutputFile = null; // Hmm, kanskje en feilmelding hadde vært på sin plass?
			System.out.println("readSlaveOutput-" + e);
			sov(60000);
		}

		return t;
		}

	public static task readSlaveStats(task t) {
		String s;
		BufferedReader slaveStatsFile = null;
		t.slave_stats = "";

		try {
			slaveStatsFile = new BufferedReader(new
								 FileReader("slave_stats.dat"));
			while(true) {
				if((s = slaveStatsFile.readLine())==null){
					slaveStatsFile.close();
					slaveStatsFile=null;
					return t;
				}
				t.slave_stats = t.slave_stats + s + "\n";
			}
		} catch (FileNotFoundException e) {
			System.out.println("slave_stats.dat not found: " + e);
			sov(60000);
		} catch (IOException e) {
			slaveStatsFile=null;
		}
	return t;
	}
					
	public static boolean returnTask(String serverName, task solvedTask){
		boolean status = false;
		try {
			System.out.print("Connectiong to server...");
			Jistributed JS = (Jistributed)Naming.lookup("//" + serverName +
													":5060/JistributedServer");
			System.out.print("Connected.\n");
			System.out.print("Returning solution to task #" + solvedTask.index);
			status = JS.returnTask(solvedTask);
			System.out.print(" Returned.\n");
			} catch (Exception e) {
				System.out.println(e);
				System.out.println("Will retry in 60 seconds.");
				sov(60000);
				status = returnTask(serverName, solvedTask);
			}
		return status;
		}

	public static void run(String serverName) {
	   task oppgave;
	   oppgave = new task();
	   
	   while(true) {
	   		oppgave = fetchTask(serverName);
			writeSlaveInput(oppgave);
			//
			StringBuffer sb = new StringBuffer();
			System.out.print("Running slave program (this might take hours).\n");
			int i = execute("./calculator.sh", sb ); 
			System.out.println( "Returnvalue: " + i );
			System.out.println(sb.toString());
			//
			if (i == 0) { 
				oppgave.slave_stdout = sb.toString();
				oppgave = readSlaveOutput(oppgave);
				oppgave = readSlaveStats(oppgave);
	   			returnTask(serverName, oppgave);
			} else { 
				System.out.print("Bad returnvalue.\n" +
							"Something bad happened with the slave-program." + 
							" Will fetch new task in 60 seconds.\n");
				sov(60000); 
			}
			
		}
	}

   public static int execute( String command, StringBuffer output )
   {
      try
      {
         Process p = Runtime.getRuntime().exec( command );
         BufferedReader dis = 
		 		new BufferedReader(new InputStreamReader(p.getInputStream()));
         String s = null;
         while( ( s = dis.readLine() ) != null )
         {
            output.append( s + "\n" );
         }
		
		// Need to sleep for a few seconds before we return p.exitValue() 
		// to let the process exit normally
		try {
			//System.out.println("sover 3 sekund");
			sleep(3000);
		} catch (java.lang.InterruptedException interrupt_e) {
			System.out.println("InterruptedException: " + interrupt_e);
			return -1;
		}
         
		 //return p.waitFor();
		 //p.destroy();
		 return p.exitValue();
      
	  // Farlig catch?
	  //} catch (java.lang.IllegalThreadStateException thread_e) {
	  	//System.out.println("IllegalThreadStateException: " + thread_e);
	  	//System.out.println("IllegalThreadStateException: " + thread_e);
	  	//System.out.println("Ignored an IllegalThreadStateException...");
	    //return 0;

	  } catch (Exception e) { 
	    System.out.println("Ooops (execute): " + e);
		sov(60000);
	  	return -1; 
	  }
   }                           

   static void writeSlaveInput(task t)
   {
   	RandomAccessFile slaveInputFile = null;
	try {
		slaveInputFile = new RandomAccessFile("slave_input.dat","rw");
		// setLength finnes ikke før java 1.2
		//slaveInputFile.setLength(0);
		// Bruker derfor seek(0) i stedet.
		slaveInputFile.seek(0);
		slaveInputFile.writeBytes(	t.ndelta + " " + 
									t.nhope + " " +
									t.nmax + 
									"       ; ndelta nhope nmax\n" +
									t.index + 
									"       ; task_number\n");
		slaveInputFile.close();
	
	} catch (IOException e) {
		System.out.println("slave_input.dat: " + e);
		sov(60000);
	}
   }
}
