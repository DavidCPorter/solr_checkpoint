#########  EXP PARAMS


setLoadArray (){
	case "$1" in
	1)
		local temp="$node20"
		echo "$temp"
		;;
	2)
		local temp="$node20 $node21"
		echo "$temp"
		;;
	3)
		local temp="$node20 $node21 $node22"
		echo "$temp"
		;;
	4)
		local temp="$node20 $node21 $node22 $node23"
		echo "$temp"
		;;
	5)
		local temp="$node20 $node21 $node22 $node23 $node16"
		echo "$temp"
		;;
	6)
		local temp="$node20 $node21 $node22 $node23 $node16 $node17"
		echo "$temp"
		;;
	7)
		local temp="$node20 $node21 $node22 $node23 $node16 $node17 $node18"
		echo "$temp"
		;;
	8)
		local temp="$node20 $node21 $node22 $node23 $node16 $node17 $node18 $node19"
		echo "$temp"
		;;
	esac
}

export -f setLoadArray

getLoadNum (){
	case "$1" in
	1)
		echo "1"
		;;
	2)
		echo "2"
		;;
	3)
		echo "3"
		;;
	4)
		echo "4"
		;;
	5)
		echo "5"
		;;
	6)
		echo "6"
		;;
	7)
		echo "7"
		;;
	8)
		echo "8"
		;;
	*)
		echo "CANNOT HAVE THIS VALUE FOR LOADS"
		;;

	esac
}


# constraint -> shards are 1, 2, or 4
SHARDS=( 1 2 4 )
QUERYS=("solrj")
RF_MULTIPLE=( 2 )


#########  PARAMS END
