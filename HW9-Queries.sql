--Question 1
SELECT 
			PO.Ponumber 'PO Number',
			Format(po.POdatePlaced, 'MMM dd,yyyy') 'PO Date',
			vendor.Name 'Vendor Name',
			ISNULL(emp.EmpLastName + ' ' + Substring(emp.EmpFirstName,1,1) + '.','No Buyer on File') 'Employee Buyer',
			ISNULL(mgr.EmpLastName + ' ' + Substring(mgr.EmpFirstName,1,1) + '.','No Manager on File') 'Manager of Buyer',
			poline.ProductID 'Product ID',
			pro.Description 'Product Description',
			Format(poline.DateNeeded, 'MMM dd,yyyy') 'Date Needed',
			poline.Price 'Product Price',
			poline.QtyOrdered 'Quantity Ordered',
			vpo.TotalQtyReceived 'Quantity Received',
			ISNULL(vpo.TotalRemaning,poline.QtyOrdered) 'Quantity Remaining',
			vpo.ReceivingStatus 'Receiving Status'

		

from tblPurchaseOrderLine poline 
LEFT OUTER JOIN tblPurchaseOrder po
ON poline.PONumber=po.PoNumber
LEFT OUTER JOIN tblVendor vendor
ON vendor.VendorID=po.VendorID
LEFT OUTER JOIN	tblEmployee emp
ON	po.BuyerEmpID=emp.EmpID
LEFT OUTER JOIN	tblEmployee mgr
ON	emp.EmpMgrID=mgr.EmpID
LEFT OUTER JOIN tblProduct pro
ON pro.ProductID=poline.ProductID
LEFT OUTER JOIN VW_PODateNeeded vpo
ON vpo.PoNumber=poline.PONumber
AND vpo.ProductID=poline.ProductID
AND vpo.DateNeeded=poline.DateNeeded

--Question 2

SELECT DISTINCT
			PO.Ponumber 'PO Number',
			Format(po.POdatePlaced, 'MMM dd,yyyy') 'PO Date',
			Format(po.PODateNeeded, 'MMM dd,yyyy') 'PO Date Needed',
			vendor.Name 'Vendor Name'
			
from tblPurchaseOrderLine poline 
LEFT OUTER JOIN tblPurchaseOrder po
ON poline.PONumber=po.PoNumber
LEFT OUTER JOIN tblVendor vendor
ON vendor.VendorID=po.VendorID
LEFT OUTER JOIN VW_PODateNeeded vpo
ON vpo.PoNumber=poline.PONumber
AND vpo.ProductID=poline.ProductID
AND vpo.DateNeeded=poline.DateNeeded

Where po.PoNumber NOT IN (Select incord.PONumber from VW_Incomplete_Order incord)


--Question 3

Select Distinct 
incord.PONumber,
incord.PODate,
incord.POdateneeded,
vendor.Name


from VW_Incomplete_Order incord
INNER JOIN tblPurchaseOrder po
ON incord.PONumber=po.PoNumber
INNER JOIN tblVendor vendor
ON po.VendorID=vendor.VendorID

--Question 4 

select

cpo.PONumber,
cpo.PoDatePlaced,
cpo.PODateNeeded,
cpo.VendorName,
cpo.ProductID,
cpo.FirstDateReceived,
cpo.LastDateReceived,
cpo.QuantityOrdered,
vpo.TotalQtyReceived

from VW_ClosedOrder cpo
INNER JOIN VW_PODateNeeded vpo
ON cpo.PONumber=vpo.PoNumber
AND cpo.ProductID=vpo.ProductID	


--Question 5
select 
poline.ProductID,
hist.ProdDescription,
hist.RecentHistPurPrice,
poline.Price 'CurrentPrice',
poline.PONumber,
vendor.Name 'VendorName'


from tblPurchaseOrderLine poline
inner JOIN VW_HistoricalPrice hist
ON hist.ProdID=poline.ProductID
INNER JOIN tblPurchaseOrder po
ON poline.PONumber=po.PoNumber
Inner join tblVendor vendor
ON po.VendorID=vendor.VendorID
Group by 

poline.ProductID,
hist.ProdDescription,
hist.RecentHistPurPrice,
poline.Price,
poline.PoNumber,
vendor.Name
Having ISNULL((poline.Price - hist.RecentHistPurPrice) / hist.RecentHistPurPrice * 100,0) > 20



--Question 6


 Select
			vendor.name 'VendorName', 
			po.VendorID 'VendorID',
			Count(vendor.Name) 'CountofVendor',
			vendor.Email
from		VW_PODateNeeded vpo --Used for the overshipment information
inner JOIN	tblPurchaseOrder po 
ON			vpo.PoNumber=po.PONumber
Inner JOIN	tblVendor vendor 
ON			vendor.VendorID=po.VendorID	

Where		ReceivingStatus LIKE 'Over Shipment'
Group By	po.VendorID,
			vendor.Name,
			vendor.Email
Having		Count(vendor.Name) = (	select 
											Max(vc.CountofVendor)
									from	VW_VendorCount vc	)			
				

--Question 7 

With cteMax as (
Select

emp.EmpID 'EmpID',
emp.EmpLastName + ' ' + SUbstring(emp.EmpFirstName,1,1) + '.' 'EmployeeName',
emp.EmpEmail 'EmpEmail',
emp.EmpMgrID 'EmpMgrID',
mgr.EmpFirstName + ' ' + SUBSTRING(mgr.Empfirstname,1,1) + '.' 'Managers Name',
mgr.EmpEmail 'mgrEmail',
SUM(rec.QtyReceived) 'SunQtyReceived'


from tblReceiver rec
Left outer join tblCondition con
ON rec.ConditionID=con.ConditionID
Left Outer JOIN tblEmployee emp 
ON rec.ReceiveEmpID=emp.EmpID
INNER JOIN	tblEmployee mgr
ON	emp.EmpMgrID=mgr.EmpID

where con.Description LIKE '%damage%'

Group By 

emp.EmpID,
emp.EmpLastName,
emp.EmpFirstName,
emp.EmpEmail,
emp.EmpMgrID,
mgr.EmpFirstName,
mgr.EmpLastName,
mgr.EmpEmail ),


cteMaxval AS
(
select
Max(ctemax.SunQtyReceived) 'Max Quantity'
from cteMax

)

select 

cteMax.EmpID,
ctemax.EmployeeName,
ctemax.EmpEmail,
ctemax.EmpMgrID,
ctemax.[Managers Name],
ctemax.mgrEmail,
cteMaxval.[Max Quantity]

 from cteMax INNER JOIN cteMaxval ON ctemax.SunQtyReceived=cteMaxval.[Max Quantity]
 where ctemax.SunQtyReceived = cteMaxval.[Max Quantity]


--Question 8 


select 

prod.ProductID,
prod.Description 'Product Description',
prtype.Description 'Product Type Description',
qpo.QtyOrdered 'Total Quantity Ordered',
ISNULL(cmmp.CurrMostExpensivePrice,0) 'Current Most Expensive Price',
ISNULL(cmmp.CurrLeastExpensicePrice,0) 'Current Least Expensive Price',
ISNULL(cmmp.CurrAVGPrice,0) 'Current Average Price',
ISNULL(mmp.MaxPrice,0) 'Past Most Expensive Price',
ISNULL(mmp.MinPrice,0) 'Past Least Expensive Price',
ISNULL(mmp.AVGProdPrice,0) 'Past Average Price',
ISNULL(histp.MostRecentPurchaseDate, 'No Previous Purchase') 'Most Recent Purchase Date',
ISNULL(histp.RecentHistPurPrice,0) 'Most Recent Purchase Price'



from tblProduct prod 
INNER JOIN tblProductType prtype
ON prod.ProductTypeID=prtype.ProductTypeID
Left Outer JOIN VW_MinMaxAvgPrice mmp
ON prod.ProductID=mmp.ProductID
Inner JOIn VW_HistoricalPrice histp
ON prod.ProductID=histp.ProdID
LEFT OUTER JOIN VW_QtyOrdered_PoLine qpo
ON prod.ProductID=qpo.ProductID
LEFT OUTER JOIN VW_currMaxMinAvgPrice cmmp
ON prod.ProductID=cmmp.ProductID

--Question 9 


With cteMaxPast AS (
	select  
			ProductID,
			Max(Price) 'Most Recent Past Purchase'
			from tblPurchaseOrderHistory

	Group By ProductID ),

cteMaxPercent as (
Select
poline.ProductID ' ProductID',
prod.Description 'ProductDescription',
poline.PONumber 'PONumber',
po.PoDatePlaced 'DOP',
vendor.Name 'VendorName',
cmmp.CurrMostExpensivePrice 'CurrMostExPrice',
ISNull(cteMaxPast.[Most Recent Past Purchase],0) 'MoRecPurPrice',
IsNull(cmmp.CurrMostExpensivePrice - cteMaxPast.[Most Recent Past Purchase],0) 'PriceDiff',
ISNull((cmmp.CurrMostExpensivePrice- cteMaxPast.[Most Recent Past Purchase]) / cteMaxPast.[Most Recent Past Purchase],0) 'Percentage'

from tblPurchaseOrderLine poline
Left outer JOIN tblProduct prod
ON poline.ProductID=prod.ProductID
Left Outer JOIN cteMaxPast
ON poline.ProductID=cteMaxPast.ProductID
Left Outer JOIN tblPurchaseOrder po 
ON poline.PONumber=po.PoNumber
Left Outer Join tblVendor vendor
ON po.VendorID=vendor.VendorID
LEFT outer JOIN VW_currMaxMinAvgPrice cmmp
on poline.ProductID=cmmp.ProductID


Group by 
poline.ProductID,
cteMaxPast.[Most Recent Past Purchase],
cmmp.CurrMostExpensivePrice,
poline.ProductID,
prod.Description,
poline.PONumber,
po.PoDatePlaced,
vendor.Name

)

select 

cm.[ ProductID] 'Product ID',
cm.ProductDescription 'Product Description',
cm.PONumber 'PO Number',
cm.Dop 'Date of Purchase',
cm.VendorName 'Vendor Name',
cm.CurrMostExPrice 'Current Most Expensive Price',
cm.MoRecPurPrice 'Most Recent Past Purchase Price',
cm.PriceDiff 'Price Difference',
Format(Max(Percentage), 'P2') as Percentage

from cteMaxPercent cm

 Group by 
cm.[ ProductID],
cm.ProductDescription,
cm.PONumber,
cm.Dop,
cm.VendorName,
cm.CurrMostExPrice,
cm.MoRecPurPrice,
cm.PriceDiff
Having Max(Percentage) = (Select Max(Percentage) from cteMaxPercent)



--Question 10 

--Current Total Ordered

With cteCurrentTotalOrdered as (
Select

poline.ProductID 'ctProductID',
sum(poline.QtyOrdered) 'TQtryOrdered'

from tblPurchaseOrderLine poline 

where poline.DateNeeded <= GetDate()
Group by 
poline.ProductID
 ),

--Current Received on time
cteCurrentRecdOnTime AS (
Select 


rec.ProductID 'crProductID',
Case	when SUM(Rec.QtyReceived) > poline.QtyOrdered Then poline.QtyOrdered 
		when SUM(Rec.QtyReceived) <= poline.QtyOrdered Then SUM(rec.QtyReceived)
END		'QtyReceived'

from tblReceiver rec
LEFT OUTER JOIN tblPurchaseOrderLine poline
on rec.PONumber=poline.PONumber
AND rec.ProductID=poline.ProductID
AND rec.DateNeeded=poline.DateNeeded

where rec.DateReceived<=poline.Dateneeded
Group by 
rec.ProductID,
poline.QtyOrdered
) ,



--Current Percent on Time 
cteCurrPercentOnTime AS (
Select 
t1.ProductID 'cpProductID',
SUM(t2QtyReceived/t1QtyOrdered) * 100 CurrentPercentOnTime


from (
Select
poline.ProductID,
sum(poline.QtyOrdered) 't1QtyOrdered'

from tblPurchaseOrderLine poline 

where poline.DateNeeded <= GetDate()
Group by 
poline.ProductID
 ) as t1

Left Outer Join (

Select 
rec.ProductID,
Case	when SUM(Rec.QtyReceived) > poline.QtyOrdered Then poline.QtyOrdered 
		when SUM(Rec.QtyReceived) <= poline.QtyOrdered Then SUM(rec.QtyReceived)
END		't2QtyReceived'

from tblReceiver rec
LEFT OUTER JOIN tblPurchaseOrderLine poline
on rec.PONumber=poline.PONumber
AND rec.ProductID=poline.ProductID
AND rec.DateNeeded=poline.DateNeeded

where rec.DateReceived<=poline.Dateneeded
Group by 

rec.ProductID,
poline.QtyOrdered

) t2
on t1.ProductID=t2.ProductID

Group by t1.ProductID ),

--Historical Total Ordered
cteHistTotalOrdered AS (
select 

histp.ProductID 'hproductID',
SUM(histp.Qty) hQty
from tblPurchaseOrderHistory histp

Group by histp.ProductID ),

--Historical Received On Time 
cteHistRecdOnTime AS (
Select 

histp.ProductID 'hrProductID',
SUM(histp.QtyReceivedOntime) hrQtryRecOnTime
from tblPurchaseOrderHistory histp
group by histp.ProductID ),

--Historical Percent On Time 
cteHistPercentOnTime AS (
Select 

t1.t1ProductID 'hpoProductID',
t2QtryRecOnTime/t1Qty *100 'HistoryPercentOnTime' 

From (
select 

histp.ProductID t1ProductID,
SUM(histp.Qty) t1Qty
from tblPurchaseOrderHistory histp

Group by histp.ProductID ) t1
INNER JOIN (
Select 

histp.ProductID t2ProductID,
SUM(histp.QtyReceivedOntime) t2QtryRecOnTime
from tblPurchaseOrderHistory histp
group by histp.ProductID ) t2
ON t1.t1ProductID=t2.t2ProductID ) 

Select 

pro.ProductID,
pro.Description,
ct.TQtryOrdered 'CurrentTotalOrdered',
sum(cr.QtyReceived) 'CurrentReceivedOnTime',
cp.CurrentPercentOnTime,
hp.hQty,
hr.hrQtryRecOnTime,
hpo.HistoryPercentOnTime

from tblProduct pro
Left outer JOIN cteCurrentTotalOrdered ct
ON pro.ProductID=ct.ctProductID
Left outer Join cteCurrentRecdOnTime cr
ON pro.ProductID=cr.crProductID
left outer join cteCurrPercentOnTime cp
ON pro.ProductID=cp.cpProductID
Left outer join cteHistTotalOrdered hp
ON pro.ProductID=hp.hproductID
Left outer join cteHistRecdOnTime hr
ON pro.ProductID=hr.hrProductID
Left Outer Join cteHistPercentOnTime hpo
ON pro.ProductID=hpo.hpoProductID

group by 
pro.ProductID,
pro.Description,
ct.TQtryOrdered,
cp.CurrentPercentOnTime,
hp.hQty,
hr.hrQtryRecOnTime,
hpo.HistoryPercentOnTime
