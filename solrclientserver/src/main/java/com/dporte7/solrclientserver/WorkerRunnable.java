package com.dporte7.solrclientserver;

import org.apache.commons.lang.ObjectUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.impl.CloudSolrClient;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocumentList;
import org.apache.solr.client.solrj.SolrRequest;

import java.io.*;
import java.net.Socket;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.solr.common.util.NamedList;

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
    private int sample_count;
    private int iter_counter;
    private InputStream input_stream;
    private OutputStream output;
    private long time;
    private boolean isStopped;
    //    we should be checking what solr responds with even tho we send default response to client each time.
    private List solr_response_list;

    public WorkerRunnable(boolean isStopped, Socket clientSocket, CloudSolrClient solrAPI, String serverText) {
        this.pySocket = clientSocket;
        this.serverText = serverText;
        this.solrAPI = solrAPI;
        this.isStopped = isStopped;
        this.iter_counter = 0;
    }

    public void run() {

        try {
            input_stream = pySocket.getInputStream();
            output = pySocket.getOutputStream();
            bf = new BufferedReader(new InputStreamReader(input_stream));
            while (!bf.ready()){
            }
            while (true){
                if (!readBuffer(output, input_stream)){
                    return;
                }
                if (this.iter_counter == 0){
                    this.pySocket.setSoTimeout(4000);
                    this.iter_counter = 1;
                }
                writeResponse();
            }
        } catch (IOException e) {
            try {
                this.pySocket.close();
            } catch (IOException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        }
    }
    private boolean readBuffer(OutputStream out, InputStream is) throws IOException {

        try{
            String line = null;
            int count = 0;
            while (!bf.ready()){
            }
            while (bf.ready()) {
                if (count == 0){
                    line = bf.readLine();
                    if (line.equalsIgnoreCase("bye")){
                        this.pySocket.close();
                        return false;
                    }
                    http_request = line;
                    callSolrAPI(http_request);
                    count +=1;
                    line = bf.readLine();
                }else{
                    line = this.bf.readLine();
                    if (line.equalsIgnoreCase("bye")){
                        this.pySocket.close();
                        return false;
                    }
                }
            }
            return true;
        }
        catch (IOException e) {
            this.pySocket.close();
            e.printStackTrace();
            return false;
        }
    }

    private void writeResponse() throws IOException {
        try{
            // time = System.currentTimeMillis();
            output.write(("HTTP/1.1 200 OK\nContent-Type: application/json;charset=utf-8\nContent-Length:0"+ "\n\n").getBytes());
        }
        catch (IOException e) {
          this.pySocket.close();

          e.printStackTrace();
        }
    }


    private void callSolrAPI(String query) {
        try {
            String[] query_parsed = query.split("/");
            String[] col = query_parsed[3].split(" ");
            doSearch(solrAPI, query_parsed[1] + ':' + query_parsed[2], col[0] );

        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void doSearch(CloudSolrClient cloudSolrClient, String q, String collection) throws Exception {
        try {

            SolrQuery query = new SolrQuery();
            query.setRows(10);
            query.setQuery(q);
            QueryResponse response = cloudSolrClient.query(collection, query);

            // SolrDocumentList ret = response.getResults();
//            System.out.println(ret);
            // SolrDocumentList docs = response.getResults();
            // bw = new BufferedWriter(
            //         new FileWriter("/users/dporte7/output.txt", true)  //Set true for append mode
            // );
            // bw.newLine();
            // bw.write("#results：" + ret.getNumFound());
            // bw.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
