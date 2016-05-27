--
--
-- SELECT
-- sum(case when split(t1.tloc,'\t')[0]= split(t2.location,'\t')[0] then 1 else 0 end ) ,
-- sum(1)
-- from
-- t_base_user_info_s t1  join  t_base_ec_tb_userinfo  t2 on t1.ds=20160310 and t1.tb_id=t2.uid ;
--
--
-- 20160418
-- 776612  185953723
--
--
--
-- 20160310
-- 2447757 185953723
--
-- select count(1) from t_base_user_info_s where    ds=20160418;


--

create TABLE  t_base_user_info_s_tbuserinfo_t as
SELECT
tb_id,
case when LENGTH(tgender)<1 then "" else tgender end as tgender ,
case when tage is null  then -1 else tage end as tage ,
case when LENGTH(tname)<1 then "" else tname end as tname ,
case when LENGTH(alipay)<1 then "" else alipay end as alipay ,
case when LENGTH(buycnt)<1 then "" else buycnt end as buycnt ,
case when LENGTH(verify)<1 then "" else verify end as verify ,
case when LENGTH(regtime)<1 then "" else regtime end as regtime ,
case when LENGTH(nick)<1 then "" else nick end as nick
FROM
(
SELECT
tb_id,CAST ( cast(tgender as int) as String ) as tgender,tage,tname,
case when  t1.tloc is not null  then t1.tloc else t2.location end as  tloc,
case when alipay is not null then  alipay else "" end as alipay ,
case when buycnt is not null then  buycnt else "" end as buycnt ,
case when verify is not null then verify else "" end as verify ,
case when regtime is not null then  regtime else "" end as regtime ,
case when nick is not null then nick else "" end as nick
from t_base_user_info_s t1  left join  t_base_ec_tb_userinfo  t2
on t1.ds=20160310 and t1.tb_id=t2.uid

 )t ;


-- select concat_ws('&&',cast(tgender as string),cast(tage as string),tname,tloc,alipay,buycnt,verify,regtime) from t_base_user_info_s_tbuserinfo limit 10
-- select rt,COUNT(1) from (SELECT split(regtime,'.')[0] as rt from t_base_ec_tb_userinfo )t group by rt