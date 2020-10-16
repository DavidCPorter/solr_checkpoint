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

def getPy(py):

    """helper function that returns name of df column name for particular percentile (py) of latency"""
    p_col_name={
        50:"P50_latency(ms)",
        90:'P90_latency(ms)',
        95:'P95_latency(ms)',
        99:'P99_latency(ms)',
        "QPS":"QPS"
    }
    return p_col_name[py]

def getPtrunk(py):

    """helper function that returns name of df column name for particular percentile (py) of latency"""
    p_col_name={
        "P50_latency(ms)":"P50ms",
        'P90_latency(ms)':"P90ms",
        'P95_latency(ms)':"P95ms",
        'P99_latency(ms)':"P99ms"
    }
    return p_col_name[py]

def getPtitle(p_col_name):
    """ returns paper-ready y axis name """

    y_axis_title={
    "P50_latency(ms)":"50th Percentile Query Latency (ms)",
    "P90_latency(ms)":"90th Percentile Query Latency (ms)",
    "P95_latency(ms)":"95th Percentile Query Latency (ms)",
    "P99_latency(ms)":"99th Percentile Query Latency (ms)",
    "QPS":"QPS"
    }
    return y_axis_title[p_col_name]

def getXtitle(input):
    """ returns paper-ready y axis name """

    x_axis_title={
    "parallel_requests":"Concurrent Connections",
    "QPS":"QPS"
    }
    return x_axis_title[input]

class LineData():
    color_matrix={
        0:{11:plotly.colors.sequential.Blues[6],12:plotly.colors.sequential.Blues[6],21:plotly.colors.sequential.Blues[6],22:plotly.colors.sequential.Blues[6],"1x":plotly.colors.sequential.Reds[6],"2x":plotly.colors.sequential.Reds[6]},
        2:{11:plotly.colors.sequential.Blues[8],12:plotly.colors.sequential.Blues[7],21:plotly.colors.sequential.Blues[6],22:plotly.colors.sequential.Blues[5]},
        4:{11:plotly.colors.sequential.Reds[8],12:plotly.colors.sequential.Reds[7],21:plotly.colors.sequential.Reds[6],22:plotly.colors.sequential.Reds[5]},
        8:{11:plotly.colors.sequential.Greens[8],12:plotly.colors.sequential.Greens[7],21:plotly.colors.sequential.Greens[6],22:plotly.colors.sequential.Greens[5]}
    }
    symbol_matrix={
        0:{11:"circle",12:"circle-open",21:"square",22:"square-open","2x":"asterisk","1x":"asterisk"},
        2:{11:"circle",12:"circle-open",21:"square",22:"square-open"},
        4:{11:"circle",12:"circle-open",21:"square",22:"square-open"},
        8:{11:"circle",12:"circle-open",21:"square",22:"square-open"}
    }

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
        self.name=the_load+the_clustersize+'\n Shards='+str(gn)[0]+",\n Replicas="+str(gn)[1]

    def setLine(self):
        print(self)
         # clustersize = df.filter(like)
        south = [i - j for i, j in zip(self.input_y, self.south_error)]
        north = [i - j for i, j in zip(self.north_error, self.input_y)]
        max_y=[sum(x) for x in zip(north, self.input_y)]
        # if self.GROUPNAME == "1x" or self.GROUPNAME == "2x":
        #     line_color=dict(color=plotly.colors.sequential.Purples[8])
        #     marker_symbol=dict(symbol=0)
        # else:
        line_color=dict(color=LineData.color_matrix[self.csize][self.GROUPNAME])
        marker_symbol=dict(symbol=LineData.symbol_matrix[self.csize][self.GROUPNAME],size=11)

        data=go.Scatter(
                x=self.input_x,
                y=max_y,
                name=self.name,
                line=line_color,
                mode='lines+markers',
                marker=marker_symbol
                )
        return data

    def setLineErrorBars(self):
         # clustersize = df.filter(like)
        south = [i - j for i, j in zip(self.input_y, self.south_error)]
        north = [i - j for i, j in zip(self.north_error, self.input_y)]
        line_color=dict(color=LineData.color_matrix[self.csize][self.GROUPNAME])
        marker_symbol=dict(symbol=LineData.symbol_matrix[self.csize][self.GROUPNAME],size=11)
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
        # color_index
        # YlGn
        # Reds
        # Blues
        line_color=dict(color=LineData.color_matrix[self.csize][self.GROUPNAME])
        marker_symbol=dict(symbol=LineData.symbol_matrix[self.csize][self.GROUPNAME],size=11)
        data=go.Scatter(
                x=self.input_x,
                y=self.input_y,
                name=self.name,
                line=line_color,
                mode='lines+markers',
                marker=marker_symbol,
                )
        return data





# REMEMBER lineList is a List full of line objects with  with just the length of the x axis (clustersize.size) and groupname attached to each object
def fillClustersizeLine(lineList, df, col,axis_x):
    """ this function will fill out each CLUSTERSIZE && GROUPNAME linelist object with a list for each  x = axis_x   and   y = col """


    # pandas complains about the parens
    p_trunk=getPtrunk(col)
    print("p_trunk %s" % p_trunk)
    df.rename(columns={col:p_trunk}, inplace=True)
    print(df)
    for ld in lineList:
        gn = ld.getGn()
        ld.setName(gn)
        gn_line_df = df.loc[df['GROUP'] == gn]
        gn_csize_df = gn_line_df.loc[df["clustersize"] == ld.csize]
        #  gn_csize_df is a df for a single line... just need to populte ld now by iterating over the parallel_requests (x) and setting latency as y
        if axis_x == "QPS":
            x_set = gn_csize_df.QPS.unique()
        else:
            x_set = gn_csize_df.parallel_requests.unique()

        x_set.sort()
        for i in x_set:
            ld.setInputX(i)
            yinput = gn_csize_df.query(axis_x+" == %s" % str(i))
            ld.setInputY(yinput.iloc[0][p_trunk])

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


def Py_max_throughput(query, codename, py, axis_x):
    """Py_max_throughput(query, codename, py, axis_x) -> produces a html plot of y=P(py), x=axis_x for the experiments"""

    lat_fig_title=""
    lat_fig_title="SolrCloud Tail Latency (Round Robin)" if query == "direct" else "SolrCloud Tail Latency (SolrJ)"
    p_col_name=getPy(py)
    total_scale_file = project_home+'/chart/scaling_exp_csvs/total_'+query+'_'+codename+'.csv'
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

    if py == "QPS":
        fillClustersizeLineQPS(latLineList, df, p_col_name)
        # name dirs
        static_dir=project_home+'/chart/exp_html_out/figs/'+codename+"/figs/"+"y-QPS_x-load/"
        html_dir=project_home+'/chart/exp_html_out/'+codename+"/figs/"+"y-QPS_x-load/"
    else:
        fillClustersizeLine(latLineList, df, p_col_name,axis_x)
        static_dir=project_home+'/chart/exp_html_out/figs/'+codename+"/figs/"+"y-percentileTails_x-throughput/"
        html_dir=project_home+'/chart/exp_html_out/'+codename+"/figs/"+"y-percentileTails_x-throughput/"

    y_title=getPtitle(p_col_name)
    x_title=getXtitle(axis_x)

# this creates the line data the lib needs and packs into a list
    lat_data_list = [ x.setTailLine() for x in latLineList]
    fig_lat = go.Figure(lat_data_list)
    x_font=dict(
        size=20,
        color="#7f7f7f"
        )

    fig_lat.update_layout(
        paper_bgcolor='rgba(255,255,255,255)',
        plot_bgcolor='rgba(255,255,255,255)',
        # title=lat_fig_title,
        xaxis_title=x_title,
        showlegend=False,
        xaxis=dict(
            showgrid=True,
            gridcolor="LightGrey",
            title={"font":x_font},
            mirror=True,
            ticks='outside',
            showline=True,
            linewidth=2,
            linecolor="black"
            ),
        yaxis=dict(
            showgrid=True,
            gridcolor="LightGrey",
            title=y_title,
            mirror=True,
            ticks='outside',
            showline=True,
            linewidth=2,
            linecolor="black"
        )
    )
    try:
        os.makedirs(static_dir)
    except FileExistsError:
        print("file"+static_dir+ "exists\n\n\n")
     # directory already exists
    try:
        os.makedirs(html_dir)
    except FileExistsError:
        print("file"+html_dir+ "exists\n\n\n")

    plotly.offline.plot(fig_lat, filename=html_dir+query+"_P"+str(py)+"_"+axis_x+'.html')
    fig_lat.write_image(static_dir+query+"_P"+str(py)+"_"+axis_x+".png")



def display_chart_scaling_errorbar(query, codename):
    qps_fig_title=""
    qps_fig_title="SolrCloud Query Throughput (Round Robin)" if query == "direct" else "SolrCloud Query Throughput (SolrJ)"
    lat_fig_title=""
    lat_fig_title="SolrCloud Tail Latency (Round Robin)" if query == "direct" else "SolrCloud Tail Latency (SolrJ)"

    total_scale_file = project_home+'/chart/scaling_exp_csvs/total_'+query+'_'+codename+'.csv'

    ideal_path=project_home+'/chart/scaling_exp_csvs/ideal_line_direct.csv'
    if query == "solrj":
        ideal_path=project_home+'/chart/scaling_exp_csvs/ideal_line.csv'

    df = pd.read_csv(total_scale_file)
    ideal_df=pd.read_csv(ideal_path)
    df_QPS=df.append(ideal_df)
    df_QPS = df_QPS.sort_values("clustersize")
    df=df.sort_values("clustersize")
    group_array_QPS= df_QPS.GROUP.unique()
    # group_array_TAIL= df.GROUP.unique()
    #  there will be a line for each config aka Group contined in the lineList
    qpsLineList = [LineData(x) for x in group_array_QPS]
    # latLineList = [LineData(x) for x in group_array_TAIL]

    fillLineList(qpsLineList, df_QPS, "QPS")
    # fillLineList(latLineList, df, "P95_latency(ms)")


# this creates the line data the lib needs and packs into a list
    qps_data_list = [ x.setLine() for x in qpsLineList]
    # lat_data_list = [ x.setLine() for x in latLineList]

    fig_qps = go.Figure(qps_data_list)
    # fig_lat = go.Figure(lat_data_list)

    # fig_qps.show()
    # fig_lat.show()

    # fig_lat.update_layout(
    #     paper_bgcolor='rgba(255,255,255,255)',
    #     plot_bgcolor='rgba(255,255,255,255)',
    #     # title=lat_fig_title,
    #     xaxis_title=x_title,
    #     showlegend=False,
    #     xaxis=dict(
    #         showgrid=True,
    #         gridcolor="LightGrey",
    #         title={"font":x_font},
    #         mirror=True,
    #         ticks='outside',
    #         showline=True,
    #         linewidth=2,
    #         linecolor="black"
    #         ),
    #     yaxis=dict(
    #         showgrid=True,
    #         gridcolor="LightGrey",
    #         title="y_title",
    #         mirror=True,
    #         ticks='outside',
    #         showline=True,
    #         linewidth=2,
    #         linecolor="black"
    #     )
    # )
    x_font=dict(
        size=20,
        color="#7f7f7f"
        )
    axis_x="clustersize"
    y_title="QPS"
    fig_qps.update_layout(
        paper_bgcolor='rgba(255,255,255,255)',
        plot_bgcolor='rgba(255,255,255,255)',
        # title=lat_fig_title,
        xaxis_title="Cluster Size",
        showlegend=False,
        xaxis=dict(
            showgrid=True,
            gridcolor="LightGrey",
            title={"font":x_font},
            mirror=True,
            ticks='outside',
            showline=True,
            linewidth=2,
            linecolor="black"
            ),
        yaxis=dict(
            showgrid=True,
            gridcolor="LightGrey",
            title=y_title,
            mirror=True,
            ticks='outside',
            showline=True,
            linewidth=2,
            linecolor="black"
        )
    )


    # fig_qps.show()
    # fig_lat.show()
    static_dir=project_home+'/chart/exp_html_out/figs/'+codename+"/figs/scaling/"
    html_dir=project_home+'/chart/exp_html_out/'+codename+"/figs/scaling/"

    try:
        os.makedirs(static_dir)
    except FileExistsError:
        print("file"+static_dir+ "exists\n\n\n")
     # directory already exists
    try:
        os.makedirs(html_dir)
    except FileExistsError:
        print("file"+html_dir+ "exists\n\n\n")

    plotly.offline.plot(fig_qps, filename=html_dir+query+"_"+y_title+"_"+axis_x+'.html')
    fig_qps.write_image(static_dir+query+"_"+y_title+"_"+axis_x+".png")


def cdf_TAIL(query, codename):
    cdf_fig_title=""

    total_scale_file = project_home+'/chart/scaling_exp_csvs/total_'+query+'_'+codename+'.csv'
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
        yaxis_title="CDF(x) at LOAD = "+str(chart)+"connections"
        xaxis_title="Latency (ms)"

        x_font=dict(
            size=20,
            color="#7f7f7f"
            )

        fig_cdf.update_layout(
            paper_bgcolor='rgba(255,255,255,255)',
            plot_bgcolor='rgba(255,255,255,255)',
            # title=lat_fig_title,
            xaxis_title=xaxis_title,
            showlegend=False,
            xaxis=dict(
                showgrid=True,
                gridcolor="LightGrey",
                title={"font":x_font},
                mirror=True,
                ticks='outside',
                showline=True,
                linewidth=2,
                linecolor="black"
                ),
            yaxis=dict(
                showgrid=True,
                gridcolor="LightGrey",
                title=yaxis_title,
                mirror=True,
                ticks='outside',
                showline=True,
                linewidth=2,
                linecolor="black"
            )
        )

        static_dir=project_home+'/chart/exp_html_out/figs/'+codename+"/figs/cdfs/"
        html_dir=project_home+'/chart/exp_html_out/'+codename+"/figs/cdfs/"
        try:
            os.makedirs(static_dir)
        except FileExistsError:
            print("file"+static_dir+ "exists\n\n\n")
         # directory already exists
        try:
            os.makedirs(html_dir)
        except FileExistsError:
            print("file"+html_dir+ "exists\n\n\n")
        plotly.offline.plot(fig_cdf, filename=html_dir+query+"_"+str(chart)+'.html')
        fig_cdf.write_image(static_dir+query+"_"+str(chart)+".png")


if __name__ == "__main__":
    print(" ***** FINAL STEP: PLOTTING CHART IN BROWSER ******")
    project_home = sys.argv[3]
    if len(sys.argv) == 4:
        # creates the two figures with x axis as clustersize
        display_chart_scaling_errorbar(sys.argv[1],sys.argv[2])
        # creates xaxis outstanding requests and y P95 tail
        # Py is meant to signify PercentileX on the Y axis -
        Py_max_throughput(sys.argv[1],sys.argv[2],50,"QPS")
        Py_max_throughput(sys.argv[1],sys.argv[2],90,"QPS")
        Py_max_throughput(sys.argv[1],sys.argv[2],95,"QPS")
        Py_max_throughput(sys.argv[1],sys.argv[2],99,"QPS")
        Py_max_throughput(sys.argv[1],sys.argv[2],50,"parallel_requests")
        Py_max_throughput(sys.argv[1],sys.argv[2],90,"parallel_requests")
        Py_max_throughput(sys.argv[1],sys.argv[2],95,"parallel_requests")
        Py_max_throughput(sys.argv[1],sys.argv[2],99,"parallel_requests")
        Py_max_throughput(sys.argv[1],sys.argv[2],"QPS","parallel_requests")
        cdf_TAIL(sys.argv[1],sys.argv[2])

    else:
        print("arg length incorrect")

    print(" ***** FINAL STEP COMPLETE ******")

    sys.exit()
