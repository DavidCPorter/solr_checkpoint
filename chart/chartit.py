import pandas as pd
import plotly.express as px
import os
import sys
from datetime import datetime
import time
import gzip
import plotly


def display_chart(query,clustersize,codename):

    df = pd.read_csv('/Users/dporter/projects/solrcloud/chart/totals/total_'+clustersize+query+'_'+codename+'.csv')
    QPS = px.scatter(df, x = 'parallel_requests', y = 'QPS', color='rfshards', title=clustersize+" solr nodes using loadbalancer_type->"+query, color_discrete_sequence=px.colors.colorbrewer.Paired)
    tail = px.scatter(df, x = 'parallel_requests', y = 'tail_lat', color='rfshards',title=clustersize+" solr nodes using loadbalancer_type->"+query, color_discrete_sequence=px.colors.colorbrewer.Paired)
    plotly.offline.plot(QPS, filename=query+clustersize+codename+'QPS.html')
    plotly.offline.plot(tail, filename=query+clustersize+codename+'tail.html')
    return

def display_chart_scaling(query, codename):
    # df1 = pd.DataFrame()
    # df2 = pd.DataFrame()
    df = pd.read_csv('/Users/dporter/projects/solrcloud/chart/totals/clusterx/all_cluster_'+query+'_'+codename+'.csv')

    # df1 = df[df['clustersize'] == int('16')]
    # df2 = df[df['clustersize'] == int('32')]
    # df = pd.merge(df1, df2, how='inner', on=['rfshards'])
    # df.dropna(inplace=True)
    #
    # print(df)
    df = df.sort_values(by=["clustersize"])
    print(df)

    QPS = px.line(df, x = 'clustersize', y = 'QPS', color='GROUP', title="QPS performance scaling "+query+" 2 -> 32 servers")
    tail = px.line(df, x = 'clustersize', y = 'P95(ms)', color='GROUP',title="tail performance scaling "+query+" 2 -> 32 servers", color_discrete_sequence=px.colors.colorbrewer.Paired)
    # fig = px.scatter_matrix(df, dimensions=["QPS_x", 'P95 latency (ms)_y', "parallel_requests_x"], color="clustersize_y", color_discrete_sequence=px.colors.colorbrewer.Paired)

    plotly.offline.plot(QPS, filename="clusterx_"+query+' '+codename+'QPS.html')
    plotly.offline.plot(tail, filename="clusterx_"+query+' '+codename+'TAIL.html')

    # plotly.offline.plot(tail, filename="clusterx"+codename+'tail.html')
    # plotly.offline.plot(fig, filename="clusterx"+codename+'fig.html')

	#fig1.show()
    #fig2.show()

    return


if __name__ == "__main__":
    if len(sys.argv) == 3:
        display_chart_scaling(sys.argv[1],sys.argv[2])
    else:
        display_chart(sys.argv[1],sys.argv[2],sys.argv[3])

    sys.exit()
