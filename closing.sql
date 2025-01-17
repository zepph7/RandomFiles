﻿USE [GMS_ERP]
GO
/****** Object:  StoredProcedure [GMSentries].[save_batch_closing_hdr]    Script Date: 14/01/2025 00:27:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [GMSentries].[save_batch_closing_hdr]
(
@batch_id varchar(100)
,@batch_date datetime
,@vehicle_id int
,@branch_id int
,@status_entry varchar(100)
,@created_by varchar(100)
)
AS 
BEGIN
SET NOCOUNT ON 
declare @Details_Status varchar(50)='', @Error_Message varchar(50)=''
--select'Error'+convert(varchar(50),@Details_Status)'Status','Can''t create user Contact IT admin'+convert(varchar(50),@Error_Message)'Message'
IF EXISTS (SELECT 1 FROM [GMSentries].[batch_closing_hdr] WHERE batch_id = @batch_id )
BEGIN
select'Error'+convert(varchar(50),@Details_Status)'Status','stock with this batch id is already closed'+convert(varchar(50),@Error_Message)'Message'
END
BEGIN
INSERT INTO [GMSentries].[batch_closing_hdr]
           ([batch_id]
           ,[batch_date]
           ,[vehicle_id]
           ,[branch_id]
           ,[status_entry]
           ,[created_by]
           ,[created_date])
     VALUES
           (@batch_id 
           ,@batch_date 
           ,@vehicle_id 
           ,@branch_id 
           ,@status_entry 
           ,@created_by 
           ,GETDATE() 
		   )
select 'Success'+convert(varchar(50),@Details_Status)'Status' ,('Batch closing  hdr successfully')'Message'
END
END



GO
ALTER procedure [GMSentries].[save_batch_closing_complete_dtl]
(
@batch_date datetime
,@batch_id varchar(100)
,@product_id int
--,@accessory_id int
,@product_closing_quantinty int
--,@accessories_quantity int
,@total_amount decimal(15,0)
,@created_by varchar(100)
)
AS 
BEGIN
SET NOCOUNT ON 
declare @Details_Status varchar(50)='', @Error_Message varchar(50)='',

--comapare the product quantiny from batch creation
----amount coumparison and fixing (selectinig from batch creation)

--select'Error'+convert(varchar(50),@Details_Status)'Status','Can''t create user Contact IT admin'+convert(varchar(50),@Error_Message)'Message'
if exists (select '10' from [GMSentries].[batch_closing_complete_dtl] where batch_id =@batch_id  and status_entry = 'closed')
begin
select 'Error'+convert(varchar(50),@Details_Status)'Status','This batch is closed please procceed to next batch '+convert(varchar(50),@Error_Message)'Message' 
end
BEGIN
INSERT INTO [GMSentries].[batch_closing_complete_dtl]
           ([batch_date]
           ,[batch_id]
           ,[product_id]
           --,[accessory_id]
           ,[product_closing_quantinty]
           --,[accessories_quantity]
           ,[total_amount]
           ,[status_entry]
           ,[created_by]
           ,[created_date]
)
     VALUES
           (@batch_date 
           ,@batch_id 
           ,@product_id 
           --,@accessory_id 
           ,@product_closing_quantinty 
           --,@accessories_quantity 
           ,@total_amount 
           ,'closed' 
           ,@created_by 
			,getdate())
select 'Success'+convert(varchar(50),@Details_Status)'Status' ,('Batch complete Gas cylider closing   successfully')'Message'
update [GMSentries].[OpeningStock_Cylinder_Gas_Dtl] set quantity = (quantity + @product_closing_quantinty)  
where product_id = @product_id

--update [GMSentries].batch_creation_c0mplete set status_entry  = 'closed'
--where batch_id =@batch_id 
END
END



GO

ALTER procedure [GMSentries].[save_batch_closing_refill_dtl]
(
@batch_date datetime
,@batch_id varchar(100)
,@product_id int
,@product_closing_quantinty int--returning gas cylinders 
,@product_closing_quantinty_empty int
,@total_amount decimal(15,0)
,@created_by varchar(100)
,@created_date datetime
)
AS 
BEGIN
SET NOCOUNT ON 
declare @Details_Status varchar(50)='', @Error_Message varchar(50)=''
--compare the product quantiny from batch creation so that asizidishe na alicho chukua 
----amount comparison and fixing (selecting from batch creation)

--select'Error'+convert(varchar(50),@Details_Status)'Status','Can''t create user Contact IT admin'+convert(varchar(50),@Error_Message)'Message'
if exists (select '10' from [GMSentries].[batch_closing_refill_dtl] where batch_id =@batch_id  and status_entry = 'closed')
begin
select 'Error'+convert(varchar(50),@Details_Status)'Status','This batch is closed please procceed to next batch '+convert(varchar(50),@Error_Message)'Message' 
end
BEGIN
INSERT INTO [GMSentries].[batch_closing_refill_dtl]
           ([batch_date]
           ,[batch_id]
           ,[product_id]
           ,[product_closing_quantinty]
           ,[product_closing_quantinty_empty]--auto calculate from batch returned 
           ,[total_amount]
           ,[status_entry]
           ,[created_by]
           ,[created_date])
     VALUES
           (@batch_date 
           ,@batch_id 
           ,@product_id 
           ,@product_closing_quantinty 
           ,@product_closing_quantinty_empty 
           ,@total_amount 
           ,'closed' 
           ,@created_by 
           ,getdate() 
)
select 'Success'+convert(varchar(50),@Details_Status)'Status' ,('Batch refill closing   successfully')'Message'
update GMSentries.OpeningStock_refill_Dtl set quantity = (quantity + @product_closing_quantinty)  
where product_id = @product_id
--need to amend according to front end needs
update GMSentries.OpeningStock_refill_Dtl set quantity = (quantity + @product_closing_quantinty_empty)  
where product_id = @product_id
END
END




GO
ALTER procedure [GMSentries].[save_batch_closing_accessories_dtl]
(
@batch_date datetime
,@batch_id varchar(100)
,@product_id int
,@product_closing_quantinty int
,@total_amount decimal(15,0)
,@status_entry varchar(100)
,@created_by varchar(100)

)
AS 
BEGIN
SET NOCOUNT ON 
declare @Details_Status varchar(50)='', @Error_Message varchar(50)=''
--compare the product quantiny from batch creation so that asizidishe na alicho chukua 
--compare for complete and both alternative
----amount comparison and fixing (selecting from batch creation)

--select'Error'+convert(varchar(50),@Details_Status)'Status','Can''t create user Contact IT admin'+convert(varchar(50),@Error_Message)'Message'
if exists (select '10' from [GMSentries].[batch_closing_accessories_dtl] where batch_id =@batch_id  and status_entry = 'closed')
begin
select 'Error'+convert(varchar(50),@Details_Status)'Status','This batch is closed please procceed to next batch '+convert(varchar(50),@Error_Message)'Message' 
end
BEGIN
INSERT INTO [GMSentries].[batch_closing_accessories_dtl]
           ([batch_date]
           ,[batch_id]
           ,[product_id]
		   --should add a column for complete accesories
           ,[product_closing_quantinty]
           ,[total_amount]
           ,[status_entry]
           ,[created_by]
           ,[created_date]
)
     VALUES
           (@batch_date 
           ,@batch_id 
           ,@product_id 
           ,@product_closing_quantinty 
           ,@total_amount 
           ,@status_entry 
           ,@created_by 
           ,getdate() 
)
select 'Success'+convert(varchar(50),@Details_Status)'Status' ,('Batch accessories closing   successfully')'Message'
update GMSentries.OpeningStock_Accessories_Dtl set quantity = (quantity + @product_closing_quantinty)  
where accessory_id = @product_id
END
END


