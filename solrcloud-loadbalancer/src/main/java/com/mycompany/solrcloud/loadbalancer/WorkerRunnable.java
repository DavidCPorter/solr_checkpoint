package com.mycompany.solrcloud.loadbalancer;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.impl.CloudSolrClient;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocumentList;

import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;
import java.net.Socket;
import java.io.DataInputStream;

/**

 */
public class WorkerRunnable implements Runnable{

    protected Socket pySocket = null;
    protected String serverText   = null;
    protected CloudSolrClient solrAPI;
    static final Log LOG = LogFactory.getLog(DistributedWebServer.class);
    private String query_string;

//    private String query;

    public WorkerRunnable(Socket clientSocket, CloudSolrClient solrAPI, String serverText) {
        this.pySocket = clientSocket;
        this.serverText   = serverText;
        this.solrAPI = solrAPI;
    }

    public void run() {

        try {
            InputStream input  = pySocket.getInputStream();
            byte[] data      = new byte[128];
            int    bytesRead = input.read(data);

            query_string = new String(data);

            query_string=query_string.trim();

            System.out.println("Request processed: " + query_string);
            callSolrAPI(query_string);

            OutputStream output = pySocket.getOutputStream();
            long time = System.currentTimeMillis();
            output.write(("HTTP/1.1 200 OK\n\nWorkerRunnable: " +
                    this.serverText + " - " +
                    time +
                    "").getBytes());
            output.close();
            input.close();
            System.out.println("Request processed: " + time);
        } catch (IOException e) {
            //report exception somewhere.
            e.printStackTrace();
        }
    }

    private void callSolrAPI(String query){
        try{
            doSearch(solrAPI,query);

        } catch (Exception e) {
            //report exception somewhere.
            e.printStackTrace();
        }
    }

    public void doSearch(CloudSolrClient cloudSolrClient, String q) throws Exception {
        SolrQuery query = new SolrQuery();
        cloudSolrClient.connect();
        query.setRows(100);
        query.setQuery(q);
        System.out.println(cloudSolrClient);
        System.out.println("query string: " + q);
        QueryResponse response = cloudSolrClient.query(query);
        SolrDocumentList docs = response.getResults();
        System.out.println("#results：" + docs.getNumFound());
        System.out.println("qTime：" + response.getQTime());
        System.out.println("elapsedTime：" + response.getElapsedTime());

    }

}
