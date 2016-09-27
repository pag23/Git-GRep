USE [CDS_Mart]
GO

/****** Object:  View [dbo].[extract_cds_full]    Script Date: 09/27/2016 14:03:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[extract_cds_full] AS
/*
SELECT TOP 1000 * FROM [dbo].[extract_cds_full] 
--v24 inc. ICD excl etc
--v25 inc. ICD attendance reason added

*/
WITH ae_out as

(
SELECT  
		'010'  CDS_Type
		,'010'   CDS_Protocol_ID
		,'BRA900' + REPLACE(ae.[identifier],'-','') CDS_Unique_ID
		,'' AS CDS_BULK_Replacement_Group
		,'9' CDS_Update_Type	
		,'' AS CDS_Extract_Date
		,'' AS CDS_Extract_Time
		,CAST(GetDate() AS DATE) CDS_Applicable_Date
		,CAST(GetDate() AS TIME(0)) CDS_Applicable_Time
		--,CAST('20150721' AS DATE) CDS_Report_Period_Start_Date
		,'' AS  CDS_Report_Period_Start_Date		
		--,CAST(GetDate() AS DATE) CDS_Report_Period_End_Date
		,'' AS  CDS_Report_Period_End_Date		
		,CAST(ae.arrival_date AS DATE) CDS_Activity_Date
		,'RA900' AS CDS_Sender_Identity  --'110000050000001'
		,ae.[organisation_code_of_residence] CDS_Prime_Recip
		,CASE 
				WHEN ae.[organisation_code_of_residence] = 'X9800' THEN 'VPP00'
				ELSE ae.purchaser 
		 END AS CDS_Copy_Recip1
		,'' AS CDS_Copy_Recip2
		,'' AS CDS_Copy_Recip3
		,'' AS CDS_Copy_Recip4
		,'' AS CDS_Copy_Recip5
		,'' AS CDS_Copy_Recip6
		,'' AS CDS_Copy_Recip7
		--ae.identifier AS UBRN
		,'' AS UBRN
		,'' AS [Patient_Pathway_ID]
		,'' AS [Org_Code_Pathway_ID]
		,'' AS [RTT_Status]
		,'' AS [RTT_WaitingTimeMeasurement]
		,'' AS [RTT_Start_Date]
		,'' AS [RTT_End_Date]
		,'' AS [Withheld_Identitiy_Reason]  
		,ISNULL(ae.[patient_number],'') [PATID]
		,'RA900' [Org_Code_PATID]--??
		,ISNULL(pat.nn_nhs_number,'') [NHS_Number]
		,ISNULL(pat.trace_status,'') [NHS_Number_Status] --MPI stuff
		--------------------- REMOVED -----------------------------------------------
		--,ISNULL(pat.first_name_1 + ' ' + pat.last_name,'') [Unstructured Patient_Name]
		,'' AS [Unstructured Patient_Name]		
		,ISNULL(pat.title,'')  [Structured PersonTitle] -- to be added
		,ISNULL(pat.first_name_1,'') [Structured PersonGivenName]
		,ISNULL(pat.last_name,'') [Structured PersonFamilyName]
		,'' AS [Structured PersonNameSuffix]
		,'' AS [Structured PersonInititials]
		,'' AS [Unstructured Address]
		,ISNULL(pat.address_1,'') [Structured Address Line 1]
		,ISNULL(pat.address_2,'') [Structured Address Line 2]
		,ISNULL(pat.address_3,'')  [Structured Address Line 3]
		,ISNULL(pat.address_4,'')  [Structured Address Line 4]
		,'' AS   [Structured Address Line 5]
		,ISNULL(pat.postcode,'ZZ99 3WZ')  [Postcode]
		
		,ISNULL(patp.residence_ccg,'') AS [Org_Code_Residence_Responsibility]
		
		,ISNULL(CAST(pat.date_of_birth AS DATE),'') [DOB]
		,ISNULL(CASE 
			WHEN pat.sex = 'M' THEN 1
			WHEN pat.sex = 'F' THEN 2 
		ELSE
			9 
		END,'') AS [Gender]
		,'' AS [Carer_Support_Indicator]
		,ISNULL(pat_eth.national_code,'') [Ethnic_Cat]
		,'' AS [Reg_GP]
		,ISNULL(pat.GP_Practice,'') [Reg_Prac]  
		----end pat -------  
		,ISNULL(ae_site.site,'') [Site_Code_Of_Treatment] -- Local_code needs dual link to site table
		,ISNULL(REPLACE(ae.[identifier],'-',''),'') [AE_Att_No] -- dashes removed----------------->>>>
		--,ISNULL(ae.attendance_number [AE_Att_No]       
		,ISNULL(arr_mod.Arrival_Modes_national,'') [AE_Arrival_Mode]
		--,ISNULL(att_cat.Attendance_Type_national,'') [AE_Att_Cat]  ------------------->>>>>>>>>>>>>
		--CHANGED PAG 15/04/2016 the mapping was lost when Symphony changed
		,ISNULL(ae.[attendance_category],'1') [AE_Att_Cat] 
		,ISNULL(CASE
			WHEN dis_out.national_code = '6' THEN '06'
			ELSE dis_out.national_code END,'') 
		[AE_Att_Disp]		  
		--,ISNULL(dis_out.national_code,'') [AE_Att_Disp]
		--,ISNULL(ae.[location] ,'')--------------remove
		--,ISNULL(ae.[location_notes],'')
		,ISNULL(inc_loc.national_code,91) [AE_Incident_Loc_Type]--Done 'location'     
		----------------- REPLACED ------------------------------------------------
		--,ISNULL(pat_grp.Patient_Groups_national,'') [AE_Patient_Group_old]
		--patient_group_local  '****************************'
		--patient_group_description  
		-----------------------*****************Testing******************************************************************************
		--,att_reason.local_description as patient_group_description
		--,att_reason.download_code
		--, ae.patient_group
		,ISNULL(att_reason.national_code,'80') [AE_Patient_Group]
		
		,ISNULL(ref_src.Source_of_Referral_national,'') [Ref_Source]

		,ISNULL(CASE 
		WHEN ae.[site] = 'ED' THEN '01'
		ELSE '03'
		END,'')	[AE_Dept_Type] -- 

		,ISNULL(CAST(ae.[arrival_date] AS DATE),'') [Arrival_Date]
		,ISNULL(CAST(ae.[arrival_date] AS TIME(0)),'') [Arrival_Time]
		,DATEDIFF(yy, CAST(pat.date_of_birth  AS DATE),CAST(ae.[arrival_date] AS DATE)) AS [Age_at_CDS_Activity_Date]
		--,ISNULL(DATEDIFF(yy, CAST(pat.date_of_birth  AS DATE),CAST(ae.[arrival_date] AS DATE)),'') AS [Age_at_CDS_Activity_Date]		
		,ISNULL(over_st.national_code,'') [Overseas_Visitor_Class_At_Activity_Date] --to be added to ref

		,ISNULL(CAST(ae.[triage_date_time] AS DATE),'') [Initial_Assmt_Date]
		,ISNULL(CAST(ae.[triage_date_time] AS TIME(0)),'') [Initial_Assmt_Time]
		,ISNULL(CAST(ae.[ae_time_seen_for_treatment] AS DATE),'') [Date_Seen_for_Treatment]
		,ISNULL(CAST(ae.[ae_time_seen_for_treatment] AS TIME(0)),'') [Time_Seen_for_Treatment]
		,ISNULL(CAST(ae.[discharge_Date] AS DATE),'') [Att_Conclusion_Date]
		,ISNULL(CAST(ae.[discharge_Date]AS TIME(0)),'') [Att_Conclusion_Time]
		,ISNULL(CAST(ae.[left_department_date] AS DATE),'') [Att_Departure_Date]
		,ISNULL(CAST(ae.[left_department_date]AS TIME(0)),'') [AE_Departure_Time]
		
		
		--,ISNULL(ambulance_call_number,'') AS [Ambulance_Incident_Number] -- TODO!NULL on old feed
		,CASE 
			WHEN ambulance_call_number IS NULL THEN ''
			WHEN ISNUMERIC(ambulance_call_number)=1 AND LEN(ambulance_call_number)=7 THEN ambulance_call_number
			ELSE ''
			END AS 	[Ambulance_Incident_Number]			
		,CASE 
			WHEN ambulance_call_number <> '' THEN 'RYF'
			ELSE ''
			END AS [Org_Code_Conveying_Ambulance_Trust] -- TODO!NULL on old feed
		,'XXXXXX' AS [Comm_Serial_No]
		,'' AS [SLA_No]
		,'' AS [Prov_Ref_No]
		,'9' AS [Comm_Ref_No]
		--,'' AS 
		,ae.provider as [Org_Code_Prov]
		,ae.purchaser [Org_Code_Comm]
		   -- purchaser
		--,patp.remarks [Org_Code_Comm]
		---------------------- ICD -----------------------------------
		,ISNULL(substring(ae.[staff_member],1,3),'') [AE_Staff_Code]
		
		,'' AS [ICD_Diag_Scheme] 
		--,ISNULL(CASE
		--	WHEN ae.[diagnosis_01_icd] IS NOT NULL THEN '02' 
		--	ELSE '' --NULL
		--  END,'') AS [ICD_Diag_Scheme]
		,'' AS [ICD_Prim_Diag] 
		--	WHEN LEN(ae.[diagnosis_01_icd]) = 3 THEN ae.[diagnosis_01_icd]+'X'
		--		ELSE ae.[diagnosis_01_icd]
		--	END	,'') [ICD_Prim_Diag]
		,'' AS [Present_On_Admission_Indicator]
		
		,'' AS [ICD_Sec_Diag_1] 		
		--,ISNULL(CASE
		--	WHEN LEN(ae.[diagnosis_02_icd]) = 3 THEN ae.[diagnosis_02_icd]+'X'
		--		ELSE ae.[diagnosis_02_icd]
		--	END	,'') [ICD_Sec_Diag_1]
		
		,'' AS [Present_On_Admission_Indicator_1]
		,'' AS [Read_Diag_Scheme]
		,'' AS [Read_Prim_Diag]
		,'' AS [Read_Sec_Diag_1]

		,ISNULL(CASE
				WHEN ae.[diagnosis_01_sus] IS NOT NULL THEN '01' 
				ELSE '' --NULL
		  END,'') AS [AE_Diag_Scheme]
		  
		,ISNULL(ae.[diagnosis_01_sus],'') [AE_Diag_1]
		------------------ check if empty -----------------
		,ISNULL(CASE
				WHEN ae.[diagnosis_01_sus] IS NOT NULL THEN ae.[diagnosis_02_sus] 
				ELSE '' --NULL
		  END,'') AS [AE_Diag_2]		  		 	
		--ISNULL(ae.[diagnosis_02_sus],'') [AE_Diag_2]
		,ISNULL(CASE
				WHEN ae.[diagnosis_02_sus] IS NOT NULL THEN ae.[diagnosis_03_sus] 
				ELSE '' --NULL
		  END,'') AS [AE_Diag_3]		  		 	
		--ISNULL(ae.[diagnosis_03_sus],'') [AE_Diag_3]
		,ISNULL(CASE
				WHEN ae.[diagnosis_03_sus] IS NOT NULL THEN ae.[diagnosis_04_sus] 
				ELSE '' --NULL
		  END,'') AS [AE_Diag_4]		  		 	
		--ISNULL(ae.[diagnosis_04_sus],'') [AE_Diag_4]
		,ISNULL(CASE
				WHEN ae.[diagnosis_04_sus] IS NOT NULL THEN ae.[diagnosis_05_sus] 
				ELSE '' --NULL
		  END,'') AS [AE_Diag_5]		  		 	
		--ISNULL(ae.[diagnosis_05_sus],'') [AE_Diag_5]
		,ISNULL(CASE
				WHEN ae.[diagnosis_05_sus] IS NOT NULL THEN ae.[diagnosis_06_sus] 
				ELSE '' --NULL
		  END,'') AS [AE_Diag_6]		  		 	
		--ISNULL(ae.[diagnosis_06_sus],'') [AE_Diag_6]
		,ISNULL(CASE
				WHEN ae.[diagnosis_06_sus] IS NOT NULL THEN ae.[diagnosis_07_sus] 
				ELSE '' --NULL
		  END,'') AS [AE_Diag_7]		  		 	
		--ISNULL(ae.[diagnosis_07_sus],'') [AE_Diag_7]
		,ISNULL(CASE
				WHEN ae.[diagnosis_07_sus] IS NOT NULL THEN ae.[diagnosis_08_sus] 
				ELSE '' --NULL
		  END,'') AS [AE_Diag_8]		  		 	
		--ISNULL(ae.[diagnosis_08_sus],'') [AE_Diag_8]
		,ISNULL(CASE
				WHEN ae.[diagnosis_08_sus] IS NOT NULL THEN ae.[diagnosis_09_sus] 
				ELSE '' --NULL
		  END,'') AS [AE_Diag_9]		  		 	
		--ISNULL(ae.[diagnosis_09_sus],'') [AE_Diag_9]
		,ISNULL(CASE
				WHEN ae.[diagnosis_09_sus] IS NOT NULL THEN ae.[diagnosis_10_sus] 
				ELSE '' --NULL
		  END,'') AS [AE_Diag_10]		  		 	
		--ISNULL(ae.[diagnosis_10_sus],'') [AE_Diag_10]
		,ISNULL(CASE
				WHEN ae.[diagnosis_10_sus] IS NOT NULL THEN ae.[diagnosis_11_sus] 
				ELSE '' --NULL
		  END,'') AS [AE_Diag_11]		  		 	
		--ISNULL(ae.[diagnosis_11_sus],'') [AE_Diag_11]
		,ISNULL(CASE
				WHEN ae.[diagnosis_11_sus] IS NOT NULL THEN ae.[diagnosis_12_sus] 
				ELSE '' --NULL
		  END,'') AS [AE_Diag_12]		  		 	
----------------------------------------------------------------------------------
		--,ISNULL(CASE
		--		WHEN ae.[diagnosis_12_sus] IS NOT NULL THEN ae.[diagnosis_13_sus] 
		--		ELSE '' --NULL
		--  END,'') AS [AE_Diag_13]		  		 	

		--,ISNULL(CASE
		--		WHEN ae.[diagnosis_13_sus] IS NOT NULL THEN ae.[diagnosis_14_sus] 
		--		ELSE '' --NULL
		--  END,'') AS [AE_Diag_14]		  		 	
	
		--,ISNULL(CASE
		--		WHEN ae.[diagnosis_14_sus] IS NOT NULL THEN ae.[diagnosis_15_sus] 
		--		ELSE '' --NULL
		--  END,'') AS [AE_Diag_15]		  		 	

		--,ISNULL(CASE
		--		WHEN ae.[diagnosis_15_sus] IS NOT NULL THEN ae.[diagnosis_16_sus] 
		--		ELSE '' --NULL
		--  END,'') AS [AE_Diag_16]		  		 	

		--,ISNULL(CASE
		--		WHEN ae.[diagnosis_16_sus] IS NOT NULL THEN ae.[diagnosis_17_sus] 
		--		ELSE '' --NULL
		--  END,'') AS [AE_Diag_17]		
		--,ISNULL(CASE
		--		WHEN ae.[diagnosis_17_sus] IS NOT NULL THEN ae.[diagnosis_18_sus] 
		--		ELSE '' --NULL
		--  END,'') AS [AE_Diag_18]		  		 	

		--,ISNULL(CASE
		--		WHEN ae.[diagnosis_18_sus] IS NOT NULL THEN ae.[diagnosis_19_sus] 
		--		ELSE '' --NULL
		--  END,'') AS [AE_Diag_19]		  		 	

		--,ISNULL(CASE
		--		WHEN ae.[diagnosis_19_sus] IS NOT NULL THEN ae.[diagnosis_20_sus] 
		--		ELSE '' --NULL
		--  END,'') AS [AE_Diag_20]		
---------------------------------------------------------------------------------
		,'' AS [AE_Diag_13]
		,'' AS [AE_Diag_14]
		,'' AS [AE_Diag_15]
		,'' AS [AE_Diag_16]
		,'' AS [AE_Diag_17]
		,'' AS [AE_Diag_18]
		,'' AS [AE_Diag_19]
		,'' AS [AE_Diag_20]			    		 	
		,'' AS [AE_Diag_21]
		,'' AS [AE_Diag_22]
		,'' AS [AE_Diag_23]
		,'' AS [AE_Diag_24]
		,'' AS [AE_Diag_25]
		,'' AS [AE_Diag_26]
		,'' AS [AE_Diag_27]
		,'' AS [AE_Diag_28]
		,'' AS [AE_Diag_29]
		,'' AS [AE_Diag_30]		

		--------------------------- investigations ------------------------------               
		,ISNULL(CASE
			WHEN ae.investigation_01 IS NOT NULL THEN '01' 
				ELSE  '' --NULL
		  END,'') AS [AE_Invest_Scheme]
		,ISNULL(ae.investigation_01,'') [AE_Invest_1] --ae.[investigation_01]
		--,inv1.Investigation_description      
		,ISNULL(ae.investigation_02,'') [AE_Invest_2]
		--,inv2.Investigation_description  
		,ISNULL(ae.investigation_03,'') [AE_Invest_3]
		,ISNULL(ae.investigation_04 ,'')[AE_Invest_4]
		,ISNULL(ae.investigation_05,'') [AE_Invest_5]
		,ISNULL(ae.investigation_06 ,'')[AE_Invest_6]
		,ISNULL(ae.investigation_07,'') [AE_Invest_7]
		,ISNULL(ae.investigation_08,'') [AE_Invest_8]
		,ISNULL(ae.investigation_09,'') [AE_Invest_9]
		,ISNULL(ae.investigation_10,'') [AE_Invest_10]
		,ISNULL(ae.investigation_11,'') [AE_Invest_11]
		,ISNULL(ae.investigation_12,'') [AE_Invest_12]   

		,ISNULL(ae.investigation_13,'') [AE_Invest_13]
		,ISNULL(ae.investigation_14,'') [AE_Invest_14]
		,ISNULL(ae.investigation_15 ,'')[AE_Invest_15]
		,ISNULL(ae.investigation_16,'') [AE_Invest_16]
		,ISNULL(ae.investigation_17 ,'')[AE_Invest_17]
		,ISNULL(ae.investigation_18,'') [AE_Invest_18]
		,ISNULL(ae.investigation_19,'') [AE_Invest_19]
		,ISNULL(ae.investigation_20,'') [AE_Invest_20]
		------------------------------------------------------
		,'' AS [AE_Invest_21]
		,'' AS [AE_Invest_22]   
		,'' AS [AE_Invest_23]
		,'' AS [AE_Invest_24]
		,'' AS [AE_Invest_25]
		,'' AS [AE_Invest_26]
		,'' AS [AE_Invest_27]
		,'' AS [AE_Invest_28]
		,'' AS [AE_Invest_29]
		,'' AS [AE_Invest_30]		
		
		
		,'' AS [OPCS_Scheme]
		,'' AS [OPCS_Prim_Proc]
		,'' AS [OPCS_Prim_Proc_Date]
		,'' AS [HCP_Prof_Reg_Issuer]
		,'' AS [HCP_Prof_Reg_Entry_Identifier]
		,'' AS [Anaesthetist_Prof_Reg_Issuer]
		,'' AS [Anaesthetist_Prof_Reg_Identifier]
		,'' AS [OPCS_Proc_2]
		,'' AS [OPCS_Proc_2_Date]
		,'' AS [HCP_Prof_Reg_Issuer_2]
		,'' AS [HCP_Prof_Reg_Entry_Identifier_2]
		,'' AS [Anaesthetist_Prof_Reg_Issuer_2]
		,'' AS [Anaesthetist_Prof_Reg_Identifier_2]
		,'' AS [Read_Proc_Scheme]
		,'' AS [Read_Prim_Proc]
		,'' AS [Read_Prim_Proc_Date]
		,'' AS [Read_Sec_Proc]
		,'' AS [Read_Sec_Proc_Date]

		--, 'treatments' t------------------------------  
		-- ------------->>>>>>>>>   
		--,'>>>>>>>>>'       
		,ISNULL(CASE
			WHEN treatment_01 IS NOT NULL THEN '01' 
				ELSE  '' --NULL
		  END ,'') AS [AE_Proc_Scheme]
		,ISNULL(treatment_01,'') [AE_Prim_Proc]
		
		--,ISNULL(trt1.Treatments_description,'')--???????????????????*********
		,ISNULL(CASE
			WHEN treatment_01 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_01] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_1_Date]
		
		--,ISNULL(treatment_02,'') [AE_Proc_2]
		,CASE		
			WHEN treatment_01 IS NULL THEN ''	
			WHEN treatment_02 IS NOT NULL THEN treatment_02
			ELSE  '' --NULL
			END  [AE_Proc_2]
-------------------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>			
		--,ISNULL(trt2.Treatments_description
		,ISNULL(CASE
			WHEN treatment_02 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_02] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_2_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_02] AS DATE) AS VARCHAR(10)),'') [AE_Proc_2_Date]

		--,ISNULL(treatment_03 ,'') [AE_Proc_3]
		,CASE		
			WHEN treatment_02 IS NULL THEN ''	
			WHEN treatment_03 IS NOT NULL THEN treatment_03
			ELSE  '' --NULL
			END  [AE_Proc_3]
-------------------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>				
		,ISNULL(CASE

			WHEN treatment_03 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_03] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_3_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_03] AS DATE) AS VARCHAR(10)),'')  [AE_Proc_3_Date]
		
		--,ISNULL(treatment_04,'') [AE_Proc_4]
		,CASE		
			WHEN treatment_03 IS NULL THEN ''	
			WHEN treatment_04 IS NOT NULL THEN treatment_04
			ELSE  '' --NULL
			END  [AE_Proc_4]
-------------------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>			
		,ISNULL(CASE
			WHEN treatment_04 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_04] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_4_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_04] AS DATE) AS VARCHAR(10)),'') [AE_Proc_4_Date]
		--,ISNULL(treatment_05,'') [AE_Proc_5]		
		,CASE		
			WHEN treatment_04 IS NULL THEN ''	
			WHEN treatment_05 IS NOT NULL THEN treatment_05
			ELSE  '' --NULL
			END  [AE_Proc_5]
-------------------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>		
		,ISNULL(CASE		
			WHEN treatment_04 IS NULL THEN ''			
			WHEN treatment_05 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_05] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_5_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_05] AS DATE) AS VARCHAR(10)),'') [AE_Proc_5_Date]
		--,ISNULL(treatment_06,'')  [AE_Proc_6]
		,CASE		
			WHEN treatment_05 = '' THEN ''	
			WHEN treatment_06 <> '' THEN treatment_06
			ELSE  '' --NULL
			END  [AE_Proc_6]
-------------------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>			
		,ISNULL(CASE
			WHEN treatment_06 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_06] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_6_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_06] AS DATE) AS VARCHAR(10)),'')  [AE_Proc_6_Date]
		--,ISNULL(treatment_07,'')  [AE_Proc_7]
		,CASE		
			WHEN treatment_06 IS NULL THEN ''	
			WHEN treatment_07 IS NOT NULL THEN treatment_07
			ELSE  '' --NULL
			END  [AE_Proc_7]
-------------------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>			
		,ISNULL(CASE
			WHEN treatment_07 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_07] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_7_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_07] AS DATE) AS VARCHAR(10)),'') [AE_Proc_7_Date]
		--,ISNULL(treatment_08,'') [AE_Proc_8]
		,CASE		
			WHEN treatment_07 IS NULL THEN ''	
			WHEN treatment_08 IS NOT NULL THEN treatment_08
			ELSE  '' --NULL
			END  [AE_Proc_8]
-------------------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>			
		,ISNULL(CASE
			WHEN treatment_08 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_08] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_8_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_08] AS DATE) AS VARCHAR(10)),'') [AE_Proc_8_Date]
		--,ISNULL(treatment_09,'') [AE_Proc_9]
		,CASE		
			WHEN treatment_08 IS NULL THEN ''	
			WHEN treatment_09 IS NOT NULL THEN treatment_09
			ELSE  '' --NULL
			END  [AE_Proc_9]
-------------------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>			
		,ISNULL(CASE
			WHEN treatment_09 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_09] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_9_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_09] AS DATE) AS VARCHAR(10)),'') [AE_Proc_9_Date]
		--,ISNULL(treatment_10,'') [AE_Proc_10]
		,CASE		
			WHEN treatment_09 IS NULL THEN ''	
			WHEN treatment_10 IS NOT NULL THEN treatment_10
			ELSE  '' --NULL
			END  [AE_Proc_10]
-------------------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>			
		,ISNULL(CASE
			WHEN treatment_10 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_10] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_10_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_10] AS DATE) AS VARCHAR(10)),'') [AE_Proc_10_Date]
		,ISNULL(treatment_11,'') [AE_Proc_11]
		,ISNULL(CASE
			WHEN treatment_11 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_11] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_11_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_11] AS DATE) AS VARCHAR(10)),'')  [AE_Proc_11_Date]
		,ISNULL(treatment_12,'') [AE_Proc_12]
		,ISNULL(CASE
			WHEN treatment_12 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_12] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_12_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_12] AS DATE) AS VARCHAR(10)),'')  [AE_Proc_12_Date]      
		,ISNULL(treatment_13,'') [AE_Proc_13]
		,ISNULL(CASE
			WHEN treatment_13 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_13] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_13_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_12] AS DATE) AS VARCHAR(10)),'')  [AE_Proc_13_Date]  
		,ISNULL(treatment_14,'') [AE_Proc_14]
		,ISNULL(CASE
			WHEN treatment_14 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_14] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_14_Date]
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_12] AS DATE) AS VARCHAR(10)),'')  [AE_Proc_14_Date]  
		,ISNULL(treatment_15,'') [AE_Proc_15]
		,ISNULL(CASE
			WHEN treatment_15 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_15] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_15_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_15] AS DATE) AS VARCHAR(10)),'')  [AE_Proc_15_Date]  
		,ISNULL(treatment_16,'') [AE_Proc_16]
		,ISNULL(CASE
			WHEN treatment_16 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_16] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_16_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_16] AS DATE) AS VARCHAR(10)),'')  [AE_Proc_16_Date]  
		,ISNULL(treatment_17,'') [AE_Proc_17]
		,ISNULL(CASE
			WHEN treatment_17 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_17] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_17_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_17] AS DATE) AS VARCHAR(10)),'')  [AE_Proc_17_Date]  
		,ISNULL(treatment_18,'') [AE_Proc_18]
		,ISNULL(CASE
			WHEN treatment_18 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_18] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_18_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_18] AS DATE) AS VARCHAR(10)),'')  [AE_Proc_18_Date]  
		,ISNULL(treatment_19,'') [AE_Proc_19]
		,ISNULL(CASE
			WHEN treatment_19 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_19] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_19_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_19] AS DATE) AS VARCHAR(10)),'')  [AE_Proc_19_Date]  
		,ISNULL(treatment_20,'') [AE_Proc_20]
		,ISNULL(CASE
			WHEN treatment_20 IS NOT NULL THEN CAST(CAST([ae].[treatment_date_time_20] AS DATE) AS VARCHAR(10))
			ELSE  '' --NULL
		  END ,'') AS [AE_Proc_20_Date]		
		--,ISNULL(CAST(CAST([ae].[treatment_date_time_20] AS DATE) AS VARCHAR(10)),'')  [AE_Proc_20_Date]  		
		,'' AS [AE_Proc_21]
		,'' AS [AE_Proc_21_Date]
		,'' AS [AE_Proc_22]
		,'' AS [AE_Proc_22_Date]
		,'' AS [AE_Proc_23]
		,'' AS [AE_Proc_23_Date]
		,'' AS [AE_Proc_24]
		,'' AS [AE_Proc_24_Date]
		,'' AS [AE_Proc_25]
		,'' AS [AE_Proc_25_Date]
		,'' AS [AE_Proc_26]
		,'' AS [AE_Proc_26_Date]
		,'' AS [AE_Proc_27]
		,'' AS [AE_Proc_27_Date]
		,'' AS [AE_Proc_28]
		,'' AS [AE_Proc_28_Date]		
		,'' AS [AE_Proc_29]
		,'' AS [AE_Proc_29_Date]
		,'' AS [AE_Proc_30]
		,'' AS [AE_Proc_30_Date]			
		---------------------------------------------------?????????????
		,'' AS [Filler_1]	
		,'' AS [Filler_2]		
		,'' AS [Filler_3]	
		,'' AS [Filler_4]	
		,'' AS [Filler_5]	
		,'' AS [Filler_6]	
		,'' AS [Filler_7]	
		,'' AS [Filler_8]	
		,'' AS [Filler_9]	
		,'' AS [Filler_10]			
		--select *
  FROM sdhis2.[CORPORATE_DATA].[activity].[ae_symphony] ae
  
  LEFT JOIN sdhis2.[CORPORATE_DATA].[activity].[patient_swift] pat
  ON 
  ae.patient_number = pat.patient_number
  
  LEFT JOIN sdhis2.[CORPORATE_DATA].dim.ethnic_origin pat_eth
  ON 
  pat.ethnic_category_local = pat_eth.download_code
  
  
  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_attendance_category att_cat
  --ON
  --ae.[attendance_category] = att_cat.download_code
  
  LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_arrival_mode arr_mod
  ON
  ae.arrival_mode = arr_mod.download_code 
  LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_discharge_outcome dis_out
  ON
  ae.discharge_outcome = dis_out.download_code 
  ------------------------ ?????????????????????? --------------------  
  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_patient_group pat_grp
  --ON
  --ae.patient_group = pat_grp.download_code 
  
  LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_attendance_reason pat_grp
  ON
  ae.reason = pat_grp.download_code   
    
  LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_source_of_referral ref_src
  ON
  ae.referral_source = ref_src.download_code 

  LEFT JOIN sdhis2.[CORPORATE_DATA].[dim].[symphony_location] inc_loc
  ON
  ae.location = inc_loc.download_code  
  AND inc_loc.national_code IS NOT NULL
  -- changed 08/02/2016 PAG
  LEFT JOIN --select * FROm
  sdhis2.[CORPORATE_DATA].[dim].[symphony_site] ae_site
  ON
  ae.[site] = ae_site.[download_code]
  --AND 
  --(CASE 
		--ae.[site] when 'ED' then 'RA900' 
		--		else 'R1G00' 
		--END ) = ae_site.provider_code
   ----------------->>>>>>   
  LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_overseas_visitor_status over_st
  ON
  ae.[overseas_status] = over_st.download_code
    
  LEFT JOIN sdhis2.[CORPORATE_DATA].activity.patient_purchaser_inview patp
  ON
  ae.patient_number = patp.patient_number
  AND ae.arrival_date  >= patp.valid_from_dt
   AND ae.arrival_date <= patp.valid_to_dt
  LEFT JOIN
  ---This is actually Patient Group 
  --select * from
  sdhis2.[CORPORATE_DATA].[dim].[symphony_attendance_reason] att_reason
  ON
  ae.reason = att_reason.download_code
      
  ----------------investigations ---------------------------
  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_investigation inv1
  --ON
  --ae.investigation_01 = inv1.download_code
  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_investigation inv2
  --ON
  --ae.investigation_02 = inv2.download_code
  
  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_investigation inv3
  --ON
  --ae.investigation_03 = inv3.download_code
  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_investigation inv4
  --ON
  --ae.investigation_04 = inv4.download_code
  
  --  LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_investigation inv5
  --ON
  --ae.investigation_05 = inv5.download_code
  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_investigation inv6
  --ON
  --ae.investigation_06 = inv6.download_code
  --  LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_investigation inv7
  --ON
  --ae.investigation_07 = inv7.download_code
  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_investigation inv8
  --ON
  --ae.investigation_08 = inv8.download_code
  --  LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_investigation inv9
  --ON
  --ae.investigation_09 = inv9.download_code
  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_investigation inv10
  --ON
  --ae.investigation_10 = inv10.download_code 

  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_investigation inv11
  --ON
  --ae.investigation_11 = inv11.download_code
  --  LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_investigation inv12
  --  ON
  --ae.investigation_12 = inv12.download_code
    ----------------treatments ---------------------------
  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_treatment trt1
  --ON
  --ae.treatment_01 = trt1.download_code
  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_treatment trt2
  --ON
  --ae.treatment_02 = trt2.download_code
  
  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_treatment trt3
  --ON
  --ae.treatment_03 = trt3.download_code
  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_treatment trt4
  --ON
  --ae.treatment_04 = trt4.download_code
  
  --  LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_treatment trt5
  --ON
  --ae.treatment_05 = trt5.download_code
  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_treatment trt6
  --ON
  --ae.treatment_06 = trt6.download_code
  --  LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_treatment trt7
  --ON
  --ae.treatment_07 = trt7.download_code
  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_treatment trt8
  --ON
  --ae.treatment_08 = trt8.download_code
  --  LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_treatment trt9
  --ON
  --ae.treatment_09 = trt9.download_code
  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_treatment trt10
  --ON
  --ae.treatment_10 = trt10.download_code 

  --LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_treatment trt11
  --ON
  --ae.treatment_11 = trt11.download_code
  --  LEFT JOIN sdhis2.[CORPORATE_DATA].dim.symphony_treatment trt12
  --  ON
  --ae.treatment_12 = trt12.download_code		
  WHERE ae.booking_date IS NULL  
  ----------AND CAST(ae.[arrival_date] AS DATE) < CAST('201500811' AS DATE)
  
  
)
   SELECT TOP 100 PERCENT * -- AE_Invest_1 , COUNT(*) DISTINCT 
   FROM ae_out 
   where Org_Code_Comm <> '' --IS NOT NULL
   AND CDS_Activity_Date <> '' --IS NOT NULL
   AND [PATID] <> '' --IS NOT NULL 
   AND DOB <> '' --IS NOT NULL
   --AND [PATID] = 'A1042101' --'A338271'
   --   AND ICD_Prim_Diag = ''
   --AND AE_Diag_1 <> ''
ORDER BY CDS_Unique_ID
   






GO


