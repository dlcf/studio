
drop procedure if exists init_data;

delimiter //

create procedure init_data(in multiplier int)
begin
 declare multiplicand_u bigint default 1000000;
 declare multiplicand_i bigint default 10000000;
 declare initnum_u bigint default 0;
 declare initnum_i bigint default 0;
 
 declare num_max_u bigint default 10;
 declare num_max_i bigint default 200;
 declare num_max_r bigint default 100;
 
 declare num_u int default 0;
 declare num_i int default 0;
 declare num_r int default 0;
 declare num_rmax int default 0;
 declare num_u_i int default 100;

 declare num_max_c int default 10000;
 declare num_c int default 0;

 set initnum_u=multiplicand_u*multiplier;
 set initnum_i=multiplicand_i*multiplier;
 
 set num_max_r=num_max_i-num_u_i;

 while(num_i<num_max_i) do
   set num_i=num_i+1;
   insert into item_5
	 select initnum_i+num_i,concat('n_',initnum_i+num_i),concat('d_',initnum_i+num_i),concat('u_',initnum_i+num_i),0;
	 insert into item_15
	 select initnum_i+num_i,concat('n_',initnum_i+num_i),concat('d_',initnum_i+num_i),concat('u_',initnum_i+num_i),
	 concat('v01_',initnum_i+num_i),concat('v02_',initnum_i+num_i),concat('v03_',initnum_i+num_i),
	 concat('v04_',initnum_i+num_i),concat('v05_',initnum_i+num_i),concat('v06_',initnum_i+num_i),
	 concat('v07_',initnum_i+num_i),concat('v08_',initnum_i+num_i),concat('v09_',initnum_i+num_i),
	 concat('v10_',initnum_i+num_i),0;

 end while;
 while(num_u<num_max_u) do
   set num_u=num_u+1;
   insert into user_5
	 select initnum_u+num_u,concat('n_',initnum_u+num_u),concat('p_',initnum_u+num_u),concat('a_',initnum_u+num_u),0;
   
	 select floor(rand()*num_max_r) into num_r;
	 set num_rmax=num_r+num_u_i;
	 while(num_r<num_rmax) do
	   set num_r=num_r+1;
		 
		 insert into user_item_5
	   select initnum_u+num_u,initnum_i+num_r,concat('p_',initnum_i+num_r),now(),now(),0;
		 insert into user_item_6
	   select null,initnum_u+num_u,initnum_i+num_r,concat('p_',initnum_i+num_r),now(),now(),0;
		 insert into user_item_15
	   select initnum_u+num_u,initnum_i+num_r,concat('p_',initnum_i+num_r),now(),now(),
		 concat('v01_',initnum_i+num_i),concat('v02_',initnum_i+num_i),concat('v03_',initnum_i+num_i),
	   concat('v04_',initnum_i+num_i),concat('v05_',initnum_i+num_i),concat('v06_',initnum_i+num_i),
	   concat('v07_',initnum_i+num_i),concat('v08_',initnum_i+num_i),concat('v09_',initnum_i+num_i),
		 concat('v10_',initnum_i+num_i),0;
		 insert into user_item_16
	   select null,initnum_u+num_u,initnum_i+num_r,concat('p_',initnum_i+num_r),now(),now(),
		 concat('v01_',initnum_i+num_i),concat('v02_',initnum_i+num_i),concat('v03_',initnum_i+num_i),
	   concat('v04_',initnum_i+num_i),concat('v05_',initnum_i+num_i),concat('v06_',initnum_i+num_i),
	   concat('v07_',initnum_i+num_i),concat('v08_',initnum_i+num_i),concat('v09_',initnum_i+num_i),
		 concat('v10_',initnum_i+num_i),0;
	 end while;
 end while;

end //

delimiter ;

call init_data(1);
