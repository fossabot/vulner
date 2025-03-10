﻿<?xml version="1.0" encoding="UTF-8" ?>  
<!DOCTYPE mapper PUBLIC "-//ibatis.apache.org//DTD Mapper 3.0//EN"      
 "http://ibatis.apache.org/dtd/ibatis-3-mapper.dtd">
<mapper namespace="org.xsx.dao.EmpDao">

<select id="findAll" resultType="org.xsx.entity.Emp">
	select id,name,age,depNo,salary from emp
</select>

<!-- if 查询部门下所有的员工 -->
<select id="findByEmp" parameterType="org.xsx.entity.Condition" resultType="org.xsx.entity.Emp">
	select * from emp
	<if test="depNo != null">
		where depNo = #{depNo}
	</if>
</select>

<!-- choose 查询gongzi大于3300的 -->
<select id="findBySalary" parameterType="org.xsx.entity.Condition" resultType="org.xsx.entity.Emp">
	select * from emp 
	<choose>
		<when test="salary > 3000">
			where salary>#{salary} 
		</when>
		<otherwise>
			where salary>=3000 
		</otherwise>
	</choose>
</select>

<!-- where depNo salary -->
<select id="findByDepNoAndSalary" parameterType="org.xsx.entity.Condition" resultType="org.xsx.entity.Emp">
	select * from emp 
	<where>
		<if test="depNo!=null">
			and depNo=${depNo}
		</if>
		<if test="salary!=null">
			and salary>#{salary}
		</if>
	</where>
</select>

<!-- set update  emp -->
<update id="updateEmp" parameterType="org.xsx.entity.Emp">
	update emp 
	<set>
		<if test="name!=null">
			name=#{name},
		</if>
		<if test="depNo!=null">
			depNo=#{depNo} 
		</if>
	</set>
	where id=#{id}
</update>

<!-- trim替代where和set -->
<select id="findByDepNoAndSalary2" parameterType="org.xsx.entity.Condition" resultType="org.xsx.entity.Emp">
	select * from emp 
	<trim prefix="where" prefixOverrides="and">
		<if test="depNo!=null">
			and depNo=#{depNo} 		
		</if>
		<if test="salary != null">
			and salary>#{salary}
		</if>
	</trim>	
</select>
<update id="updateEmp2" parameterType="org.xsx.entity.Emp">
	update emp 
	<trim prefix="set" prefixOverrides=",">
		<if test="name!=null">
			name=${name} 
		</if>
		<if test="depNo!=null">
			depNo=${depNo} 
		</if>
	</trim>
	where id=#{id}
</update>

<!-- foreach -->
<select id="findByIds"  parameterType="org.xsx.entity.Condition" resultType="org.xsx.entity.Emp">
	select * from emp where id in 
	<foreach collection="ids" open="(" close=")" separator="," item="id">
		#{id}
	</foreach>
</select>
</mapper>