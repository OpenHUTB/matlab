classdef TraceabilityTablePart < slreq.report.ReportPart










































properties ( Access = public )
AllReqSets;
TableMap;
TableMapOrderedKeys = {  };
SelectedLinksTypes = {  };
GroupTablesBy = '';
end 

properties ( Access = private )
TableMapKeyDelimiter = "/";
end 

methods 
function part = TraceabilityTablePart( doc )
part = part@slreq.report.ReportPart( doc, 'SLReqTraceabilityTablePart' );
part.GroupTablesBy = doc.ReportOptions.includes.groupTraceabilityTablesBy;
part.SelectedLinksTypes = strsplit( doc.ReportOptions.includes.traceabilityTablesLinkTypes, '.' );
part.TableMap = containers.Map(  );
end 
end 

methods 
function fill( this )
this.fillTitle(  );
while ( ~strcmp( this.CurrentHoleId, '#dummyend#' ) && ~strcmp( this.CurrentHoleId, '#end#' ) )
switch lower( this.CurrentHoleId )
case 'header'
this.fillHeader(  );
case 'tablecontent'
this.fillTableContent(  );
end 
moveToNextHole( this );
end 
end 

function setReqSet( this, reqSets )
this.AllReqSets = reqSets;
end 
end 

methods ( Access = public )
function fillTitle( this )
heading = getString( message( 'Slvnv:slreq:TraceabilityTable' ) );
p = mlreportgen.dom.Paragraph( 'Chapter ', 'SLReqReportChapter' );
chapter = mlreportgen.dom.AutoNumber( 'chapter' );
p.Style = { mlreportgen.dom.CounterInc( 'chapter' ),  ...
mlreportgen.dom.WhiteSpace( 'preserve' ),  ...
mlreportgen.dom.PageBreakBefore( true ) };
append( p, chapter );
append( p, ': ' );
append( p, heading );
append( this, p );
end 

function fillTableContent( this )
import mlreportgen.dom.*;
if isempty( this.AllReqSets )
error( "Not enough number of ReqSets" );
end 

this.preprocessReqSetsForTables(  );



for i = 1:numel( this.TableMapOrderedKeys )
table = Table(  );


table.Border = 'single';
table.ColSep = 'single';
table.RowSep = 'single';

tableMapKey = char( this.TableMapOrderedKeys{ i } );
tableData = this.TableMap( tableMapKey );


row = TableRow(  );



if strcmp( this.GroupTablesBy, getString( message( 'Slvnv:slreq:ReportOPTGUIGroupTraceabilityTablesByReqSets' ) ) )
if tableData.outlinks
append( row, TableEntry( strcat( tableData.srcReqSetName, ' ID' ) ) );
append( row, TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableHeaderSourceRequirementSummary' ) ) ) );
append( row, TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableHeaderLinkTypeName' ) ) ) );
append( row, TableEntry( strcat( tableData.dstReqSetName, ' ID' ) ) );
append( row, TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableHeaderDestinationRequirementSummary' ) ) ) );
append( table, row );
else 
append( row, TableEntry( strcat( tableData.dstReqSetName, ' ID' ) ) );
append( row, TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableHeaderDestinationRequirementSummary' ) ) ) );
append( row, TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableHeaderLinkTypeName' ) ) ) );
append( row, TableEntry( strcat( tableData.srcReqSetName, ' ID' ) ) );
append( row, TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableHeaderSourceRequirementSummary' ) ) ) );
append( table, row );
end 
else 
if tableData.outlinks
append( row, TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableHeaderSourceRequirementID' ) ) ) );
append( row, TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableHeaderSourceRequirementSummary' ) ) ) );
append( row, TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableHeaderLinkTypeName' ) ) ) );
append( row, TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableHeaderDestinationRequirementID' ) ) ) );
append( row, TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableHeaderDestinationRequirementSummary' ) ) ) );
append( table, row );
else 
append( row, TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableHeaderDestinationRequirementID' ) ) ) );
append( row, TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableHeaderDestinationRequirementSummary' ) ) ) );
append( row, TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableHeaderLinkTypeName' ) ) ) );
append( row, TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableHeaderSourceRequirementID' ) ) ) );
append( row, TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableHeaderSourceRequirementSummary' ) ) ) );
append( table, row );
end 
end 


for j = 1:size( tableData.srcReqs, 2 )
srcReq = tableData.srcReqs( j );
dstReqs = tableData.dstReqsMap( srcReq.SID );
numDstReqs = size( dstReqs, 2 );
if numDstReqs == 0
srcRowSpan = 1;
else 
srcRowSpan = numDstReqs;
end 


row = TableRow;
te = TableEntry( srcReq.reqSet.Name + "_" + srcReq.SID );

te.RowSpan = srcRowSpan;
append( row, te );

te = TableEntry( srcReq.Summary );
te.RowSpan = srcRowSpan;
append( row, te );

if numDstReqs == 0


te = TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableNotAvailable' ) ) );
te.RowSpan = 1;
append( row, te );

te = TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableNotAvailable' ) ) );
te.RowSpan = 1;
append( row, te );

te = TableEntry( getString( message( 'Slvnv:slreq:TraceabilityTableNotAvailable' ) ) );
te.RowSpan = 1;
append( row, te );
append( table, row );
else 

dstReq = dstReqs( 1 );
te = TableEntry( dstReq.linkTypeName );
te.RowSpan = 1;
append( row, te );

te = TableEntry( dstReq.requirement.reqSet.Name + "_" + dstReq.requirement.SID );
te.RowSpan = 1;
append( row, te );

te = TableEntry( dstReq.requirement.Summary );
te.RowSpan = 1;
append( row, te );
append( table, row );


for k = 2:numDstReqs
row = TableRow;
dstReq = dstReqs( k );

te = TableEntry( dstReq.linkTypeName );
te.RowSpan = 1;
append( row, te );

te = TableEntry( dstReq.requirement.reqSet.Name + "_" + dstReq.requirement.SID );
te.RowSpan = 1;
append( row, te );

te = TableEntry( dstReq.requirement.Summary );
te.RowSpan = 1;
append( row, te );
append( table, row );
end 
end 
end 


append( this, table );


lb = mlreportgen.dom.LineBreak;
append( this, lb );
end 
end 
end 

methods ( Access = public )
function preprocessTableDataByReqSets( this )

for i = 1:numel( this.AllReqSets )
dataReqSet = this.AllReqSets( i );
reqSet = slreq.utils.dataToApiObject( dataReqSet );

reqs = reqSet.children;


reverseOutLinkedReqsMap = containers.Map( 'KeyType', 'int32', 'ValueType', 'any' );
reverseOutLinkedReqsMapKeysReqs = slreq.Requirement.empty;
for j = 1:numel( reqs )
curReq = reqs( j );
curReqSid = curReq.SID;
reqOutLinks = curReq.outLinks;
numOfOutLinkedReqs = 0;
for k = 1:numel( reqOutLinks )



if isempty( reqOutLinks( k ).destination(  ) )
continue ;
end 

newDstReq = slreq.structToObj( reqOutLinks( k ).destination(  ) );
newDstReqSetName = newDstReq.reqSet.Name;



if ~strcmp( reqOutLinks( k ).destination(  ).domain, 'linktype_rmi_slreq' ) ||  ...
~this.isLinkTypeSelected( reqOutLinks( k ).Type ) ||  ...
~isa( newDstReq, 'slreq.Requirement' )
continue ;
end 

numOfOutLinkedReqs = numOfOutLinkedReqs + 1;
tableDataMapKey = char( reqSet.Name + this.TableMapKeyDelimiter + newDstReqSetName );

if isKey( this.TableMap, tableDataMapKey )
tableDataMapVal = this.TableMap( tableDataMapKey );
else 
tableDataMapVal.outlinks = true;
tableDataMapVal.srcReqs = slreq.Requirement.empty;
tableDataMapVal.srcReqSetName = reqSet.Name;
tableDataMapVal.dstReqSetName = newDstReqSetName;
tableDataMapVal.dstReqsMap = containers.Map( 'KeyType', 'int32', 'ValueType', 'any' );
this.TableMapOrderedKeys{ end  + 1 } = tableDataMapKey;
end 

if isKey( tableDataMapVal.dstReqsMap, curReqSid )
dstReqs = tableDataMapVal.dstReqsMap( curReqSid );
len = length( dstReqs );
dstReqs( len + 1 ).linkTypeName = slreq.app.LinkTypeManager.getForwardName( reqOutLinks( k ).Type );
dstReqs( len + 1 ).requirement = newDstReq;
tableDataMapVal.dstReqsMap( curReqSid ) = dstReqs;
else 
dstReqs = struct( 'linkTypeName', {  }, 'requirement', {  } );
dstReqs( 1 ).linkTypeName = slreq.app.LinkTypeManager.getForwardName( reqOutLinks( k ).Type );
dstReqs( 1 ).requirement = newDstReq;
tableDataMapVal.dstReqsMap( curReqSid ) = dstReqs;
tableDataMapVal.srcReqs( end  + 1 ) = curReq;
end 
this.TableMap( tableDataMapKey ) = tableDataMapVal;


dstReqSid = newDstReq.SID;
if isKey( reverseOutLinkedReqsMap, dstReqSid )
srcReqs = reverseOutLinkedReqsMap( dstReqSid );
len = length( srcReqs );
srcReqs( len + 1 ).linkTypeName = slreq.app.LinkTypeManager.getBackwardName( reqOutLinks( k ).Type );
srcReqs( len + 1 ).requirement = curReq;
reverseOutLinkedReqsMap( dstReqSid ) = srcReqs;
else 
reverseOutLinkedReqsMapKeysReqs( end  + 1 ) = newDstReq;
srcReqs = struct( 'linkTypeName', {  }, 'requirement', {  } );
srcReqs( 1 ).linkTypeName = slreq.app.LinkTypeManager.getBackwardName( reqOutLinks( k ).Type );
srcReqs( 1 ).requirement = curReq;
reverseOutLinkedReqsMap( dstReqSid ) = srcReqs;
end 
end 


if numOfOutLinkedReqs == 0
tableDataMapKey = char( reqSet.Name + this.TableMapKeyDelimiter + "DerivedReqsAtTail" );
if isKey( this.TableMap, tableDataMapKey )
tableDataMapVal = this.TableMap( tableDataMapKey );
else 
tableDataMapVal.outlinks = true;
tableDataMapVal.srcReqSetName = reqSet.Name;
tableDataMapVal.dstReqSetName = "No Destination ReqSet";
tableDataMapVal.srcReqs = slreq.Requirement.empty;
tableDataMapVal.dstReqsMap = containers.Map( 'KeyType', 'int32', 'ValueType', 'any' );
if ~ismember( tableDataMapKey, this.TableMapOrderedKeys )
this.TableMapOrderedKeys{ end  + 1 } = tableDataMapKey;
end 
end 

dstReqs = struct( 'linkTypeName', {  }, 'requirement', {  } );
tableDataMapVal.dstReqsMap( curReqSid ) = dstReqs;
tableDataMapVal.srcReqs( end  + 1 ) = curReq;
this.TableMap( tableDataMapKey ) = tableDataMapVal;
end 
end 





for j = 1:numel( reverseOutLinkedReqsMapKeysReqs )
curDstReq = reverseOutLinkedReqsMapKeysReqs( j );
srcReqs = reverseOutLinkedReqsMap( curDstReq.SID );

tableDataMapKey = char( curDstReq.reqSet.Name + this.TableMapKeyDelimiter + reqSet.Name );

if isKey( this.TableMap, tableDataMapKey )
tableDataMapVal = this.TableMap( tableDataMapKey );
else 
tableDataMapVal.outlinks = false;
tableDataMapVal.srcReqSetName = reqSet.Name;
tableDataMapVal.dstReqSetName = curDstReq.reqSet.Name;
tableDataMapVal.srcReqs = slreq.Requirement.empty;
tableDataMapVal.dstReqsMap = containers.Map( 'KeyType', 'int32', 'ValueType', 'any' );
this.TableMapOrderedKeys{ end  + 1 } = tableDataMapKey;
end 



tableDataMapVal.srcReqs( end  + 1 ) = curDstReq;
tableDataMapVal.dstReqsMap( curDstReq.SID ) = srcReqs;
this.TableMap( tableDataMapKey ) = tableDataMapVal;
end 
end 
end 

function preprocessTableDataBySrcAndDstReqSets( this )

for i = 1:numel( this.AllReqSets )
dataReqSet = this.AllReqSets( i );
reqSet = slreq.utils.dataToApiObject( dataReqSet );

reqs = reqSet.children;


reverseOutLinkedReqsMap = containers.Map( 'KeyType', 'int32', 'ValueType', 'any' );
reverseOutLinkedReqsMapKeysReqs = slreq.Requirement.empty;
for j = 1:numel( reqs )
curReq = reqs( j );
reqOutLinks = curReq.outLinks;
numOfOutLinkedReqs = 0;
for k = 1:numel( reqOutLinks )



if isempty( reqOutLinks( k ).destination(  ) )
continue ;
end 

newDstReq = slreq.structToObj( reqOutLinks( k ).destination(  ) );



if ~strcmp( reqOutLinks( k ).destination(  ).domain, 'linktype_rmi_slreq' ) ||  ...
~this.isLinkTypeSelected( reqOutLinks( k ).Type ) ||  ...
~isa( newDstReq, 'slreq.Requirement' )
continue ;
end 

tableDataMapKey = char( reqSet.Name + this.TableMapKeyDelimiter + "toOutLinkedReqs" );

if isKey( this.TableMap, tableDataMapKey )
tableDataMapVal = this.TableMap( tableDataMapKey );
else 
tableDataMapVal.outlinks = true;
tableDataMapVal.srcReqs = slreq.Requirement.empty;
tableDataMapVal.dstReqsMap = containers.Map( 'KeyType', 'int32', 'ValueType', 'any' );
this.TableMapOrderedKeys{ end  + 1 } = tableDataMapKey;
end 

numOfOutLinkedReqs = numOfOutLinkedReqs + 1;

curReqSid = curReq.SID;
if isKey( tableDataMapVal.dstReqsMap, curReqSid )
dstReqs = tableDataMapVal.dstReqsMap( curReqSid );
len = length( dstReqs );
dstReqs( len + 1 ).linkTypeName = slreq.app.LinkTypeManager.getForwardName( reqOutLinks( k ).Type );
dstReqs( len + 1 ).requirement = newDstReq;
tableDataMapVal.dstReqsMap( curReqSid ) = dstReqs;
else 
dstReqs = struct( 'linkTypeName', {  }, 'requirement', {  } );
dstReqs( 1 ).linkTypeName = slreq.app.LinkTypeManager.getForwardName( reqOutLinks( k ).Type );
dstReqs( 1 ).requirement = newDstReq;
tableDataMapVal.dstReqsMap( curReqSid ) = dstReqs;
tableDataMapVal.srcReqs( end  + 1 ) = curReq;
end 
this.TableMap( tableDataMapKey ) = tableDataMapVal;


dstReqSid = newDstReq.SID;
if isKey( reverseOutLinkedReqsMap, dstReqSid )
srcReqs = reverseOutLinkedReqsMap( dstReqSid );
len = length( srcReqs );
srcReqs( len + 1 ).linkTypeName = slreq.app.LinkTypeManager.getBackwardName( reqOutLinks( k ).Type );
srcReqs( len + 1 ).requirement = curReq;
reverseOutLinkedReqsMap( dstReqSid ) = srcReqs;
else 
reverseOutLinkedReqsMapKeysReqs( end  + 1 ) = newDstReq;
srcReqs = struct( 'linkTypeName', {  }, 'requirement', {  } );
srcReqs( 1 ).linkTypeName = slreq.app.LinkTypeManager.getBackwardName( reqOutLinks( k ).Type );
srcReqs( 1 ).requirement = curReq;
reverseOutLinkedReqsMap( dstReqSid ) = srcReqs;
end 
end 


if numOfOutLinkedReqs == 0
tableDataMapKey = char( reqSet.Name + this.TableMapKeyDelimiter + "toOutLinkedReqs" );
if isKey( this.TableMap, tableDataMapKey )
tableDataMapVal = this.TableMap( tableDataMapKey );
else 
tableDataMapVal.outlinks = true;
tableDataMapVal.srcReqs = slreq.Requirement.empty;
tableDataMapVal.dstReqsMap = containers.Map( 'KeyType', 'int32', 'ValueType', 'any' );
if ~ismember( tableDataMapKey, this.TableMapOrderedKeys )
this.TableMapOrderedKeys{ end  + 1 } = tableDataMapKey;
end 
end 

curReqSid = curReq.SID;
dstReqs = struct( 'linkTypeName', {  }, 'requirement', {  } );
tableDataMapVal.dstReqsMap( curReqSid ) = dstReqs;
tableDataMapVal.srcReqs( end  + 1 ) = curReq;
this.TableMap( tableDataMapKey ) = tableDataMapVal;
end 
end 





for j = 1:numel( reverseOutLinkedReqsMapKeysReqs )
tableDataMapKey = char( reqSet.Name + this.TableMapKeyDelimiter + "fromOutLinkedReqs" );

curDstReq = reverseOutLinkedReqsMapKeysReqs( j );
srcReqs = reverseOutLinkedReqsMap( curDstReq.SID );

if isKey( this.TableMap, tableDataMapKey )
tableDataMapVal = this.TableMap( tableDataMapKey );
else 
tableDataMapVal.outlinks = false;
tableDataMapVal.srcReqs = slreq.Requirement.empty;
tableDataMapVal.dstReqsMap = containers.Map( 'KeyType', 'int32', 'ValueType', 'any' );
this.TableMapOrderedKeys{ end  + 1 } = tableDataMapKey;
end 

tableDataMapVal.srcReqs( end  + 1 ) = curDstReq;
tableDataMapVal.dstReqsMap( curDstReq.SID ) = srcReqs;
this.TableMap( tableDataMapKey ) = tableDataMapVal;
end 
end 
end 

function res = isLinkTypeSelected( this, selectedLinkType )
if ~ischar( selectedLinkType )
error( 'selectedLinkType is not char' );
end 
res = ismember( selectedLinkType, this.SelectedLinksTypes );
end 

function preprocessReqSetsForTables( this )
if strcmp( this.GroupTablesBy, 'ReqSets' )
this.preprocessTableDataByReqSets(  );
elseif strcmp( this.GroupTablesBy, 'Reduced Number of Tables' )
this.preprocessTableDataBySrcAndDstReqSets(  );
else 
warning( 'Unsupported GroupTablesBy' );
return ;
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpvyCNBT.p.
% Please follow local copyright laws when handling this file.

