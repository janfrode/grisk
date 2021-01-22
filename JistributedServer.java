/*	
 * Server for distributed calculation.
 * Serves input for external clients, and saves the returned results.
 *
 * Copyright 1999 Jan-Frode Myklebust <janfrode@ii.uib.no>
 *
 * $Id: JistributedServer.java,v 1.30 1999/07/07 14:55:50 janfrode Exp $
 */

package jistributed;

import java.rmi.*;
import java.rmi.server.*;
import java.rmi.registry.*;
import java.io.*;
import java.util.*;
import java.text.DateFormat; // For å bruke Dateformat..
import java.text.SimpleDateFormat;
import java.net.InetAddress;


public class JistributedServer 
       extends UnicastRemoteObject
       implements Jistributed {

       Vector tasks = new Vector();
       Vector inProgress = new Vector();
       RandomAccessFile logFile = null;
       RandomAccessFile solvedFile = null;
       RandomAccessFile slave_stdout = null;
       RandomAccessFile slave_status = null;

		Integer max_int = new Integer(Integer.MAX_VALUE); // Maks 32-bit
														 // integerverdi
	   int currentNBest = max_int.intValue();
	   int el_idx = 0;
	   int bestIdx = -1;
	   //int currentNBest = -1;
	   int unsolved = 0;
	   int solved = 0;
	   String restartfilename = null;

       // Class Constructor
      public JistributedServer(int ndelta, int nhope, int nmax, int
	  						number_of_tasks, String restartinputfilename,
							int lastTask) throws RemoteException {
		unsolved = number_of_tasks;
		restartfilename = restartinputfilename;
		//System.out.print(restartfilename);
		try {
			// Open files
         	logFile = new RandomAccessFile("logFile.txt","rw");
	     	logFile.seek(logFile.length());
		 	solvedFile = new RandomAccessFile("solvedData.txt","rw");
		 	solvedFile.seek(solvedFile.length());
		 	slave_stdout = new RandomAccessFile("slave_stdout.txt","rw");
		 	slave_stdout.seek(slave_stdout.length());
			slave_status  = new RandomAccessFile("slave_stats.txt","rw");
			slave_status.seek(slave_status.length());
	  	} catch (IOException e) { 
			System.out.println(e);
	  	}
	  	DateFormat dateFormatter;
	  	Date now;
	  	dateFormatter = DateFormat.getDateTimeInstance(DateFormat.FULL,
	  	DateFormat.FULL);
	  	now = new Date();
	  	//System.out.println("JistributedServer starting at " + 
			      			//dateFormatter.format(now)); 

	  	makeTasks(ndelta, nhope, nmax, number_of_tasks); 
	  	tasks.trimToSize();
	  	System.out.println(tasks.size() + " tasks registered.");
		if (restartfilename != null) {
	  		readSolved(restartfilename);
			System.out.println("Best task: " + bestIdx + "\nNbest: " +
				currentNBest +"\nUnsolved: " + unsolved + "\nSolved: " + 
				solved);
			if (unsolved <= 0) System.exit(0);
		}
	   this.el_idx = lastTask;
	   System.out.println("First task will be task#: " + lastTask);
       }

 /***********************************
 *  Remote Method implementations   *
 ***********************************/

    public task reqestTask() {
		// Format the current time.
		SimpleDateFormat formatter
			= new SimpleDateFormat ("yyyy.MM.dd@HH:mm:ss");
		Date now = new Date();
		String dateString = formatter.format(now);

		// Who's knocking?
		String clientHost = null;
		try {
			clientHost = getClientHost();
			InetAddress clientaddress = InetAddress.getByName(clientHost);
			clientHost = clientaddress.getHostName();
			//System.out.print(clientHost);
		} catch (java.rmi.server.ServerNotActiveException e) {
			System.out.print(e);
		} catch (java.net.UnknownHostException e) {
			System.out.print("Unable to resolve hostname for " + clientHost);
		}

		System.out.print("-");
		//System.out.println(dateString + " Connection from " + id);
		task oppgave;
		//String data = null;
		int lastindex = el_idx; // For å ikke gå i sirkel når alt er løst.
		oppgave = new task();
		oppgave.NBest = -3;

		while (oppgave.NBest != -2) {
			oppgave = (task)tasks.elementAt(el_idx);
			if (el_idx < tasks.size()-1) {
			el_idx++; 
			} else { el_idx = 0; }

			if ((el_idx == lastindex) && (oppgave.NBest != -2)) {
				System.out.println("\n\nAll done!\n\nNBest = " + currentNBest + 
									"\nOn task: " + bestIdx +"\n");
				System.exit(0);
			}
		}
    	try {
        	logFile.writeBytes(dateString + " " + oppgave.index
			+ " started " + clientHost + "\n");
    	} catch (IOException e) {
        	System.out.println("Ooops: " + e);
    	}                                                 
		if (currentNBest < max_int.intValue()) oppgave.nmax = currentNBest;
		return oppgave;
	}

    public boolean returnTask(task solvedTask) {
        // Format the current time.
        SimpleDateFormat formatter
            = new SimpleDateFormat ("yyyy.MM.dd@HH:mm:ss");
        Date now = new Date();
        String dateString = formatter.format(now);

		//System.out.println(dateFormatter.format(now) + " Connection from " + id);
        // Who's knocking?
        String clientHost = null;
        try {
            clientHost = getClientHost();
            InetAddress clientaddress = InetAddress.getByName(clientHost);
            clientHost = clientaddress.getHostName();
            //System.out.print(clientHost);
        } catch (java.rmi.server.ServerNotActiveException e) {
            System.out.print(e);
        } catch (java.net.UnknownHostException e) {
            System.out.print("Unable to resolve hostname for " + clientHost);
        }
		//System.out.print(".");
		task oppgave;
		oppgave = (task)tasks.elementAt(solvedTask.index);
		//if (oppgave.NBest == -2 && solvedTask.NBest != -2) {
		if (oppgave.NBest == -2 && 
			 solvedTask.NBest != -2 &&
			 solvedTask.ndelta == oppgave.ndelta &&
			 solvedTask.nhope == solvedTask.nhope) {
		// Register results to file
        try {
            solvedFile.writeBytes(solvedTask.index + " " + 
								   solvedTask.NBest + "\n");
			slave_stdout.writeBytes(solvedTask.index + ":\n" +
									 solvedTask.slave_stdout + "\n");
			solvedTask.slave_stdout = null;
			slave_status.writeBytes(solvedTask.index + ":\n" + 
		   							solvedTask.slave_stats + "\n");
		    solvedTask.slave_stats = null;
			//System.out.println(id + " returned task " + solvedTask.index);
			System.out.print("[" + solvedTask.NBest + "]");
			tasks.removeElementAt(solvedTask.index);
			tasks.insertElementAt(solvedTask, solvedTask.index);
			if ((solvedTask.NBest < currentNBest) && (solvedTask.NBest > -1)){
				currentNBest = solvedTask.NBest;
				bestIdx = solvedTask.index;
			}
			--unsolved;
			++solved;
			logFile.writeBytes(dateString + " " + oppgave.index
			            + " solved " + clientHost + "\n");       
        } catch (IOException e) {
            System.out.println("Error writing solution to file.\n " + e);
        }                               
		} else {
			System.out.println("Error returning tasksolution!");
			System.out.println("Oldtask: " + oppgave.NBest + 
							   " " + oppgave.index);
			System.out.println("Returned task: " + solvedTask.index + 
							   " NBest: " + solvedTask.NBest);
		}
		return true;
	}

	 
	 public String statusInfo() {
		// Who's knocking?
		String clientHost = null;
		try {
			clientHost = getClientHost();
			//System.out.print(clientHost);
		} catch (java.rmi.server.ServerNotActiveException e){
			System.out.print(e);
		}
		
		/* 
		 * Log koblingen til logFile
		 */ 

		System.out.print("?");
		return "Best task: " + bestIdx + "\nNbest: " + currentNBest + 
				"\nUnsolved: " + unsolved + "\nSolved: " + solved;
	 }


/*
 * The main part. Create a JistributedServer, bind it to the registry, and
 * do nothing until someone call our services.
 */
	public static void main(String arg[]) {
	   ResourceBundle messages;
	   messages = ResourceBundle.getBundle("MessagesBundle");
	   //System.out.println(messages.getString("greetings"));
	   
	   System.out.println("$Id: JistributedServer.java,v 1.30 1999/07/07 14:55:50 janfrode Exp $\n");

	   int ndelta = 0, nhope = 0, nmax = 0, number_of_tasks = 0, lastTask = 0;
	   String restartinputfilename = null;
	   if (arg.length == 4 | arg.length == 5 | arg.length == 6) {
	   		Integer integ = new Integer(arg[0]);
	   		ndelta = integ.intValue();
	   		integ = new Integer(arg[1]);
	   		nhope = integ.intValue();
	   		integ = new Integer(arg[2]);
	   		nmax = integ.intValue();
	   		integ = new Integer(arg[3]);
	   		number_of_tasks = integ.intValue();
			if (arg.length >= 5) restartinputfilename = arg[4];
			if (arg.length == 6) {
				integ = new Integer(arg[5]);
				lastTask = integ.intValue();
			}
		} else {
			System.out.println(messages.getString("ServerUsage"));
			System.exit(1);
		}

	    Registry reg;
	   //System.setSecurityManager(new RMISecurityManager());
	   try {
		   JistributedServer JS = new JistributedServer(ndelta, nhope,
		   											nmax, number_of_tasks,
													restartinputfilename,
													lastTask);
		   reg = LocateRegistry.createRegistry(5060);
		   reg.rebind("JistributedServer", JS);
		   System.out.println("Binding to //localhost:5060/JistributedServer");
		   System.out.println("Server Ready");
	       } catch (Exception e) {
		System.out.println("JistributedServer error: " + e);
           }
        }

		
	/* 
	 * Register solved data from file. 
	 * The fileformat should be a textfile with one set of solved data per
	 * line. Each line should contain an integer taskindex and then the
	 * solution to the tsk with this index.
	 *
	 * taskindex_0 solution_0
	 * taskindex_1 solution_1
	 * ...
	 * taskindex_n solution_n
	 *
	 */
	
    void readSolved(String filename) { 
	   String s;
	   task currentTask;
	   currentTask = new task();
       BufferedReader inputFile = null;

	   try {
            inputFile = new BufferedReader(new 
	        FileReader(filename)); 
			Integer integ;
	      	while(true) {
	        	if((s = inputFile.readLine())==null){
					inputFile=null;
					return;
		 		}
				StringTokenizer st = new StringTokenizer(s, " ");
				s = st.nextToken();
				integ = new Integer(s);
				currentTask = (task)tasks.elementAt(integ.intValue());
				tasks.removeElementAt(currentTask.index);
				s = st.nextToken();
				integ = new Integer(s);
				currentTask.NBest = integ.intValue();
		 		tasks.insertElementAt(currentTask, currentTask.index);
				// Register best solution
				if ((currentTask.NBest < currentNBest) && 
								(currentTask.NBest > -1)) {
					currentNBest = currentTask.NBest;
					bestIdx = currentTask.index;
				}
				--unsolved;
				++solved;
	      	} 
	   	} catch (FileNotFoundException e) { 
		   	System.out.println("inputfile not found: " + e);
	   	} catch (IOException e) {
			System.out.println("IOException: " + e);
	   	}
       }

	/* 
	 * Generate the Vector() of tasks.
	 */
	void makeTasks(int ndelta, int nhope, int nmax, int number_of_tasks) {
	   task currentTask;
	   currentTask = new task();
	   for (int i = 0; i < number_of_tasks; ++i){
	   		currentTask = new task();
			currentTask.index = i;
			currentTask.ndelta = ndelta;
			currentTask.nhope = nhope;
			currentTask.nmax = nmax;
			tasks.insertElementAt(currentTask, i);
		}
       }
}
