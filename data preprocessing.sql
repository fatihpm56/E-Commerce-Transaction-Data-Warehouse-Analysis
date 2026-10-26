select *
from ecommerce_transaction

-- Melihat data type
select 
	column_name,
    data_type
from information_schema.columns
where table_name='ecommerce_transaction'

-- Membuat table baru berisikan raw data pada staging
create table stg.stg_raw_ecommerce_transaction as 
select *
from public.ecommerce_transaction

select *
from stg.stg_raw_ecommerce_transaction
--where transaction_status = 'Successful'

-- Transform
-- Melakukan Transformasi data dan menyimpan data yang siap digunakan
create table stg.stg_ecommerce_transaction as
select
    transaction_id,
    date(transaction_time) transaction_time,
    user_id,
    user_name,
    lower(user_email) user_email,
    user_phone,
    lower(user_gender) user_gender,
    user_age,
    lower(user_city) user_city,
    store_id,
    store_name,
    store_phone,
    lower(store_city) store_city,
    product_id,
    product_name,
    lower(product_category) product_category,
    product_price,
    quantity,
    total_price
from stg.stg_raw_ecommerce_transaction

create table dwh.dim_user as
select distinct
	user_id,
    user_name,
    user_email,
    user_phone,
    user_gender,
    user_age,
    user_city
from stg.stg_ecommerce_transaction
 
create table dwh.dim_store as
select distinct
 	store_id,
    store_name,
    store_phone,
    store_city
from stg.stg_ecommerce_transaction
 
create table dwh.dim_product as
select distinct
	product_id,
    product_name,
    product_category,
    product_price
from stg.stg_ecommerce_transaction

create table dwh.fact_table as
select 
	transaction_id,
	transaction_time,
	user_id,
	store_id,
	product_id,
	quantity,
	total_price
from stg.stg_ecommerce_transaction

-- Menampilkan avg transaksi harian
select 
	transaction_time,
	round(avg(total_price)::numeric, 2) avg_transaction
from dwh.fact_table
group by 1
order by 1

-- Menampilkan tren harian total transaksi user
select 
	transaction_time,
	round(sum(total_price)::numeric, 2) total_sales
from dwh.fact_table
group by 1
order by 1

-- Menampilkan user yang melakukan transaksi paling banyak
select 
	user_id,
	count(*) total_transaction
from dwh.fact_table
group by 1
order by 2 desc