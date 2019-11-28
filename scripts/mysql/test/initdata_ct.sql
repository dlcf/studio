drop table if exists user_item_5;
drop table if exists user_item_6;
drop table if exists user_item_15;
drop table if exists user_item_16;
drop table if exists user_5;
drop table if exists item_5;
drop table if exists item_15;


create table user_item_5(user_id BIGINT unsigned,item_id bigint unsigned,price varchar(50),create_date datetime,update_date datetime,isdelete tinyint(2));
create table user_item_6(id bigint unsigned AUTO_INCREMENT,user_id BIGINT unsigned,item_id bigint unsigned,price varchar(50),create_date datetime,update_date datetime,isdelete tinyint(2),PRIMARY KEY (`id`));
create table user_item_15(user_id BIGINT unsigned,item_id bigint unsigned,price varchar(50),create_date datetime,update_date datetime,
var_01 varchar(50),var_02 varchar(50),var_03 varchar(50),var_04 varchar(50),var_05 varchar(50),
var_06 varchar(50),var_07 varchar(50),var_08 varchar(50),var_09 varchar(50),var_10 varchar(50),
isdelete tinyint(2));
create table user_item_16(id bigint unsigned AUTO_INCREMENT,user_id BIGINT unsigned,item_id bigint unsigned,price varchar(50),create_date datetime,update_date datetime,
var_01 varchar(50),var_02 varchar(50),var_03 varchar(50),var_04 varchar(50),var_05 varchar(50),
var_06 varchar(50),var_07 varchar(50),var_08 varchar(50),var_09 varchar(50),var_10 varchar(50),
isdelete tinyint(2),PRIMARY KEY (`id`));

create table user_5(id BIGINT unsigned,name varchar(50),phone varchar(50),addr varchar(255),isdelete tinyint(2));
create table item_5(id BIGINT unsigned,name varchar(50),descb varchar(255),url varchar(100),isdelete tinyint(2));
create table item_15(id BIGINT unsigned,name varchar(50),descb varchar(255),url varchar(100),
var_01 varchar(50),var_02 varchar(50),var_03 varchar(50),var_04 varchar(50),var_05 varchar(50),
var_06 varchar(50),var_07 varchar(50),var_08 varchar(50),var_09 varchar(50),var_10 varchar(50),
isdelete tinyint(2));

-- 更新完数据添加
-- ALTER TABLE user_5 ADD PRIMARY KEY (`id`);

-- ALTER TABLE item_5 ADD PRIMARY KEY (id);
-- ALTER TABLE item_15 ADD PRIMARY KEY (`id`);

-- ALTER TABLE user_item_5 ADD PRIMARY KEY (user_id, item_id);
-- ALTER TABLE user_item_15 ADD PRIMARY KEY (user_id, item_id);
-- ALTER TABLE user_item_6 ADD UNIQUE INDEX user_item_6_useritemid(user_id, item_id);
-- ALTER TABLE user_item_16 ADD UNIQUE INDEX user_item_16_useritemid(user_id, item_id);



/*
create table user_item_5(user_id BIGINT unsigned,item_id bigint unsigned,price varchar(50),create_date datetime,update_date datetime,isdelete tinyint(2),PRIMARY KEY (`user_id`,`item_id`));
create table user_item_6(id bigint unsigned AUTO_INCREMENT,user_id BIGINT unsigned,item_id bigint unsigned,price varchar(50),create_date datetime,update_date datetime,isdelete tinyint(2),PRIMARY KEY (`id`),KEY `user_item_6_itemid` (`item_id`) USING BTREE,KEY `user_item_6_useritemid` (`user_id`,`item_id`) USING BTREE);
create table user_item_15(user_id BIGINT unsigned,item_id bigint unsigned,price varchar(50),create_date datetime,update_date datetime,
var_01 varchar(50),var_02 varchar(50),var_03 varchar(50),var_04 varchar(50),var_05 varchar(50),
var_06 varchar(50),var_07 varchar(50),var_08 varchar(50),var_09 varchar(50),var_10 varchar(50),
isdelete tinyint(2),PRIMARY KEY (`user_id`,`item_id`));
create table user_item_16(id bigint unsigned AUTO_INCREMENT,user_id BIGINT unsigned,item_id bigint unsigned,price varchar(50),create_date datetime,update_date datetime,
var_01 varchar(50),var_02 varchar(50),var_03 varchar(50),var_04 varchar(50),var_05 varchar(50),
var_06 varchar(50),var_07 varchar(50),var_08 varchar(50),var_09 varchar(50),var_10 varchar(50),
isdelete tinyint(2),PRIMARY KEY (`id`),KEY `user_item_6_itemid` (`item_id`) USING BTREE,KEY `user_item_6_useritemid` (`user_id`,`item_id`) USING BTREE);

create table user_5(id BIGINT unsigned,name varchar(50),phone varchar(50),addr varchar(255),isdelete tinyint(2),PRIMARY KEY (`id`));
create table item_5(id BIGINT unsigned,name varchar(50),descb varchar(255),url varchar(100),isdelete tinyint(2),PRIMARY KEY (`id`));
create table item_15(id BIGINT unsigned,name varchar(50),descb varchar(255),url varchar(100),
var_01 varchar(50),var_02 varchar(50),var_03 varchar(50),var_04 varchar(50),var_05 varchar(50),
var_06 varchar(50),var_07 varchar(50),var_08 varchar(50),var_09 varchar(50),var_10 varchar(50),
isdelete tinyint(2),PRIMARY KEY (`id`));
*/
