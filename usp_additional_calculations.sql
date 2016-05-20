USE [nhs_inview_stage]
GO

/****** Object:  StoredProcedure [dbo].[usp_additional_calculations]    Script Date: 05/17/2016 09:23:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








ALTER procedure [dbo].[usp_additional_calculations] @module varchar(256)
as
--exec [dbo].[usp_additional_calculations 'PATH'
begin
if @module = 'PATH'
begin

update stage_pathway
set file_last_modified_date = replace(REPLACE([file_name],'PATHWAYS_',''),'.TXT','')

--select distinct 
--file_last_modified_date
--from stage_pathway
--order by file_last_modified_date desc 

update stage_pathway
set current_record = 0

 
select Pathway_id,pathway_identifier,MAX(file_last_modified_date) dd  into #X
from stage_pathway
group by Pathway_id,pathway_identifier

create index temp1 on #X(Pathway_id)
create index temp2 on #X(pathway_identifier)
create index temp3 on #X(dd)
----------------------------------Set current record -------------------------------
update stage_pathway
set current_record = case when x.dd IS not null then 1 else 0 end 
from
#X x 
where x.Pathway_id = stage_pathway.Pathway_id
and x.pathway_identifier = stage_pathway.pathway_identifier
and x.dd = stage_pathway.file_last_modified_date

 

update dbo.stage_pathway
set stage_calculated_sequence_number = null

 
--Removed 20120915 PAG
--select Pathway_id pid,Pathway_Identifier pii,rownum, ROW_NUMBER() over(partition by Pathway_id,Pathway_Identifier order by rtt_start,rownum asc) cc 
--into #Y
--from stage_pathway 
--where current_record = 1

--create index Y_rownum on #Y(rownum)

--update stage_pathway
--set stage_calculated_sequence_number = x.cc
--from
--#Y x 
--where 
--x.rownum = stage_pathway.rownum
--and current_record = 1

--drop table #Y

--Added 20120915 PAG to update sequence from the pathway_sequence field extracted from IHCS
--select top 1000 * from dbo.stage_pathway
update dbo.stage_pathway
set stage_calculated_sequence_number = pathway_sequence
where stage_calculated_sequence_number is null

-----------------add stage_calculated_clock_no -------------------------------

update dbo.stage_pathway
set stage_calculated_clock_no = null

select Pathway_id pid,Pathway_Identifier pii,rtt_start,rtt_end, ROW_NUMBER() over(partition by Pathway_id,Pathway_Identifier 
order by rtt_start asc) cc 
into #Z
from (select distinct Pathway_id,Pathway_Identifier,rtt_start,rtt_end 
from  stage_pathway where current_record = 1) stage_pathway
 

create index Z_pid on #Z(pid)
create index Z_pii on #Z(pii)
create index Z_rtt_start on #Z(rtt_start)
create index Z_rtt_end on #Z(rtt_end)
 


update stage_pathway
set stage_calculated_clock_no = x.cc
from
#Z x 
where 
x.pid = stage_pathway.Pathway_id and
x.pii = stage_pathway.Pathway_Identifier and
isnull(x.rtt_start,'19000101') = isnull(stage_pathway.rtt_start,'19000101') and
isnull(x.rtt_end,'19000101') = isnull(stage_pathway.rtt_end,'19000101')  
and current_record = 1

 

 drop table #Z
 
end
-- PAG:03/03/2010 Don't think this does anything?????????????????? Delete?
-- PAG:25/09/2013 Removed 
--if @module = 'Obstetrics'
--begin
--delete stage_obstetrics where disnop is null
--end

end

 


 





GO


