#1
SELECT *
FROM subscriptions
LIMIT 100;

#2
SELECT Min(subscription_start), Max(subscription_start),Min(subscription_end),Max(subscription_end)
FROM subscriptions; 

#3
WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
)
SELECT *
FROM months;

#4
WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
),
cross_join AS (
SELECT * 
FROM subscriptions
  CROSS JOIN months
)
SELECT *
FROM cross_join
LIMIT 100;

#5
WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
),
cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months),
status AS
(SELECT id, first_day as month,
CASE
  WHEN (segment IS 30)
 	 	AND (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    ) THEN 1
  ELSE 0
END as is_active_30,
CASE 
  WHEN (segment IS 87)
    AND (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    ) THEN 1
  ELSE 0
END as is_active_87
FROM cross_join)
SELECT *
FROM status
LIMIT 100;

#6
WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
),
cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months),
status AS
(SELECT id, first_day as month,
CASE
  WHEN (segment IS 30)
 	 	AND (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    ) THEN 1
  ELSE 0
END as is_active_30,
CASE 
  WHEN (segment IS 87)
    AND (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    ) THEN 1
  ELSE 0
END as is_active_87,
CASE 
  WHEN segment IS 30 AND subscription_end BETWEEN first_day AND last_day THEN 1
  ELSE 0
END as is_canceled_30,
CASE 
  WHEN segment IS 87 AND subscription_end BETWEEN first_day AND last_day THEN 1
  ELSE 0
END as is_canceled_87
FROM cross_join)
SELECT *
FROM status
LIMIT 100;

#7
WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
),
cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months),
status AS
(SELECT id, first_day as month,
CASE
  WHEN (segment IS 30)
 	 	AND (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    ) THEN 1
  ELSE 0
END as is_active_30,
CASE 
  WHEN (segment IS 87)
    AND (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    ) THEN 1
  ELSE 0
END as is_active_87,
CASE 
  WHEN segment IS 30 AND subscription_end BETWEEN first_day AND last_day THEN 1
  ELSE 0
END as is_canceled_30,
CASE 
  WHEN segment IS 87 AND subscription_end BETWEEN first_day AND last_day THEN 1
  ELSE 0
END as is_canceled_87
FROM cross_join),
status_aggregate AS
(SELECT
  month,
  SUM(is_active_30) as active_30,
  SUM(is_canceled_30) as canceled_30,
  SUM(is_active_87) as active_87,
  SUM(is_canceled_87) as canceled_87
FROM status
GROUP BY month)
SELECT *
FROM status_aggregate;

#8 
WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
),
cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months),
status AS
(SELECT id, first_day as month,
CASE
  WHEN (segment IS 30)
 	 	AND (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    ) THEN 1
  ELSE 0
END as is_active_30,
CASE 
  WHEN (segment IS 87)
    AND (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    ) THEN 1
  ELSE 0
END as is_active_87,
CASE 
  WHEN segment IS 30 AND subscription_end BETWEEN first_day AND last_day THEN 1
  ELSE 0
END as is_canceled_30,
CASE 
  WHEN segment IS 87 AND subscription_end BETWEEN first_day AND last_day THEN 1
  ELSE 0
END as is_canceled_87
FROM cross_join),
status_aggregate AS
(SELECT
  month,
  SUM(is_active_30) as active_30,
  SUM(is_canceled_30) as canceled_30,
  SUM(is_active_87) as active_87,
  SUM(is_canceled_87) as canceled_87
FROM status
GROUP BY month)
SELECT
  month,
  1.0 * canceled_30/active_30 AS churn_rate_30, 1.0 * canceled_87/active_87 AS churn_rate_87
FROM status_aggregate;