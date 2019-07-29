package com.mycompany.solrcloud.loadbalancer;

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

 */



public class WorkerRunnable implements Runnable{
    // private static final Logger logger = LogManager.getLogger();
    protected Socket pySocket = null;
    protected String serverText   = null;
    protected CloudSolrClient solrAPI;
    //    static final Log LOG = LogFactory.getLog(DistributedWebServer.class);
    private String query_string;
    private String http_request;
    private BufferedReader bf;
    private BufferedWriter bw;

    private InputStream input_stream;
    private OutputStream output;
    private long time;

//    private String query;

    public WorkerRunnable(Socket clientSocket, CloudSolrClient solrAPI, String serverText) {
        this.pySocket = clientSocket;
        this.serverText   = serverText;
        this.solrAPI = solrAPI;
    }

    public void run() {

        try {
            //System.out.println("running thread... ");

            input_stream  = pySocket.getInputStream();
            output = pySocket.getOutputStream();
            //System.out.println("inputStream: " + input_stream);


            bf = new BufferedReader(new InputStreamReader(input_stream));

            // //System.out.println(bf);
            String line;
            // //System.out.println(first_line);
            int count =0;
            while ((line = bf.readLine()) != null) {
                if (count==0){
                    http_request = line;
                    //System.out.println("query line: " + http_request);
                    callSolrAPI(http_request);

                    time = System.currentTimeMillis();
                    output.write(("HTTP/1.1 200 OK\n\nWorkerRunnable: " +
                            this.serverText + " - " +
                            time +
                            "").getBytes());
                    output.close();
                }
                //System.out.println(line);
                count +=1;
                // logger.info(http_request);
            }
            output.close();
            input_stream.close();
            //System.out.println("Request processed: " + time);
        } catch (IOException e) {
            //report exception somewhere.
            // e.printStackTrace();
        }
    }

    private void callSolrAPI(String query){
        try{
            String[] query_parsed = query.split("/");
            //System.out.println("Request term: " + query_parsed[1]+':'+query_parsed[2]);
            doSearch(solrAPI,query_parsed[1]+':'+query_parsed[2]);

        } catch (Exception e) {
            //report exception somewhere.
            // e.printStackTrace();
        }
    }

    private void doSearch(CloudSolrClient cloudSolrClient, String q) throws Exception {
        SolrQuery query = new SolrQuery();
        cloudSolrClient.connect();
        query.setRows(100);
        query.setQuery(q);
        //System.out.println("query string: " + q);
        QueryResponse response = cloudSolrClient.query("reviews", query);
        SolrDocumentList docs = response.getResults();
        bw = new BufferedWriter(
                            new FileWriter("/users/dporte7/output.txt", true)  //Set true for append mode
                        );
        bw.newLine();   //Add new line
        bw.write("#results：" + docs.getNumFound());
        bw.close();
        System.out.println("#results：" + docs.getNumFound());
        System.out.println("qTime：" + response.getQTime());
        System.out.println("elapsedTime：" + response.getElapsedTime());

    }

}
