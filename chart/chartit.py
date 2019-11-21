import pandas as pd
import plotly.express as px
import os
import sys
from datetime import datetime
import time
import gzip
import plotly
import shutil

def display_chart(query,clustersize,codename):

    df = pd.read_csv('/Users/dporter/projects/solrcloud/chart/totals/total_'+clustersize+query+'_'+codename+'.csv')
    QPS = px.scatter(df, x = 'parallel_requests', y = 'QPS', color='rfshards', title=clustersize+" solr nodes using loadbalancer_type->"+query, color_discrete_sequence=px.colors.colorbrewer.Paired)
    tail = px.scatter(df, x = 'parallel_requests', y = 'tail_lat', color='rfshards',title=clustersize+" solr nodes using loadbalancer_type->"+query, color_discrete_sequence=px.colors.colorbrewer.Paired)
    plotly.offline.plot(QPS, filename=query+clustersize+codename+'QPS.html')
    plotly.offline.plot(tail, filename=query+clustersize+codename+'tail.html')
    return

def display_chart_scaling(query, codename):
    # df = pd.DataFrame()
    # df2 = pd.DataFrame()

    total_scale_file = '/Users/dporter/projects/solrcloud/chart/scaling_exp_csvs/total_'+query+'_'+codename+'.csv'
    df = pd.read_csv(total_scale_file)

    # df1 = df[df['clustersize'] == int('16')]
    # df2 = df[df['clustersize'] == int('32')]
    # df = pd.merge(df1, df2, how='inner', on=['rfshards'])
    # df.dropna(inplace=True)
    #
    # print(df)
    # new_dfs = df.sort_values(["QPS","GROUP","clustersize"], ascending=[False,False,False])
    # new_df = df.sort_values(["QPS"], ascending=[False])
    # new_dff = new_df.sort_values(["GROUP"], ascending=[False])

    # df = df.sort_values(by=["GROUP"], ascending=False, inplace=True)
    #
    # df = df.sort_values(by=["clustersize"], ascending=False)

    # print(new_df)
    # new_df.to_csv(r'output.csv',index=False)
    QPS = px.line(df, x = 'clustersize', y = 'QPS', color='GROUP', title="QPS performance scaling "+query+" 2 -> 32 servers")
    tail = px.line(df, x = 'clustersize', y = 'P95_latency(ms)', color='GROUP',title="tail performance scaling "+query+" 2 -> 32 servers", color_discrete_sequence=px.colors.colorbrewer.Paired)
    # fig = px.scatter_matrix(df, dimensions=["QPS_x", 'P95 latency (ms)_y', "parallel_requests_x"], color="clustersize_y", color_discrete_sequence=px.colors.colorbrewer.Paired)
    try:
        os.makedirs('/Users/dporter/projects/solrcloud/chart/exp_html_out/_'+codename)
    except FileExistsError:
        print("file exists\n\n\n")
     # directory already exists
        pass
    plotly.offline.plot(QPS, filename="/Users/dporter/projects/solrcloud/chart/exp_html_out/_"+codename+"/_"+query+'_'+codename+'QPS.html')
    plotly.offline.plot(tail, filename="/Users/dporter/projects/solrcloud/chart/exp_html_out/_"+codename+"/_"+query+'_'+codename+'TAIL.html')

    # plotly.offline.plot(tail, filename="clusterx"+codename+'tail.html')
    # plotly.offline.plot(fig, filename="clusterx"+codename+'fig.html')

	#fig1.show()
    #fig2.show()

    # shutil.copytree("/Users/dporter/projects/solrcloud/chart/exp_records/"+codename, "/Users/dporter/projects/solrcloud/chart/exp_records/" )

    return


if __name__ == "__main__":
    if len(sys.argv) == 3:
        display_chart_scaling(sys.argv[1],sys.argv[2])
    else:
        display_chart(sys.argv[1],sys.argv[2],sys.argv[3])

    sys.exit()
