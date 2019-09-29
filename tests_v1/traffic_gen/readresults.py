import os
import sys
from datetime import datetime
import time

# args = $THREADS $DURATION $CON $QUERY $LOOP $PROCESSES

def main(p, t, d, rf, q, l, shards):
    proj_home = "~/projects/solrcloud"
    print('RUNNING READRESULTS %s%s%s' % (p, t, d))
    results = []
    files = os.popen('ls '+proj_home+'/tests_v1/profiling_data/proc_results | grep '+q).read()
    files = files.split('\n')
    files.pop()
    print(files)
    f=''
    for file in files:
        print(file)
        f = open("/Users/dporter/projects/solrcloud/tests_v1/profiling_data/proc_results/"+file, 'r')
        # read first line which is the request total
        results.append(f.readline())
    f.close()
    total_queries=0
    for i in results:
        total_queries +=int(i)

    fp = open('/Users/dporter/projects/solrcloud/tests_v1/profiling_data/exp_results/'+"query_"+q+"-->  proc_"+p+"threads_"+t+"dur_"+d+":::TIME->"+datetime.today().strftime('%Y-%m-%d-%H:%M:%S'), 'w+')

    fp.write(str(total_queries)+'\n'+p+'\n'+t+'\n'+d+'\n'+q)
    fp.close()


if __name__ == "__main__":
    arg_dict = {}
    # keys = [sys.argv[x*2] for x in range(1,len(sys.argv[1:])/2)]
    # values = [sys.argv[x*2] for x in range(1,len(sys.argv[1:])/2)]
    # print(keys)
    processes = sys.argv[1]
    threads = sys.argv[3]
    duration = sys.argv[5]
    connections = sys.argv[7]
    query = sys.argv[9]
    loop = sys.argv[11]
    sys.exit(
    main(processes,threads,duration,connections,query,loop)
    )
