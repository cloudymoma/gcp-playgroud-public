# Firebase Instance ID & Labels 

表结构

[table schema](https://github.com/cloudymoma/raycom/blob/streaming/schemas/bq_SegmentMemberships.json)

[How to get `instance id` / `user_pseudo_id`](https://github.com/cloudymoma/gcp-playgroud-public/tree/master/BigQuery/get_user_pseudo_id)

根据标签圈选用户`id`

```sql
#standardSQL
SELECT instance_id
FROM `project.dataset.SegmentMemberships`
WHERE 2 = (SELECT COUNT(DISTINCT label) FROM UNNEST(segment_labels) label WHERE label IN ('label1','label4'))
```
