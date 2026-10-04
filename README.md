# Major League Baseball (MLB) Historical Analytics (PostgreSQL)

## Project Overview
An end-to-end analytical study evaluating decades of historical MLB player demographics, franchise payroll trajectories, collegiate talent pipelines, and player physical evolution using advanced PostgreSQL querying techniques.

## Core Analytical Areas
* **Collegiate Sourcing:** Ranked historical player production across schools decade-over-decade using dense ranking and window partitions.
* **Payroll Trajectory:** Segmented franchise spending quintiles (`NTILE(5)`), running financial totals (`SUM() OVER`), and pinpointed the exact milestone years franchises crossed the $1 billion threshold.
* **Player Lifecycles:** Computed debut/retirement ages, career spans, and isolated players with single-franchise loyalty over 10+ seasons using self-joins and first/last value tracking.
* **Biometric Trends:** Analyzed batting stance distributions per franchise using conditional aggregation and tracked decade-over-decade deltas in player height and weight using `LAG()`.

## Advanced SQL Techniques Demonstrated
* **Window Functions:** `ROW_NUMBER()`, `DENSE_RANK()`, `NTILE()`, `LAG()`, running sums with framed partitions.
* **Common Table Expressions (CTEs):** Modularized multi-pass logic for milestone boundary detection.
* **Conditional Aggregation:** Dynamic pivot summaries using `CASE WHEN` to extract batting stance percentages.
* **Self-Joins & Set Logic:** Pinpointed shared birthdates and multi-decade tenure.

## SQL Implementation
All queries and data transformations are documented in [`mlb_advanced_sql_analysis.sql`](mlb_advanced_sql_analysis.sql).
