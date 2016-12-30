

drop table t_zlj_base_match;


create table t_zlj_base_match(
tel string,
id1 string ,
id2 string ,
id3 string ,
id4 string ,
id5 string ,
id6 string ,
id7 string
)
COMMENT '商务匹配表'
PARTITIONED BY  (ds STRING )
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\,'   LINES TERMINATED BY '\n'
stored as textfile ;

LOAD DATA   INPATH '/user/zlj/match/data.csv' OVERWRITE INTO TABLE t_zlj_base_match PARTITION (ds='rong360_test_1111') ;
LOAD DATA   INPATH '/user/zlj/match/rong360.csv' OVERWRITE INTO TABLE wlfinance.t_zlj_base_match PARTITION (ds='ygz_part') ;
LOAD DATA   INPATH '/user/zlj/match/data_2k.csv' OVERWRITE INTO TABLE wlfinance.t_zlj_base_match PARTITION (ds='data_2k') ;
LOAD DATA   INPATH '/user/zlj/match/7w.csv' OVERWRITE INTO TABLE wlfinance.t_zlj_base_match PARTITION (ds='7wid') ;
LOAD DATA   INPATH '/user/zlj/match/20161223.zhima.csv' OVERWRITE INTO TABLE wlfinance.t_zlj_base_match PARTITION (ds='zhima_1223') ;
-- index,userid,tel,zhima_score

SELECT
 uid,tel_index
from wlrefer.t_zlj_phone_rank_index t1 join wlfinance.t_zlj_base_match t2 on t1.tel_index  =t2.tel;
-- LOAD DATA   INPATH '/user/zlj/match/browse_group1.csv' OVERWRITE INTO TABLE wlfinance.t_zlj_base_match PARTITION (ds='rong360_browse_group1') ;

SELECT
COUNT(1)
 from  t_zlj_base_match t1 join wlbase_dev.t_base_yhhx_model_tel t2 on t1.ds='rong360_test_1111' and t1.tel=t2.uid ;


SELECT
   user_id  ,concat_ws(',', collect_set(concat_ws(':',tview,tcount)))
   from
(
SELECT
tel as user_id ,
id1 as tview,
id2 as view_s ,
id3 as tcount
from wlfinance.t_zlj_base_match where ds='rong360_browse_group1'
)t group by user_id ;



LOAD DATA  local   INPATH '/home/zlj/data/360/credit/train/browse_history_train.txt' OVERWRITE
  INTO TABLE wlfinance.t_zlj_tmp_csv PARTITION (ds='360_browse_history_train') ;

LOAD DATA  local   INPATH '/home/zlj/data/360/credit/train/bill_detail_train.txt' OVERWRITE
  INTO TABLE wlfinance.t_zlj_tmp_csv PARTITION (ds='bill_detail_train') ;

  LOAD DATA  local   INPATH '/home/zlj/data/360/credit/train/bank_detail_train.txt' OVERWRITE
  INTO TABLE wlfinance.t_zlj_tmp_csv PARTITION (ds='bank_detail_train') ;



LOAD DATA  local   INPATH '/home/zlj/data/360/credit/browse_history' OVERWRITE
  INTO TABLE wlfinance.t_zlj_tmp_csv PARTITION (ds='360_browse_history') ;

  LOAD DATA  local   INPATH '/home/zlj/data/360/credit/bill_detail' OVERWRITE
  INTO TABLE wlfinance.t_zlj_tmp_csv PARTITION (ds='360_bill_detail') ;

  LOAD DATA  local   INPATH '/home/zlj/data/360/credit/bank_detail' OVERWRITE
  INTO TABLE wlfinance.t_zlj_tmp_csv PARTITION (ds='360_bank_detail') ;

    LOAD DATA  local   INPATH '/home/zlj/data/360/credit/loan_time' OVERWRITE
  INTO TABLE wlfinance.t_zlj_tmp_csv PARTITION (ds='360_loan_time') ;


    LOAD DATA  local   INPATH '/home/zlj/data/360/credit/user_overdue_label' OVERWRITE
  INTO TABLE wlfinance.t_zlj_tmp_csv PARTITION (ds='360_user_overdue_label') ;



  LOAD DATA  local   INPATH '/home/zlj/data/360/credit/browse_history_dropdup' OVERWRITE
  INTO TABLE wlfinance.t_zlj_tmp_csv PARTITION (ds='360_browse_history_dropdup') ;

  LOAD DATA  local   INPATH '/home/zlj/data/360/credit/bill_detail_dropdup' OVERWRITE
  INTO TABLE wlfinance.t_zlj_tmp_csv PARTITION (ds='360_bill_detail_dropdup') ;

  LOAD DATA  local   INPATH '/home/zlj/data/360/credit/bank_detail_dropdup' OVERWRITE
  INTO TABLE wlfinance.t_zlj_tmp_csv PARTITION (ds='360_bank_detail_dropdup') ;