# Pythonで作成した予測モデルをSQL Serverに展開し利用する

## コンテンツ

[このサンプルについて](#このサンプルについて)

[Step 1. 環境構築](#step-1-環境構築)

[Step 2. Pythonによる予測モデルの作成](#step-2-pythonによる予測モデルの作成)

[Step 3. SQL Serverへの予測モデルの展開と利用](#step-3-sql-serverへの予測モデルの展開と利用)

## このサンプルについて

このサンプルはSQL Server 2017で機械学習を実行します。
シナリオはスキーレンタル事業における将来のレンタル数の予測です。
以下に示す過去のレンタル履歴データセットを用います。

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

**出典:**

この記事は[Build a predictive model using Python and SQL Server ML Services](https://microsoft.github.io/sql-ml-tutorials/python/rentalprediction/)をベースに作成しています。

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

```SQL:Results
model_name                     model
------------------------------ ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
linear_model                   0x800363736B6C6561726E2E6C696E6561725F6D6F64656C2E626173650A4C696E65617252656772657373696F6E0A7100298171017D71022858060000006E5F6A6F627371034B01580500000072616E6B5F71044B0758100000005F736B6C6561726E5F76657273696F6E71055806000000302E31382E31710658090000006E

(1 行処理されました)
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

```SQL:Results
RentalCount_Predicted RentalCount_Actual Month       Day         WeekDay     Snow        Holiday     Year
--------------------- ------------------ ----------- ----------- ----------- ----------- ----------- -----------
41                    42                 2           11          4           0           0           2015
360                   360                3           29          1           0           0           2015
19                    20                 4           22          4           0           0           2015
...
25                    26                 3           18          4           0           0           2015
28                    29                 3           24          3           1           0           2015
377                   377                12          6           1           1           0           2015

(151 行処理されました)
```

SQL Server内に登録した結果をPowerBIなどで可視化します。