## Airflow/Composer MetaDB cleansing

Free up MetaDB to 
- Increase DB performance
- Composer 2 has a [limitation](https://cloud.google.com/composer/docs/composer-2/cleanup-airflow-database) may cause series of issues

1. [airflow_db_cleanup.py](https://github.com/GoogleCloudPlatform/python-docs-samples/blob/HEAD/composer/workflows/airflow_db_cleanup.py)

2. Set a Retention Period for XCom data

2.1 To set the retention period for a specific DAG, modify the DAG code as follows:

```python
default_args = {
    'xcom_delete_old': timedelta(days=7),  # Specify retention period (e.g., 7 days)
}
```

2.2 To set the retention period globally, modify the airflow.cfg configuration file:

```
[scheduler]
xcom_delete_old = 7  # Specify retention period in days
```