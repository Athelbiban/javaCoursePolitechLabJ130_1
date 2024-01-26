CREATE DATABASE IF NOT EXISTS store;
USE store;

DROP TABLE IF EXISTS position;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS orders;

CREATE TABLE products (
                          article CHAR(7) PRIMARY KEY NOT NULL,
                          product_name VARCHAR(50) NOT NULL,
                          color VARCHAR(20),
                          price INT,
                          stock_balance INT,
                          CONSTRAINT prod_check_price CHECK(price > 0),
                          CONSTRAINT stock_balance CHECK(stock_balance >= 0)
) COLLATE utf8mb4_unicode_ci;

CREATE TABLE orders (
                        order_id INT PRIMARY KEY AUTO_INCREMENT,
                        order_create DATE NOT NULL,
                        customer_name VARCHAR(100) NOT NULL,
                        customer_phone VARCHAR(50),
                        customer_email VARCHAR(50),
                        customer_address VARCHAR(200) NOT NULL,
                        order_status CHAR(1),
                        order_shipment DATE,
                        CONSTRAINT check_order_status CHECK(order_status IN ('P', 'S', 'C')),
                        CONSTRAINT check_order_shipment CHECK(
                                        order_status = 'S' AND order_shipment IS NOT NULL OR order_status != 'S' AND order_shipment IS NULL
                            ),
                        CONSTRAINT check_customer_phone CHECK(customer_phone != ''),
                        CONSTRAINT check_customer_email CHECK(customer_email != '')
) COLLATE utf8mb4_unicode_ci;

CREATE TABLE position (
                          order_id INT NOT NULL,
                          article CHAR(7) NOT NULL,
                          price INT NOT NULL,
                          amount INT NOT NULL,
                          CONSTRAINT FK_positionToOrder FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
                          CONSTRAINT FK_positionToProducts FOREIGN KEY (article) REFERENCES products(article) ON DELETE CASCADE,
                          CONSTRAINT PK_positionDoubleKey PRIMARY KEY (order_id, article),
                          CONSTRAINT pos_check_price CHECK(price > 0),
                          CONSTRAINT check_amount CHECK(amount > 0)
) COLLATE utf8mb4_unicode_ci;

INSERT INTO products VALUES
                         ('3251615', 'Стол кухонный', 'белый', 8000, 12),
                         ('3251616', 'Стол кухонный', NULL, 8000, 15),
                         ('3251617', 'Стул столовый "гусарский"', 'орех', 4000, 0),
                         ('3251619', 'Стул столовый с высокой спинкой', 'белый', 3500, 37),
                         ('3251620', 'Стул столовый с высокой спинкой', 'коричневый', 3500, 52);

INSERT INTO orders (order_create, customer_name, customer_phone, customer_email, customer_address, order_status, order_shipment) VALUES
                       ('2020-11-20', 'Сергей Иванов', '(981)123-45-67', NULL, 'ул. Веденеева, 20-1-41', 'S', '2020-11-29'),
                       ('2020-11-22', 'Алексей Комаров', '(921)001-22-33', NULL, 'пр. Пархоменко 51-2-123', 'S', '2020-11-29'),
                       ('2020-11-28', 'Ирина Викторова', '(911)009-88-77', NULL, 'Тихорецкий пр. 21-21', 'P', NULL),
                       ('2020-12-03', 'Павел Николаев', NULL, 'pasha_nick@mail.ru', 'ул. Хлопина 3-88', 'P', NULL),
                       ('2020-12-03', 'Антонина Васильева', '(931)777-66-55', 'antvas66@gmail.com', 'пр. Науки, 11-3-9', 'P', NULL),
                       ('2020-12-10', 'Ирина Викторова', '(911)009-88-77', NULL, 'Тихорецкий пр. 21-21', 'P', NULL);

INSERT INTO position VALUES
                         (1, '3251616', 7500, 1),
                         (2, '3251615', 7500, 1),
                         (3, '3251615', 8000, 1),
                         (3, '3251617', 4000, 4),
                         (4, '3251619', 3500, 2),
                         (5, '3251615', 8000, 1),
                         (5, '3251617', 4000, 4),
                         (6, '3251617', 4000, 2)

/* список заказов созданных в ноябре, декабре
SELECT *
FROM orders
WHERE order_create BETWEEN '2020-11-01' AND '2020-12-31';
*/

/* список заказов отгруженных в ноябре, декабре
SELECT *
FROM orders
WHERE order_shipment BETWEEN '2020-11-01' AND '2020-12-31';
*/

/* список клиентов
SELECT customer_name AS 'ФИО', customer_phone AS 'телефон', customer_email as 'электронная почта'
FROM orders;
*/

/* список позиций заказа с id=3
SELECT *
FROM position
WHERE order_id = 3;
*/

/* названия товаров, включённых в заказ id=3
SELECT product_name AS 'Названия товаров'
FROM position AS p
    JOIN products AS pr ON p.article = pr.article AND order_id = 3;
*/

/* *список отгруженных заказов, и количество позиций в каждом из них
SELECT orders.order_id AS 'Заказ',
    customer_name AS 'ФИО',
    amount AS 'Количество'
FROM position
    JOIN orders ON position.order_id = orders.order_id
    AND order_status = 'S'
    JOIN products USING(article);
*/

/* *доработанный запрос из предыдущего пункта, чтобы он вычислял общую стоимость
SELECT orders.order_id AS 'Заказ',
    customer_name AS 'ФИО',
    SUM(amount) AS 'Общее количество',
    SUM(position.price * amount) AS 'Общая стоимость'
FROM position
    JOIN orders ON position.order_id = orders.order_id
    AND order_status = 'S'
    JOIN products USING(article)
GROUP BY orders.order_id, customer_name
ORDER BY 'Заказ';
*/

/* запрос, фиксирующий отгрузку заказа с id=5. Должен менять статус, фиксировать дату, уменьшать остаток на складе.

   Данный запрос выдает ошибку т.к. некоторые позиции заказа отсутствуют на складе.
   При необходимости формирования заказа с отсутствующими позициями - раскомментировать указанную строку.

UPDATE orders o
    JOIN position p ON o.order_id = p.order_id
        AND p.order_id = 5
    JOIN products pr ON pr.article = p.article
--        AND p.amount <= pr.stock_balance   -- раскомментировать для проверки количества товара на складе перед изменением
SET order_status = 'S',
    order_shipment = CURDATE(),
    pr.stock_balance = pr.stock_balance - p.amount;
 */

