# encoding: utf-8
__author__ = 'zlj'
import sys

reload(sys)
sys.setdefaultencoding('utf8')


#-*- encoding:utf-8 -*-
'''
Created on Nov 30, 2014
@author: letian
'''

import networkx as nx
from Segmentation import Segmentation
import numpy as np

class TextRank4Keyword(object):

    def __init__(self, stop_words_file = None, delimiters = '?!;？！。；…\n'):
        '''
        `stop_words_file`：默认值为None，此时内部停止词表为空；可以设置为文件路径（字符串），将从停止词文件中提取停止词。
        `delimiters`：默认值是`'?!;？！。；…\n'`，用来将文本拆分为句子。

        self.words_no_filter：对sentences中每个句子分词而得到的两级列表。
        self.words_no_stop_words：去掉words_no_filter中的停止词而得到的两级列表。
        self.words_all_filters：保留words_no_stop_words中指定词性的单词而得到的两级列表。
        '''
        self.text = ''
        self.keywords = []

        self.seg = Segmentation(stop_words_file=stop_words_file, delimiters=delimiters)

        self.words_no_filter = None     # 2维列表
        self.words_no_stop_words = None
        self.words_all_filters = None

        self.word_index = {}
        self.index_word = {}
        self.graph = None

    def train(self, text, window = 2, lower = False, speech_tag_filter=True,
              vertex_source = 'all_filters',
              edge_source = 'no_stop_words'):
        '''
        `text`：文本内容，字符串。
        `window`：窗口大小，int，用来构造单词之间的边。默认值为2。
        `lower`：是否将文本转换为小写。默认为False。
        `speech_tag_filter`：若值为True，将调用内部的词性列表来过滤生成words_all_filters。
                        若值为False，words_all_filters与words_no_stop_words相同。
        `vertex_source`：选择使用words_no_filter, words_no_stop_words, words_all_filters中的哪一个来构造pagerank对应的图中的节点。
                        默认值为`'all_filters'`，可选值为`'no_filter', 'no_stop_words', 'all_filters'`。关键词也来自`vertex_source`。
        `edge_source`：选择使用words_no_filter, words_no_stop_words, words_all_filters中的哪一个来构造pagerank对应的图中的节点之间的边。
                        默认值为`'no_stop_words'`，可选值为`'no_filter', 'no_stop_words', 'all_filters'`。边的构造要结合`window`参数。
        '''

        self.text = text
        self.word_index = {}
        self.index_word = {}
        self.keywords = []
        self.graph = None

        (_, self.words_no_filter, self.words_no_stop_words, self.words_all_filters) = self.seg.segment(text=text,
                                                                                                     lower=lower,
                                                                                                     speech_tag_filter=speech_tag_filter)

        if vertex_source == 'no_filter':
            vertex_source = self.words_no_filter
        elif vertex_source == 'no_stop_words':
            vertex_source = self.words_no_stop_words
        else:
            vertex_source = self.words_all_filters

        if edge_source == 'no_filter':
            edge_source = self.words_no_filter
        elif vertex_source == 'all_filters':
            edge_source = self.words_all_filters
        else:
            edge_source = self.words_no_stop_words



        index = 0
        for words in vertex_source:
            for word in words:
                if not self.word_index.has_key(word):
                    self.word_index[word] = index
                    self.index_word[index] = word
                    index += 1

        words_number = index # 单词数量
        self.graph = np.zeros((words_number, words_number))

        for word_list in edge_source:
            for w1, w2 in self.combine(word_list, window):
                if not self.word_index.has_key(w1):
                    continue
                if not self.word_index.has_key(w2):
                    continue
                index1 = self.word_index[w1]
                index2 = self.word_index[w2]
                self.graph[index1][index2] = 1.0
                self.graph[index2][index1] = 1.0

#         for x in xrange(words_number):
#             row_sum = np.sum(self.graph[x, :])
#             if row_sum > 0:
#                 self.graph[x, :] = self.graph[x, :] / row_sum

        nx_graph = nx.from_numpy_matrix(self.graph)
        scores = nx.pagerank(nx_graph) # this is a dict
        sorted_scores = sorted(scores.items(), key = lambda item: item[1], reverse=True)
        for index, t in sorted_scores:
            self.keywords.append(self.index_word[index]+'-'+str(t))




    def combine(self, word_list, window = 2):
        '''
        构造在window下的单词组合，用来构造单词之间的边。使用了生成器。
        word_list: 由单词组成的列表。
        windows：窗口大小。
        '''
        window = int(window)
        if window < 2: window = 2
        for x in xrange(1, window):
            if x >= len(word_list):
                break
            word_list2 = word_list[x:]
            res = zip(word_list, word_list2)
            for r in res:
                yield r

    def get_keywords(self, num = 6, word_min_len = 1):
        '''
        获取最重要的num个长度大于等于word_min_len的关键词。
        返回关键词列表。
        '''
        result = []
        count = 0
        for word in self.keywords:
            if count >= num:
                break
            if len(word) >= word_min_len:
                result.append(word)
                count += 1
        return result

    def get_keyphrases(self, keywords_num = 12, min_occur_num = 2):
        '''
        获取关键短语。
        获取 keywords_num 个关键词构造在可能出现的短语，要求这个短语在原文本中至少出现的次数为min_occur_num。
        返回关键短语的列表。
        '''
        keywords_set = set(self.get_keywords(num=keywords_num, word_min_len = 1))

        keyphrases = set()
        one = []
        for sentence_list in self.words_no_filter:
            for word in sentence_list:
                # print '/'.join(one)
                # print word
                if word in keywords_set:
                    one.append(word)
                else:
                    if len(one)>1:
                        keyphrases.add(''.join(one))
                        one = []
                        continue
                    one = []

        return [phrase for phrase in keyphrases
                if self.text.count(phrase) >= min_occur_num]


if __name__ == '__main__':
    # text = codecs.open('../text/02.txt', 'r', 'utf-8').read()
    text='''
    满 19 包邮 双面 亚克力 硬质 卡通 送 金属 链 ic 公交卡 套 带 小 镜子   阿拉蕾
    秋冬季 日常 休闲 鞋子 工装 鞋 男鞋 圆头 休闲 皮鞋 男士 英伦 潮鞋 系带 真皮
    正品 新款 夏季 短袖 女装 桑蚕丝 圆领 真丝 上衣   中年 时尚 套头 T 恤 妈妈 装
    四川 特产 原味 冰粉 原料 手 搓 冰 粉籽   冰籽   凉粉 籽 送 石灰 送 量 勺 包 教会
    Benks  魅族 mx 4 钢化膜 防 指纹 MX 4 手机 玻璃 贴膜 魅族 4 高清 超薄 抗 蓝光
    包邮 性感 成人 情趣内衣 女式 真人制服 风骚 女 SM 吊带 丝袜 极度 套装 诱惑
    古西亚 秋冬款 加 绒 打底裤 女 外 穿 长裤 弹力 显 瘦 黑色 小脚裤 加厚 女 长裤
    有 鲤 原创 中国 风 秋 棉质 连 帽 外套 中式 盘扣 插袋 开衫 夹克 男
    歌瑞尔 秋冬 性感 聚拢 甜美 女士内衣 套装 【 文胸 + 内裤 】 引吭高歌 FB
    蜀信 高档 茉莉花 茶叶   特级 浓香型 四川 花茶   春茶 2015 新茶 250 g 包 邮
    15 秋装 新款 复古 宫廷 赫本 蕾丝 显 瘦 修身 吊带 小 黑裙 天鹅 公主 裙 连衣裙
    努西娜   2015 秋冬 平底 短靴 女 真皮 厚底 靴子 马丁靴平 跟 女靴 切尔西 靴
    官方 超 快 充 — 四川 移动 50 元 手机 话费 充值
    四川 移动 话费 充值 50 元   自动 充值   即时 到 账   手机 充值   快 充
    自动 充值   即时 到 帐   四川 移动 话费 快 充 50 元
    四川 移动 话费 100 元 快 充   手机 话费 充值   自动 充值   官网 充值 立即 到 账
    新款 简约 中国 风 修身 短袖 纯色 圆领 T 恤 夏季 男士 休闲 上 衣体 恤衫 男装
    有 鲤   复古 中国 风   宽松 棉麻 t恤 男 短袖   薄款 圆领 亚麻 男装   秋季 原创
    美宝莲   奇妙 净颜 净彻 深层 卸妆油   卸妆液   深层 清洁 毛孔   专柜 正品
    '''
    # text = "坏人"
    # tr4w = TextRank4Keyword(stop_words_file='../stopword.data')
    tr4w = TextRank4Keyword()
    tr4w.train(text=text, speech_tag_filter=True, lower=True, window=2)

    tmap={}
    ap=[(word.split('-')[0],float(word.split('-')[1]))for word in tr4w.get_keywords(15, word_min_len=2)]
    s=sum([i[1] for i in ap])
    print s
    for k,v in ap:
        print k,v,v/s
        tmap[k]=tmap.get(k,0.0)+v/s

    print '---'

    for phrase in tr4w.get_keyphrases(keywords_num=20, min_occur_num= 2):
        print phrase

    txt='''
        四川_0.312365141802	盘扣_0.286314008159	努西娜_0.17634053513	话费_0.167798146179	充值_0.156272316349	移动_0.151058281406	原创_0.144609359992	皮厚_0.128006486549	风秋_0.127364448715	净颜_0.124612531918	款加绒_0.12401539166	西亚_0.119278369986
        '''

    ts=[(unicode(i.split('_')[0]),float(i.split('_')[1]))for i in txt.split()]
    s=sum([i[1] for i in ts])
    print s
    for k,v in ts:
        print k,v,v/s
        tmap[k]=tmap.get(k,0.0)+v/s*1.5

    print
    dic=sorted(tmap.iteritems(),key=lambda t:t[1],reverse=True)
    for k,v in dic:
        print k,v,type(k)
