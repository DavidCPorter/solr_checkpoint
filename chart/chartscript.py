import pandas as pd
import plotly.express as px
import os
import sys
from datetime import datetime
import time
import gzip
import plotly.graph_objects as go


def display_chart(clustersize,query):
    # proj_home = "~/projects/solrcloud"
    #
    # dirs = os.popen('ls '+proj_home+'/chart | grep clustersize').read()
    # dirs = dirs.split('\n')
    # dirs.pop()
    #
    # for d in dirs:
    #     print(d)
    #     files = os.popen('ls '+proj_home+'/chart/'+d+'/query'+query).read()
    #     print(files)
    #     files = files.split('\n')
    #     files.pop()
    #     print(files)

    # for f in files:
    df = pd.read_csv('/Users/dporter/projects/solrcloud/chart/totals/total_'+str(clustersize)+query+'_18:38:43-2019-10-03-.csv')
    fig1 = px.line(df, x = 'parallel_requests', y = 'QPS', color='rfshards',title=str(clustersize)+" solr nodes using loadbalancer_type->"+query)
    fig2 = px.line(df, x = 'parallel_requests', y = 'tail_lat', color='rfshards',title=str(clustersize)+" solr nodes using loadbalancer_type->"+query)
    fig1.show()
    fig2.show()

    return


if __name__ == "__main__":
    sys.exit(
    display_chart(32,'solrj')
    )
