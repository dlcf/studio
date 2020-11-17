#!/usr/bin/env python3
# -*- encoding: utf-8 -*-
'''
@File : AreaCoding.py
@Contact : 15130091299@139.com
@Modify Time     @Author  @Version  @Desciption
---------------  -------  --------  -----------
2020/7/11 12:58      sam       1.0  None
'''
import os
import time

import pymysql
import datetime
import lxml.etree as etree
import requests

class AreaCoding():

    def __init__(self):

        ''' 访问配置 '''
        # 访问首页
        self.index_url = "http://www.stats.gov.cn/tjsj/tjbz/tjyqhdmhcxhfdm/2019/index.html"
        # 定义headers
        self.page_headers = {"User-Agent": "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:78.0) Gecko/20100101 Firefox/78.0",
                        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"}
        # 最大重连次数
        self.max_retry = 5
        # 超时时间
        self.max_timeout = 20

        self.await_seconds = 20
        # 页面编码
        self.page_encoding = "gbk"

        # 指定省-如: "河北省" 或者 None
        #self.specific_province = "河北省"
        self.specific_province = None

        self.tr_dict = {
            1: '//tr[@class="provincetr"]',
            2: '//tr[@class="citytr"]',
            3: '//tr[@class="countytr"]',
            4: '//tr[@class="towntr"]',
            5: '//tr[@class="villagetr"]'
        }

        '''  数据库配置 '''
        self.mysql_server_host = "192.168.0.73" # 服务端ip
        self.mysql_server_port = 3306              # 服务端端口 整型数字
        self.mysql_server_user = "clssops"            # 服务端用户,拥有建库建表权限
        self.mysql_server_pass = "cLssOps123"            # 服务端密码
        self.mysql_server_charset = "utf8"         # 客户端字符集,勿改

        self.db_name = "nbs"                       # 目标数据库
        self.table_name = "sys_area_coding"        # 目标表名

        self.is_bak = True                         # 是否备份
        self.bak_strf = "%Y%m%d_%H%M%S"            # 备份表的后缀,时期格式 被日志后缀引用

        self.is_replace = False                    # 是否删除原表,重新创建

        self.parent_dict = {"pid":0,"parent_code":"000000000000","parent_name":""}

        if not self.specific_province is None:
            self.table_name = "%s_%s" %(self.table_name,self.specific_province)

        # 建表语句,引用上面的目标数据库和目标表的定义
        self.create_table_sql_text = "create table if not exists `%s`.`%s` (" \
                                     " `id` int not null auto_increment," \
                                     " `area_code` varchar(12) not null," \
                                     " `area_name` varchar(100) not null," \
                                     " `area_level` int not null," \
                                     " `area_type` varchar(10) not null," \
                                     " `pid` int not null default 0," \
                                     " `parent_code` varchar(12) not null default '000000000000'," \
                                     " `parent_name` varchar(100) not null default ''," \
                                     " `curr_url` varchar(500) not null," \
                                     " `next_url` varchar(500) not null default ''," \
                                     " primary key(`id`)" \
                                     ") engine=InnoDB auto_increment=1 default charset=utf8mb4;" % (self.db_name, self.table_name,)

        # 数据库连接
        self.conn = pymysql.connect(host=self.mysql_server_host, port=self.mysql_server_port, user=self.mysql_server_user, password=self.mysql_server_pass, charset=self.mysql_server_charset)
        self.cur = self.conn.cursor()

        ''' 日志文件配置 '''
        self.file_nme = "%s_%s.log" %(os.path.splitext(__file__)[0],datetime.datetime.now().strftime(self.bak_strf))
        self.logfile = open(self.file_nme,mode="w+",buffering=1,encoding="utf-8")

    def __del__(self):
        if self.cur:
            self.cur.close()
        if self.conn:
            self.conn.close()
        if self.logfile:
            self.logfile.close()

    def logging(self,logText):
        self.logfile.write("%s: %s" % (datetime.datetime.now(), logText)+"\n")

    def init_db(self):
        # 判断是否存在目标数据库
        sqltext = "select schema_name from information_schema.schemata where schema_name = '%s';" %(self.db_name)
        self.cur.execute(sqltext)
        db_name = self.cur.fetchone()

        # 创建数据库
        if not db_name:
            sqltext = "create database if not exists %s;" %(self.db_name)
            self.cur.execute(sqltext)
            self.logging("创建数据库 `%s`" % (self.db_name))

        # 使用目标数据库
        sqltext = "use %s;" % (self.db_name)
        self.cur.execute(sqltext)

        # 判断是否存在目标表
        sqltext = "select table_name from information_schema.tables where table_schema = '%s' and table_name = '%s';" %(self.db_name,self.table_name)
        self.cur.execute(sqltext)
        table_name = self.cur.fetchone()

        # 根据是否存在表结果进行处理
        if table_name:
            # 判断是否备份
            if self.is_bak:
                bak_table_name = "%s_%s" %(self.table_name,datetime.datetime.now().strftime(self.bak_strf))
                sqltext = "rename table %s.%s to %s.%s;" % (self.db_name, self.table_name,self.db_name,bak_table_name)
                self.cur.execute(sqltext)
                self.logging("备份原表 `%s`.`%s` 为 `%s`.`%s`" %(self.db_name, self.table_name,self.db_name,bak_table_name))
            else:
                # 判断是否替换
                if self.is_replace:
                    sqltext = "drop table if exists %s.%s;" % (self.db_name, self.table_name)
                    self.cur.execute(sqltext)
                    self.logging("删除原表 `%s`.`%s`" % (self.db_name, self.table_name))
                else:
                    print("%s exist,is_replace is %s" %(self.table_name,str(self.is_replace)))
                    self.logging("原表 `%s`.`%s` 存在，参数[is_bak]为[False]，不允许备份原表，[is_replace]为[False]，不允许替换原表，退出程序(-1)" % (self.db_name, self.table_name))
                    exit(-1)

        sqltext = self.create_table_sql_text
        self.cur.execute(sqltext)
        self.logging("创建表 `%s`.`%s`" % (self.db_name, self.table_name))

    def insert_to_db(self, area):
        param = []
        lastid = 0
        try:
            sqltext = "INSERT INTO `{}`.`{}` values (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s);".format(self.db_name,self.table_name)
            param = (None, area.get("area_code"), area.get("area_name"), area.get("area_level"), area.get("area_type"),
                     area.get("pid"), area.get("parent_code"), area.get("parent_name"), area.get("curr_url"), area.get("next_url"))
            self.cur.execute(sqltext, param)
            lastid = self.cur.lastrowid
            self.conn.commit()
        except Exception as e:
            print(e)
            self.logging(e)
            self.conn.rollback()
        return lastid

    # 爬取网页
    def crawl_page(self, url):
        i = 0
        while i < self.max_retry:
            try:
                html = requests.get(url, headers=self.page_headers, timeout=self.max_timeout)
                html.encoding = self.page_encoding
                text = html.text
                return text
            except requests.exceptions.RequestException:
                i += 1
                print("[%s]请求超时" %(url))
                time.sleep(self.await_seconds)
                if i == self.max_retry:
                    self.logging("[%s]请求失败" %(url))

    def get_area_coding(self,curr_url="default",area_level=1,dict={}):

        if curr_url == "default":
            curr_url = self.index_url
        if not dict:
            dict = self.parent_dict
        child_dict = {}

        html = self.crawl_page(curr_url)

        tree = etree.HTML(html, parser=etree.HTMLParser(encoding=self.page_encoding))
        nodes = tree.xpath(self.tr_dict.get(area_level))

        if len(nodes) == 0:
            self.logging("[%s]没有级别为[%s]的数据" % (curr_url,area_level))
            child_area_level = area_level + 1
            self.get_area_coding(curr_url,child_area_level,dict)

        if area_level == 1:
            for node in nodes:
                area = {}
                items = node.xpath('./td')
                for item in items:
                    area_name = "".join(item.xpath('./a/text()'))
                    next_url = "".join(item.xpath('./a/@href'))
                    if not self.specific_province is None and area_name != self.specific_province or len(area_name) == 0:
                        continue
                    area_code = os.path.splitext(next_url)[0].ljust(12,"0")
                    dir_url=os.path.dirname(curr_url)
                    next_url = "%s/%s" %(dir_url,next_url)

                    area["area_code"] = area_code
                    area["area_name"] = area_name
                    area["area_level"] = area_level
                    area["area_type"] = ""
                    area["pid"] = dict.get("pid")
                    area["parent_code"] = dict.get("parent_code")
                    area["parent_name"] = dict.get("parent_name")
                    area["curr_url"] = curr_url
                    area["next_url"] = next_url

                    child_dict["pid"] = self.insert_to_db(area)
                    child_dict["parent_code"] = area_code
                    child_dict["parent_name"] = area_name

                    if len(next_url) > 0:
                        child_area_level = area_level + 1
                        self.get_area_coding(next_url, child_area_level, child_dict)

        elif area_level == 5:
            for node in nodes:
                area = {}
                next_url = "".join(node.xpath('./td[1]/a/@href'))
                area_code = "".join(node.xpath('./td[1]/text()'))
                area_type = "".join(node.xpath('./td[2]/text()'))
                area_name = "".join(node.xpath('./td[3]/text()'))
                if len(area_name) == 0 :
                    continue
                area["area_code"] = area_code
                area["area_name"] = area_name
                area["area_level"] = area_level
                area["area_type"] = area_type
                area["pid"] = dict.get("pid")
                area["parent_code"] = dict.get("parent_code")
                area["parent_name"] = dict.get("parent_name")
                area["curr_url"] = curr_url
                area["next_url"] = next_url

                self.insert_to_db(area)

        else:
            for node in nodes:
                area = {}
                next_url = "".join(node.xpath('./td[1]/a/@href'))
                if len(next_url) > 0:
                    dir_url = os.path.dirname(curr_url)
                    next_url = "%s/%s" % (dir_url, next_url)
                area_code = "".join(node.xpath('./td[1]/a/text()'))
                if len(area_code) == 0:
                    area_code = "".join(node.xpath('./td[1]/text()'))
                area_name = "".join(node.xpath('./td[2]/a/text()'))
                if len(area_name) == 0:
                    area_name = "".join(node.xpath('./td[2]/text()'))
                if area_name == "":
                    continue
                area["area_code"] = area_code
                area["area_name"] = area_name
                area["area_level"] = area_level
                area["area_type"] = ""
                area["pid"] = dict.get("pid")
                area["parent_code"] = dict.get("parent_code")
                area["parent_name"] = dict.get("parent_name")
                area["curr_url"] = curr_url
                area["next_url"] = next_url

                child_dict["pid"] = self.insert_to_db(area)
                child_dict["parent_code"] = area_code
                child_dict["parent_name"] = area_name

                if len(next_url) > 0:
                    child_area_level = area_level + 1
                    self.get_area_coding(next_url, child_area_level, child_dict)

if __name__ == '__main__':
    AreaCoding = AreaCoding()
    AreaCoding.init_db()
    AreaCoding.get_area_coding()

