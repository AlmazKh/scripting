#!/bin/bash

unset -v dir_path
unset -v name

while getopts 'd:n:' opt; do
  case "$opt" in
    d) dir_path=$OPTARG ;;
    n) name=$OPTARG ;;
    ?)
      echo -e "Invalid command option"
      exit 1 ;;
  esac
done

if [ -z "$dir_path" ] || [ -z "$name" ]; then
        echo -e "Missing -d or -n arguments"
        exit 1
fi

shift "$(($OPTIND -1))"

arch_file="$(pwd)/$name.tar.gz"
tar -czvf $arch_file -C $dir_path .
if [ $? -ne 0 ]; then
     exit 1
fi
touch $name.sh
echo '#!/bin/bash' >> $name.sh
echo "tar_path=$arch_file" >> $name.sh

printf 'dir_path=$(pwd)
      while getopts ':o' opt; do
        case "$opt" in
          o) dir_path="$OPTARG" ;;
          ?)
            echo -e "Invalid command option"
            exit 1 ;;
        esac
      done
      shift "$(($OPTIND -1))"
      tar -xzvf $tar_path -C $dir_path' >> $name.sh

chmod +x $name.sh

