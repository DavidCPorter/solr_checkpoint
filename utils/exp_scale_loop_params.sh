#########  EXP PARAMS

# constraint -> shards are 1, 2, or 4
DSTAT_SWITCH=off
copy_python_scripts="no"
SHARDS=( 1 2 )
QUERYS=( "solrj" "direct" )
RF_MULTIPLE=( 1 2 )
LOAD=36
load_start=3
export MAX_LOAD=36
instances=0
export SOLRJ_PORT_OVERRIDE=true
load_server_incrementer=3
EXTRA_ITERS=12




#########  PARAMS END

setLoadArray (){
	load_seq=($( seq 1 $MAX_LOAD ))
	if [[ ! " ${load_seq[@]} " =~ " $1 " ]]; then
			echo "NOT VALID LOAD PARAMETER"
			return
	else
		case "$1" in
		*)
			tmp=($(echo $ALL_LOAD))
			echo ${tmp[@]:0:$1}
			;;
		esac
	fi
}


export -f setLoadArray

# this function is stupid now but whatever

getLoadNum (){
	load_seq=($( seq 1 $MAX_LOAD ))
	if [[ ! " ${load_seq[@]} " =~ " $1 " ]]; then
	    # whatever you want to do when arr contains value
			echo "NOT VALID LOAD PARAMETER"
			return
	else
		case "$1" in
		*)
			echo "$1"
			;;
		esac

	fi

}

export -f getLoadNum
