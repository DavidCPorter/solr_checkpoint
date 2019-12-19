import os
import sys
from datetime import datetime
import time
import gzip

# args = $THREADS $DURATION $CON $QUERY $LOOP $PROCESSES

def main(p, t, d, rf, q, l, shards, solrnum, loadnodes, instances=None):
    proj_home = "~/projects/solrcloud"
    print('\n\nRUNNING readresults.py ::: ARGS == proc=%s threads=%s duration=%s' % (p, t, d))
    QPS = []
    median_lat = []
    tail_lat = []
    files = os.popen('ls '+proj_home+'/tests_v1/profiling_data/proc_results | grep '+q).read()
    files = files.split('\n')
    processes = float(len(files))
    print("num output files copied from remote == %s | should == %s (num procs passsed in to this script)" % (str(processes*int(t)), p) )
    files.pop()
    for file in files:
        f = open("/Users/dporter/projects/solrcloud/tests_v1/profiling_data/proc_results/"+file, 'r')
        #
        f.readline()
        # read first line which is the request total
        QPS.append(f.readline())
        f.readline()
        median_lat.append(f.readline())
        f.readline()
        tail_lat.append(f.readline())

        f.close()

    sum_queries_per_second=0.0
    for i in QPS:
        sum_queries_per_second +=float(i)

    sum_median_lat=0
    for i in median_lat:
        sum_median_lat +=int(float(i))

    sum_tail_lat=0
    for i in tail_lat:
        sum_tail_lat +=int(float(i))

    total_qps = round(sum_queries_per_second,2)
    total_med_lat = int(sum_median_lat/int(processes))
    total_tail_lat = int(sum_tail_lat/int(processes))

# simply to denote this is a single node cluster record
    if instances != "0":
        print("SINGLE NODE READRESULTS ")
        solrnum='9'+str(solrnum)

    try:
        os.makedirs('/Users/dporter/projects/solrcloud/tests_v1/profiling_data/exp_results/rf'+rf+'_s'+shards+'__clustersize'+solrnum)
    except FileExistsError:
        print("file exists\n\n\n")
        # directory already exists
        pass

    fp = open('/Users/dporter/projects/solrcloud/tests_v1/profiling_data/exp_results/rf'+rf+'_s'+shards+'__clustersize'+solrnum+'/rf'+rf+'_s'+shards+'__clustersize'+solrnum+"::query="+q+"::proc="+p+"::threads="+t+"::dur="+d+":::TIME->"+datetime.today().strftime('%Y-%m-%d-%H:%M:%S'), 'w+')
# for charting
#  writes -> total outstanding requests, QPS, median LAT, Tail LAT
    # 2*2 is simply compensating for the fact that I don't want to change the driver code to generate the correct number here - so i'm just hardcoding the outstanding requests position with p*2*2 b/c thats the right number.
    fp.write(p+','+str(total_qps)+','+str(total_med_lat)+','+str(total_tail_lat))
    fp.close()
    print("READRESULTS SCRIPT COMPLETE\n\n\n")

if __name__ == "__main__":
    arg_dict = {}
    # keys = [sys.argv[x*2] for x in range(1,len(sys.argv[1:])/2)]
    # values = [sys.argv[x*2] for x in range(1,len(sys.argv[1:])/2)]
    # print(keys)
    processes = sys.argv[1]
    threads = sys.argv[3]
    duration = sys.argv[5]
    replicas = sys.argv[7]
    query = sys.argv[9]
    loop = sys.argv[11]
    shards = sys.argv[13]
    solrnum = sys.argv[15]
    loadnodes = sys.argv[16]
    instances = sys.argv[17]

    sys.exit(
    main(processes,threads,duration,replicas,query,loop, shards, solrnum, loadnodes, instances)
    )
