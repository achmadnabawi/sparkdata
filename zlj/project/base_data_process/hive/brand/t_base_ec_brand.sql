SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

use wlbase_dev;

-- insert  OVERWRITE table t_base_ec_brand PARTITION(ds)
--
-- select brand_id ,brand_name,cast(from_unixtime(unix_timestamp()-86400,'yyyyMMdd') as STRING) ds
--
--  from t_base_ec_item_dev where  ds=cast(from_unixtime(unix_timestamp()-86400,'yyyyMMdd') as STRING)
--
-- GROUP by brand_id ,brand_name;



-- insert  OVERWRITE table t_base_ec_brand PARTITION(ds)
-- select brand_id ,brand_name,cast(from_unixtime(unix_timestamp()-86400,'yyyyMMdd') as STRING) ds
--  from t_base_ec_item_dev where  ds=cast(from_unixtime(unix_timestamp()-86400,'yyyyMMdd') as STRING)
-- and  LENGTH(brand_id)>1
-- GROUP by brand_id ,brand_name;


insert  OVERWRITE table t_base_ec_brand PARTITION(ds='20160124')
select brand_id ,brand_name,count(1)
 from t_base_ec_item_dev where  ds=20160124 and  brand_id  rlike   '^\\d+$'
and  LENGTH(brand_id)>1 and LENGTH(brand_name)>1
GROUP by brand_id ,brand_name;



select brand_id ,brand_name  from t_base_ec_item_dev where  ds=20160124 and  brand_id  rlike   '^\\d+$' limit 10 ;