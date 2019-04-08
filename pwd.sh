cpath=$(readlink -f $0)
name=$(basename ${cpath})

echo $cpath
echo $name
