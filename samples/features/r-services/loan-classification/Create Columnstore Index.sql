USE [LendingClub]
GO

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
GO


