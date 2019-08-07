/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.dporte7.solrclientserver;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.impl.CloudSolrClient;
import org.apache.solr.client.solrj.response.QueryResponse;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
/**
 *
 * @author dporter
 */
public class DistributedWebServer {

    private static String defaultCollection = "reviews";
    private static CloudSolrClient instance;
    static {
        CloudSolrClient.Builder builder = new CloudSolrClient.Builder();
        builder.withZkHost(Arrays.asList("10.10.1.1:2181","10.10.1.2:2181","10.10.1.3:2181"));
        instance = builder.build();
        final int zkClientTimeout = 9999;
        final int zkConnectTimeout = 9999;
        instance.setDefaultCollection(defaultCollection);
        instance.setZkClientTimeout(zkClientTimeout);
        instance.setZkConnectTimeout(zkConnectTimeout);
    }

    public static void main(String[] args) throws Exception {
        //try passing just one instance of cloudsolrclient to thread generator class
        System.out.println("starting Server");
        System.out.println(instance);
        MultiThreadedServer server = new MultiThreadedServer(9111, instance);
        new Thread(server).start();

        try {
            Thread.sleep(200 * 1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("Stopping Server");
        //stops multithreded server loop
        server.stop();

    }

}
