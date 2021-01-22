# Makefile for Jistributed
#
# $Id: Makefile,v 1.3 1999/05/13 15:39:59 janfrode Exp $
#

all	: 
	javac -g -d . task.java JistributedClient.java Jistributed.java JistributedServer.java 
	rmic -d . jistributed.JistributedServer
server	: 
		javac -d . JistributedServer.java
client	: 
		javac -d . JistributedClient.java
stub	: 
		rmic -d . jistributed.JistributedServer
