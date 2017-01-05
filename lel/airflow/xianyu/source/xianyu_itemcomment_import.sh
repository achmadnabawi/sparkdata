#!/usr/bin

source ~/.bashrc
date
date  +%Y%m%d

lastday=$(date -d '1 days ago' +%Y%m%d)
thedaybeforelastday=$(date -d '2 days ago' +%Y%m%d)

table=wlbase_dev.t_base_ec_xianyu_item_comment

hive<<EOF
use wlbase_dev;
LOAD DATA  INPATH '/user/lel/temp/xianyu_comment_2016' OVERWRITE INTO TABLE $table PARTITION (ds='tmp');
insert OVERWRITE table $table PARTITION(ds = $lastday)
select
case when t1.itemid is null then t2.itemid else t1.itemid end,
case when t1.itemid is null then t2.commentId else t1.commentId end,
case when t1.itemid is null then t2.content else t1.content end,
case when t1.itemid is null then t2.reportTime else t1.reportTime end,
case when t1.itemid is null then t2.reporterName else t1.reporterName end,
case when t1.itemid is null then t2.reporterNick else t1.reporterNick end,
case when t1.itemid is null then t2.ts else t1.ts end
from
(select * from  $table where ds = 'tmp')t1
full outer JOIN
(select * from $table where ds = $thedaybeforelastday)t2
ON
t1.itemid = t2.itemid;
EOF