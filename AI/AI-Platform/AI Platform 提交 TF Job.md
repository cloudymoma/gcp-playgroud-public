

# AI Platform 提交 TF Job

官方Demo 参考：[使用入门：使用 TensorFlow Estimator 进行训练和预测](https://cloud.google.com/ml-engine/docs/tensorflow/getting-started-training-prediction#cloud-shell_3)


# 基本要求



*   TF 1.14
*   启用 AI Platform（“Cloud Machine Learning Engine”）和 Compute Engine API
    *   [启动API](https://console.cloud.google.com/flows/enableapi?apiid=ml.googleapis.com,compute_component&_ga=2.141033073.25325032.1588734551-1966959884.1579600848)
*   Python 2.7


# 云端多节点测试
## 获取代码和训练数据(公开GCS Buket)


```
wget https://github.com/GoogleCloudPlatform/cloudml-samples/archive/master.zip
unzip master.zip
cd cloudml-samples-master/census/estimator

mkdir data
gsutil -m cp gs://cloud-samples-data/ai-platform/census/data/* data/
```



```
├── constants
│   ├── __init__.py
│   └── constants.py
├── data //训练数据集合
│   ├── adult.data.csv
│   ├── adult.test.csv
│   ├── census.test.csv
│   └── census.train.csv
├── dataflow_setup.py
├── preprocessing
│   ├── __init__.py 
│   ├── preprocess.py
│   ├── preprocessing_config.ini
│   └── run_preprocessing.py
├── requirements.txt
├── scripts
│   └── train-local.sh
├── setup.py //setuptool 打包成tar.gz
└── trainer //模型训练函数
    ├── __init__.py
    ├── featurizer.py
    ├── input.py
    ├── model.py
    └── task.py
```



## 上传代码、数据至GCS 对象存储


### 在Project 中新建训练GCS Bucket


```
gsutil mb -l us-central1  gs://ai_platform-bucket
gsutil ls
---------
gs://ai_platform-bucket/
```



### 上传代码


```
 gsutil cp -r trainer/  gs://ai_platform-bucket/

gsutil ls  gs://ai_platform-bucket/trainer
gs://ai_platform-bucket/trainer/__init__.py
gs://ai_platform-bucket/trainer/featurizer.py
gs://ai_platform-bucket/trainer/input.py
gs://ai_platform-bucket/trainer/model.py
gs://ai_platform-bucket/trainer/task.py
```



### 上传数据


```
gsutil cp -r data gs://ai_platform-bucket/data
gsutil cp ../test.json gs://ai_platform-bucket/data/test.json

gsutil ls  gs://ai_platform-bucket/data
------------
gs://ai_platform-bucket/data/adult.data.csv
gs://ai_platform-bucket/data/adult.test.csv
gs://ai_platform-bucket/data/census.test.csv
gs://ai_platform-bucket/data/census.train.csv
gs://ai_platform-bucket/data/test.json
```



## Job训练模型预测---- gcloud 


### 配置环境变量


```
JOB_NAME=census_dist_1
BUCKET_NAME=ai_platform-bucket
OUTPUT_PATH=gs://$BUCKET_NAME/$JOB_NAME
REGION=us-central1
TRAIN_DATA=gs://$BUCKET_NAME/data/adult.data.csv
EVAL_DATA=gs://$BUCKET_NAME/data/adult.test.csv
```



### 启动任务

启动STANDARD_1 集群进行训练, 打包本地python 为tar包上传至gcs


```
gcloud ai-platform jobs submit training $JOB_NAME \
    --job-dir $OUTPUT_PATH \
    --runtime-version 1.14 \
    --module-name trainer.task \
    --package-path trainer/ \
    --region $REGION \
    --scale-tier STANDARD_1 \
    -- \
    --train-files $TRAIN_DATA \
    --eval-files $EVAL_DATA \
    --train-steps 1000 \
    --verbosity DEBUG  \
    --eval-steps 100
```


代码目录打包结构：

[https://cloud.google.com/ml-engine/docs/packaging-trainer](https://cloud.google.com/ml-engine/docs/packaging-trainer)



*   --package-path 指定了应用目录的本地路径。gcloud 工具根据 --package-path 所指定目录的父级目录中的 setup.py 文件，从您的代码构建 .tar.gz 分发软件包。该工具随后将此 .tar.gz 文件上传到 Cloud Storage，并使用它运行您的训练作业。如果预期位置没有 setup.py 文件，gcloud 工具会创建一个简单的临时 setup.py，并只将 --package-path 指定的目录包含在它构建的 .tar.gz 文件中。
*   --module-name 指定了应用主模块的名称，该名称使用软件包的命名空间点表示法。这是用于启动应用的 Python 文件。例如，如果主模块是 .../my_application/trainer/task.py（请参阅推荐的项目结构），则该模块名称为 trainer.task


### 查看package


```
 gsutil ls  gs://ai_platform-bucket/census_dist_1/packages/378e668ca477277d1098e93bf8c14334fbaf377f5e5716f064a645a3de98049e

-----------
gs://ai_platform-bucket/census_dist_1/packages/378e668ca477277d1098e93bf8c14334fbaf377f5e5716f064a645a3de98049e/preprocessing-1.0.tar.gz
```



### 查看日志


```
gcloud ai-platform jobs stream-logs census_dist_1

-------
INFO	2020-05-09 13:41:11 +0800	service		Validating job requirements...
INFO	2020-05-09 13:41:11 +0800	service		Job creation request has been successfully validated.
INFO	2020-05-09 13:41:12 +0800	service		Waiting for job to be provisioned.
INFO	2020-05-09 13:41:12 +0800	service		Job census_dist_1 is queued.
INFO	2020-05-09 13:41:12 +0800	service		Waiting for training program to start.
INFO	2020-05-09 13:41:12 +0800	service		Job is preparing.

```



### 模型输出


```
gs://ai_platform-bucket/census_dist_1/export/census/1589003360/saved_model.pb	
```



## 模型部署


### 生成模型


```
gcloud ai-platform models create census --regions=us-central1

--------
Created ml engine model [projects/dataaisolutions/models/census]
```


链接二进制model，创建version v1


```
gcloud ai-platform versions create v1 \
    --model  census \
    --origin gs://ai_platform-bucket/census_dist_1/export/census/1589003360/ \
    --runtime-version 1.14
```


查看模型


```
gcloud ai-platform models list
------
NAME    DEFAULT_VERSION_NAME
census  v1
```



### 模型预测


```
cat ../test.json 
-----------
{"age": 25, "workclass": " Private", "education": " 11th", "education_num": 7, "marital_status": " Never-married", "occupation": " Machine-op-inspct", "relationship": " Own-child", "race": " Black", "gender": " Male", "capital_gain": 0, "capital_loss": 0, "hours_per_week": 40, "native_country": " United-States"}
```



```
gcloud ai-platform predict   --model census  --version v1     --json-instances ../test.json
-----------
ALL_CLASS_IDS  ALL_CLASSES   CLASS_IDS  CLASSES  LOGISTIC                LOGITS                PROBABILITIES
[0, 1]         [u'0', u'1']  [0]        [u'0']   [0.054197873920202255]  [-2.859391689300537]  [0.9458020925521851, 0.05419787019491196]
```


收入大于50K 概率为0.05419787019491196


## Job训练模型预测---- Console


### 本地package 打包 上传至GCS

在setup.py目录,生成packagedist/preprocessing-1.0.tar.gz


```
python setup.py sdist

ls dist/
preprocessing-1.0.tar.gz
```


上传至GCS


```
gsutil cp -r dist/preprocessing-1.0.tar.gz   gs://ai_platform-bucket/gcs_package/
```



### Console 提交训练任务



<p id="gdcalert1" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/AI-Platform0.png). Store image on your image server and adjust path/filename if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert2">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/AI-Platform0.png "image_tooltip")




<p id="gdcalert2" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/AI-Platform1.png). Store image on your image server and adjust path/filename if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert3">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/AI-Platform1.png "image_tooltip")



### 创建模型



<p id="gdcalert3" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/AI-Platform2.png). Store image on your image server and adjust path/filename if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert4">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/AI-Platform2.png "image_tooltip")




<p id="gdcalert4" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/AI-Platform3.png). Store image on your image server and adjust path/filename if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert5">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/AI-Platform3.png "image_tooltip")



### 预测模型



<p id="gdcalert5" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/AI-Platform4.png). Store image on your image server and adjust path/filename if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert6">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/AI-Platform4.png "image_tooltip")



```
{
 "predictions": [
   {
     "all_class_ids": [
       0,
       1
     ],
     "all_classes": [
       "0",
       "1"
     ],
     "probabilities": [
       0.8749655485153198,
       0.1250344216823578
     ],
     "classes": [
       "0"
     ],
     "logistic": [
       0.1250344216823578
     ],
     "class_ids": [
       0
     ],
     "logits": [
       -1.9455955028533936
     ]
   }
 ]
}
```

