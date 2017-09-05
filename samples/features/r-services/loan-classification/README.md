# SQL Server 2017 Machine Learning Services �ɂ��ݓ|���p�x����What-If����

## �V�i���I

���[���f�[�^�����f�������A�ݕt�������㏸�������ꍇ�̑ݓ|���p�x���̕ω��ɂ���What-If���͂��s���܂��B

## �V�X�e���A�[�L�e�N�`��

1. ���[���f�[�^��DB�ɃC���|�[�g
2. DB�Ɏ�荞�񂾃��[���f�[�^���������œK����X�g�A�\���ɕϊ�����i�@�B�w�K�ɂ��O�����̌������j
3. R�Ƀf�[�^�����[�h���f�B�V�W�����t�H���X�g�ɂ�郂�f���g���[�j���O�����s����
4. �g���[�j���O�ς݃��f���𗘗p��What-If���͂��s���A���ʂ��������œK���s�X�g�A�\���Ɋi�[����i�@�B�w�K�ɂ��㏈���̌������j
5. ���͌��ʂ�Power BI�ŉ�������

## �͂��߂�

### �\�t�g�E�F�A�v��

* [SQL Server 2017](https://www.microsoft.com/en-us/sql-server/sql-server-2017)
* [SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
* [Power BI Desktop�i�p��Łj](https://powerbi.microsoft.com/en-us/desktop/) 

(*) Power BI Desktop �p��ł�p�ӂ��Ă��������i�T���v���f�[�^���̈ʒu�f�[�^�i�A�����J�̏B�̗��̃f�[�^�j�����{��ł�BingMap�n�}�Ƀ}�b�s���O���ł��Ȃ����߁j�B

### SQL Server �̎��O�ݒ�

- SQL Server 2017��Database Engine Services�����Machine Learning Services�iIn-Database�j��R���C���X�g�[�����Ă��������B

- SQL Server 2017 ����R���s����ɂ�sp_configure��external scripts enabled�̐ݒ�ύX���K�v�ł��B�܂�external scripts enabled�p�����[�^�͐ݒ�ύX�̔��f��SQL Server 2017�̍ċN�����K�v�ł��B

    - 1.�O���X�N���v�g���s�@�\�̗L����


        ```SQL:T-SQL
        EXEC sp_configure 'external scripts enabled', 1;
        ```

    - 2.SQL Server 2017�̍ċN��

        ```cmd:cmd
        net stop "SQL Server Launchpad (MSSQLSERVER)"
        net stop "SQL Server (MSSQLSERVER)"
        net start "SQL Server (MSSQLSERVER)"
        net start "SQL Server Launchpad (MSSQLSERVER)"
        ```

        net�R�}���h�ɓn���C���X�^���X���͊��ɉ����ĕύX���Ă��������B�܂�SQL Server Agent�T�[�r�X�Ȃ�SQL Server�T�[�r�X�Ɉˑ�����T�[�r�X������ꍇ�ɂ͖����I�ɍĊJ���Ă��������B

### �T���v���f�[�^

LendingClub ��(�ݕt�^�N���E�h�t�@���f�B���O���Ǝ�)�����J���Ă��郍�[���f�[�^�𗘗p���܂��B

�f�[�^�_�E�����[�h�T�C�g�֍s���A�uDOWNLOAD LOAN DATA�v������Ԃ�I������CSV�t�@�C���Ƃ��ă_�E�����[�h���܂��B
��葽���̊��Ԃ𗘗p����̂��]�܂����ł��B���̋L���ŏЉ��f���́u2007-2011�v�`�u2017 Q2�v�܂ł̃f�[�^���_�E�����[�h���Ă��܂��B

����CSV�t�@�C���ɂ́A���݂̃��[���X�e�[�^�X�i�ؓ����A�x��A���ςȂǁj��ŐV�̎x���������܂ށA���s���ꂽ���ׂẴ��[���̊��S�ȃf�[�^���܂܂�Ă��܂��B
### �T���v���R�[�h

* [Create Database.sql]()
���̃`���[�g���A���ɕK�v�Ȋe��f�[�^�x�[�X�I�u�W�F�N�g���쐬���܂��B

* [ImportCSVData.ps1]()
�_�E�����[�h�����T���v���f�[�^��DB�ɃC���|�[�g���܂��B

* [Create Columnstore Index.sql]()
DB�ɃC���|�[�g�����T���v���f�[�^���������œK����X�g�A�\���ɕϊ����܂��B

* [Create Model.sql]()
R�Ƀf�[�^�����[�h���f�B�V�W�����t�H���X�g�ɂ�郂�f���g���[�j���O�����s���܂��B

* [ScoreLoans.ps1]()
�ݕt����������ێ������ꍇ�̑ݕt�]���̃X�R�A�����O���s���܂��B

* [WhatIf.ps1]()
�ݕt������ϓ������ꍇ�̑ݕt�]���̃X�R�A�����O���s���܂��B

* [Loan Status.pbix]()
�ݕt����������ێ������ꍇ�ƕϓ������ꍇ���ꂼ��̑ݕt�]�������|�[�g�������ϓ��̉e�����������܂��B

## �`���[�g���A��

### STEP 1. �f�[�^�x�[�X�I�u�W�F�N�g�̍쐬

SSMS����[Create Database.sql]()�����s���A�f�[�^�x�[�X�I�u�W�F�N�g���쐬���܂��B

(*)�f�[�^�x�[�X�̃f�[�^�t�@�C������уg�����U�N�V�������O��`C:\Tiger\DATA`�ɍ쐬����悤�L�q����Ă��܂��B���ɉ����ēK�X�ύX���Ă��������B

```SQL:Create Database.sql�i�����j
CREATE DATABASE [LendingClub]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'LendingClubData', FILENAME = N'C:\Tiger\DATA\LendingClub.mdf' , SIZE = 19210240KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536MB ), 
 FILEGROUP [InMemOLTP] CONTAINS MEMORY_OPTIMIZED_DATA  DEFAULT
( NAME = N'InMem', FILENAME = N'C:\Tiger\DATA\InMem' , MAXSIZE = UNLIMITED)
 LOG ON 
( NAME = N'LendingClubLog', FILENAME = N'C:\Tiger\DATA\LendingClub_log.ldf' , SIZE = 512MB , MAXSIZE = 2048GB , FILEGROWTH = 64MB )
GO
```

����SQL��������I������ƈȉ��̃I�u�W�F�N�g���쐬����܂��B

|�I�u�W�F�N�g���|�I�u�W�F�N�g��|����|
|:---|:---|:---|
|DATABASE|LendingClub|�`���[�g���A���Ɏg�p����f�[�^�x�[�X|
|TABLE|LoanStatsStaging|�T���v���f�[�^�C���|�[�g�p�̃X�e�[�W���O�e�[�u��|
|TABLE|LoanStats|�@�B�w�K�̑ΏۂƂȂ郍�[���f�[�^|
|TABLE|models|�g���[�j���O�ς݃��f�����i�[����e�[�u��|
|TABLE|LoanStatsPredictions|�ݕt����������ێ������ꍇ�̑ݕt�]���X�R�A���i�[����e�[�u��|
|TABLE|LoanPredictionsWhatIf|�ݕt������ϓ������ꍇ�̑ݕt�]���X�R�A���i�[����e�[�u��|
|TABLE|WhatIf|What-If���͂̂��߂Ɏw�肵���ݕt�����̈����グ�����i�[����e�[�u��|
|TABLE|RunTimeStats|���s���Ԃ��L�^���邽�߂̃e�[�u��|
|PROCEDURE|PerformETL|�T���v���f�[�^��ETL�����s����v���V�[�W��|
|PROCEDURE|TrainLoansModel|�f�B�V�W�����t�H���X�g�ɂ�郂�f���g���[�j���O�����s����v���V�[�W��|
|PROCEDURE|ScoreLoans|�ݕt����������ێ������ꍇ�̑ݕt�]���̃X�R�A�����O���s���v���V�[�W��|
|PROCEDURE|ScoreLoansWhatIf|�ݕt������ϓ������ꍇ�̑ݕt�]���̃X�R�A�����O���s���v���V�[�W��|

![step1-1](media/step1-1.png "step1-1")

### STEP 2. �T���v���f�[�^�̃C���|�[�g��ETL����

PowerShell����[ImportCSVData.ps1]()�����s���A�T���v���f�[�^���C���|�[�g���܂��B

```PowerShell:ImportCSVData.ps1�̏����̗���
CSV�t�@�C�����i�[�����t�H���_�z����CSV�t�@�C����Foreach�Ŏ��o�� {
    ���o����CSV�t�@�C�����̂P���R�[�h��Foreach�Ŏ��o�� {
        ���o�����P���R�[�h��LoanStatsStaging�e�[�u����INSERT
    }
    PerformETL�v���V�[�W�����Ăяo�� {
        LoanStatsStaging�e�[�u���̃f�[�^�����H����LoanStats�e�[�u���ɓ]��
        LoanStats�e�[�u���̃f�[�^�ɑ΂��ē������o���� {
            IF (loan_status��l���uLate (16-30 days)�v�uLate (31-120 days)�v�uDefault�v�uCharged Off�v)
                is_bad(�ݕt�]��) = 1
            ELSE
                is_bad(�ݕt�]��) = 0
        }
        LoanStatsStaging�e�[�u����DELETE
    }
}
```

![step2-1](media/step2-1.png "step2-1")

(*)DB�ւ̐ڑ����ACSV�t�@�C�����i�[�����t�H���_`C:\Tiger\Extract\`�A���O���o�͂���t�H���_'C:\Tiger\Logs\'�͊��ɉ����ēK�X�ύX���Ă��������B

```SQL:ImportCSVData.ps1�i�����j
# Connection Info
$SqlServer = "." # TODO: Change the name of SQL Server instance name
$dbName = "LendingClub" # TODO: Change the name of the database

# Get a list of all the CSV files in the folder
$files = ls C:\Tiger\Extract\*.csv # TODO: Change the path to the appropriate location of the CSV files

# Log folder path
$LogPath = "C:\Tiger\Logs\" # TODO: Change the path of the log folder
```

(*)PowerShell���Ŏ��s���Ă���Invoke-Sqlcmd�̊���̃^�C���A�E�g�l�i30�b�j�����ɂȂ�ꍇ�͓K�X�ύX���Ă��������B

### STEP 3. �C���|�[�g�f�[�^���������œK����X�g�A�\���ɕϊ�

[Create Columnstore Index.sql]()�����s���A�@�B�w�K�ɂ��O�����̌������̂��߂ɃC���|�[�g�f�[�^���������œK����X�g�A�\���ɕϊ����܂��B

```SQL:Create Columnstore Index.sql
CREATE NONCLUSTERED COLUMNSTORE INDEX [ncci_LoanStats] ON [dbo].[LoanStats]
(
	[revol_util],
	[int_rate],
	[mths_since_last_record],
	[annual_inc_joint],
	[dti_joint],
	[total_rec_prncp],
	[all_util],
	[is_bad]
)WITH (COMPRESSION_DELAY = 0, MAXDOP = 1) ON [PRIMARY];
```

![step3-1](media/step3-1.png "step3-1")

### STEP 4. �f�B�V�W�����t�H���X�g�ɂ�郂�f���g���[�j���O

[Create Model.sql]()�����s���AR�Ƀf�[�^�����[�h���f�B�V�W�����t�H���X�g�ɂ�郂�f���g���[�j���O�����s���A�g���[�j���O�ς݃��f����model�e�[�u���Ɋi�[���܂��B

Create Model.sql���ŌĂяo����Ă���TrainLoansModel�v���V�[�W���������̎��̂ł��B�g���[�j���O�̂��߂̃f�[�^�Z�b�g��LoanStats�e�[�u����75���T���v�����O�ł��B

![step4-1](media/step4-1.png "step4-1")

### STEP 5. �ݕt����������ێ������ꍇ�̑ݕt�]���̃X�R�A�����O

[ScoreLoans.ps1]()�����s���A�ݕt����������ێ������ꍇ�̑ݕt�]���̃X�R�A�����O���s���܂��B

ScoreLoans.ps1���ŌĂяo����Ă���ScoreLoans�v���V�[�W���������̎��̂ł��BSTEP 4�ō쐬�������f���𗘗p���ALoanStats�e�[�u���̃f�[�^�ɑ΂���ݕt�]���̃X�R�A�����O���s���A���ʂ�LoanStatsPredictions�C���������e�[�u���Ɋi�[���܂��B

![step5-1](media/step5-1.png "step5-1")

![step5-2](media/step5-2.png "step5-2")

(*)DB�ւ̐ڑ����͊��ɉ����ēK�X�ύX���Ă��������B

```SQL:ScoreLoans.ps1�i�����j
$SqlServer = "."  # TODO: Change the name of SQL Server instance name
$dbName = "LendingClub" # TODO: Change the name of the database
```

(*)�X�R�A�����O�͕�����s�i�ΏۂƂ��郌�R�[�h�͈̔͂��Ƃɕ��S�����j���Ă��܂��B�������d�x��WRITE���s���悤�ȃ��[�N���[�h�ɑ΂��ăC���������e�[�u���̗��p�͓K���Ă��܂��B�����SETP 7.�̉����ɔ���READ�Ƃ̕�����s�ɂ����Ă����l�ł��B

### STEP 6. �ݕt������ϓ������ꍇ�̑ݕt�]���̃X�R�A�����O

[WhatIf.ps1]()�����s���A�ݕt����������ێ������ꍇ�̑ݕt�]���̃X�R�A�����O���s���܂��B

WhatIf.ps1�͕ϓ�������ݕt������Θb�^�Ŏ󂯎��i�����グ�������P�ʂŎw�肵�Ă��������j�A�����̎��̂ƂȂ�ScoreLoansWhatIf�v���V�[�W���ɓn���܂��B
ScoreLoansWhatIf��STEP 4�ō쐬�������f���𗘗p���A�ݕt������ϓ�������LoanStats�e�[�u���̃f�[�^�ɑ΂��đݕt�]���̃X�R�A�����O���s���A���ʂ�LoanPredictionsWhatIf�C���������e�[�u���Ɋi�[���܂��B

![step6-1](media/step6-1.png "step6-1")

![step6-2](media/step6-2.png "step6-2")

(*)DB�ւ̐ڑ����͊��ɉ����ēK�X�ύX���Ă��������B

```SQL:WhatIf.ps1�i�����j
$SqlServer = "."  # TODO: Change the name of SQL Server instance name
$dbName = "LendingClub" # TODO: Change the name of the database
```

(*)�X�R�A�����O�͕�����s�i�ΏۂƂ��郌�R�[�h�͈̔͂��Ƃɕ��S�����j���Ă��܂��B�������d�x��WRITE���s���悤�ȃ��[�N���[�h�ɑ΂��ăC���������e�[�u���̗��p�͓K���Ă��܂��B�����SETP 7.�̉����ɔ���READ�Ƃ̕�����s�ɂ����Ă����l�ł��B

### STEP 7. �����ϓ��ɂ��e���̉���

�ȉ��̎菇�őݕt����������ێ������ꍇ�ƕϓ������ꍇ���ꂼ��̑ݕt�]�������|�[�g�������ϓ��̉e�����������܂��B

1. [Loan Status.pbix]()���J��
2. �ڑ�����K�X�ύX����
    Menu -> Home -> Edit Queries -> Data Source Settings -> �f�[�^�x�[�X�̃A�C�R����I�� -> Change Source... ��Server��Database��K�X�C�����܂��B
    
    ![step7-1](media/step7-1.png "step7-1")
    ![step7-2](media/step7-2.png "step7-2")

3. [State Codes.xlsx]()�i�B���Ɨ��̂̃}�b�s���O�j�̃t�@�C���p�X��K�X�ύX����

    Menu -> Home -> Edit Queries -> Data Source Settings -> �t�@�C���̃A�C�R����I�� -> Change Source... ��File path��K�X�C�����܂��B

    ![step7-3](media/step7-3.png "step7-3")

    ![step7-4](media/step7-4.png "step7-4")

4. �f�[�^�����t���b�V�����ŐV�̃f�[�^���C���|�[�g����

    �ȉ��̃e�[�u���ɂ��Ă͎蓮�X�V�iFields -> �Ώۂ̃e�[�u�����E�N���b�N -> Refresh data�j���s���܂��B

    * BasePrediction
    * Branch
    * States

    ![step7-5-2](media/step7-5-2.png "step7-5-2")

    ![step7-5](media/step7-5.png "step7-5")

    (*) ��L�̓��|�[�g�̃��t���b�V���̑ΏۊO�ɐݒ肵�Ă��邽�߂Ɏ蓮�X�V���K�v�ł��B

    �ȉ��ɂ��Ă̓��|�[�g�̃��t���b�V���iMenu -> Home -> Refresh�j�ɂ���Ď����X�V���s���܂��B

    * Rate
    * WhatIf

    What-If���͂̂��߂�STEP 6�����s����s�x���|�[�g�̃��t���b�V�����s���Ă��������B

    ![step7-6-2](media/step7-6-2.png "step7-6-2")

    ![step7-6](media/step7-6.png "step7-6")

5. ���|�[�g���Q�Ƃ���

Loan Status Power BI���|�[�g�͈ȉ��̂Q�̃��|�[�g���p�ӂ���Ă��܂��B

* Current State�F���݂̃��[�����

    * Distribution by Loan Status
    ���[����Ԃ��Ƃ̑ݕt���z���v���������ςݏグ���_�O���t

    * ��L�̉E�ɂ���\�iExcel����̓]�L�j
    �B�����s�A���[����Ԃ��ō\�������\�A���l�͑ݕt���z���v

    * Distribution by Loan Status across States
    �B���Ƃ̃��[����Ԃ̊�����ݕt���z���v�Ŏ�����100���ςݏグ���_�O���t

    * Loan Distribution Map
    ���[����Ԃ�"Current"�ɂȂ��Ă���A�B���Ƃ̑ݕt���z���v���������h�蕪���n�}

    ![step7-7](media/step7-7.png "step7-7")

* What-If�F�\���l�Ƌ��������鐔�l�ő�����������What-If����

    * ChargeOffProbability
    �\�������ݓ|���p�x���������iHigh�F���X�N��ALow�F���X�N��j

    * What-If Rate
    What-If���͂Ŏw�肵���������������������J�[�h

    * Predicted Charge-offs (�ݕt����������ێ������ꍇ�Ƒݕt������ϓ������ꍇ���ꂼ��)
    ���[����Ԃ�"Current"�̑ݕt���z���v���������J�[�h

    * Predicted Charge-offs by Credit Score (�ݕt����������ێ������ꍇ�Ƒݕt������ϓ������ꍇ���ꂼ��)
    �B���Ƃ̑ݓ|���p�x���̍���̊������������n�}

    * Predicted Charge-offs (�ݕt����������ێ������ꍇ�Ƒݕt������ϓ������ꍇ���ꂼ��)
    ���[����Ԃ�"Current"�́A�B���Ƃ̑ݕt���z���v��ݓ|���p�x���̊����Ŏ�����100���ςݏグ�c�_�O���t

    ![step7-8](media/step7-8.png "step7-8")

## �o�T

[Loan Classification using SQL Server 2016 R Services](https://github.com/Microsoft/sql-server-samples/tree/master/samples/features/r-services/loan-classification)

## �֘A

[A walkthrough of Loan Classification using SQL Server 2016 R Services](https://blogs.msdn.microsoft.com/sql_server_team/a-walkthrough-of-loan-classification-using-sql-server-2016-r-services/)

[Lending Club Statistics](https://www.lendingclub.com/info/download-data.action)

