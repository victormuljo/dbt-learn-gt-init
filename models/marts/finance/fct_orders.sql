with payments as (
    select * from {{ref('stg_stripe__payments')}}
),

orders as (
    select * from {{ ref('stg_jaffle_shop__orders')}}
),

-- want to get orders, who ordered it, and what they paid for it total.
order_payments as (
    select 
        order_id, 
        sum(case when status = 'success' then amount end) as amount
    from payments
    group by 1 -- group by the 1st selected column (so group by order id)
),

-- want order_id, customer_id, and amount. Order id comes from orders, customer id comes from customers, and amount comes from payments.
final as (
    select
    orders.order_id,
    orders.customer_id,
    orders.order_date,
    coalesce (order_payments.amount, 0) as amount
    from orders
    left join order_payments using (order_id)
)

select * from final