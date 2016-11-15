-- rong360
Drop table t_zlj_tmp_rong360_1w_data ;
create table t_zlj_tmp_rong360_1w_data as
SELECT
-- t1.tel,
class ,
label,
gender,
age,
t2.*
from
(
SELECT  tel,'8000_c' as class , id1 as label,id3 as gender,id4 as age
   from
   wlfinance.t_zlj_base_match where ds='ygz_part'
   union all
    SELECT tel,'2000_c' as class,'' as label ,id1 as gender,id2 as age
   from
   wlfinance.t_zlj_base_match where ds='rong360_test_1111'
    )t1 join t_base_yhhx_model_tel t2 on  t1.tel=t2.tel  ;



create table t_zlj_tmp_rong360_1w_record as
SELECT tel, class,label ,gender,age,t4.*
from
(
SELECT tel ,tel_index,class,label ,gender,age from
(
SELECT  tel,'8000_c' as class , id1 as label,id3 as gender,id4 as age
   from
   wlfinance.t_zlj_base_match where ds='ygz_part'
   union all
    SELECT tel,'2000_c' as class,'' as label ,id1 as gender,id2 as age
   from
   wlfinance.t_zlj_base_match where ds='rong360_test_1111'
    )t1
    join
t_zlj_phone_rank_index t2 on t1.tel =t2.uid
group by tel_index,class,label ,gender,age,t1.tel
)t3 join
t_base_ec_record_dev_new_telindex_fix t4 on t3.tel_index=t4.tel_index ;


-- check
18782413399

