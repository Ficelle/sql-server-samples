# Pythonで作成した予測モデルをSQL Serverに展開し利用する

## コンテンツ

[このサンプルについて](#このサンプルについて)

[Step 1. 環境構築](#step-1-環境構築)

[Step 2. Pythonによる予測モデルの作成](#step-2-pythonによる予測モデルの作成)

[Step 3. SQL Serverへの予測モデルの展開と利用](#step-3-sql-serverへの予測モデルの展開と利用)

## このサンプルについて

このサンプルは[Build a predictive model using Python and SQL Server ML Services](https://microsoft.github.io/sql-ml-tutorials/python/rentalprediction/)を参考にしています。

このサンプルのシナリオはスキーレンタル事業における将来のレンタル数を予測します。
以下に示す過去のレンタル履歴のデータセットを元に予測モデルを作成します。

|Year|Month|Day|WeekDay|Holiday|Snow|RentalCount|
|:---|:---|:---|:---|:---|:---|:---|
|年|月|日|曜日|祝日フラグ|降雪フラグ|レンタル数|

**ソフトウェア要件:**

* [SQL Server 2017](https://www.microsoft.com/en-us/sql-server/sql-server-2017)
* [SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
* [Python Tools for Visual Studio](https://www.visualstudio.com/vs/python/) もしくはその他の Python IDE（Visual Studio Code、PyCharmなど）

**サンプルコード:**

* [rental_prediction.py](rental_prediction.py)
予測モデルを生成し、それを使用してレンタル数を予測するPythonスクリプトです。

* [rental_prediction.sql](rental_prediction.sql)
rent_prediction.pyの処理をSQL Server内に展開（トレーニング用のストアドプロシージャとテーブルの作成、モデルの保存、予測用のストアドプロシージャの作成）します。

* [setup.sql](setup.sql)
バックアップファイルをリストアします（ファイルパスをダウンロードしたパスに置き換えてください）。

**サンプルデータ:**

* [TutorialDB.bak](https://github.com/gho9o9/sql-server-samples/raw/master/samples/features/machine-learning-services/python/getting-started/rental-prediction/TutorialDB.bak)
サンプルコードを実行するために必要なレンタル履歴データです。

## Step 1. 環境構築

このサンプルを実行するための環境構築をします。

### 1-1. SQL Server 2017 のインストール

[SQL Server 2017 In-Database Python を使ってみた](https://blogs.msdn.microsoft.com/dataplatjp/2017/05/29/sqlserver2017-in-database-python/)を参考にSQL Server 2017 のDatabase Engine ServicesおよびMachine Learning Services（In-Database）をインストールします。

### 1-2. サンプルDBのリストア

サンプルDBの[バックアップファイル(TutorialDB.bak)](https://github.com/gho9o9/sql-server-samples/raw/master/samples/features/machine-learning-services/python/getting-started/rental-prediction/TutorialDB.bak)をダウンロードし、Setup.sqlの実行によりリストアします。
Setup.sqlはC:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backupにバックアップファイルをダウンロードしたものとしています。環境に応じて適宜パスを変更してください。

```SQL:Setup.sql
USE master;
GO
RESTORE DATABASE TutorialDB
   FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\TutorialDB.bak'
   WITH
   MOVE 'TutorialDB' TO 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\TutorialDB.mdf'
   ,MOVE 'TutorialDB_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\TutorialDB.ldf';
GO
```

リストアによって作成されたデータを確認します。

```SQL:T-SQL
USE TutorialDB;
SELECT * FROM [dbo].[rental_data];
```

### 1-3. 外部スクリプト実行機能の有効化

SQL Server 2017 内でPython（およびR）実行するにはsp_configureでexternal scripts enabledの設定変更が必要です。またexternal scripts enabledパラメータは設定変更の反映にSQL Server 2017の再起動が必要です。

* 1-3-1. 外部スクリプト実行機能の有効化

```SQL:T-SQL
EXEC sp_configure 'external scripts enabled', 1;
```

* 1-3-2. SQL Server 2017の再起動

```cmd:cmd
net stop "SQL Server Launchpad (MSSQLSERVER)"
net stop "SQL Server (MSSQLSERVER)"
net start "SQL Server (MSSQLSERVER)"
net start "SQL Server Launchpad (MSSQLSERVER)"

```
(*) 環境に応じてインスタンス名を変更してください。またSQL Server AgentサービスなどSQL Serverサービスに依存するサービスがある場合には明示的に再開してください。


## Step 2. Pythonによる予測モデルの作成

まずはPython IDE にてPythonによる予測モデルを作成します。

### 2-1. ライブラリのインポート

必要なライブラリをインポートします。

```Python:rental_prediction.py
import os
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error
from revoscalepy import RxSqlServerData
from revoscalepy import rx_import
```

#### インポートしたライブラリ

|ライブラリ|用途|
|:---|:---|
|[scikit-learn](http://scikit-learn.org/)|機械学習に利用|
|[RevoScalePy](https://docs.microsoft.com/en-us/sql/advanced-analytics/python/what-is-revoscalepy)|SQL Serverへのアクセスに利用(機械学習にも利用可能)|

### 2-2. データのロード

SQL Serverへ接続＆データを取得しpanasデータフレームにロードします。

```Python:rental_prediction.py
sql_server = os.getenv('PYTEST_SQL_SERVER', '.')
conn_str = 'Driver=SQL Server;Server=' + sql_server + ';Database=TutorialDB;Trusted_Connection=True;'
column_info = { 
        "Year" : { "type" : "integer" },
        "Month" : { "type" : "integer" }, 
        "Day" : { "type" : "integer" }, 
        "RentalCount" : { "type" : "integer" }, 
        "WeekDay" : { 
            "type" : "factor", 
            "levels" : ["1", "2", "3", "4", "5", "6", "7"]
        },
        "Holiday" : { 
            "type" : "factor", 
            "levels" : ["1", "0"]
        },
        "Snow" : { 
            "type" : "factor", 
            "levels" : ["1", "0"]
        }
    }

data_source = RxSqlServerData(sql_query="SELECT RentalCount, Year, Month, Day, WeekDay, Snow, Holiday FROM dbo.rental_data",
                              connection_string=conn_str, column_info=column_info)
    
# import data source and convert to pandas dataframe
df = pd.DataFrame(rx_import(data_source))
print("Data frame:", df)
# Get all the columns from the dataframe.
columns = df.columns.tolist()
# Filter the columns to remove ones we don't want.
columns = [c for c in columns if c not in ["Year"]]
```

(*)環境に応じて接続先のサーバ（変数：sql_server）を変更してください。

```Python:Results
Rows Processed: 453 
Data frame:      RentalCount  Year  Month  Day WeekDay Snow Holiday
0            445  2014      1   20       2    0       1
1             40  2014      2   13       5    0       0
2            456  2013      3   10       1    0       0
...
450           29  2015      3   24       3    1       0
451           50  2014      3   26       4    1       0
452          377  2015     12    6       1    1       0
[453 rows x 7 columns]
```

### 2-3. モデルトレーニング

このサンプルでは線形回帰アルゴリズムを使ってモデルトレーニングを行います。このモデルトレーニングとはデータセット内の変数の相関を最もよく説明する関数（モデル）を見つけることです。

```Python:rental_prediction.py
# Store the variable we'll be predicting on.
target = "RentalCount"
# Generate the training set.  Set random_state to be able to replicate results.
train = df.sample(frac=0.8, random_state=1)
# Select anything not in the training set and put it in the testing set.
test = df.loc[~df.index.isin(train.index)]
# Print the shapes of both sets.
print("Training set shape:", train.shape)
print("Testing set shape:", test.shape)
# Initialize the model class.
lin_model = LinearRegression()
# Fit the model to the training data.
lin_model.fit(train[columns], train[target])
```

```Python:Results
Training set shape: (362, 7)
Testing set shape: (91, 7)
```

### 2-4. 予測

テストデータを使って先ほど作成したモデルで予測をします。

```Python:rental_prediction.py
# Generate our predictions for the test set.
lin_predictions = lin_model.predict(test[columns])
print("Predictions:", end="")
print(['{:.15f}'.format(n) for n in lin_predictions])
# Compute error between our test predictions and the actual values.
lin_mse = mean_squared_error(lin_predictions, test[target])
print("Computed error:", lin_mse)
```

```Python:Results
Predictions:['40.000000000000007', '38.000000000000007', '240.000000000000000', '39.000000000000000', '514.000000000000000', '48.000000000000007', '297.000000000000000', '24.999999999999993',
...
'432.000000000000000', '24.999999999999993', '39.000000000000007', '28.000000000000004', '325.000000000000000', '46.000000000000014', '36.000000000000014', '50.000000000000007', '63.000000000000007']
Computed error: 6.85182043392e-29
```

## Step 3. SQL Serverへの予測モデルの展開と利用

SQL Server Machine Learning Servicesを使用すると、SQL Serverのコンテキストで予測モデルのトレーニングおよびテストが実行できます。 埋め込みPythonスクリプトを含むT-SQLプログラムを作成し、これをSQL Serverデータベースエンジンが処理します。これらPythonコードはSQL Serverで実行されるため、データベースに格納されたデータとのやりとりが簡素化されます。

### 3-1. テーブル定義

モデルおよび予測結果を格納するためのテーブルを定義します。

```SQL:rental_prediction.sql
-- 3-1. テーブル定義
--Setup model table
DROP TABLE IF EXISTS rental_py_models;
GO
CREATE TABLE rental_py_models (
                model_name VARCHAR(30) NOT NULL DEFAULT('default model') PRIMARY KEY,
                model VARBINARY(MAX) NOT NULL
);
GO

--Create a table to store the predictions in
DROP TABLE IF EXISTS [dbo].[py_rental_predictions];
GO
CREATE TABLE [dbo].[py_rental_predictions](
	[RentalCount_Predicted] [int] NULL,
	[RentalCount_Actual] [int] NULL,
	[Month] [int] NULL,
	[Day] [int] NULL,
	[WeekDay] [int] NULL,
	[Snow] [int] NULL,
	[Holiday] [int] NULL,
	[Year] [int] NULL
) ON [PRIMARY]
GO
```

### 3-2. モデル作成ストアドプロシージャ定義

Pythonで作成したモデル作成コードを流用し、SQL Server内に実装します。
このストアドプロシージャはSQL Server内のデータを利用し線形回帰モデル作成します。

```SQL:rental_prediction.sql
-- 3-2. モデル作成ストアドプロシージャ定義
-- Stored procedure that trains and generates an R model using the rental_data and a decision tree algorithm
DROP PROCEDURE IF EXISTS generate_rental_py_model;
go
CREATE PROCEDURE generate_rental_py_model (@trained_model varbinary(max) OUTPUT)
AS
BEGIN
    EXECUTE sp_execute_external_script
      @language = N'Python'
    , @script = N'

df = rental_train_data

# Get all the columns from the dataframe.
columns = df.columns.tolist()

# Store the variable well be predicting on.
target = "RentalCount"

from sklearn.linear_model import LinearRegression

# Initialize the model class.
lin_model = LinearRegression()

# Fit the model to the training data.
lin_model.fit(df[columns], df[target])

import pickle
#Before saving the model to the DB table, we need to convert it to a binary object
trained_model = pickle.dumps(lin_model)
'
    , @input_data_1 = N'select "RentalCount", "Year", "Month", "Day", "WeekDay", "Snow", "Holiday" from dbo.rental_data where Year < 2015'
    , @input_data_1_name = N'rental_train_data'
    , @params = N'@trained_model varbinary(max) OUTPUT'
    , @trained_model = @trained_model OUTPUT;
END;
GO
```

### 3-3. モデル作成実行

モデル作成ストアドプロシージャを実行し作成したモデルをSQL Server内にVARBINARYデータとして登録します。

```SQL:rental_prediction.sql
-- 3-3. モデル作成実行
TRUNCATE TABLE rental_py_models;

DECLARE @model VARBINARY(MAX);
EXEC generate_rental_py_model @model OUTPUT;

INSERT INTO rental_py_models (model_name, model) VALUES('linear_model', @model);

SELECT * FROM rental_py_models;
```

### 3-4. 予測ストアドプロシージャ定義

SQL Server内に登録されたテストデータをSQL Server内に登録されたモデルで予測をします。

```SQL:rental_prediction.sql
-- 3-4. 予測ストアドプロシージャ定義
DROP PROCEDURE IF EXISTS py_predict_rentalcount;
GO
CREATE PROCEDURE py_predict_rentalcount (@model varchar(100))
AS
BEGIN
	DECLARE @py_model varbinary(max) = (select model from rental_py_models where model_name = @model);

	EXEC sp_execute_external_script 
					@language = N'Python'
				  , @script = N'

import pickle
rental_model = pickle.loads(py_model)

df = rental_score_data

# Get all the columns from the dataframe.
columns = df.columns.tolist()

# Store the variable well be predicting on.
target = "RentalCount"

# Generate our predictions for the test set.
lin_predictions = rental_model.predict(df[columns])

# Import the scikit-learn function to compute error.
from sklearn.metrics import mean_squared_error
# Compute error between our test predictions and the actual values.
lin_mse = mean_squared_error(lin_predictions, df[target])

import pandas as pd
predictions_df = pd.DataFrame(lin_predictions)  
OutputDataSet = pd.concat([predictions_df, df["RentalCount"], df["Month"], df["Day"], df["WeekDay"], df["Snow"], df["Holiday"], df["Year"]], axis=1)
'
	, @input_data_1 = N'Select "RentalCount", "Year" ,"Month", "Day", "WeekDay", "Snow", "Holiday"  from rental_data where Year = 2015'
	, @input_data_1_name = N'rental_score_data'
	, @params = N'@py_model varbinary(max)'
	, @py_model = @py_model
	with result sets (("RentalCount_Predicted" float, "RentalCount" float, "Month" float,"Day" float,"WeekDay" float,"Snow" float,"Holiday" float, "Year" float));
END;
GO
```


### 3-5. 予測実行

予測ストアドプロシージャを実行し予測を行い、結果をSQL Server内に登録します。

```SQL:rental_prediction.sql
--3-5. 予測実行
TRUNCATE TABLE py_rental_predictions;
--Insert the results of the predictions for test set into a table
INSERT INTO py_rental_predictions
EXEC py_predict_rentalcount 'linear_model';
-- Select contents of the table
SELECT * FROM py_rental_predictions;
```

SQL Server内に登録した結果をPowerBIなどで可視化します。

<!--
# Pythonで作成した予測モデルをSQL Serverに展開し利用する

### コンテンツ


[このサンプルについて](#このサンプルについて)

[はじめに](#はじめに)

[サンプルの実行](#サンプルの実行)

[サンプル詳細](#サンプル詳細)



## このサンプルについて

このサンプルはPythonで予測モデルを作成し、それをSQL Server 2017に展開して利用する例を示します。

<!-- Delete the ones that don't apply -->
- **対象:** SQL Server 2017 CTP2.0（もしくはそれ以降）
- **機能:** SQL Server Machine Learning Services 
- **ワークロード:** SQL Server Machine Learning Services
- **プログラム言語:** Python, TSQL
- **著者:** Nellie Gustafsson
- **更新履歴:** gho9o9（日本語化、説明補足、参考情報のリンク追加）

## はじめに

このサンプルを実行するためには以下の事前準備が必要です：
1. [このバックアップファイルをダウンロードし](https://github.com/gho9o9/sql-server-samples/raw/master/samples/features/machine-learning-services/python/getting-started/rental-prediction/TutorialDB.bak) Setup.sqlを利用しリストアを実行してください. 

**ソフトウェア要件:**
1. [SQL Server 2017 CTP2.0](https://www.microsoft.com/en-us/sql-server/sql-server-2017) (もしくはそれ以降) と Machine Learning Services (Python) がインストールされていること
   *  参考：[SQL Server 2017 In-Database Python を使ってみた](https://blogs.msdn.microsoft.com/dataplatjp/2017/05/29/sqlserver2017-in-database-python/)
2. [SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)がインストールされていること
3. [Python Tools for Visual Studio](https://www.visualstudio.com/vs/python/) もしくはその他の Python IDE がインストールされていること

## サンプルの実行
1. SQL Server Management Studio から SQL Server 2017 のデータベースに接続し、Setup.sql の実行によってダウンロードしてきたバックアップファイルをリストアします。
2. SQL Server 2017 内でPython実行を有効化するためのインスタンス設定を行い、SQL Server 2017を再起動します。
   *  EXEC sp_configure 'external scripts enabled', 1;
   *  RECONFIGURE WITH OVERRIDE
   *  SQL Server 2017を再起動
3. SQL Server Management Studio から rental_prediction.sql を開きます。
このスクリプトは以下を実行しています。
   *  必要なテーブルの作成
   *  モデル訓練のためのストアドプロシージャ作成
   *  訓練モデルによる予測実行のためのストアドプロシージャ作成
   *  予測結果をデータベース内のテーブルに保存
4. 同じ処理をPythonスクリプトで実行することもできます。このスクリプトはSQL Serverに接続し、RevoScalePy Rx 関数によってデータを取得しています。Pythonスクリプトで実行する場合は適切なPython環境パスを指定することに注意してください。
   *  "C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\PYTHON_SERVICES" Machine Learning Services（データベース内）でインストールしている場合
   *  "C:\Program Files\Microsoft SQL Server\140\PYTHON_SERVER" Machine Learning Services（スタンドアロン）でインストールしている場合

## サンプル詳細

予測モデリングによってアプリケーションは新しいデータに対する結果を予測することができます。
予測をアプリケーションに組み込むには「モデル訓練」と「モデル操作」の大きく2つの段階があります。
このサンプルで作成する予測モデリングは以下のデータセットからレンタル数を予測します。

このサンプルでは、Pythonで予測モデルを作成し、それをSQL Server Machine Learning Servicesを使用してSQL Serverに展開する方法を示します。

### [rental_prediction.py](rental_prediction.py)
予測モデルを生成し、それを使用してレンタル数を予測するPythonスクリプトです。

###  [rental_prediction.sql](rental_prediction.sql)
rent_prediction.pyの処理をSQL Server内に展開（トレーニング用のストアドプロシージャとテーブルの作成、モデルの保存、予測用のストアドプロシージャの作成）します。

###  [setup.sql](setup.sql)
バックアップファイルをリストアします（ファイルパスをダウンロードしたパスに置き換えてください）。

## 参考
[Build a predictive model using Python and SQL Server ML Services](https://microsoft.github.io/sql-ml-tutorials/python/rentalprediction/)
-->

<!--
# Build a predictive model with Python using SQL Server 2017 Machine Learning Services

This sample shows how to create a predictive model in Python and operationalize it with SQL Server 2017

### Contents

[About this sample](#about-this-sample)<br/>
[Before you begin](#before-you-begin)<br/>
[Sample details](#sample-details)<br/>



<a name=about-this-sample></a>

## About this sample

Predictive modeling is a powerful way to add intelligence to your application. It enables applications to predict outcomes against new data.
The act of incorporating predictive analytics into your applications involves two major phases: 
model training and model operationalization.

In this sample, you will learn how to create a predictive model in python and operationalize it with SQL Server vNext.


<!-- Delete the ones that don't apply -->
- **Applies to:** SQL Server 2017 CTP2.0 or higher
- **Key features:** SQL Server Machine Learning Services 
- **Workload:** SQL Server Machine Learning Services
- **Programming Language:** T-SQL, Python
- **Authors:** Nellie Gustafsson
- **Update history:** Getting started tutorial for SQL Server ML Services - Python 

<a name=before-you-begin></a>

## Before you begin

To run this sample, you need the following prerequisites: </br>
[Download this DB backup file](https://deve2e.azureedge.net/sqlchoice/static/TutorialDB.bak) and restore it using Setup.sql. 

**Software prerequisites:**

<!-- Examples -->
1. [SQL Server 2017 CTP2.0](https://www.microsoft.com/en-us/sql-server/sql-server-2017) (or higher) with Machine Learning Services (Python) installed
2. [SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
3. [Python Tools for Visual Studio](https://www.visualstudio.com/vs/python/) or another Python IDE

## Run this sample
1. From SQL Server Management Studio, or SQL Server Data Tools, connect to your SQL Server 2017 database and execute setup.sql to restore the sample DB you have downloaded </br>
2. From SQL Server Management Studio or SQL Server Data Tools, open the rental_prediction.sql script </br>
This script sets up: </br>
Necessary tables </br>
Creates stored procedure to train a model </br>
Creates a stored procedure to predict using that model </br>
Saves the predicted results to a DB table </br>
3. You can also try the Python script on its own, connecting to SQL Server and getting data using RevoScalePy Rx functions. Just remember to point the Python environment to the corresponding path "C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\PYTHON_SERVICES" if you run in-db Python Server, or 
"C:\Program Files\Microsoft SQL Server\140\PYTHON_SERVER" if you have the standalone Machine Learning Server installed.

<a name=sample-details></a>

## Sample details

This sample shows how to create a predictive model with Python and generate predictions using the model and deploy that in SQL Server with SQL Server Machine Learning Services. 

### rental_prediction.py
The Python script that generates a predictive model and uses it to predict rental counts

###  rental_prediction.sql
Takes the Python code in rental_prediction.py and deploys it inside SQL Server. Creating stored procedures and tables for training, storing models and creating stored procedures for prediction.

###  setup.sql
Restores the sample DB (Make sure to update the path to the .bak file)
-->