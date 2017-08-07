# Pythonで予測モデルを作成し、SQL Server Machine Learning Servicesを使用して予測モデルをSQL Serverに展開する

このサンプルはPythonで予測モデルを作成し、それをSQL Server 2017で操作する方法を示しています。

### コンテンツ


[このサンプルについて](#このサンプルについて)

[はじめに](#はじめに)

[サンプルの実行](#サンプルの実行)

[サンプル詳細](#サンプル詳細)



## このサンプルについて

予測モデリングはアプリケーションにインテリジェンスを追加する強力な方法で、アプリケーションは新しいデータに対する結果を予測することができます。
予測分析をアプリケーションに組み込むには「モデル訓練」と「モデル操作」の大きく2つの段階があります。

このサンプルでは、Pythonで予測モデルを作成、SQL Server 2017で予測モデルを操作の２点を学習します。


<!-- Delete the ones that don't apply -->
- **対象:** SQL Server 2017 CTP2.0（もしくはそれ以降）
- **機能:** SQL Server Machine Learning Services 
- **ワークロード:** SQL Server Machine Learning Services
- **プログラム言語:** Python, TSQL
- **著者:** Nellie Gustafsson
- **更新履歴:** Tomoyuki Oota（日本語化、説明補足、参考情報のリンク追加）

## はじめに

このサンプルを実行するためには以下の事前準備が必要です：
1. [このバックアップファイルをダウンロードし](https://deve2e.azureedge.net/sqlchoice/static/TutorialDB.bak) Setup.sqlを利用しリストアを実行してください. 

**ソフトウェア要件:**
1. [SQL Server 2017 CTP2.0](https://www.microsoft.com/en-us/sql-server/sql-server-2017) (もしくはそれ以降) と Machine Learning Services (Python) がインストールされていること
   *  参考：[SQL Server 2017 In-Database Python を使ってみた](https://blogs.msdn.microsoft.com/dataplatjp/2017/05/29/sqlserver2017-in-database-python/)
2. [SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)がインストールされていること
3. [Python Tools for Visual Studio](https://www.visualstudio.com/vs/python/) もしくはその他の Python IDE がインストールされていること

## サンプルの実行
1. SQL Server Management Studio から SQL Server 2017 のデータベースに接続し、Setup.sql の実行によってダウンロードしてきたバックアップファイルをリストアします。
2. SQL Server 2017 内でPython実行を有効化するためのインスタンス設定を行い、SQL Server 2017を再起動します。
   *  2-1.EXEC sp_configure 'external scripts enabled', 1;
   *  2-2.RECONFIGURE WITH OVERRIDE
   *  2-3.SQL Server 2017を再起動
3. SQL Server Management Studio から rental_prediction.sql を開きます。
このスクリプトは以下を実行します。
   *  3-1.必要なテーブルの作成
   *  3-2.モデル訓練のためのストアドプロシージャ作成
   *  3-3.訓練モデルによる予測実行のためのストアドプロシージャ作成
   *  3-4.予測結果をデータベース内のテーブルに保存
4. 同じ処理をPythonスクリプトで実行することもできます。このスクリプトはSQL Serverに接続し、RevoScalePy Rx 関数によってデータを取得しています。Pythonスクリプトで実行する場合は適切なPython環境パスを指定することに注意してください。
   *  "C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\PYTHON_SERVICES" Machine Learning Services（データベース内）でインストールしている場合
   *  "C:\Program Files\Microsoft SQL Server\140\PYTHON_SERVER" Machine Learning Services（スタンドアロン）でインストールしている場合

## サンプル詳細

このサンプルでは、Pythonで予測モデルを作成し、SQL Server Machine Learning Servicesを使用して予測モデルをSQL Serverに展開する方法を示します。

### rental_prediction.py
予測モデルを生成し、それを使用してレンタル数を予測するPythonスクリプトです。

###  rental_prediction.sql
rent_prediction.pyの処理をSQL Server内に展開（トレーニング用のストアドプロシージャとテーブルの作成、モデルの保存、予測用のストアドプロシージャの作成）します。

###  setup.sql
バックアップファイルをリストアします（ファイルパスをダウンロードしたパスに置き換えてください）。

## 参考
[Build a predictive model using Python and SQL Server ML Services](https://microsoft.github.io/sql-ml-tutorials/python/rentalprediction/)





