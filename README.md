# E-Commerce Data Engineering Project

A production-grade data pipeline built on Snowflake, dbt, Apache Airflow, and AWS.

## Dataset
[Olist Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — 100k real orders across 9 tables.

## Architecture
Raw (S3) → Snowflake RAW → dbt Staging → dbt Marts → Dashboard

## Stack
- **Warehouse**: Snowflake
- **Transformation**: dbt Core
- **Orchestration**: Apache Airflow
- **Cloud**: AWS (S3, IAM, Secrets Manager)
- **IaC**: Terraform
- **CI/CD**: GitHub Actions

## Environments
| Branch | Environment | Snowflake DB |
|--------|-------------|--------------|
| feature/* | dev | DEV_<username> |
| develop | staging | STAGING |
| main | prod | PROD |

## Setup
See `docs/setup.md` for local environment setup.
