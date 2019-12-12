#########  EXP PARAMS

# constraint -> shards are 1, 2, or 4
SHARDS=( 1 )
QUERYS=("direct")
RF_MULTIPLE=( 2 )
LOAD=24
export MAX_LOAD=24
#########  PARAMS END

setLoadArray (){
	load_seq=($( seq 1 $MAX_LOAD ))
	if [[ ! " ${load_seq[@]} " =~ " $1 " ]]; then
	    # whatever you want to do when arr contains value
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
