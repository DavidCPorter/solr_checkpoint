import pandas as pd
import plotly.express as px
import os
import sys
from datetime import datetime
import time
import gzip
import plotly
import shutil
import plotly.graph_objects as go

# class GroupBucket(list):


class LineData():
    def __repr__(self):
        return str(self.__dict__)
    # input_x == cluster sizes list
    #  input_y == average QPS for each cluster size for a given GROUP
    #  GROUPNAME == the config for that exp. ee.g. rf_multiple == 4 and Shard == 2 ; GROUP =(4 2)
    #  north error == the max QPS for theat cluster for given GROUP
    #  south_error == the min QPS for that GROUP and Cluster

    def __init__(self, gn, csize):
        self.csize = csize
        self.input_x = []
        self.input_y = []
        self.GROUPNAME = gn
        self.north_error = []
        self.south_error = []
        self.name=''

    def getGn(self):
        return self.GROUPNAME
#  just gonna save some time and append since this is done in sorted order anyway, so values match across lists
    def setInputX(self, x):
        self.input_x.append(x)

    def setInputY(self, y):
        self.input_y.append(y)

    def setInputNe(self, ne):
        self.north_error.append(ne)

    def setInputSe(self, se):
        self.south_error.append(se)

    def setName(self, gn):
        self.name='Shards='+str(gn)[0]+", RF_multiple="+str(gn)[1]

    def setLine(self):
         # clustersize = df.filter(like)
        south = [i - j for i, j in zip(self.input_y, self.south_error)]
        north = [i - j for i, j in zip(self.north_error, self.input_y)]
        data=go.Scatter(
                x=self.input_x,
                y=self.input_y,
                error_y=dict(
                    type='data',
                    symmetric=False,
                    array=north,
                    arrayminus=south),
                name=self.name)
        return data



def display_chart(query,clustersize,codename):

    df = pd.read_csv('/Users/dporter/projects/solrcloud/chart/totals/total_'+clustersize+query+'_'+codename+'.csv')
    QPS = px.scatter(df, x = 'parallel_requests', y = 'QPS', color='rfshards', title=clustersize+" solr nodes using loadbalancer_type->"+query, color_discrete_sequence=px.colors.colorbrewer.Paired)
    tail = px.scatter(df, x = 'parallel_requests', y = 'tail_lat', color='rfshards',title=clustersize+" solr nodes using loadbalancer_type->"+query, color_discrete_sequence=px.colors.colorbrewer.Paired)
    plotly.offline.plot(QPS, filename=query+clustersize+codename+'QPS.html')
    plotly.offline.plot(tail, filename=query+clustersize+codename+'tail.html')
    return


def fillLineList(lineList, df, c):
    # this loop fills the data structure the plotting library needs to project the results
    for ld in lineList:
        gn = ld.getGn()
        ld.setName(gn)
        gn_line_df = df.loc[df['GROUP'] == gn]
        gn_line_df.sort_values("clustersize")
        # this loop creates a single line on the chart that corresponds to a GN aka config set
        for i in gn_line_df.clustersize.unique():
            cluster_spec_data_for_gn = gn_line_df.loc[gn_line_df['clustersize'] == i ]

            ld.setInputX(i)
            # these set the value for a single error bar on the line
            ld.setInputY(cluster_spec_data_for_gn[c].mean())
            ld.setInputNe(cluster_spec_data_for_gn[c].max())
            ld.setInputSe(cluster_spec_data_for_gn[c].min())
            print(str(ld))


def display_chart_scaling_errorbar(query, codename):

    total_scale_file = '/Users/dporter/projects/solrcloud/chart/scaling_exp_csvs/total_'+query+'_'+codename+'.csv'
    df = pd.read_csv(total_scale_file)
    df = df.sort_values("clustersize")
    # <class 'numpy.ndarray'>
    cluster_array = df.clustersize.unique()
    group_array = df.GROUP.unique()
    #  there will be a line for each config aka Group contined in the lineList
    qpsLineList = [LineData(x, cluster_array.size) for x in group_array]
    latLineList = [LineData(x, cluster_array.size) for x in group_array]

    fillLineList(qpsLineList, df, "QPS")
    fillLineList(latLineList, df, "P95_latency(ms)")


# this creates the line data the lib needs and packs into a list
    qps_data_list = [ x.setLine() for x in qpsLineList]
    lat_data_list = [ x.setLine() for x in latLineList]

    fig_qps = go.Figure(qps_data_list)
    fig_lat = go.Figure(lat_data_list)

    fig_qps.show()
    fig_lat.show()
    try:
        os.makedirs('/Users/dporter/projects/solrcloud/chart/exp_html_out/_'+codename)
    except FileExistsError:
        print("file exists\n\n\n")
     # directory already exists
        pass
    plotly.offline.plot(fig_qps, filename="/Users/dporter/projects/solrcloud/chart/exp_html_out/_"+codename+"/_"+query+'_'+codename+'QPS.html')
    plotly.offline.plot(fig_lat, filename="/Users/dporter/projects/solrcloud/chart/exp_html_out/_"+codename+"/_"+query+'_'+codename+'TAIL.html')





if __name__ == "__main__":
    if len(sys.argv) == 3:
        display_chart_scaling_errorbar(sys.argv[1],sys.argv[2])
    else:
        display_chart(sys.argv[1],sys.argv[2],sys.argv[3])

    sys.exit()
