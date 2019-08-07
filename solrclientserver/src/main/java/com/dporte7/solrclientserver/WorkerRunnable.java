package com.dporte7.solrclientserver;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.impl.CloudSolrClient;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocumentList;
import org.apache.solr.client.solrj.SolrRequest;

import java.io.*;
import java.net.Socket;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 *
 * @author dporter
 */


public class WorkerRunnable implements Runnable {
    private Socket pySocket = null;
    private String serverText = null;
    private CloudSolrClient solrAPI;
    private String query_string;
    private String http_request;
    private BufferedReader bf;
    private BufferedWriter bw;

    private InputStream input_stream;
    private OutputStream output;
    private long time;

    public WorkerRunnable(Socket clientSocket, CloudSolrClient solrAPI, String serverText) {
        this.pySocket = clientSocket;
        this.serverText = serverText;
        this.solrAPI = solrAPI;
    }

    public void run() {

        try {
            input_stream = pySocket.getInputStream();
            output = pySocket.getOutputStream();
            bf = new BufferedReader(new InputStreamReader(input_stream));
            String line;
            int count = 0;
            line = bf.readLine();
            while (line.length() != 0) {
                if (count == 0) {
                    http_request = line;
                    callSolrAPI(http_request);
                    count += 1;
                    line = bf.readLine();
                }else{
                    line = bf.readLine();
                }

            }
            time = System.currentTimeMillis();
            output.write(("HTTP/1.1 200 OK\n\nWorkerRunnable: " +
                    this.serverText + " - " +
                    time +
                    "").getBytes());
            output.close();
            input_stream.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void callSolrAPI(String query) {
        try {
            String[] query_parsed = query.split("/");
            doSearch(solrAPI, query_parsed[1] + ':' + query_parsed[2]);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void doSearch(CloudSolrClient cloudSolrClient, String q) throws Exception {
        try {

            SolrQuery query = new SolrQuery();
            cloudSolrClient.connect();
            query.setRows(100);
            query.setQuery(q);
            QueryResponse response = cloudSolrClient.query("reviews", query);
            SolrDocumentList docs = response.getResults();
            bw = new BufferedWriter(
                    new FileWriter("/users/dporte7/output.txt", true)  //Set true for append mode
            );
            bw.newLine();
            bw.write("#results：" + docs.getNumFound());
            bw.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
