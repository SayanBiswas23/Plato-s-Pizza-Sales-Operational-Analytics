-- DDL Script: Table Creation for Plato's Pizza

CREATE TABLE IF NOT EXISTS public.pizza_types (
    pizza_type_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    ingredients TEXT
);

CREATE TABLE IF NOT EXISTS public.pizzas (
    pizza_id VARCHAR(50) PRIMARY KEY,
    pizza_type_id VARCHAR(50) REFERENCES public.pizza_types(pizza_type_id),
    size VARCHAR(5),
    price NUMERIC(5, 2)
);

CREATE TABLE IF NOT EXISTS public.orders (
    order_id INT PRIMARY KEY,
    date DATE,
    time TIME
);

CREATE TABLE IF NOT EXISTS public.order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT REFERENCES public.orders(order_id),
    pizza_id VARCHAR(50) REFERENCES public.pizzas(pizza_id),
    quantity INT
);
