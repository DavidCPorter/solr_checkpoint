/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.mycompany.solrcloud.loadbalancer;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.impl.CloudSolrClient;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;
import org.apache.solr.common.SolrInputDocument;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
/**
 *
 * @author dporter
 */
public class DistributedWebServer {

    static final Log LOG = LogFactory.getLog(DistributedWebServer.class);
    private static CloudSolrClient cloudSolrClient;

    private static String defaultCollection = "reviews";

    static {
        CloudSolrClient.Builder builder = new CloudSolrClient.Builder();
        builder.withZkHost(Arrays.asList(new String[] { "10.10.1.1:2181,10.10.1.2:2181,10.10.1.3:2181" }));
        cloudSolrClient = builder.build();
        final int zkClientTimeout = 9999;
        final int zkConnectTimeout = 9999;
        cloudSolrClient.setDefaultCollection(defaultCollection);
        cloudSolrClient.setZkClientTimeout(zkClientTimeout);
        cloudSolrClient.setZkConnectTimeout(zkConnectTimeout);
    }


    public void search(CloudSolrClient cloudSolrClient, String Str) throws Exception {
        SolrQuery query = new SolrQuery();
        query.setRows(100);
        query.setQuery(Str);
        QueryResponse response = cloudSolrClient.query(query);
        SolrDocumentList docs = response.getResults();
        System.out.println("query: " + query);
        System.out.println("#results：" + docs.getNumFound());
        System.out.println("qTime：" + response.getQTime());
        System.out.println("elapsedTime：" + response.getElapsedTime());

    }

    public static void main(String[] args) throws Exception {
        String str = "overall:5.0";
        cloudSolrClient.connect();
        DistributedWebServer webserver = new DistributedWebServer();
        webserver.search(cloudSolrClient, str);
        cloudSolrClient.close();
    }
}
