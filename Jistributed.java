/*
 * Interface for jistributed data.
 * Copyright 1999 Jan-Frode Myklebust <janfrode@ii.uib.no>
 *
 * $Id: Jistributed.java,v 1.7 1999/06/20 16:05:59 janfrode Exp $
 */

package jistributed;

import java.rmi.*;

public interface Jistributed extends Remote {
	public task reqestTask() throws RemoteException;
    public boolean returnTask(task solvedTask) throws RemoteException;
    public String statusInfo() throws RemoteException;

    // Kanskje jeg skal ha en funksjon for å få serveren til å lese inn nye
	// tasks og løsninger?
	// public boolean readNewTasks(String fileName) throws RemoteException;
}
