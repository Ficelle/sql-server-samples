# RevoScalePyライブラリで実装した予測モデルをSQL Server 2017 Machine Learning Servicesで実行する

これはRevoScalePyライブラリを活用したPython機械学習スタックによる予測モデルの作り方のサンプルです。

このチュートリアルで使用されているデータセットは、パリのレンタルバイクの大規模な公共サービスであるVélibに基づいています。このサービスは、現在約1230台のステーションで14500台のバイクを提供しています。http://en.velib.paris.fr/

このデータセットは、パリの8番通りにおける15分ごとにサンプリングされた1ヵ月分のレンタルデータです。


### コンテンツ

[このサンプルについて](#このサンプルについて)

[はじめに](#はじめに)

[サンプルの実行](#サンプルの実行)

[サンプル詳細](#サンプル詳細)




## このサンプルについて


このサンプルは特定のバイクステーションが空であるかどうかを予測します。




- **対象:** SQL Server 2017 CTP2.0 or higher
- **機能:** SQL Server Machine Learning Services 
- **ワークロード:** SQL Server Machine Learning Services
- **プログラム言語:** Python, TSQL



## はじめに

このサンプルを実行するためには以下の事前準備が必要です：
1. [このバックアップファイルをダウンロードし](https://sq14samples.blob.core.windows.net/data/velibDB.bak) Setup.sqlを利用しリストアを実行してください. 

**ソフトウェア要件:**


1. [SQL Server 2017 CTP2.0](https://www.microsoft.com/en-us/sql-server/sql-server-2017) (もしくはそれ以降) と Machine Learning Services (Python) がインストールされていること
2. [SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)がインストールされていること
3. [Python Tools for Visual Studio](https://www.visualstudio.com/vs/python/) もしくはその他の Python IDE がインストールされていること

## サンプルの実行
1. SQL Server Management Studio から SQL Server 2017 のデータベースに接続し、Setup.sql の実行によってダウンロードしてきたバックアップファイルをリストアします。

   *  参考：[SQL Server 2017 In-Database Python を使ってみた](https://blogs.msdn.microsoft.com/dataplatjp/2017/05/29/sqlserver2017-in-database-python/)

2. Python Tools for Visual Studio のツールメニューから python tools command を開き、Machine Learning Services の Python 環境へのパスを設定してください。https://docs.microsoft.com/en-us/visualstudio/python/python-environments

   *  "C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\PYTHON_SERVICES" Machine Learning Services（データベース内）でインストールしている場合
   *  "C:\Program Files\Microsoft SQL Server\140\PYTHON_SERVER" Machine Learning Services（スタンドアロン）でインストールしている場合

3. ダウンロードしたPythonソースを実行します。






## サンプル詳細

#### datasource.py
このPythonファイルは、SQL Serverからデータを取得し、SQL Server Compute Contextへのアクセスを提供するクラスを定義します。

####  pipeline.sql
このPythonファイルは、フィーチャエンジニアリングを実行するマシン学習パイプラインと、RevoScalePyバイナリロジスティック回帰に適合するクラシファイアを定義します。

This python file defines the machine learning pipeline that performs features engineering and the classifier that fits the RevoScalePy binary logistic regression.

####  runner.sql
このPythonファイルは、ソリューションを実行するための起動コードとメインメソッドを定義します。

####  setup.sql
Restores the sample DB (Make sure to update the path to the .bak file)





## 免責事項
このサンプルで使用されているデータセットは、JCdecauxのhttps://developer.jcdecaux.com/#/opendata/licenseから取得しています。




