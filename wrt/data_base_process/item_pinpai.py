__author__ = 'wrt'
#coding:utf-8
from pyspark import SparkContext
import sys
from pyspark.sql import *
from pyspark.sql.types import *
import rapidjson as json

sc=SparkContext(appName="item_pinpai")
sqlContext = SQLContext(sc)
hiveContext = HiveContext(sc)


def valid_jsontxt(content):
    if type(content) == type(u""):
        return content.encode("utf-8")
    else :
        return content
def pinpai(line):
    ss = line.split('\001')
    return (valid_jsontxt(ss[1]),None)
def f(x,p_dict):
    n = 0
    if p_dict.has_key(valid_jsontxt(x[0])):
        return x[1] + "\t" + x[0]

hiveContext.sql('use wlbase_dev')
rdd = hiveContext.sql('select * from t_base_ec_brand')
rdd2 = sc.textFile('/user/wrt/pinpai.info')
p_dict = rdd2.map(lambda x: pinpai(x)).collectAsMap()
broadcastVar = sc.broadcast(p_dict)
place_dict = broadcastVar.value
rdd.map(lambda x:[x.brand_name, x.brand_id]).map(lambda x:f(x,place_dict))\
		.filter(lambda x:x!=None)\
			.saveAsTextFile(sys.argv[1])
sc.stop()