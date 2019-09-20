#!/usr/bin/python
# from __future__ import with_statement
import os
import sys
import time
import random
import logging
import threading
import numpy as np



def duration_based_test( test_param, thread_stats, conn, urls, start_flag, stop_flag, name ):
    """ Duration-based test to be carried out by each thread """
    sys.stdout.flush()
    j = int( name )
    # np.random.seed( j )

    # Pre-stage requests and wait times
    # sleep_times = [test_param.gauss_mean]
    # if test_param.req_dist == "gauss":
    #     sleep_times = np.abs( np.random.normal(loc=test_param.gauss_mean,
    #                                            scale=test_param.gauss_std, size=test_param.max_iters) )
    # elif test_param.req_dist == "poisson":
    #     sleep_times = np.random.poisson( lam=test_param.poisson_lam, size=test_param.max_iters )

    # Wait for start signal
    logging.debug( "Waiting for start event %s" % name )
    event_start = start_flag.wait()
    logging.debug( "Event %s: Starting" , event_start )
    start = time.time()

    # i = 0
    while not stop_flag.is_set():
    # while (time.time() - start) < 19:
        # dt = time.time() - start
        # req_start = time.time()
        try:
            # if dt > test_param.ramp:
            conn.request( "GET", urls[random.randint(1,1000)], headers = {'Connection':'keep-alive'})
            resp = conn.getresponse()
            resp.read()

                # req_finish = time.time()
                # fct = req_finish - req_start
                # thread_stats.avg_lat[j] += fct
                # # request_list.put((name,urls[i%test_param.max_iters],req_start,req_finish,fct))
                # thread_stats.avg_lat[j] += time.time() - req_start
            # thread_stats.responses[j] += 1
            j+=1
                # thread_stats.byte_count[j] += len( rsp.data )
            # logging.debug("SUCCESS->"+str(i)+urls[i%test_param.max_iters])
            # i+=1

        except Exception as e:
            print("ERROR")
            # logging.debug( "Error while requesting: %s - %s - %s" % (str(i%test_param.max_iters), urls[i%test_param.max_iters], str(e)) )
            # if dt > test_param.ramp:
            #     thread_stats.errors[j] += 1
        # i += 1
        # print(i)
        #
        # print(hex(id(i)))
    conn.close()
    thread_stats.requests[int( name )] = j-int(name)
    # if thread_stats.requests[j] > 0:
    #     thread_stats.avg_lat[j] = thread_stats.avg_lat[j] / float( thread_stats.requests[j] )
    logging.debug( "Exiting" )

    return

def size_based_test( test_param, thread_stats, start_flag, stop_flag ):
    """ Size-based test to be carried out by each thread """
    # terms = ["good","bad","5","stars","best","horrible","incredible","terrific","garbage"]
    # indexed_fields = ["reviewerName","reviewText","overall ","summary"]
    # name = threading.currentThread().getName()
    # j = int( name )
    # prefix_url = "%s/" % (test_param.base_url)
    # np.random.seed( j )
    # http_pool = test_param.http_pool
    #
    # # Pre-stage requests and wait times
    # sleep_times = [test_param.gauss_mean]
    # if test_param.req_dist == "gauss":
    #     sleep_times = np.abs( np.random.normal(loc=test_param.gauss_mean,
    #                                            scale=test_param.gauss_std, size=test_param.max_iters) )
    # elif test_param.req_dist == "poisson":
    #     sleep_times = np.random.poisson( lam=test_param.poisson_lam, size=test_param.max_iters )
    # urls = []
    #
    # if test_param.rand_req:
    #     for i in range( test_param.max_iters ):
    #         #add random query here
    #         term = terms[i%len(terms)]
    #         field = indexed_fields[i%len(indexed_fields)]
    #         q = 'solr/reviews/select?q='+field+'%3A'+term+'&rows=10'
    #         urls.append( "%s%s" % (prefix_url, q))
    # else:
    #     for i in range( test_param.max_iters ):
    #         term = terms[i%len(terms)]
    #         field = indexed_fields[i%len(indexed_fields)]
    #         q = 'solr/reviews/select?q='+field+'%3A'+term+'&rows=10'
    #         urls.append( "%s%s" % (prefix_url, q))
    # # Wait for start signal
    # with start_flag:
    #     start_flag.wait()
    #     logging.debug( "Starting" )
    #
    # i = 0
    # while not stop_flag.isSet():
    #     # Wait before making next request
    #     time.sleep( sleep_times[i] )
    #     req_start = time.time()
    #     try:
    #         # rsp = http_pool.request( "GET", urls[i%test_param.max_iters] )
    #         rsp = http_pool.request( "GET", "/good/" )
    #
    #         thread_stats.avg_lat[j] += time.time() - req_start
    #         thread_stats.responses[j] += 1
    #         thread_stats.byte_count[j] += len( rsp.data )
    #     except Exception as e:
    #         logging.debug( "Error while requesting: %s - %s" % (urls[i], str(e)) )
    #         thread_stats.errors[j] += 1
    #     i += 1
    # thread_stats.requests[j] = http_pool.num_requests
    # if thread_stats.requests[j] > 0:
    #     thread_stats.avg_lat[j] = thread_stats.avg_lat[j] / float( thread_stats.requests[j] )
    # logging.debug( "Exiting" )

    return
