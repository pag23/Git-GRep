USE [CDS_Mart]
GO

/****** Object:  StoredProcedure [dbo].[extract_ae_period_data_sp]    Script Date: 09/27/2016 13:58:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[extract_ae_period_data_sp] 
AS
/*---------------------------------
CREATED 10/09/2015 PAG LOAD Stage 1 AE CDS data

exec dbo.[extract_ae_period_data_sp]

*/
DECLARE @start_date as date
DECLARE @end_date as date

SET @start_date =
(
Select CAST(start_date AS DATE)
FROM sdhis5.cds_audit.dbo.tbl_cds_submission_dates
WHERE cds ='010'
)

SET @end_date =
(
Select CAST(end_date AS DATE)
FROM sdhis5.cds_audit.dbo.tbl_cds_submission_dates
WHERE cds ='010'
)

TRUNCATE TABLE dbo.extract_cds_out_sync_temp
--SELECT * FROM dbo.[extract_cds_out_sync_temp]

INSERT INTO dbo.[extract_cds_out_sync_temp]
SELECT * FROM dbo.extract_cds_out_sync

TRUNCATE TABLE dbo.extract_cds_out_sync

/****** 

Script for SelectTopNRows command from SSMS  

SELECT * FROM [dbo].[extract_cds_out_sync]

******/
INSERT INTO [dbo].[extract_cds_out_sync]
(
		[CDS_Type]
      ,[CDS_Protocol_ID]
      ,[CDS_Unique_ID]
      ,[CDS_BULK_Replacement_Group]
      ,[CDS_Update_Type]
      ,[CDS_Extract_Date]
      ,[CDS_Extract_Time]
      ,[CDS_Applicable_Date]
      ,[CDS_Applicable_Time]
      ,[CDS_Report_Period_Start_Date]
      ,[CDS_Report_Period_End_Date]
      ,[CDS_Activity_Date]
      ,[CDS_Sender_Identity]
      ,[CDS_Prime_Recip]
      ,[CDS_Copy_Recip1]
      ,[CDS_Copy_Recip2]
      ,[CDS_Copy_Recip3]
      ,[CDS_Copy_Recip4]
      ,[CDS_Copy_Recip5]
      ,[CDS_Copy_Recip6]
      ,[CDS_Copy_Recip7]
      ,[UBRN]
      ,[Patient_Pathway_ID]
      ,[Org_Code_Pathway_ID]
      ,[RTT_Status]
      ,[RTT_WaitingTimeMeasurement]
      ,[RTT_Start_Date]
      ,[RTT_End_Date]
      ,[Withheld_Identitiy_Reason]
      ,[PATID]
      ,[Org_Code_PATID]
      ,[NHS_Number]
      ,[NHS_Number_Status]
      ,[Unstructured Patient_Name]
      ,[Structured PersonTitle]
      ,[Structured PersonGivenName]
      ,[Structured PersonFamilyName]
      ,[Structured PersonNameSuffix]
      ,[Structured PersonInititials]
      ,[Unstructured Address]
      ,[Structured Address Line 1]
      ,[Structured Address Line 2]
      ,[Structured Address Line 3]
      ,[Structured Address Line 4]
      ,[Structured Address Line 5]
      ,[Postcode]
      ,[Org_Code_Residence_Responsibility]
      ,[DOB]
      ,[Gender]
      ,[Carer_Support_Indicator]
      ,[Ethnic_Cat]
      ,[Reg_GP]
      ,[Reg_Prac]
      ,[Site_Code_Of_Treatment]
      ,[AE_Att_No]
      ,[AE_Arrival_Mode]
      ,[AE_Att_Cat]
      ,[AE_Att_Disp]
      ,[AE_Incident_Loc_Type]
      ,[AE_Patient_Group]
      ,[Ref_Source]
      ,[AE_Dept_Type]
      ,[Arrival_Date]
      ,[Arrival_Time]
      ,[Age_at_CDS_Activity_Date]
      ,[Overseas_Visitor_Class_At_Activity_Date]
      ,[Initial_Assmt_Date]
      ,[Initial_Assmt_Time]
      ,[Date_Seen_for_Treatment]
      ,[Time_Seen_for_Treatment]
      ,[Att_Conclusion_Date]
      ,[Att_Conclusion_Time]
      ,[Att_Departure_Date]
      ,[AE_Departure_Time]
      ,[Ambulance_Incident_Number]
      ,[Org_Code_Conveying_Ambulance_Trust]
      ,[Comm_Serial_No]
      ,[SLA_No]
      ,[Prov_Ref_No]
      ,[Comm_Ref_No]
      ,[Org_Code_Prov]
      ,[Org_Code_Comm]
      ,[AE_Staff_Code]
      ,[ICD_Diag_Scheme]
      ,[ICD_Prim_Diag]
      ,[Present_On_Admission_Indicator]
      ,[ICD_Sec_Diag_1]
      ,[Present_On_Admission_Indicator_1]
      ,[Read_Diag_Scheme]
      ,[Read_Prim_Diag]
      ,[Read_Sec_Diag_1]
      ,[AE_Diag_Scheme]
      ,[AE_Diag_1]
      ,[AE_Diag_2]
      ,[AE_Diag_3]
      ,[AE_Diag_4]
      ,[AE_Diag_5]
      ,[AE_Diag_6]
      ,[AE_Diag_7]
      ,[AE_Diag_8]
      ,[AE_Diag_9]
      ,[AE_Diag_10]
      ,[AE_Diag_11]
      ,[AE_Diag_12]
      ,[AE_Diag_13]
      ,[AE_Diag_14]
      ,[AE_Diag_15]
      ,[AE_Diag_16]
      ,[AE_Diag_17]
      ,[AE_Diag_18]
      ,[AE_Diag_19]
      ,[AE_Diag_20]
      ,[AE_Diag_21]
      ,[AE_Diag_22]
      ,[AE_Diag_23]
      ,[AE_Diag_24]
      ,[AE_Diag_25]
      ,[AE_Diag_26]
      ,[AE_Diag_27]
      ,[AE_Diag_28]
      ,[AE_Diag_29]
      ,[AE_Diag_30]
      ,[AE_Invest_Scheme]
      ,[AE_Invest_1]
      ,[AE_Invest_2]
      ,[AE_Invest_3]
      ,[AE_Invest_4]
      ,[AE_Invest_5]
      ,[AE_Invest_6]
      ,[AE_Invest_7]
      ,[AE_Invest_8]
      ,[AE_Invest_9]
      ,[AE_Invest_10]
      ,[AE_Invest_11]
      ,[AE_Invest_12]
      ,[AE_Invest_13]
      ,[AE_Invest_14]
      ,[AE_Invest_15]
      ,[AE_Invest_16]
      ,[AE_Invest_17]
      ,[AE_Invest_18]
      ,[AE_Invest_19]
      ,[AE_Invest_20]
      ,[AE_Invest_21]
      ,[AE_Invest_22]
      ,[AE_Invest_23]
      ,[AE_Invest_24]
      ,[AE_Invest_25]
      ,[AE_Invest_26]
      ,[AE_Invest_27]
      ,[AE_Invest_28]
      ,[AE_Invest_29]
      ,[AE_Invest_30]
      ,[OPCS_Scheme]
      ,[OPCS_Prim_Proc]
      ,[OPCS_Prim_Proc_Date]
      ,[HCP_Prof_Reg_Issuer]
      ,[HCP_Prof_Reg_Entry_Identifier]
      ,[Anaesthetist_Prof_Reg_Issuer]
      ,[Anaesthetist_Prof_Reg_Identifier]
      ,[OPCS_Proc_2]
      ,[OPCS_Proc_2_Date]
      ,[HCP_Prof_Reg_Issuer_2]
      ,[HCP_Prof_Reg_Entry_Identifier_2]
      ,[Anaesthetist_Prof_Reg_Issuer_2]
      ,[Anaesthetist_Prof_Reg_Identifier_2]
      ,[Read_Proc_Scheme]
      ,[Read_Prim_Proc]
      ,[Read_Prim_Proc_Date]
      ,[Read_Sec_Proc]
      ,[Read_Sec_Proc_Date]
      ,[AE_Proc_Scheme]
      ,[AE_Prim_Proc]
      ,[AE_Proc_1_Date]
      ,[AE_Proc_2]
      ,[AE_Proc_2_Date]
      ,[AE_Proc_3]
      ,[AE_Proc_3_Date]
      ,[AE_Proc_4]
      ,[AE_Proc_4_Date]
      ,[AE_Proc_5]
      ,[AE_Proc_5_Date]
      ,[AE_Proc_6]
      ,[AE_Proc_6_Date]
      ,[AE_Proc_7]
      ,[AE_Proc_7_Date]
      ,[AE_Proc_8]
      ,[AE_Proc_8_Date]
      ,[AE_Proc_9]
      ,[AE_Proc_9_Date]
      ,[AE_Proc_10]
      ,[AE_Proc_10_Date]
      ,[AE_Proc_11]
      ,[AE_Proc_11_Date]
      ,[AE_Proc_12]
      ,[AE_Proc_12_Date]
      ,[AE_Proc_13]
      ,[AE_Proc_13_Date]
      ,[AE_Proc_14]
      ,[AE_Proc_14_Date]
      ,[AE_Proc_15]
      ,[AE_Proc_15_Date]
      ,[AE_Proc_16]
      ,[AE_Proc_16_Date]
      ,[AE_Proc_17]
      ,[AE_Proc_17_Date]
      ,[AE_Proc_18]
      ,[AE_Proc_18_Date]
      ,[AE_Proc_19]
      ,[AE_Proc_19_Date]
      ,[AE_Proc_20]
      ,[AE_Proc_20_Date]
      ,[AE_Proc_21]
      ,[AE_Proc_21_Date]
      ,[AE_Proc_22]
      ,[AE_Proc_22_Date]
      ,[AE_Proc_23]
      ,[AE_Proc_23_Date]
      ,[AE_Proc_24]
      ,[AE_Proc_24_Date]
      ,[AE_Proc_25]
      ,[AE_Proc_25_Date]
      ,[AE_Proc_26]
      ,[AE_Proc_26_Date]
      ,[AE_Proc_27]
      ,[AE_Proc_27_Date]
      ,[AE_Proc_28]
      ,[AE_Proc_28_Date]
      ,[AE_Proc_29]
      ,[AE_Proc_29_Date]
      ,[AE_Proc_30]
      ,[AE_Proc_30_Date]
      ,[Filler_1]
      ,[Filler_2]
      ,[Filler_3]
      ,[Filler_4]
      ,[Filler_5]
      ,[Filler_6]
      ,[Filler_7]
      ,[Filler_8]
      ,[Filler_9]
      ,[Filler_10]
      ,[mod_date]
      ,[hash__value]
)
SELECT [CDS_Type]
      ,[CDS_Protocol_ID]
      ,[CDS_Unique_ID]
      ,[CDS_BULK_Replacement_Group]
      ,[CDS_Update_Type]
      ,[CDS_Extract_Date]
      ,[CDS_Extract_Time]
      ,[CDS_Applicable_Date]
      ,[CDS_Applicable_Time]
      ,[CDS_Report_Period_Start_Date]
      ,[CDS_Report_Period_End_Date]
      ,[CDS_Activity_Date]
      ,[CDS_Sender_Identity]
      ,[CDS_Prime_Recip]
      ,[CDS_Copy_Recip1]
      ,[CDS_Copy_Recip2]
      ,[CDS_Copy_Recip3]
      ,[CDS_Copy_Recip4]
      ,[CDS_Copy_Recip5]
      ,[CDS_Copy_Recip6]
      ,[CDS_Copy_Recip7]
      ,[UBRN]
      ,[Patient_Pathway_ID]
      ,[Org_Code_Pathway_ID]
      ,[RTT_Status]
      ,[RTT_WaitingTimeMeasurement]
      ,[RTT_Start_Date]
      ,[RTT_End_Date]
      ,[Withheld_Identitiy_Reason]
      ,[PATID]
      ,[Org_Code_PATID]
      ,[NHS_Number]
      ,[NHS_Number_Status]
      ,[Unstructured Patient_Name]
      ,[Structured PersonTitle]
      ,[Structured PersonGivenName]
      ,[Structured PersonFamilyName]
      ,[Structured PersonNameSuffix]
      ,[Structured PersonInititials]
      ,[Unstructured Address]
      ,[Structured Address Line 1]
      ,[Structured Address Line 2]
      ,[Structured Address Line 3]
      ,[Structured Address Line 4]
      ,[Structured Address Line 5]
      ,[Postcode]
      ,[Org_Code_Residence_Responsibility]
      ,[DOB]
      ,[Gender]
      ,[Carer_Support_Indicator]
      ,[Ethnic_Cat]
      ,[Reg_GP]
      ,[Reg_Prac]
      ,[Site_Code_Of_Treatment]
      ,[AE_Att_No]
      ,[AE_Arrival_Mode]
      ,[AE_Att_Cat]
      ,[AE_Att_Disp]
      ,[AE_Incident_Loc_Type]
      ,[AE_Patient_Group]
      ,[Ref_Source]
      ,[AE_Dept_Type]
      ,[Arrival_Date]
      ,[Arrival_Time]
      ,[Age_at_CDS_Activity_Date]
      ,[Overseas_Visitor_Class_At_Activity_Date]
      ,[Initial_Assmt_Date]
      ,[Initial_Assmt_Time]
      ,[Date_Seen_for_Treatment]
      ,[Time_Seen_for_Treatment]
      ,[Att_Conclusion_Date]
      ,[Att_Conclusion_Time]
      ,[Att_Departure_Date]
      ,[AE_Departure_Time]
      ,[Ambulance_Incident_Number]
      ,[Org_Code_Conveying_Ambulance_Trust]
      ,[Comm_Serial_No]
      ,[SLA_No]
      ,[Prov_Ref_No]
      ,[Comm_Ref_No]
      ,[Org_Code_Prov]
      ,[Org_Code_Comm]
      ,[AE_Staff_Code]
      ,[ICD_Diag_Scheme]
      ,[ICD_Prim_Diag]
      ,[Present_On_Admission_Indicator]
      ,[ICD_Sec_Diag_1]
      ,[Present_On_Admission_Indicator_1]
      ,[Read_Diag_Scheme]
      ,[Read_Prim_Diag]
      ,[Read_Sec_Diag_1]
      ,[AE_Diag_Scheme]
      ,[AE_Diag_1]
      ,[AE_Diag_2]
      ,[AE_Diag_3]
      ,[AE_Diag_4]
      ,[AE_Diag_5]
      ,[AE_Diag_6]
      ,[AE_Diag_7]
      ,[AE_Diag_8]
      ,[AE_Diag_9]
      ,[AE_Diag_10]
      ,[AE_Diag_11]
      ,[AE_Diag_12]
      ,[AE_Diag_13]
      ,[AE_Diag_14]
      ,[AE_Diag_15]
      ,[AE_Diag_16]
      ,[AE_Diag_17]
      ,[AE_Diag_18]
      ,[AE_Diag_19]
      ,[AE_Diag_20]
      ,[AE_Diag_21]
      ,[AE_Diag_22]
      ,[AE_Diag_23]
      ,[AE_Diag_24]
      ,[AE_Diag_25]
      ,[AE_Diag_26]
      ,[AE_Diag_27]
      ,[AE_Diag_28]
      ,[AE_Diag_29]
      ,[AE_Diag_30]
      ,[AE_Invest_Scheme]
      ,[AE_Invest_1]
      ,[AE_Invest_2]
      ,[AE_Invest_3]
      ,[AE_Invest_4]
      ,[AE_Invest_5]
      ,[AE_Invest_6]
      ,[AE_Invest_7]
      ,[AE_Invest_8]
      ,[AE_Invest_9]
      ,[AE_Invest_10]
      ,[AE_Invest_11]
      ,[AE_Invest_12]
      ,[AE_Invest_13]
      ,[AE_Invest_14]
      ,[AE_Invest_15]
      ,[AE_Invest_16]
      ,[AE_Invest_17]
      ,[AE_Invest_18]
      ,[AE_Invest_19]
      ,[AE_Invest_20]
      ,[AE_Invest_21]
      ,[AE_Invest_22]
      ,[AE_Invest_23]
      ,[AE_Invest_24]
      ,[AE_Invest_25]
      ,[AE_Invest_26]
      ,[AE_Invest_27]
      ,[AE_Invest_28]
      ,[AE_Invest_29]
      ,[AE_Invest_30]
      ,[OPCS_Scheme]
      ,[OPCS_Prim_Proc]
      ,[OPCS_Prim_Proc_Date]
      ,[HCP_Prof_Reg_Issuer]
      ,[HCP_Prof_Reg_Entry_Identifier]
      ,[Anaesthetist_Prof_Reg_Issuer]
      ,[Anaesthetist_Prof_Reg_Identifier]
      ,[OPCS_Proc_2]
      ,[OPCS_Proc_2_Date]
      ,[HCP_Prof_Reg_Issuer_2]
      ,[HCP_Prof_Reg_Entry_Identifier_2]
      ,[Anaesthetist_Prof_Reg_Issuer_2]
      ,[Anaesthetist_Prof_Reg_Identifier_2]
      ,[Read_Proc_Scheme]
      ,[Read_Prim_Proc]
      ,[Read_Prim_Proc_Date]
      ,[Read_Sec_Proc]
      ,[Read_Sec_Proc_Date]
      ,[AE_Proc_Scheme]
      ,[AE_Prim_Proc]
      ,[AE_Proc_1_Date]
      ,[AE_Proc_2]
      ,[AE_Proc_2_Date]
      ,[AE_Proc_3]
      ,[AE_Proc_3_Date]
      ,[AE_Proc_4]
      ,[AE_Proc_4_Date]
      ,[AE_Proc_5]
      ,[AE_Proc_5_Date]
      ,[AE_Proc_6]
      ,[AE_Proc_6_Date]
      ,[AE_Proc_7]
      ,[AE_Proc_7_Date]
      ,[AE_Proc_8]
      ,[AE_Proc_8_Date]
      ,[AE_Proc_9]
      ,[AE_Proc_9_Date]
      ,[AE_Proc_10]
      ,[AE_Proc_10_Date]
      ,[AE_Proc_11]
      ,[AE_Proc_11_Date]
      ,[AE_Proc_12]
      ,[AE_Proc_12_Date]
      ,[AE_Proc_13]
      ,[AE_Proc_13_Date]
      ,[AE_Proc_14]
      ,[AE_Proc_14_Date]
      ,[AE_Proc_15]
      ,[AE_Proc_15_Date]
      ,[AE_Proc_16]
      ,[AE_Proc_16_Date]
      ,[AE_Proc_17]
      ,[AE_Proc_17_Date]
      ,[AE_Proc_18]
      ,[AE_Proc_18_Date]
      ,[AE_Proc_19]
      ,[AE_Proc_19_Date]
      ,[AE_Proc_20]
      ,[AE_Proc_20_Date]
      ,[AE_Proc_21]
      ,[AE_Proc_21_Date]
      ,[AE_Proc_22]
      ,[AE_Proc_22_Date]
      ,[AE_Proc_23]
      ,[AE_Proc_23_Date]
      ,[AE_Proc_24]
      ,[AE_Proc_24_Date]
      ,[AE_Proc_25]
      ,[AE_Proc_25_Date]
      ,[AE_Proc_26]
      ,[AE_Proc_26_Date]
      ,[AE_Proc_27]
      ,[AE_Proc_27_Date]
      ,[AE_Proc_28]
      ,[AE_Proc_28_Date]
      ,[AE_Proc_29]
      ,[AE_Proc_29_Date]
      ,[AE_Proc_30]
      ,[AE_Proc_30_Date]
      ,[Filler_1]
      ,[Filler_2]
      ,[Filler_3]
      ,[Filler_4]
      ,[Filler_5]
      ,[Filler_6]
      ,[Filler_7]
      ,[Filler_8]
      ,[Filler_9]
      ,[Filler_10]
      ,CAST(GETDATE() AS DATE)
      ,(SELECT hashbytes('md5', (SELECT
       [CDS_Unique_ID] 
      ,[AE_Arrival_Mode]
      ,[AE_Att_Cat]
      ,[AE_Att_Disp]
      ,[AE_Incident_Loc_Type]
      ,[AE_Patient_Group]
      ,[Ref_Source]
      ,[AE_Dept_Type]
      ,[Arrival_Date]
      ,[Arrival_Time] 
     ,[Overseas_Visitor_Class_At_Activity_Date]
      ,[Initial_Assmt_Date]
      ,[Initial_Assmt_Time]
      ,[Date_Seen_for_Treatment]
      ,[Time_Seen_for_Treatment]
      ,[Att_Conclusion_Date]
      ,[Att_Conclusion_Time]
      ,[Att_Departure_Date]
      ,[AE_Departure_Time]
      ,[Ambulance_Incident_Number]
      ,[Org_Code_Conveying_Ambulance_Trust]
      ,[Comm_Serial_No]
      ,[SLA_No]
      ,[Prov_Ref_No]
      ,[Comm_Ref_No]
      ,[Org_Code_Prov]
      ,[Org_Code_Comm]
      ,[AE_Staff_Code]
      ,[ICD_Diag_Scheme]
      ,[ICD_Prim_Diag]
      ,[Present_On_Admission_Indicator]
      ,[ICD_Sec_Diag_1]
      ,[Present_On_Admission_Indicator_1]
      --,[Read_Diag_Scheme]
      --,[Read_Prim_Diag]
      --,[Read_Sec_Diag_1]
      ,[AE_Diag_Scheme]
      ,[AE_Diag_1]
      ,[AE_Diag_2]
      ,[AE_Diag_3]
      ,[AE_Diag_4]
      ,[AE_Diag_5]
      ,[AE_Diag_6]
      ,[AE_Diag_7]
      ,[AE_Diag_8]
      ,[AE_Diag_9]
      ,[AE_Diag_10]
      ,[AE_Diag_11]
      ,[AE_Diag_12]
      ,[AE_Diag_13]
      ,[AE_Diag_14]
      ,[AE_Diag_15]
      ,[AE_Diag_16]
      ,[AE_Diag_17]
      ,[AE_Diag_18]
      ,[AE_Diag_19]
      ,[AE_Diag_20]
      --,[AE_Diag_21]
      --,[AE_Diag_22]
      --,[AE_Diag_23]
      --,[AE_Diag_24]
      --,[AE_Diag_25]
      --,[AE_Diag_26]
      --,[AE_Diag_27]
      --,[AE_Diag_28]
      --,[AE_Diag_29]
      --,[AE_Diag_30]
      ,[AE_Invest_Scheme]
      ,[AE_Invest_1]
      ,[AE_Invest_2]
      ,[AE_Invest_3]
      ,[AE_Invest_4]
      ,[AE_Invest_5]
      ,[AE_Invest_6]
      ,[AE_Invest_7]
      ,[AE_Invest_8]
      ,[AE_Invest_9]
      ,[AE_Invest_10]
      ,[AE_Invest_11]
      ,[AE_Invest_12]
      ,[AE_Invest_13]
      ,[AE_Invest_14]
      ,[AE_Invest_15]
      ,[AE_Invest_16]
      ,[AE_Invest_17]
      ,[AE_Invest_18]
      ,[AE_Invest_19]
      ,[AE_Invest_20]
      --,[AE_Invest_21]
      --,[AE_Invest_22]
      --,[AE_Invest_23]
      --,[AE_Invest_24]
      --,[AE_Invest_25]
      --,[AE_Invest_26]
      --,[AE_Invest_27]
      --,[AE_Invest_28]
      --,[AE_Invest_29]
      --,[AE_Invest_30]
      ,[OPCS_Scheme]
      ,[OPCS_Prim_Proc]
      ,[OPCS_Prim_Proc_Date]
      ,[HCP_Prof_Reg_Issuer]
      ,[HCP_Prof_Reg_Entry_Identifier]
      ,[Anaesthetist_Prof_Reg_Issuer]
      ,[Anaesthetist_Prof_Reg_Identifier]
      ,[OPCS_Proc_2]
      ,[OPCS_Proc_2_Date]
      ,[HCP_Prof_Reg_Issuer_2]
      ,[HCP_Prof_Reg_Entry_Identifier_2]
      ,[Anaesthetist_Prof_Reg_Issuer_2]
      ,[Anaesthetist_Prof_Reg_Identifier_2]
      --,[Read_Proc_Scheme]
      --,[Read_Prim_Proc]
      --,[Read_Prim_Proc_Date]
      --,[Read_Sec_Proc]
      --,[Read_Sec_Proc_Date]
      ,[AE_Proc_Scheme]
      ,[AE_Prim_Proc]
      ,[AE_Proc_1_Date]
      ,[AE_Proc_2]
      ,[AE_Proc_2_Date]
      ,[AE_Proc_3]
      ,[AE_Proc_3_Date]
      ,[AE_Proc_4]
      ,[AE_Proc_4_Date]
      ,[AE_Proc_5]
      ,[AE_Proc_5_Date]
      ,[AE_Proc_6]
      ,[AE_Proc_6_Date]
      ,[AE_Proc_7]
      ,[AE_Proc_7_Date]
      ,[AE_Proc_8]
      ,[AE_Proc_8_Date]
      ,[AE_Proc_9]
      ,[AE_Proc_9_Date]
      ,[AE_Proc_10]
      ,[AE_Proc_10_Date]
      ,[AE_Proc_11]
      ,[AE_Proc_11_Date]
      ,[AE_Proc_12]
      ,[AE_Proc_12_Date]
      ,[AE_Proc_13]
      ,[AE_Proc_13_Date]
      ,[AE_Proc_14]
      ,[AE_Proc_14_Date]
      ,[AE_Proc_15]
      ,[AE_Proc_15_Date]
      ,[AE_Proc_16]
      ,[AE_Proc_16_Date]
      ,[AE_Proc_17]
      ,[AE_Proc_17_Date]
      ,[AE_Proc_18]
      ,[AE_Proc_18_Date]
      ,[AE_Proc_19]
      ,[AE_Proc_19_Date]
      ,[AE_Proc_20]
      ,[AE_Proc_20_Date] FOR xml raw)))
      --,[AE_Proc_21]
      --,[AE_Proc_21_Date]
      --,[AE_Proc_22]
      --,[AE_Proc_22_Date]
      --,[AE_Proc_23]
      --,[AE_Proc_23_Date]
      --,[AE_Proc_24]
      --,[AE_Proc_24_Date]
      --,[AE_Proc_25]
      --,[AE_Proc_25_Date]
      --,[AE_Proc_26]
      --,[AE_Proc_26_Date]
      --,[AE_Proc_27]
      --,[AE_Proc_27_Date]
      --,[AE_Proc_28]
      --,[AE_Proc_28_Date]
      --,[AE_Proc_29]
      --,[AE_Proc_29_Date]
      --,[AE_Proc_30]
      --,[AE_Proc_30_Date]  FOR xml raw)))
  FROM [dbo].[extract_cds_full]
  WHERE [Arrival_Date] >= @start_date
  AND [Arrival_Date] <= @end_date



GO


