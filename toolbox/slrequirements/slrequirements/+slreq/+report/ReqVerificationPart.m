classdef ReqVerificationPart < slreq.report.ReportPart

properties 
VerStatus;
StyleStruct;
end 

methods 

function part = ReqVerificationPart( p1, verStatus, styleType )
part = part@slreq.report.ReportPart( p1, 'SLReqReqVerificationPart' );
part.VerStatus = verStatus;
if strcmpi( styleType, 'set' )
part.StyleStruct.title = 'SLReqReqSetVerificationTitle';
part.StyleStruct.totalName = 'SLReqReqSetVeriTotalName';
part.StyleStruct.totalValue = 'SLReqReqSetVeriTotalValue';
part.StyleStruct.passedName = 'SLReqReqSetVeriPassedName';
part.StyleStruct.passedValue = 'SLReqReqSetVeriPassedValue';
part.StyleStruct.justifiedName = 'SLReqReqSetVeriJustifiedName';
part.StyleStruct.justifiedValue = 'SLReqReqSetVeriJustifiedValue';
part.StyleStruct.failedName = 'SLReqReqSetVeriFailedName';
part.StyleStruct.failedValue = 'SLReqReqSetVeriFailedValue';
part.StyleStruct.unexecutedName = 'SLReqReqSetVeriUnexecutedName';
part.StyleStruct.unexecutedValue = 'SLReqReqSetVeriUnexecutedValue';
part.StyleStruct.noTestName = 'SLReqReqSetVeriNoTestName';
part.StyleStruct.noTestValue = 'SLReqReqSetVeriNoTestValue';
else 
part.StyleStruct.title = 'SLReqReqVerificationTitle';
part.StyleStruct.totalName = 'SLReqReqVeriTotalName';
part.StyleStruct.totalValue = 'SLReqReqVeriTotalValue';
part.StyleStruct.passedName = 'SLReqReqVeriPassedName';
part.StyleStruct.passedValue = 'SLReqReqVeriPassedValue';
part.StyleStruct.justifiedName = 'SLReqReqVeriJustifiedName';
part.StyleStruct.justifiedValue = 'SLReqReqVeriJustifiedValue';
part.StyleStruct.failedName = 'SLReqReqVeriFailedName';
part.StyleStruct.failedValue = 'SLReqReqVeriFailedValue';
part.StyleStruct.unexecutedName = 'SLReqReqVeriUnexecutedName';
part.StyleStruct.unexecutedValue = 'SLReqReqVeriUnexecutedValue';
part.StyleStruct.noTestName = 'SLReqReqVeriNoTestName';
part.StyleStruct.noTestValue = 'SLReqReqVeriNoTestValue';
end 
end 


function fill( this )
verStatus = this.VerStatus;
while ( ~strcmp( this.CurrentHoleId, '#dummyend#' ) && ~strcmp( this.CurrentHoleId, '#end#' ) )
text = [  ];
switch lower( this.CurrentHoleId )
case 'verificationstatusname'
str = getString( message( 'Slvnv:slreq:VerificationStatus' ) );
text = mlreportgen.dom.Text( str, this.StyleStruct.title );
case 'totalname'
str = getString( message( 'Slvnv:slreq:Total' ) );
text = mlreportgen.dom.Text( str, this.StyleStruct.totalName );
case 'totalvalue'
text = mlreportgen.dom.Text( verStatus( 1 ), this.StyleStruct.totalValue );
case 'passedname'
str = getString( message( 'Slvnv:slreq:Passed' ) );
text = mlreportgen.dom.Text( str, this.StyleStruct.passedName );
case 'passedvalue'
text = mlreportgen.dom.Text( verStatus( 2 ), this.StyleStruct.passedValue );
case 'justifiedname'
str = getString( message( 'Slvnv:slreq:Justified' ) );
text = mlreportgen.dom.Text( str, this.StyleStruct.justifiedName );
case 'justifiedvalue'
text = mlreportgen.dom.Text( verStatus( 3 ), this.StyleStruct.justifiedValue );
case 'failedname'
str = getString( message( 'Slvnv:slreq:Failed' ) );
text = mlreportgen.dom.Text( str, this.StyleStruct.failedName );
case 'failedvalue'
text = mlreportgen.dom.Text( verStatus( 4 ), this.StyleStruct.failedValue );
case 'unexecutedname'
str = getString( message( 'Slvnv:slreq:Unexecuted' ) );
text = mlreportgen.dom.Text( str, this.StyleStruct.unexecutedName );
case 'unexecutedvalue'
text = mlreportgen.dom.Text( verStatus( 5 ), this.StyleStruct.unexecutedValue );
case 'notestname'
str = getString( message( 'Slvnv:slreq:None' ) );
text = mlreportgen.dom.Text( str, this.StyleStruct.noTestName );
case 'notestvalue'
text = mlreportgen.dom.Text( verStatus( 6 ), this.StyleStruct.noTestValue );
end 
if ~isempty( text )
append( this, text );
end 
moveToNextHole( this );
end 
end 
end 
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpXKewRG.p.
% Please follow local copyright laws when handling this file.

