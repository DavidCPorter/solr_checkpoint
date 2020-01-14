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

    def __init__(self, gn, csize=0, load=0):
        self.csize = csize
        self.input_x = []
        self.input_y = []
        self.GROUPNAME = gn
        self.north_error = []
        self.south_error = []
        self.load=load
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
        the_load=''
        the_clustersize=''
        if self.load > 0:
            the_load="load="+str(self.load)+"::"
        if self.csize > 0:
            the_clustersize='clustersize='+str(self.csize)+"::"
        self.name=the_load+the_clustersize+' Shards='+str(gn)[0]+", Replicas="+str(gn)[1]

    def setLine(self):
         # clustersize = df.filter(like)
        south = [i - j for i, j in zip(self.input_y, self.south_error)]
        north = [i - j for i, j in zip(self.north_error, self.input_y)]
        max_y=[sum(x) for x in zip(north, self.input_y)]
        data=go.Scatter(
                x=self.input_x,
                # using max QPS w/ north
                y=max_y,
                name=self.name)
        return data

    def setLineErrorBars(self):
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

    def setTailLine(self):
         # clustersize = df.filter(like)
        data=go.Scatter(
                x=self.input_x,
                y=self.input_y,
                name=self.name,
                )
        return data





# REMEMBER lineList is a List full of line objects with  with just the length of the x axis (clustersize.size) and groupname attached to each object
# this function will fill out each CLUSTERSIZE AND GROUPNAME linelist object with   x = parallel_requests and   y = P95_latency(ms)
def fillClustersizeLine(lineList, df, col):
    df.rename(columns={'P95_latency(ms)':'P95ms'}, inplace=True)
    for ld in lineList:
        gn = ld.getGn()
        ld.setName(gn)
        gn_line_df = df.loc[df['GROUP'] == gn]
        gn_csize_df = gn_line_df.loc[df["clustersize"] == ld.csize]

        #  gn_csize_df is a df for a single line... just need to populte ld now by iterating over the parallel_requests (x) and setting latency as y
        x_set = gn_csize_df.parallel_requests.unique()
        x_set.sort()
        for i in x_set:
            ld.setInputX(i)
            yinput = gn_csize_df.query("parallel_requests == %s" % str(i))
            ld.setInputY(yinput.iloc[0]['P95ms'])

def fillClustersizeLineQPS(lineList, df, col):
    for ld in lineList:
        gn = ld.getGn()
        ld.setName(gn)
        gn_line_df = df.loc[df['GROUP'] == gn]
        gn_csize_df = gn_line_df.loc[df["clustersize"] == ld.csize]

        #  gn_csize_df is a df for a single line... just need to populte ld now by iterating over the parallel_requests (x_set) and setting latency as y
        x_set = gn_csize_df.parallel_requests.unique()
        x_set.sort()
        for i in x_set:
            ld.setInputX(i)
            yinput = gn_csize_df.query("parallel_requests == %s" % str(i))
            ld.setInputY(yinput.iloc[0]['QPS'])

def fillLineList(lineList, df, c):
    # this loop fills the data structure the plotting library needs to project the results
    for ld in lineList:
        gn = ld.getGn()
        ld.setName(gn)
        gn_line_df = df.loc[df['GROUP'] == gn]
        gn_line_df.sort_values("clustersize")
        # for each point on the line's x axis
        for i in gn_line_df.clustersize.unique():
            cluster_spec_data_for_gn = gn_line_df.loc[gn_line_df['clustersize'] == i ]

            ld.setInputX(i)

            # these two lines remove the warm cache line

            cluster_spec_data_for_gn.sort_values("QPS", inplace=True)
            # cluster_spec_data_for_gn = cluster_spec_data_for_gn.drop(cluster_spec_data_for_gn.index[0])
            # these set the value for a single error bar on the line

            ld.setInputY(cluster_spec_data_for_gn[c].mean())
            ld.setInputNe(cluster_spec_data_for_gn[c].max())
            ld.setInputSe(cluster_spec_data_for_gn[c].min())
            # print(str(ld))

# def fillLineListCDF(lineList, df, c):
#     for ld in lineList:
#         gn = ld.getGn()
#         ld.setName(gn)
#         gn_line_df = df.loc[df['GROUP'] == gn]
#         gn_csize_df = gn_line_df.loc[df["clustersize"] == ld.csize]
#
#         #  gn_csize_df is a df for a single line... just need to populte ld now by iterating over the parallel_requests (x_set) and setting latency as y
#         x_set = gn_csize_df.parallel_requests.unique()
#         x_set.sort()
#         for i in x_set:
#             ld.setInputX(i)
#             yinput = gn_csize_df.query("parallel_requests == %s" % str(i))
#             ld.setInputY(yinput.iloc[0][''])

def cdfFillLineList(lineList, df):
    # this loop fills the data structure the plotting library needs to project the results
    seconds_to_millis_factor=1000

    for ld in lineList:
        gn = ld.getGn()
        ld.setName(gn)
        gn_line_df = df.loc[df['GROUP'] == gn]
        l_row = gn_line_df.loc[gn_line_df['clustersize'] == ld.csize]
        line_row = l_row.loc[l_row['parallel_requests'] == ld.load]
        fct_values=line_row.iloc[0]["fcts"].split("--")
        # print(fct_values)
        percentile_count=0
        for i in fct_values:
            ld.setInputX(float(i)*seconds_to_millis_factor)
            ld.setInputY(percentile_count)
            percentile_count=percentile_count+5


def QPS_max_throughput(query, codename):
    lat_fig_title=""
    lat_fig_title="SolrCloud QPS (Round Robin)" if query == "direct" else "SolrCloud QPS (SolrJ)"

    total_scale_file = '/Users/dporter/projects/solrcloud/chart/scaling_exp_csvs/total_'+query+'_'+codename+'.csv'
    df = pd.read_csv(total_scale_file)
    df = df.sort_values("clustersize")
    # <class 'numpy.ndarray'>
    clustersizeList = df.clustersize.unique()
    group_array = df.GROUP.unique()
    #  this creates a list of line objects for each groupname/clusersize combo
    latLineList=[]
    for csize in clustersizeList:
        for gn in group_array:
            latLineList.append(LineData(gn,csize))
    fillClustersizeLineQPS(latLineList, df, "QPS")



# this creates the line data the lib needs and packs into a list
    lat_data_list = [ x.setTailLine() for x in latLineList]
    print(lat_data_list)
    fig_lat = go.Figure(lat_data_list)
    x_font=dict(
        size=20,
        color="#7f7f7f"
        )

    fig_lat.update_layout(
        title=lat_fig_title,
        xaxis_title="parallel_requests",
        xaxis={"title":{"font":x_font}},
        yaxis_title="QPS",

    )


    # fig_qps.show()
    # fig_lat.show()
    try:
        os.makedirs('/Users/dporter/projects/solrcloud/chart/exp_html_out/_'+codename)
    except FileExistsError:
        print("file exists\n\n\n")
     # directory already exists
        pass
    plotly.offline.plot(fig_lat, filename="/Users/dporter/projects/solrcloud/chart/exp_html_out/_"+codename+"/tailchart_"+query+'_'+codename+'QPS.html')

def P95_max_throughput(query, codename):
    lat_fig_title=""
    lat_fig_title="SolrCloud Tail Latency (Round Robin)" if query == "direct" else "SolrCloud Tail Latency (SolrJ)"

    total_scale_file = '/Users/dporter/projects/solrcloud/chart/scaling_exp_csvs/total_'+query+'_'+codename+'.csv'
    df = pd.read_csv(total_scale_file)
    df = df.sort_values("clustersize")
    # <class 'numpy.ndarray'>
    clustersizeList = df.clustersize.unique()
    group_array = df.GROUP.unique()
    #  this creates a list of line objects for each groupname/clusersize combo
    latLineList=[]
    for csize in clustersizeList:
        for gn in group_array:
            latLineList.append(LineData(gn,csize))
    fillClustersizeLine(latLineList, df, "P95_latency(ms)")



# this creates the line data the lib needs and packs into a list
    lat_data_list = [ x.setTailLine() for x in latLineList]
    fig_lat = go.Figure(lat_data_list)
    x_font=dict(
        size=20,
        color="#7f7f7f"
        )

    fig_lat.update_layout(
        barmode='overlay',
        title=lat_fig_title,
        xaxis_title="outstanding_requests",
        xaxis={"title":{"font":x_font}},
        yaxis_title="P95_latency(ms)",

    )


    # fig_qps.show()
    # fig_lat.show()
    try:
        os.makedirs('/Users/dporter/projects/solrcloud/chart/exp_html_out/_'+codename)
    except FileExistsError:
        print("file exists\n\n\n")
     # directory already exists
        pass
    plotly.offline.plot(fig_lat, filename="/Users/dporter/projects/solrcloud/chart/exp_html_out/_"+codename+"/tailchart_"+query+'_'+codename+'TAIL.html')



def display_chart_scaling_errorbar(query, codename):
    qps_fig_title=""
    qps_fig_title="SolrCloud Query Throughput (Round Robin)" if query == "direct" else "SolrCloud Query Throughput (SolrJ)"
    lat_fig_title=""
    lat_fig_title="SolrCloud Tail Latency (Round Robin)" if query == "direct" else "SolrCloud Tail Latency (SolrJ)"

    total_scale_file = '/Users/dporter/projects/solrcloud/chart/scaling_exp_csvs/total_'+query+'_'+codename+'.csv'

    ideal_path='/Users/dporter/projects/solrcloud/chart/scaling_exp_csvs/ideal_line_direct.csv'
    if query == "solrj":
        ideal_path='/Users/dporter/projects/solrcloud/chart/scaling_exp_csvs/ideal_line.csv'

    df = pd.read_csv(total_scale_file)
    ideal_df=pd.read_csv(ideal_path)
    df_QPS=df.append(ideal_df)
    df_QPS = df_QPS.sort_values("clustersize")
    df=df.sort_values("clustersize")
    group_array_QPS= df_QPS.GROUP.unique()
    group_array_TAIL= df.GROUP.unique()
    #  there will be a line for each config aka Group contined in the lineList
    qpsLineList = [LineData(x) for x in group_array_QPS]
    latLineList = [LineData(x) for x in group_array_TAIL]

    fillLineList(qpsLineList, df_QPS, "QPS")
    fillLineList(latLineList, df, "P95_latency(ms)")


# this creates the line data the lib needs and packs into a list
    qps_data_list = [ x.setLine() for x in qpsLineList]
    lat_data_list = [ x.setLine() for x in latLineList]

    fig_qps = go.Figure(qps_data_list)
    fig_lat = go.Figure(lat_data_list)
    fig_qps.update_layout(
        title=qps_fig_title,
        xaxis_title="Cluster Size",
        yaxis_title="QPS",
        font=dict(
            family="Courier New, monospace",
            size=18,
            color="#7f7f7f"
            )
    )
    fig_lat.update_layout(
        title=lat_fig_title,
        xaxis_title="Cluster Size",
        yaxis_title="P95_latency(ms)",
        font=dict(
            family="Courier New, monospace",
            size=18,
            color="#7f7f7f"
            )
    )




    # fig_qps.show()
    # fig_lat.show()
    try:
        os.makedirs('/Users/dporter/projects/solrcloud/chart/exp_html_out/_'+codename)
    except FileExistsError:
        print("file exists\n\n\n")
     # directory already exists
        pass
    plotly.offline.plot(fig_qps, filename="/Users/dporter/projects/solrcloud/chart/exp_html_out/_"+codename+"/_"+query+'_'+codename+'QPS.html')
    plotly.offline.plot(fig_lat, filename="/Users/dporter/projects/solrcloud/chart/exp_html_out/_"+codename+"/_"+query+'_'+codename+'TAIL.html')


def cdf_TAIL(query, codename):
    cdf_fig_title=""

    total_scale_file = '/Users/dporter/projects/solrcloud/chart/scaling_exp_csvs/total_'+query+'_'+codename+'.csv'
    df = pd.read_csv(total_scale_file)
    df = df.sort_values("parallel_requests")
    pr_unique = df.parallel_requests.unique()
    for chart in pr_unique:
        cdf_fig_title="SolrCloud LOAD="+str(chart)+" TAIL CDF (Round Robin)" if query == "direct" else "SolrCloud "+str(chart)+" TAIL CDF (SolrJ)"

        cdfLineList=[]
        df_pr = df.loc[df['parallel_requests'] == chart ]
        for index, row in df_pr.iterrows():
        #  there will be a line for each row in the cvs
        #     def __init__(self, gn, csize=0, load=0):
            gn=row["GROUP"]
            load=row["parallel_requests"]
            csize=row["clustersize"]
            cdfLineList.append(LineData(gn,csize,load))

        cdfFillLineList(cdfLineList, df_pr)


        cdf_data_list = [ x.setTailLine() for x in cdfLineList]


        fig_cdf = go.Figure(cdf_data_list)

        # latLineList = [LineData(gn) for gn in group_array]
        fig_cdf.update_layout(
            title=cdf_fig_title,
            xaxis_title="Latency (ms)",
            yaxis_title="CDF(x)",
            font=dict(
                family="Courier New, monospace",
                size=18,
                color="#7f7f7f"
                )
        )
        try:
            os.makedirs('/Users/dporter/projects/solrcloud/chart/exp_html_out/_'+codename)
        except FileExistsError:
            print("file exists\n\n\n")
         # directory already exists
            pass
        plotly.offline.plot(fig_cdf, filename="/Users/dporter/projects/solrcloud/chart/exp_html_out/_"+codename+"/_"+query+'_'+codename+'load='+str(chart)+'CDF.html')

if __name__ == "__main__":
    print(" ***** FINAL STEP: PLOTTING CHART IN BROWSER ******")
    if len(sys.argv) == 3:
        display_chart_scaling_errorbar(sys.argv[1],sys.argv[2])
        # P95_max_throughput(sys.argv[1],sys.argv[2])
        # QPS_max_throughput(sys.argv[1],sys.argv[2])

        # cdf_TAIL(sys.argv[1],sys.argv[2])

    else:
        print("arg length incorrect")

    print(" ***** FINAL STEP COMPLETE ******")

    sys.exit()
