# Connection Info
$SqlServer = "." # TODO: Change the name of SQL Server instance name
$dbName = "LendingClub" # TODO: Change the name of the database

# Get a list of all the CSV files in the folder
$files = ls C:\Tiger\Extract\*.csv # TODO: Change the path to the appropriate location of the CSV files

# Log folder path
$LogPath = "C:\Tiger\Logs\" # TODO: Change the path of the log folder

$Now = Get-Date
# Log file name (exe)
$ExeLogFile  = "ExecutionLog" + "_" +$Now.ToString("yyyy-MM-dd_HH-mm-ss") + ".log" # TODO: Change the name of the execution log
# Log file name (error)
$ErrLogFile  = "ErrorLog" + "_" +$Now.ToString("yyyy-MM-dd_HH-mm-ss") + ".log" # TODO: Change the name of the error log
# Log file full path
$ExeLogFullPath = Join-Path $LogPath $ExeLogFile
$ErrLogFullPath = Join-Path $LogPath $ErrLogFile

# Log is recorded in a designated file
function RecordLog($LogString, $LogFullPath){
    # The time is added to an output character string (YYYY/MM/DD HH:MM:SS.MMM $LogString) 
    $RecordLog = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss.fff") + " " + $LogString
    # If there are no log folders, it's made
    if( -not (Test-Path $LogPath) ) {
        New-Item $LogPath -Type Directory
    }
    # Log printout
    Write-Output $RecordLog | Out-File -FilePath $LogFullPath -Encoding Unicode -append
}

# Create a function to import the CSV data by skipping the first line
# You will see a number of Invoke-SqlCmd failures for rows that are not being imported into the database
function ImportData ($csvFile)
{
    RecordLog "CSVFile : $csvFile" $ExeLogFullPath
    $csvData = Get-Content -Path $csvFile | Select-Object -Skip 1 | Where-Object {$_.id -notcontains "*Total amount funded in policy code*"} | ConvertFrom-Csv 
    foreach ($line in $csvData)
    {
        $Query = ""
        try{
            $Query = "INSERT INTO dbo.LoanStatsStaging (id,member_id,loan_amnt,funded_amnt,funded_amnt_inv,term,int_rate,installment,grade,sub_grade,emp_title,emp_length,home_ownership,annual_inc,verification_status,issue_d,loan_status,pymnt_plan,[url],[desc],purpose,title,zip_code,addr_state,dti,delinq_2yrs,earliest_cr_line,inq_last_6mths,mths_since_last_delinq,mths_since_last_record,open_acc,pub_rec,revol_bal,revol_util,total_acc,initial_list_status,out_prncp,out_prncp_inv,total_pymnt,total_pymnt_inv,total_rec_prncp,total_rec_int,total_rec_late_fee,recoveries,collection_recovery_fee,last_pymnt_d,last_pymnt_amnt,next_pymnt_d,last_credit_pull_d,collections_12_mths_ex_med,mths_since_last_major_derog,policy_code,application_type,annual_inc_joint,dti_joint,verification_status_joint,acc_now_delinq,tot_coll_amt,tot_cur_bal,open_acc_6m,open_il_6m,open_il_12m,open_il_24m,mths_since_rcnt_il,total_bal_il,il_util,open_rv_12m,open_rv_24m,max_bal_bc,all_util,total_rev_hi_lim,inq_fi,total_cu_tl,inq_last_12m,acc_open_past_24mths,avg_cur_bal,bc_open_to_buy,bc_util,chargeoff_within_12_mths,delinq_amnt,mo_sin_old_il_acct,mo_sin_old_rev_tl_op,mo_sin_rcnt_rev_tl_op,mo_sin_rcnt_tl,mort_acc,mths_since_recent_bc,mths_since_recent_bc_dlq,mths_since_recent_inq,mths_since_recent_revol_delinq,num_accts_ever_120_pd,num_actv_bc_tl,num_actv_rev_tl,num_bc_sats,num_bc_tl,num_il_tl,num_op_rev_tl,num_rev_accts,num_rev_tl_bal_gt_0,num_sats,num_tl_120dpd_2m,num_tl_30dpd,num_tl_90g_dpd_24m,num_tl_op_past_12m,pct_tl_nvr_dlq,percent_bc_gt_75,pub_rec_bankruptcies,tax_liens,tot_hi_cred_lim,total_bal_ex_mort,total_bc_limit,total_il_high_credit_limit) VALUES ("
            $Query = $Query + $line.id.Replace("'","''") + "," + $line.member_id.Replace("'","''") + "," + $line.loan_amnt.Replace("'","''") + "," + $line.funded_amnt.Replace("'","''") + "," + $line.funded_amnt_inv.Replace("'","''") + "," + "N'" + $line.term.Replace("'","''") + "',"+ "N'" + $line.int_rate.Replace("'","''") + "',"+ $line.installment.Replace("'","''") + "," + "N'" + $line.grade.Replace("'","''") + "',"+ "N'" + $line.sub_grade.Replace("'","''") + "',"+ "N'" + $line.emp_title.Replace("'","''") + "',"+ "N'" + $line.emp_length.Replace("'","''") + "',"+ "N'" + $line.home_ownership.Replace("'","''") + "',"+ $line.annual_inc.Replace("'","''") + "," + "N'" + $line.verification_status.Replace("'","''") + "',"+ "N'" + $line.issue_d.Replace("'","''") + "',"+ "N'" + $line.loan_status.Replace("'","''") + "',"+ "N'" + $line.pymnt_plan.Replace("'","''") + "',"+ "N'" + $line.url.Replace("'","''") + "',"+ "N'" + $line.desc.Replace("'","''") + "',"+ "N'" + $line.purpose.Replace("'","''") + "',"+ "N'" + $line.title.Replace("'","''") + "',"+ "N'" + $line.zip_code.Replace("'","''") + "',"+ "N'" + $line.addr_state.Replace("'","''") + "',"+ $line.dti.Replace("'","''") + "," + $line.delinq_2yrs.Replace("'","''") + "," + "N'" + $line.earliest_cr_line.Replace("'","''") + "',"+ $line.inq_last_6mths.Replace("'","''") + "," + $line.mths_since_last_delinq.Replace("'","''") + "," + $line.mths_since_last_record.Replace("'","''") + "," + $line.open_acc.Replace("'","''") + "," + $line.pub_rec.Replace("'","''") + "," + $line.revol_bal.Replace("'","''") + "," + "N'" + $line.revol_util.Replace("'","''") + "',"+ $line.total_acc.Replace("'","''") + "," + "N'" + $line.initial_list_status.Replace("'","''") + "',"+ $line.out_prncp.Replace("'","''") + "," + $line.out_prncp_inv.Replace("'","''") + "," + $line.total_pymnt.Replace("'","''") + "," + $line.total_pymnt_inv.Replace("'","''") + "," + $line.total_rec_prncp.Replace("'","''") + "," + $line.total_rec_int.Replace("'","''") + "," + $line.total_rec_late_fee.Replace("'","''") + "," + $line.recoveries.Replace("'","''") + "," + $line.collection_recovery_fee.Replace("'","''") + "," + "N'" + $line.last_pymnt_d.Replace("'","''") + "',"+ $line.last_pymnt_amnt.Replace("'","''") + "," + "N'" + $line.next_pymnt_d.Replace("'","''") + "',"+ "N'" + $line.last_credit_pull_d.Replace("'","''") + "',"+ $line.collections_12_mths_ex_med.Replace("'","''") + "," + $line.mths_since_last_major_derog.Replace("'","''") + "," + $line.policy_code.Replace("'","''") + "," + "N'" + $line.application_type.Replace("'","''") + "',"+ $line.annual_inc_joint.Replace("'","''") + "," + $line.dti_joint.Replace("'","''") + "," + "N'" + $line.verification_status_joint.Replace("'","''") + "',"+ $line.acc_now_delinq.Replace("'","''") + "," + $line.tot_coll_amt.Replace("'","''") + "," + $line.tot_cur_bal.Replace("'","''") + "," + $line.open_acc_6m.Replace("'","''") + "," + $line.open_il_6m.Replace("'","''") + "," + $line.open_il_12m.Replace("'","''") + "," + $line.open_il_24m.Replace("'","''") + "," + $line.mths_since_rcnt_il.Replace("'","''") + "," + $line.total_bal_il.Replace("'","''") + "," + $line.il_util.Replace("'","''") + "," + $line.open_rv_12m.Replace("'","''") + "," + $line.open_rv_24m.Replace("'","''") + "," + $line.max_bal_bc.Replace("'","''") + "," + $line.all_util.Replace("'","''") + "," + $line.total_rev_hi_lim.Replace("'","''") + "," + $line.inq_fi.Replace("'","''") + "," + $line.total_cu_tl.Replace("'","''") + "," + $line.inq_last_12m.Replace("'","''") + "," + $line.acc_open_past_24mths.Replace("'","''") + "," + $line.avg_cur_bal.Replace("'","''") + "," + $line.bc_open_to_buy.Replace("'","''") + "," + $line.bc_util.Replace("'","''") + "," + $line.chargeoff_within_12_mths.Replace("'","''") + "," + $line.delinq_amnt.Replace("'","''") + "," + $line.mo_sin_old_il_acct.Replace("'","''") + "," + $line.mo_sin_old_rev_tl_op.Replace("'","''") + "," + $line.mo_sin_rcnt_rev_tl_op.Replace("'","''") + "," + $line.mo_sin_rcnt_tl.Replace("'","''") + "," + $line.mort_acc.Replace("'","''") + "," + $line.mths_since_recent_bc.Replace("'","''") + "," + $line.mths_since_recent_bc_dlq.Replace("'","''") + "," + $line.mths_since_recent_inq.Replace("'","''") + "," + $line.mths_since_recent_revol_delinq.Replace("'","''") + "," + $line.num_accts_ever_120_pd.Replace("'","''") + "," + $line.num_actv_bc_tl.Replace("'","''") + "," + $line.num_actv_rev_tl.Replace("'","''") + "," + $line.num_bc_sats.Replace("'","''") + "," + $line.num_bc_tl.Replace("'","''") + "," + $line.num_il_tl.Replace("'","''") + "," + $line.num_op_rev_tl.Replace("'","''") + "," + $line.num_rev_accts.Replace("'","''") + "," + $line.num_rev_tl_bal_gt_0.Replace("'","''") + "," + $line.num_sats.Replace("'","''") + "," + $line.num_tl_120dpd_2m.Replace("'","''") + "," + $line.num_tl_30dpd.Replace("'","''") + "," + $line.num_tl_90g_dpd_24m.Replace("'","''") + "," + $line.num_tl_op_past_12m.Replace("'","''") + "," + $line.pct_tl_nvr_dlq.Replace("'","''") + "," + $line.percent_bc_gt_75.Replace("'","''") + "," + $line.pub_rec_bankruptcies.Replace("'","''") + "," + $line.tax_liens.Replace("'","''") + "," + $line.tot_hi_cred_lim.Replace("'","''") + "," + $line.total_bal_ex_mort.Replace("'","''") + "," + $line.total_bc_limit.Replace("'","''") + "," + $line.total_il_high_credit_limit.Replace("'","''") + ")"
		    $Query = $Query.Replace("(,","(NULL,")
            $Query = $Query.Replace(",)",",NULL)")
            while ($Query.Contains(",,") -eq 1)
            {
                #Write-Host "Removing NULLs"
                $Query = $Query.Replace(",,",",NULL,")
            }
            #Write-Host $query
            Invoke-Sqlcmd -ServerInstance $SqlServer -Database $dbName -Query $Query -Verbose *>> $ErrLogFullPath
        }
        catch{
            RecordLog  "QueryString : $Query" $ErrLogFullPath
            RecordLog  $error[0].exception $ErrLogFullPath
        }
    }
}

# Create a while loop to import the data from the CSV files to an in-memory table
RecordLog "ImportCSVData Start" $ExeLogFullPath
foreach ($file in $files)
{
   RecordLog "ImportData Start" $ExeLogFullPath
   ImportData $file.FullName
   RecordLog "ImportData End" $ExeLogFullPath
   try{
       RecordLog "PerformETL Start" $ExeLogFullPath
       # The time-out value of the query is established at 65535 seconds of the maximum which can be designated
       Invoke-Sqlcmd -ServerInstance $SqlServer -Database $dbName -Query "EXEC dbo.PerformETL" -QueryTimeout 65535 -Verbose *>> $ErrLogFullPath
   }
   catch{
       RecordLog $error[0].exception $ErrLogFullPath
   }
   finally{
       RecordLog "PerformETL End" $ExeLogFullPath
   }
}
RecordLog "ImportCSVData End" $ExeLogFullPath