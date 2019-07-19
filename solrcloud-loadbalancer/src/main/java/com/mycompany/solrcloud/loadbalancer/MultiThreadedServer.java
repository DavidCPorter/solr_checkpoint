package com.mycompany.solrcloud.loadbalancer;

import org.apache.solr.client.solrj.impl.CloudSolrClient;

import java.net.ServerSocket;
import java.net.Socket;
import java.io.IOException;

public class MultiThreadedServer implements Runnable{

    private int          serverPort;
    private ServerSocket pyServer = null;
    private boolean      isStopped    = false;
    private Thread       runningThread= null;
    private CloudSolrClient solrAPI;

    public MultiThreadedServer(int port, CloudSolrClient solrAPI){
        this.serverPort = port;
        this.solrAPI = solrAPI;
    }

    public void run(){
        synchronized(this){
            this.runningThread = Thread.currentThread();
        }
        openServerSocket();
        while(! isStopped()){
            Socket pySocket = null;
            try {
                pySocket = this.pyServer.accept();
                
            } catch (IOException e) {
                if(isStopped()) {
                    System.out.println("Server Stopped.") ;
                    return;
                }
                throw new RuntimeException(
                        "Error accepting client connection", e);
            }
            new Thread(
                    new WorkerRunnable(
                            pySocket, this.solrAPI, "Multithreaded Server")
            ).start();
        }
        System.out.println("Server Stopped.") ;
    }


    private synchronized boolean isStopped() {
        return this.isStopped;
    }

    public synchronized void stop(){
        this.isStopped = true;
        try {
            this.pyServer.close();
        } catch (IOException e) {
            throw new RuntimeException("Error closing server", e);
        }
    }

    private void openServerSocket() {
        try {
            this.pyServer = new ServerSocket(this.serverPort);
        } catch (IOException e) {
            throw new RuntimeException("Cannot open serverPort", e);
        }
    }

}
