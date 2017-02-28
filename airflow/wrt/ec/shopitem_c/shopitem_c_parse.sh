#!/usr/bin/env bash
source ~/.bashrc
pre_path='/home/wrt/sparkdata'
lastday=$1

hadoop fs -test -e /user/wrt/shopitem_c_tmp
if [ $? -eq 0 ] ;then
hadoop fs  -rmr /user/wrt/shopitem_c_tmp
else
echo 'Directory is not exist,you can run you spark job as you want!!!'
fi

spark-submit  --executor-memory 6G  --driver-memory 6G  --total-executor-cores 60 \
$pre_path/wrt/data_base_process/t_base_shopitem_c.py $lastday

