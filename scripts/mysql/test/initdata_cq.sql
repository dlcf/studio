
drop procedure if exists init_data;

delimiter //

create procedure init_data(in multiplier int)
begin
 declare multiplicand_u bigint default 1000000;
 declare multiplicand_i bigint default 10000000;
 declare initnum_u bigint default 0;
 declare initnum_i bigint default 0;
 
 declare num_max_u bigint default 10000;
 declare num_max_i bigint default 100000;
 
 declare num_u int default 0;
 declare num_i int default 0;

 declare num_u_i int default 100;
 declare num_u_c int default 0;
 
 declare num_mod_i int default 0;

 declare num_floor_u int default 100;
 declare num_floor_i int default 100;

 declare num_max_c int default 10000;
 declare num_c int default 0;

 set initnum_u=multiplicand_u*multiplier;
 set initnum_i=multiplicand_i*multiplier;

 set num_floor_u=num_max_u/num_u_i;
 set num_floor_i=num_max_i/num_u_i;
 
 set num_c=0;
 start transaction;
 
 
 while(num_u<num_max_u) do
   set num_u=num_u+1;
	 
   insert into user_5
	 select initnum_u+num_u,concat('n_',initnum_u+num_u),concat('p_',initnum_u+num_u),concat('a_',initnum_u+num_u),0;
	 
	 set num_c=num_c+1;
   if num_c >= num_max_c then
     commit;
     set num_c=0;
     start transaction;
	 end if;
	 
 end while;
 
 while(num_i<num_max_i) do
   set num_i=num_i+1;
   
   insert into item_5
	 select initnum_i+num_i,concat('n_',initnum_i+num_i),concat('d_',initnum_i+num_i),concat('u_',initnum_i+num_i),0;
	 
	 set num_c=num_c+1;
   if num_c >= num_max_c then
     commit;
     set num_c=0;
     start transaction;
	 end if;
	 
	 insert into item_15
	 select initnum_i+num_i,concat('n_',initnum_i+num_i),concat('d_',initnum_i+num_i),concat('u_',initnum_i+num_i),
	 concat('v01_',initnum_i+num_i),concat('v02_',initnum_i+num_i),concat('v03_',initnum_i+num_i),
	 concat('v04_',initnum_i+num_i),concat('v05_',initnum_i+num_i),concat('v06_',initnum_i+num_i),
	 concat('v07_',initnum_i+num_i),concat('v08_',initnum_i+num_i),concat('v09_',initnum_i+num_i),
	 concat('v10_',initnum_i+num_i),0;
	 
	 set num_c=num_c+1;
   if num_c >= num_max_c then
     commit;
     set num_c=0;
     start transaction;
	 end if;
   
	 set num_u_c=0;
	 set num_mod_i=mod(num_i,num_u_i);
   if mod(num_i,num_floor_i) < num_u_i THEN
     while(num_u_c < num_floor_u) do
			 if (num_u_c > 0 || num_mod_i > 0) then
		     insert into user_item_5
	       select initnum_u+num_u_c*num_u_i+num_mod_i,initnum_i+num_i,concat('p_',initnum_i+num_i),now(),now(),0;
				 
				 set num_c=num_c+1;
				 if num_c >= num_max_c then
				   commit;
					 set num_c=0;
           start transaction;
				 end if;
				 
				 insert into user_item_6
	       select null,initnum_u+num_u_c*num_u_i+num_mod_i,initnum_i+num_i,concat('p_',initnum_i+num_i),now(),now(),0;
				 
				 set num_c=num_c+1;
				 if num_c >= num_max_c then
				   commit;
					 set num_c=0;
           start transaction;
				 end if;
				 
				 insert into user_item_15
	       select initnum_u+num_u_c*num_u_i+num_mod_i,initnum_i+num_i,concat('p_',initnum_i+num_i),now(),now(),
		     concat('v01_',initnum_i+num_i),concat('v02_',initnum_i+num_i),concat('v03_',initnum_i+num_i),
	       concat('v04_',initnum_i+num_i),concat('v05_',initnum_i+num_i),concat('v06_',initnum_i+num_i),
	       concat('v07_',initnum_i+num_i),concat('v08_',initnum_i+num_i),concat('v09_',initnum_i+num_i),
		     concat('v10_',initnum_i+num_i),0;
				 
				 set num_c=num_c+1;
				 if num_c >= num_max_c then
				   commit;
					 set num_c=0;
           start transaction;
				 end if;
				 
				 insert into user_item_16
	       select null,initnum_u+num_u_c*num_u_i+num_mod_i,initnum_i+num_i,concat('p_',initnum_i+num_i),now(),now(),
		     concat('v01_',initnum_i+num_i),concat('v02_',initnum_i+num_i),concat('v03_',initnum_i+num_i),
	       concat('v04_',initnum_i+num_i),concat('v05_',initnum_i+num_i),concat('v06_',initnum_i+num_i),
	       concat('v07_',initnum_i+num_i),concat('v08_',initnum_i+num_i),concat('v09_',initnum_i+num_i),
		     concat('v10_',initnum_i+num_i),0;
				 
				 set num_c=num_c+1;
				 if num_c >= num_max_c then
				   commit;
					 set num_c=0;
           start transaction;
				 end if;
				 
		   end if;
			 
			 set num_u_c=num_u_c+1;
			 
		 end while;
   end if;

 end while;

commit;
end //

delimiter ;

-- call init_data(1);

commit;
