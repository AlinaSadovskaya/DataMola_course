set autotrace on explain;
SELECT  *
    FROM scott.emp e, scott.dept d
    WHERE e.deptno = d.deptno
    AND d.deptno   = 10;

SELECT /*+ USE_MERGE(d e) */ *
    FROM scott.emp e, scott.dept d
    WHERE e.deptno = d.deptno;


SELECT  /* USE_HASH */*
    FROM scott.emp e, scott.dept d
    WHERE e.deptno = d.deptno;
    
SELECT ename, dname, job, loc 
    FROM scott.emp, scott.dept;
 
    
SELECT e.ename, e.deptno, e.job, d.dname
    FROM   scott.emp e 
    LEFT OUTER JOIN
    scott.dept d
    ON (e.deptno = d.deptno); 

SELECT e.ename, e.deptno, e.job, d.dname
    FROM   scott.emp e 
    RIGHT OUTER JOIN
    scott.dept d
    ON (e.deptno = d.deptno);
    
select e.ename, e.deptno, e.job, d.dname
    from   scott.emp e
    full outer join 
    scott.dept d
    on (e.deptno = d.deptno); 
    

select e.ename, e.deptno, e.job, d.dname
    from   scott.emp e
    full outer join 
    scott.dept d
    on (e.deptno = d.deptno); 
    
SELECT  *
    FROM scott.emp


select /* using in */ DNAME
    from scott.dept d
    where deptno IN (select deptno from scott.emp e); 
        
select /* inner join */ DNAME
    from scott.emp e, scott.dept d
    where e.deptno = d.deptno; 

select /* using exists */ DNAME 
    from SCOTT.DEPT d
    where EXISTS (select null from SCOTT.EMP e
            where e.deptno= d.deptno); 
            
select /* inner join with distinct */ distinct DNAME
    from SCOTT.DEPT d, SCOTT.EMP e
    where d.DEPTNO = e.DEPTNO; 
    
select /* ANY subquery */ DNAME
    from SCOTT.DEPT d
    where DEPTNO = ANY (select DEPTNO from SCOTT.EMP e); 
    
select /* NOT IN */ DNAME
    from SCOTT.DEPT d
    where DEPTNO NOT IN 
    (select DEPTNO from SCOTT.EMP e); 
    
select /* NOT EXISTS */ DNAME
    from SCOTT.DEPT d
    where NOT EXISTS (select null from SCOTT.EMP e
                       where e.DEPTNO = d.DEPTNO); 
                       
select /* MINUS */ DNAME
    from SCOTT.DEPT
    where DEPTNO in
        (select DEPTNO from SCOTT.DEPT minus
            select DEPTNO from SCOTT.EMP); 
            
select /* LEFT OUTER */ DNAME
    from SCOTT.DEPT d, SCOTT.EMP e
    where d.DEPTNO = e.DEPTNO(+)
    and e.DEPTNO is null; 
    