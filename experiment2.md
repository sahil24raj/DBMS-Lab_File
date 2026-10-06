# Experiment 2: Convert ER Diagram into Relational Schema

## Aim
To convert the ER diagram of an Indian e-commerce platform into a relational schema and implement it using MySQL with appropriate constraints (Primary Key, Foreign Key, `NOT NULL`, `UNIQUE`, `ON DELETE CASCADE`, and `ON DELETE SET NULL`). Also, to insert sample data and demonstrate referential integrity violations.

## Relational Schema
1. **Customer** (`customer_id`, `customer_name`, `email`, `phone`)
2. **Address** (`address_id`, `customer_id`, `address_line`, `city`, `state`, `pincode`)
3. **Seller** (`seller_id`, `seller_name`, `email`, `phone`)
4. **Category** (`category_id`, `category_name`)
5. **Product** (`product_id`, `product_name`, `price`, `category_id`, `seller_id`)
6. **Product_Details** (`product_id`, `brand`, `description`, `stock`)
7. **Orders** (`order_id`, `customer_id`, `order_date`, `order_status`)
8. **OrderItem** (`order_id`, `product_id`, `quantity`, `price`)
9. **Payment** (`payment_id`, `order_id`, `payment_method`, `payment_status`, `amount`)
10. **Delivery** (`delivery_id`, `order_id`, `delivery_address_id`, `delivery_date`, `delivery_status`)

## SQL Commands

For the full setup, table creations, sample data insertion and constraint demonstration queries please refer to the `schema.sql` file in this directory. The SQL queries include the following tables:
- `Customer`
- `Address`
- `Seller`
- `Category`
- `Product`
- `Product_Details`
- `Orders`
- `OrderItem`
- `Payment`
- `Delivery`

## Constraint Demonstrations

The `schema.sql` file includes queries to test various constraints:

### A. Referential Integrity Violation
- **Invalid Customer**: Attempting to insert an order with an invalid customer ID fails parent key constraint.
- **Invalid Product**: Attempting to add an order item for a non-existent product ID fails parent key constraint.
- **Invalid Address**: Attempting to add an address for a non-existent customer ID fails parent key constraint.

### B. ON DELETE CASCADE
- **Customer Deletion**: Deleting a customer (e.g. `customer_id = 1`) automatically deletes all their addresses and orders, because the `Address` and `Orders` tables use `ON DELETE CASCADE` on their foreign keys referencing `Customer(customer_id)`.

### C. ON DELETE SET NULL
- **Seller / Category Deletion**: Deleting a seller or a category will set the `seller_id` or `category_id` to `NULL` in the `Product` table instead of deleting the products themselves.

### D. NOT NULL Constraint
- Attempting to insert `NULL` into a `NOT NULL` column (e.g., `customer_name`) fails.

### E. UNIQUE Constraint
- Attempting to insert duplicate values into columns defined as `UNIQUE` (e.g., `email` in `Customer`) fails.
