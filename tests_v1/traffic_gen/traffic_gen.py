#!/usr/bin/python
# from __future__ import with_statement
import os
import sys
import time
import random
import logging
import argparse
import threading
import numpy as np
import queue
from testmodes import *
from clparsing import *
from benchstats import *
from threadargs import *



def main( ):
    """ Main function """
    # get args
    main_args = parse_commandline(sys.argv[1:])
    if main_args.query == 'direct':
        main_args.host = '10.10.1.'+str(random.randint(0,2))
        main_args.port = 8983

# config for closed loop -> throughput
    if main_args.loop == 'closed':
        main_args.threads = 1
        main_args.connections = 1


    # Setup logging
    logging.basicConfig( level=logging.DEBUG,
                         format="[%(threadName)s]: [%(asctime)-15s] - %(message)s",
                         filename="traffic_gen.log" )
    logging.getLogger( "urllib3" ).setLevel( logging.WARNING )

    # objects to sync start time for threads
    start_flag = threading.Event()
    stop_flag = threading.Event()

    # randomized traffic params
    gauss_mean = 1.0 / 16384.0
    gauss_std = 0.5
    poisson_lam = gauss_mean

    # returns tuple with thread args
    thread_args = create_threadargs(main_args, start_flag, stop_flag, gauss_mean, gauss_std, poisson_lam)

    # ******* START TEST ********
    # set test function
    target = size_based_test if main_args.test_type == "size" else duration_based_test

    # Spawn threads
    for i in range( main_args.threads ):
        next_name = "%03d" % ( i )
        next_thread = threading.Thread( name=next_name,
                                        target=target,
                                        args=thread_args,
                                      )
        next_thread.start()


    init_interval = 3
    logging.debug( "Waiting %d s for %d threads to initialize" % (init_interval, main_args.threads) )
    time.sleep( init_interval )
    logging.debug( "Signaling threads to start test" )

    # start threads
    start_flag.set()

    # Add ramp time

    # Wait for test completion
    start = time.time()
    if main_args.test_type == "duration":
        sleep_time = main_args.ramp + main_args.duration
        logging.debug( "Waiting %d s for test to complete" % (sleep_time) )
        time.sleep ( sleep_time )
    else:
        logging.debug( "Waiting for %d B to be requested for test to complete" % (main_args.transfer_size) )
        sleep_time = gauss_mean * 10.0
        if main_args.req_dist == "poisson":
            sleep_time = poisson_lam * 10.0
        while np.sum(thread_stats.byte_count) < main_args.transfer_size:
            time.sleep( sleep_time )
    stop_flag.set()
    # global thread_stats
    thread_stats.duration = time.time() - start
    logging.debug( "Test completed" )

    # Join on threads
    main_thread = threading.currentThread()
    for next_thread in threading.enumerate():
        if next_thread is not main_thread:
            next_thread.join( )

    # Calculate statistics
    web_stats = calc_web_stats( thread_stats )
    web_stats = convert_units( web_stats )

    # Save statistics to CSV file
    if main_args.query == 'direct':
        csv_file = os.path.join( main_args.output_dir, "http_benchmark_direct.csv" )
    else:
        csv_file = os.path.join( main_args.output_dir, "http_benchmark_solrj.csv" )

    write_csv( csv_file, web_stats, main_args, return_list )
    logging.debug( "Wrote %s" % (csv_file) )

    return 0

if __name__ == "__main__":
    sys.exit( main() )
