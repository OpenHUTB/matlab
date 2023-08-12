classdef TruthTable < slreportgen.report.Reporter









































































properties 




Object{ mustBeTruthTableObject( Object ) } = [  ];



















ConditionTableReporter{ mustBeBaseTable( ConditionTableReporter ) } = [  ];

















ActionTableReporter{ mustBeBaseTable( ActionTableReporter ) } = [  ];





IncludeConditionTableHeader{ mustBeLogical } = true;




IncludeConditionTableRowNumber{ mustBeLogical } = true;




IncludeConditionTableConditionCol{ mustBeLogical } = true;





IncludeConditionTableDescriptionCol{ mustBeLogical } = true;




IncludeActionTableHeader{ mustBeLogical } = true;




IncludeActionTableRowNumber{ mustBeLogical } = true;




IncludeActionTableActionCol{ mustBeLogical } = true;




IncludeActionTableDescriptionCol{ mustBeLogical } = true;

end 

properties ( Access = private )




TruthTableObject = [  ];


ShouldNumberTableHierarchically = [  ];



IsImplTruthTableObj = [  ];
end 

methods 
function this = TruthTable( varargin )
if ( nargin == 1 )
varargin = [ { "Object" }, varargin ];
end 
this = this@slreportgen.report.Reporter( varargin{ : } );





p = inputParser;




p.KeepUnmatched = true;




addParameter( p, 'TemplateName', "TruthTable" );
addParameter( p, 'Object', [  ] );

conditionTableReporter = mlreportgen.report.BaseTable(  );
addParameter( p, 'ConditionTableReporter', conditionTableReporter );

actionTableReporter = mlreportgen.report.BaseTable(  );
addParameter( p, 'ActionTableReporter', actionTableReporter );


parse( p, varargin{ : } );



results = p.Results;
this.TemplateName = results.TemplateName;
this.ConditionTableReporter = results.ConditionTableReporter;
this.ActionTableReporter = results.ActionTableReporter;
end 

function set.Object( this, value )
if ischar( value )
this.Object = string( value );
else 
this.Object = value;
end 
resetTruthTableObject( this );
end 

function set.ConditionTableReporter( this, value )


mustBeNonempty( value );



this.ConditionTableReporter = value;
end 

function set.ActionTableReporter( this, value )


mustBeNonempty( value );



this.ActionTableReporter = value;
end 

function impl = getImpl( this, rpt )
R36
this( 1, 1 )
rpt( 1, 1 ){ validateReport( this, rpt ) }
end 

if isempty( this.Object )

error( message( "slreportgen:report:error:noSourceObjectSpecified", class( this ) ) );
else 



ttObjH = resolveTruthTableObject( this );

hs = slreportgen.utils.HierarchyService;

if isempty( this.LinkTarget )

deObjH = ttObjH;
if isTruthTableAsImplObj( this )
parent = slreportgen.utils.pathParts( ttObjH.Path );
deObjH = slreportgen.utils.getSlSfHandle( ttObjH.Path );
else 
parent = ttObjH.Subviewer.Path;
end 

dhid = hs.getDiagramHID( parent );
parentPath = hs.getPath( dhid );

if ~isempty( parentPath )
parentDiagram = getContext( rpt, parentPath );
if ~isempty( parentDiagram ) && ( parentDiagram.HyperLinkDiagram )
this.LinkTarget = slreportgen.utils.getObjectID( deObjH );
end 
end 
end 


modelH = slreportgen.utils.getModelHandle( this.Object );
compileModel( rpt, modelH );
this.ShouldNumberTableHierarchically = isChapterNumberHierarchical( this, rpt );
impl = getImpl@slreportgen.report.Reporter( this, rpt );
end 
end 
end 


methods ( Access = { ?mlreportgen.report.ReportForm, ?slreporten.report.TruthTable } )





function conditionTableReporter = getConditionTable( this, rpt )


conditionData = getConditionTableData( this );


decisionData = getDecisionTableData( this );


conditionTable = [ conditionData, decisionData ];
if ~isempty( conditionTable )





numOfConditonColsIncluded = double( this.IncludeConditionTableRowNumber ) +  ...
double( this.IncludeConditionTableDescriptionCol ) +  ...
double( this.IncludeConditionTableConditionCol );

condTable = formatTruthTable( conditionTable, this.IncludeConditionTableHeader,  ...
this.IncludeConditionTableRowNumber, "TruthTableCondTableRowNumStyle", numOfConditonColsIncluded );

condTable = formatCondTable( condTable, numOfConditonColsIncluded );

truthTableObjectTitle = getDisplayLabel( this );

conditionTableTitle = getString( message( "slreportgen:report:TruthTable:conditionTableTitle",  ...
truthTableObjectTitle ) );







if ( this.ConditionTableReporter.MaxCols ~= Inf )
this.ConditionTableReporter.RepeatCols = numOfConditonColsIncluded;
end 


conditionTableReporter = copy( this.ConditionTableReporter );
if isempty( conditionTableReporter.TableStyleName )

assignDefaultConditionTableStyleName( conditionTableReporter,  ...
this.IncludeConditionTableHeader,  ...
this.IncludeConditionTableRowNumber, rpt );
end 

conditionTableReporter.Title = conditionTableTitle;
conditionTableReporter.Content = condTable;


if mlreportgen.report.Reporter.isInlineContent( conditionTableReporter.Title )
titleReporter = getTitleReporter( conditionTableReporter );
titleReporter.TemplateSrc = this;

if this.ShouldNumberTableHierarchically
titleReporter.TemplateName = "TruthTableHierNumberedTitle";
else 
titleReporter.TemplateName = "TruthTableNumberedTitle";
end 
conditionTableReporter.Title = titleReporter;
end 

if isempty( conditionTableReporter.TableSliceTitleStyleName )
conditionTableReporter.TableSliceTitleStyleName = "TruthTableSliceTitleStyleName";
end 
else 


truthTableObjectTitle = getDisplayLabel( this );
para = mlreportgen.dom.Paragraph(  );
str1 = getString( message( "slreportgen:report:TruthTable:note" ) );
text1 = mlreportgen.dom.Text( str1 );
text1.Bold = true;
append( para, text1 );
str2 = getString( message( "slreportgen:report:TruthTable:emptyConditionTable", truthTableObjectTitle ) );
text2 = mlreportgen.dom.Text( str2 );
append( para, text2 );
para.Style = [ para.Style, { mlreportgen.dom.OuterMargin( '0pt', '0pt', '5pt', '0pt' ) } ];
conditionTableReporter = para;
end 
end 





function actionTableReporter = getActionTable( this, rpt )


actionTableData = getActionTableData( this );


if ~isempty( actionTableData )






numOfActionColsIncluded = double( this.IncludeActionTableRowNumber ) +  ...
double( this.IncludeActionTableDescriptionCol ) +  ...
double( this.IncludeActionTableActionCol );

actionTable = formatTruthTable( actionTableData, this.IncludeActionTableHeader,  ...
this.IncludeActionTableRowNumber, "TruthTableActionTableRowNumStyle", numOfActionColsIncluded );

truthTableObjectTitle = getDisplayLabel( this );

actionTableTitle = getString( message( "slreportgen:report:TruthTable:actionTableTitle",  ...
truthTableObjectTitle ) );



if ( this.ActionTableReporter.MaxCols ~= Inf )
this.ActionTableReporter.RepeatCols =  ...
double( this.IncludeActionTableRowNumber );
end 


actionTableReporter = copy( this.ActionTableReporter );

if isempty( actionTableReporter.TableStyleName )
assignDefaultActionTableStyleName( actionTableReporter, this.IncludeActionTableHeader,  ...
this.IncludeActionTableRowNumber, rpt );
end 

actionTableReporter.Title = actionTableTitle;
actionTableReporter.Content = actionTable;

if mlreportgen.report.Reporter.isInlineContent( actionTableReporter.Title )
titleReporter = getTitleReporter( actionTableReporter );
titleReporter.TemplateSrc = this;

if this.ShouldNumberTableHierarchically
titleReporter.TemplateName = "TruthTableHierNumberedTitle";
else 
titleReporter.TemplateName = "TruthTableNumberedTitle";
end 
actionTableReporter.Title = titleReporter;
end 
else 


truthTableObjectTitle = getDisplayLabel( this );
para = mlreportgen.dom.Paragraph(  );
str1 = getString( message( "slreportgen:report:TruthTable:note" ) );
text1 = mlreportgen.dom.Text( str1 );
text1.Bold = true;
append( para, text1 );
str2 = getString( message( "slreportgen:report:TruthTable:emptyActionTable", truthTableObjectTitle ) );
text2 = mlreportgen.dom.Text( str2 );
append( para, text2 );
para.Style = [ para.Style, { mlreportgen.dom.OuterMargin( '0pt', '0pt', '5pt', '0pt' ) } ];
actionTableReporter = para;
end 

end 

end 

methods ( Access = private )

function resetTruthTableObject( this )
this.IsImplTruthTableObj = [  ];
this.TruthTableObject = [  ];
end 

function isTruthTableBlock = isTruthTableAsImplObj( this )
if isempty( this.IsImplTruthTableObj )











objH = resolveTruthTableObject( this );
this.IsImplTruthTableObj = isa( objH, "Stateflow.Object" ) &&  ...
slreportgen.utils.isTruthTable( objH.Path );
end 
isTruthTableBlock = this.IsImplTruthTableObj;

end 


function ttObjH = resolveTruthTableObject( this )
if isempty( this.TruthTableObject )
objH = slreportgen.utils.getSlSfHandle( this.Object );
if isa( objH, 'Stateflow.Object' )
this.TruthTableObject = objH;
else 
if slreportgen.utils.isValidSlSystem( objH )
this.TruthTableObject = slreportgen.utils.block2chart( objH );
end 
end 
end 
ttObjH = this.TruthTableObject;
end 


function condTableData = getConditionTableData( this )
condTableData = [  ];
ttObjH = resolveTruthTableObject( this );
conditionTableData = ttObjH.ConditionTable;
if ~isempty( conditionTableData ) && ~hasConditionTableData( conditionTableData )



if ( this.IncludeConditionTableDescriptionCol )


descriptionData = conditionTableData( :, 1 );
if this.IncludeConditionTableHeader
descriptionData = [ getString( message( "slreportgen:report:TruthTable:description" ) ); ...
descriptionData ];
end 
if ~this.IncludeConditionTableConditionCol
descriptionData( end , 1 ) = { getString( message( "slreportgen:report:TruthTable:actions" ) ) };
end 
else 
descriptionData = [  ];
end 




if ( this.IncludeConditionTableConditionCol )
conditionData = conditionTableData( :, 2 );
conditionData( end , 1 ) = { getString( message( "slreportgen:report:TruthTable:actions" ) ) };
if this.IncludeConditionTableHeader
conditionData = [ getString( message( "slreportgen:report:TruthTable:condition" ) ); ...
conditionData ];
end 
else 
conditionData = [  ];
end 




if this.IncludeConditionTableRowNumber
sz = size( conditionTableData );
rowNumCol = getRowNumber( sz( 1 ), this.IncludeConditionTableHeader );
rowNumCol{ end  } = '';
else 
rowNumCol = [  ];
end 

condTableData = [ rowNumCol, descriptionData, conditionData ];
end 
end 


function decisionData = getDecisionTableData( this )
decisionData = [  ];
ttObjH = resolveTruthTableObject( this );
conditionTableData = ttObjH.ConditionTable;
if ~isempty( conditionTableData ) && ~hasConditionTableData( conditionTableData )
decisionData = conditionTableData( :, 3:end  );


if this.IncludeConditionTableHeader
sz = size( decisionData );
header = cell( 1, sz( 2 ) );
for ind = 1:sz( 2 )
header{ ind } = strcat( "D", num2str( ind ) );
end 
decisionData = [ header;decisionData ];
end 
end 
end 

function actionTableData = getActionTableData( this )
actionTableData = [  ];
ttObjH = resolveTruthTableObject( this );
actionTable = ttObjH.ActionTable;


if ~isempty( actionTable ) && ~isempty( find( ~cellfun( @isempty, actionTable ), 1 ) )
descriptionData = [  ];
actionData = [  ];




hasRowNumber = this.IncludeActionTableRowNumber &&  ...
( this.IncludeActionTableDescriptionCol || this.IncludeActionTableActionCol );

if hasRowNumber
sz = size( actionTable );
rowNumCol = getRowNumber( sz( 1 ), this.IncludeActionTableHeader );
else 
rowNumCol = [  ];
end 


if this.IncludeActionTableDescriptionCol




descriptionData = actionTable( :, 1 );
if this.IncludeActionTableHeader
descriptionData = [ getString( message( "slreportgen:report:TruthTable:description" ) ); ...
descriptionData ];
end 
end 

if this.IncludeActionTableActionCol
actionData = actionTable( :, 2 );
if this.IncludeActionTableHeader
actionData = [ getString( message( "slreportgen:report:TruthTable:action" ) ); ...
actionData ];
end 
end 
actionTableData = [ rowNumCol, descriptionData, actionData ];
end 
end 


function truthTableObjectTitle = getDisplayLabel( this )

ttobjH = resolveTruthTableObject( this );
if isTruthTableAsImplObj( this )
[ ~, blockName ] = slreportgen.utils.pathParts( ttobjH.Path );
else 
blockName = ttobjH.Name;
end 
truthTableObjectTitle = mlreportgen.utils.normalizeString( blockName );
truthTableObjectTitle = mlreportgen.utils.capitalizeFirstChar( truthTableObjectTitle );
end 
end 

methods ( Static )
function path = getClassFolder(  )


[ path ] = fileparts( mfilename( 'fullpath' ) );
end 

function template = createTemplate( templatePath, type )








path = slreportgen.report.TruthTable.getClassFolder(  );
template = mlreportgen.report.ReportForm.createFormTemplate(  ...
templatePath, type, path );
end 

function classfile = customizeReporter( toClasspath )









classfile = mlreportgen.report.ReportForm.customizeClass( toClasspath,  ...
"slreportgen.report.TruthTable" );
end 
end 

methods ( Access = protected, Hidden )

result = openImpl( reporter, impl, varargin )

end 
end 






function tf = hasConditionTableData( conditionTableData )
nonEmptyConditionTableInd = find( ~cellfun( @isempty, conditionTableData ) );
tf = numel( nonEmptyConditionTableInd ) == 2 &&  ...
strcmp( conditionTableData{ nonEmptyConditionTableInd( 1 ) }, 'Actions' ) &&  ...
strcmp( conditionTableData{ nonEmptyConditionTableInd( 2 ) }, '-' );
end 

function mustBeBaseTable( table )
mlreportgen.report.validators.mustBeInstanceOf( 'mlreportgen.report.BaseTable', table );
end 

function mustBeTruthTableObject( object )
if ~isempty( object ) && ~slreportgen.utils.isTruthTable( object )
error( message( "slreportgen:report:error:invalidSourceObject" ) );
end 
end 

function mustBeLogical( varargin )
mlreportgen.report.validators.mustBeLogical( varargin{ : } );
end 



function table = formatTruthTable( truthTableData, hasHeader, hasRowNumber, styleName, numOfConditonColsIncluded )

numOfConditonColsIncluded = numOfConditonColsIncluded - double( hasRowNumber );
table = mlreportgen.dom.FormalTable(  );

if hasHeader
firstRowValue = truthTableData( 1, : );
truthTableData = truthTableData( 2:end , : );

tableRow = mlreportgen.dom.TableRow(  );
for ind = 1:length( firstRowValue )
append( tableRow, mlreportgen.dom.TableHeaderEntry( firstRowValue{ ind } ) );
end 
append( table.Header, tableRow );
end 

s = size( truthTableData );
for rownum = 1:s( 1 )
numOfColsleftAligned = numOfConditonColsIncluded;
tableRow = mlreportgen.dom.TableRow(  );
firstTableEntryPara = mlreportgen.dom.Paragraph( truthTableData{ rownum, 1 } );
firstTableEntryPara.WhiteSpace = 'preserve';
firstTableColumn = mlreportgen.dom.TableEntry( firstTableEntryPara );

if hasRowNumber
firstTableColumn.StyleName = styleName;
else 


if ( numOfColsleftAligned > 0 )
firstTableColumn.Style = [ firstTableColumn.Style, { mlreportgen.dom.HAlign( 'left' ) } ];
numOfColsleftAligned = numOfColsleftAligned - 1;

else 
firstTableColumn.Style = [ firstTableColumn.Style, { mlreportgen.dom.HAlign( 'center' ) } ];
end 
end 
append( tableRow, firstTableColumn );

for colnum = 2:s( 2 )
tableEntryPara = mlreportgen.dom.Paragraph( truthTableData{ rownum, colnum } );
tableEntryPara.WhiteSpace = "preserve";
tableEntry = mlreportgen.dom.TableEntry( tableEntryPara );


if ( numOfColsleftAligned > 0 )
tableEntry.Style = [ tableEntry.Style, { mlreportgen.dom.HAlign( 'left' ) } ];
numOfColsleftAligned = numOfColsleftAligned - 1;
else 
tableEntry.Style = [ tableEntry.Style, { mlreportgen.dom.HAlign( 'center' ) } ];
end 
append( tableRow, tableEntry );
end 
append( table.Body, tableRow );
end 
end 




function table = formatCondTable( table, numOfConditonColsIncluded )
numOfColsToApplyStyle = numOfConditonColsIncluded;

totalTableRows = length( table.Body.Children );

lastRowEntries = table.Body.Children( totalTableRows ).Children;


for lastRowEntry = lastRowEntries
para = lastRowEntry.Children;
para.StyleName = "TruthTableConditionTableLastRowStyle";




if numOfColsToApplyStyle > 0
lastRowEntry.Style = [ lastRowEntry.Style, { mlreportgen.dom.BackgroundColor( "#e3e3e3" ) } ];
numOfColsToApplyStyle = numOfColsToApplyStyle - 1;
end 
end 
end 


function rowNumCol = getRowNumber( sz, hasHeader )
rowNumCol = cell( sz, 1 );
for ind = 1:sz
rowNumCol{ ind } = num2str( ind );
end 
if hasHeader
headerRowNum = { "#" };
rowNumCol = [ headerRowNum;rowNumCol ];
end 
end 









function assignDefaultActionTableStyleName( actionTableReporter, hasHeader, hasRowNumber, rpt )

if strcmp( rpt.Type, 'docx' )

if hasHeader && hasRowNumber
actionTableReporter.TableStyleName = "TruthTableActionHeaderRowNumStyle";

elseif hasHeader && ~hasRowNumber
actionTableReporter.TableStyleName = "TruthTableActionHeaderStyle";

elseif ~hasHeader && hasRowNumber
actionTableReporter.TableStyleName = "TruthTableActionRowNumStyle";

else 
actionTableReporter.TableStyleName = "TruthTableActionNormalStyle";
end 


else 
actionTableReporter.TableStyleName = "TruthTableActionTableStyle";
end 
end 







function assignDefaultConditionTableStyleName( conditionTableReporter, hasHeader, hasRowNumber, rpt )

if strcmp( rpt.Type, 'docx' )

if hasHeader && hasRowNumber
conditionTableReporter.TableStyleName = "TruthTableCondHeaderRowNumStyle";

elseif hasHeader && ~hasRowNumber
conditionTableReporter.TableStyleName = "TruthTableCondHeaderStyle";

elseif ~hasHeader && hasRowNumber
conditionTableReporter.TableStyleName = "TruthTableCondRowNumStyle";

else 
conditionTableReporter.TableStyleName = "TruthTableCondNormalStyle";
end 

else 
conditionTableReporter.TableStyleName = "TruthTableConditionTableStyle";
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpfobrmC.p.
% Please follow local copyright laws when handling this file.

