-- Ranking Functions:
use hr;
-- Find the top 3 highest paid employees in each department using RANK().
 select * from (
				select e.salary,d.department_name,
				rank() over(partition by d.department_name order by e.salary desc) as highest_paid
				from employees e 
                join departments d on d.department_id = e.department_id) as  emp
where emp.highest_paid < 4;




-- Assign a unique row number to each employee within their department using ROW_NUMBER() based on salary descending.
select e.salary, d.department_name, 
row_number() over (partition by d.department_name order by e.salary desc) as unique_row
from employees e join departments d on d.department_id = e.department_id ;






-- List departments where at least two employees share the same salary rank using DENSE_RANK().
SELECT DISTINCT department_id
FROM ( SELECT department_id, 
	   DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS drk
       FROM employees ) e
GROUP BY department_id, drk
HAVING COUNT(*) >= 2; 



WITH Ranked AS (
  SELECT department_id, DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rnk
  FROM Employees
),
Repeated AS (
  SELECT department_id FROM Ranked GROUP BY department_id, rnk
  HAVING COUNT(*) >= 2
)
SELECT DISTINCT department_id FROM Repeated;








           
-- Divide employees into 4 equal salary groups using NTILE(4) and display the group number along with employee details.
select employee_id , first_name , last_name, email , salary,
ntile(4) over (order by SALARY) as salary_group
from employees
order by  salary_group, salary;






-- Find the top 3 highest paid employees in each department using RANK().
select * from (select d.department_name ,
				rank() over(partition by d.department_name order by salary desc ) as rnk
				from employees e
				join departments d on d.department_id = e.department_id 
   ) emp_rank
where emp_rank.rnk <4;





-- Assign a unique row number to each employee within their department using ROW_NUMBER() based on salary descending.
select d.department_name , e.employee_id ,
row_number() over(partition by d.department_name order by salary desc) drk
from employees e join departments d on d.department_id = e.department_id ;




-- Assign a unique row number to each employee within their department using ROW_NUMBER() based on salary descending.

with cte as(
select *, row_number() over(partition by department_id order by salary desc) as rnk from employees
)
select * from cte order by department_id, rnk;







-- List departments where at least two employees share the same salary rank using DENSE_RANK().

select distinct department_id 
from(
		select department_id, 
		dense_rank() over(partition by department_id order by salary desc ) drk 
		from employees ) e
group by department_id, drk
having count(*) >=2;


-- same 


WITH Ranked AS (
  SELECT department_id, DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rnk
  FROM Employees
), RepeatedRanks AS (
  SELECT department_id, rnk FROM Ranked
  GROUP BY department_id, rnk
  HAVING COUNT(*) >= 2
)
SELECT DISTINCT department_id FROM RepeatedRanks;






-- Divide employees into 4 equal salary groups using NTILE(4) and display the group number along with employee details.
select employee_id , first_name , last_name, email , salary,
ntile(4) over (order by SALARY) as salary_group
from employees
order by  salary_group, salary;







-- Aggregate Window Functions
-- For each employee, show their salary and the average salary of their department using AVG() as a window function.
select employee_id, salary, 
avg(salary) over(partition by department_id ) as avg_sal
from employees ;







-- Show the running total of salaries for each department ordered by hire date using SUM() window function.
select salary, employee_id,
sum(salary) over(partition by department_id order by hire_date desc ) as total_sal
from employees;




-- Find the maximum salary in each department and compare it with each employee’s salary.
select employee_id, department_id, salary, 
max(salary) over(partition by department_id) as max_sal_in_dept,
case 
    when salary = max(salary) over (partition by department_id) then 'highest'
    else 'below max'
    end as salary_comparison
from employees ;





-- For each employee, show their salary and the average salary of their department using AVG() as a window function.
select employee_id , salary , 
avg(salary) over(partition by department_id) as avg_sal 
from employees;





-- Show the running total of salaries for each department ordered by hire date using SUM() window function.
select e.salary , e.department_id, e.employee_id , e.hire_date ,d.department_name ,
sum(salary) over(partition by d.department_name  order by hire_date desc) as sum_sal
from employees e join departments d on d.department_id = e.department_id;








-- Find the maximum salary in each department and compare it with each employee’s salary.
select d.department_name, e.employee_id , e.salary, 
max(e.salary) over(partition by d.department_name) as max_sal_dept,
case  
    when e.salary = max(e.salary) over(partition by d.department_name) then 'higher'
    else 'below max'
    end as sal_caparison
 from employees e join departments d on d.department_id = e.department_id;   
   




--  Value Functions
-- For each employee, show their salary and the salary of the employee hired just before them using LAG().
select employee_id , first_name , last_name , salary ,
lag(salary) over (order by hire_date) as prev_emp_salary
from employees 
order by hire_date;




-- Display each employee’s salary and the salary of the next hired employee in the same department using LEAD().    
select employee_id , first_name , last_name , department_id , salary, 
lead(salary) over (partition by department_id order by hire_date) as next_emp_salary
from employees order by department_id , hire_date ;    
    
    
    
-- List each department and show the first and last hired employee using FIRST_VALUE() and LAST_VALUE() functions.

select department_id , employee_id , first_name , last_name , hire_date , 
first_value(first_name) over(partition by department_id order by hire_date) as first_hired,
last_value(first_name) over(partition by department_id order by hire_date rows between unbounded preceding and unbounded following)as last_hired
from employees
order by department_id, hire_date;
    
  
  

    
-- For each employee, show their salary and the salary of the employee hired just before them using LAG().
select employee_id , first_name , last_name , salary ,
lag(salary) over (order by hire_date) as prev_emp_salary
from employees 
order by hire_date;






-- Display each employee’s salary and the salary of the next hired employee in the same department using LEAD().
select employee_id , first_name , last_name , department_id , salary, 
lead(salary) over (partition by department_id order by hire_date) as next_emp_salary
from employees order by department_id , hire_date ; 





-- List each department and show the first and last hired employee using FIRST_VALUE() and LAST_VALUE() functions.
select department_id , employee_id , first_name , last_name , hire_date , 
first_value(first_name) over(partition by department_id order by hire_date) as first_hired,
last_value(first_name) over(partition by department_id order by hire_date rows between unbounded preceding and unbounded following)as last_hired
from employees
order by department_id, hire_date;