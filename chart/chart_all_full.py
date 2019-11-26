import os
import sys
from datetime import datetime
import time
import gzip

# args = $THREADS $DURATION $CON $QUERY $LOOP $PROCESSES

def main(query,codename):
    proj_home = "~/projects/solrcloud"
    exp_home = "/Users/dporter/projects/solrcloud/chart/exp_records/"+codename
    print('RUNNING chart results')
    QPS = []
    median_lat = []
    tail_lat = []
    dirs = os.popen('ls '+exp_home+' | grep clustersize').read()
    print(dirs)
    dirs = dirs.split('\n')
    dirs.pop()
    print(dirs)

    try:
        os.makedirs('/Users/dporter/projects/solrcloud/chart/scaling_exp_csvs')
    except FileExistsError:
        print("file exists\n\n\n")
     # directory already exists
        pass

# this is for total file
    total_scale_file = '/Users/dporter/projects/solrcloud/chart/scaling_exp_csvs/total_'+query+'_'+codename+'.csv'
    fm = open(total_scale_file, "w+")
    fm.write('parallel_requests,QPS,median_lat,P95_latency(ms),clustersize,query,rfshards,GROUP\n')

    for d in dirs:
        print(d)        
        files = os.popen('ls '+exp_home+'/'+d+' | grep '+query).read()
        print(files)
        files = files.split('\n')
        files.pop()
        print(files[1:])
        # out_dir='/Users/dporter/projects/solrcloud/chart/records_cluster_specific/'+d+'/query'+query+'/'
        # try:
        #     os.makedirs(out_dir)
        # except FileExistsError:
        #     print("file exists\n\n\n")
        #     # directory already exists
        #     pass
        #
        #
        # # add table headers
        # complete_out_file=out_dir+d+'query'+query+'_chartdata_'+codename+'.csv'
        # fp = open(complete_out_file, "w+")
        # fp.write('parallel_requests,QPS,median_lat,tail_lat,clustersize,query,rfshards,GROUP\n')
        # fp.close()


        # removing cache warming file with [1:]
        for exp_output in files[1:]:
            f = open(exp_home+'/'+d+'/'+exp_output, 'r')
            data = f.readline()
            f.close()
            # fp = open(complete_out_file, "a+")
            csize=d[-4:]
            csize = csize.strip(' size')
            rf=str(d[2:4])
            rf = int(rf.strip('_'))
            shard=str(d[5:7])
            shard=shard.strip('_s')
            print(shard+'shard')
            rf_mult=int(rf/int(csize))
            print(rf_mult)
            # group is shards+replication_multiple
            group = shard+str(rf_mult)
            print(group)
            # fp.write(data+','+csize+','+query+','+d[:8]+','+group+'\n')
            # fp.close()
            fm = open(total_scale_file, "a+")
            fm.write(data+','+csize+','+query+','+d[:8]+','+group+'\n')
            fm.close()



if __name__ == "__main__":
    arg_dict = {}
    # keys = [sys.argv[x*2] for x in range(1,len(sys.argv[1:])/2)]
    # values = [sys.argv[x*2] for x in range(1,len(sys.argv[1:])/2)]
    # print(keys)
    # c = sys.argv[1]
    # q = sys.argv[2]
    # duration = sys.argv[5]
    # replicas = sys.argv[7]
    # query = sys.argv[9]
    # loop = sys.argv[11]
    # shards = sys.argv[13]
    # solrnum = sys.argv[15]
    sys.exit(
    main(sys.argv[1],sys.argv[2])
    )
