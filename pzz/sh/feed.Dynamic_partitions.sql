source /home/hadoop/.bashrc
path=$1

/home/hadoop/hive/bin/hive<<EOF

SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.max.dynamic.partitions.pernode = 1000;
SET hive.exec.max.dynamic.partitions=2000;

set hive.exec.reducers.bytes.per.reducer=500000000;

use wlbase_dev;

LOAD DATA  INPATH '$path' OVERWRITE INTO TABLE t_base_ec_item_feed_dev_zlj PARTITION (ds='20000001');



-- ��̬����
-- INSERT overwrite TABLE t_base_ec_item_feed_dev PARTITION (ds )

INSERT INTO TABLE t_base_ec_item_feed_dev_zlj PARTITION (ds)
select
item_id,
item_title,
feed_id,
user_id,
content,
f_date ,
annoy  ,
ts ,
regexp_replace(f_date,'-','') ds
FROM t_base_ec_item_feed_dev_zlj where ds=20000001
;

EOF