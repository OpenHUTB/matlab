classdef ReqSetPart < slreq.report.ReportPart



properties 

SetInfo;
AllCustomAttributes;
NumOfFailedReqs;
end 

methods 

function part = ReqSetPart( doc )

part = part@slreq.report.ReportPart( doc, 'SLReqReqSetPart' );
end 


function fill( this )
this.fillTitle(  );
this.fillSummary(  );

if this.ReportOptions.includes.revision
this.fillAttributes(  );
end 
if this.ReportOptions.includes.customAttributes
this.fillCustomAttributes(  );
end 
if this.ReportOptions.includes.implementationStatus
this.fillImplementationStatus(  );
end 

if this.ReportOptions.includes.verificationStatus
this.fillVerificationStatus(  );
end 

if this.ReportOptions.includes.links && this.ReportOptions.includes.changeInformation
this.fillChangeInformation(  );
end 
this.fillRequirements(  );
end 


function fillTitle( reqsetpart )
heading = getString( message( 'Slvnv:slreq:ReportContentReqSetTitle', reqsetpart.SetInfo.name ) );
p = mlreportgen.dom.Paragraph( 'Chapter ', 'SLReqReportChapter' );
chapter = mlreportgen.dom.AutoNumber( 'chapter' );
p.Style = { mlreportgen.dom.CounterInc( 'chapter' ),  ...
mlreportgen.dom.WhiteSpace( 'preserve' ),  ...
mlreportgen.dom.PageBreakBefore( true ) };
append( p, chapter );
append( p, ': ' );
append( p, heading );
append( reqsetpart, p );
end 


function fillSummary( this )

while ( ~strcmp( this.CurrentHoleId, '#dummyend#' ) && ~strcmp( this.CurrentHoleId, '#end#' ) )
switch lower( this.CurrentHoleId )
case 'descriptionname'
str = getString( message( 'Slvnv:slreq:Description' ) );
description = mlreportgen.dom.Text( str, 'SLReqReqSetDescriptionName' );
append( this, description );
case 'descriptionvalue'
text = mlreportgen.dom.Text( this.SetInfo.description, 'SLReqReqSetDescriptionValue' );
text.Style = { mlreportgen.dom.WhiteSpace( 'preserve' ) };
append( this, text );

end 
moveToNextHole( this );
end 

end 


function fillAttributes( this )
attpart = slreq.report.ReqSetAttributesPart( this );
attpart.fill(  );
append( this, attpart );
end 

function fillCustomAttributes( this )
if isempty( this.AllCustomAttributes ) && ~this.ReportOptions.includes.emptySections
return ;
end 
attpart = slreq.report.ReqSetCustomAttributesPart( this );
attpart.fill(  );
append( this, attpart );
end 


function fillRequirements( this )
rootItems = this.SetInfo.children;
if ~isempty( rootItems )
br = mlreportgen.dom.PageBreak(  );
append( this, br );
end 
for rootIdx = 1:length( rootItems )

reqItem = slreq.report.ReqItemPart( this, 2, rootItems( rootIdx ) );
reqItem.fill(  );
append( this, reqItem );
end 
end 

function fillImplementationStatus( this )
impStatus = slreq.report.utils.getReqStatus(  ...
this.SetInfo, 'implementationstatus', true );
if impStatus( 1 ) == 0 && ~this.ReportOptions.includes.emptySections
return 
end 
part = slreq.report.ReqImplementationPart( this, impStatus, 'set' );
part.fill
append( this, part );
end 


function fillChangeInformation( this )
dataReqSet = this.SetInfo;



ctvisitor = slreq.analysis.ChangeTrackingRefreshVisitor(  );
dataReqSet.accept( ctvisitor );
changedReqInfo = dataReqSet.getChildrenWithChangeIssues;
numOfReqs = changedReqInfo.count;
this.NumOfFailedReqs = numOfReqs;
part = slreq.report.ReqChangeInfoPart( this, numOfReqs, 'set' );
part.fill;
append( this, part );
end 

function fillVerificationStatus( this )

verStatus = slreq.report.utils.getReqStatus(  ...
this.SetInfo, 'verificationstatus', true );

if verStatus( 1 ) == 0 && ~this.ReportOptions.includes.emptySections
return 
end 

part = slreq.report.ReqVerificationPart( this, verStatus, 'set' );
part.fill
append( this, part );
end 

end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpgQbiMB.p.
% Please follow local copyright laws when handling this file.

