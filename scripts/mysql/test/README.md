## initdata

```yaml
initdata:
  name: 初始化数据。
  desc: 初始化用户表，商品表和关系表，一个用户同时对应100个商品，可修改语句增加比率，商品最少10000个，用户最少100，否则存储过程无错误校验。
    - initdata_ct: 建表语句。
    - initdata_cq: 存储过程，通过"call init_data(dd);"执行，使用事务提交，最后要执行"commit;"，dd为正整数参数，依次+1执行，可并发。
    - initdata_cp_delete: 过程脚本，仅做保留。
```

