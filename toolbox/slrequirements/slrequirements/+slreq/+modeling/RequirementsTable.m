classdef RequirementsTable < handle




properties ( Access = private )
ChartH
InternalRequirement
end 

properties ( Dependent )
Name
Path
RequirementHeaders
end 

properties ( Access = private, Constant )
PRECONDITION = 'Preconditions'
POSTCONDITION = 'Postconditions'
ACTION = 'Actions'
end 

methods 

function symbol = addSymbol( obj, options )
R36
obj
options.Name{ mustBeTextScalar }
options.Scope char{ mustBeMember( options.Scope, { 'Input', 'Output', 'Local', 'Constant', 'Parameter' } ) } = 'Local'
options.Complexity char{ mustBeMember( options.Complexity, { 'On', 'Off', 'Inherited' } ) } = 'Off'
options.InitialValue{ mustBeTextScalar }
options.Size{ mustBeTextScalar } = '-1'
options.Type{ mustBeTextScalar }
options.IsDesignOutput{ mustBeNumericOrLogical, mustBeNonempty }
end 
symbol = slreq.modeling.Symbol( obj.ChartH, options );
end 

function symbols = findSymbol( obj, options )
R36
obj
options.InitialValue{ mustBeTextScalar }
options.Name{ mustBeTextScalar }
options.Scope{ mustBeTextScalar, mustBeMember( options.Scope, { 'Input', 'Output', 'Local', 'Constant', 'Parameter' } ) }
options.Size{ mustBeTextScalar }
options.Complexity{ mustBeTextScalar, mustBeMember( options.Complexity, { 'On', 'Off', 'Inherited' } ) }
options.Type{ mustBeTextScalar }
options.IsDesignOutput{ mustBeNonempty, mustBeNumericOrLogical }
end 
dataInChart = sf( 'DataOf', obj.ChartH.Id );

if isfield( options, 'Scope' ) && ~isempty( dataInChart )
propName = 'data.scope';
scope = [ upper( options.Scope ), '_DATA' ];
dataInChart = sf( 'find', dataInChart, propName, scope );
end 

if isfield( options, 'Name' ) && ~isempty( dataInChart )
propName = 'data.name';
dataInChart = sf( 'find', dataInChart, propName, options.Name );
end 

if isfield( options, 'Size' ) && ~isempty( dataInChart )
propName = 'data.props.array.size';
dataInChart = sf( 'find', dataInChart, propName, options.Size );
end 

if isfield( options, 'InitialValue' ) && ~isempty( dataInChart )
propName = 'data.props.initialValue';
dataInChart = sf( 'find', dataInChart, propName, options.InitialValue );
end 

if isfield( options, 'Complexity' ) && ~isempty( dataInChart )
propName = 'data.props.complexity';
if strcmp( options.Complexity, 'On' )
complexity = 'SF_COMPLEX_YES';
elseif strcmp( options.Complexity, 'Off' )
complexity = 'SF_COMPLEX_NO';
elseif strcmp( options.Complexity, 'Inherited' )
complexity = 'SF_COMPLEX_INHERITED';
else 
complexity = 'SF_COMPLEX_UNKNOWN';
end 
dataInChart = sf( 'find', dataInChart, propName, complexity );
end 

if isfield( options, 'Type' ) && ~isempty( dataInChart )
propName = 'data.dataType';
dataInChart = sf( 'find', dataInChart, propName, options.Type );
end 

if isfield( options, 'IsDesignOutput' ) && ~isempty( dataInChart )
if isfield( options, 'Scope' ) && ~strcmp( options.Scope, 'Input' )
dataInChart = [  ];
else 
propName = 'data.scope';
dataInChart = sf( 'find', dataInChart, propName, 'INPUT_DATA' );
propName = 'data.isModelOutput';
dataInChart = sf( 'find', dataInChart, propName, options.IsDesignOutput );
end 
end 

allData = sf( 'IdToHandle', dataInChart );
symbols = obj.wrapSymbols( allData );
end 

function obj = RequirementsTable( reqTable, chartH )
obj.ChartH = chartH;
obj.InternalRequirement = reqTable;
end 

function path = get.Path( obj )
path = obj.ChartH.Path;
end 

function name = get.Name( obj )
name = obj.ChartH.Name;
end 

function set.Name( obj, newValue )
R36
obj
newValue{ mustBeNonzeroLengthText }
end 
obj.ChartH.Name = newValue;
end 

function removeRow( obj, row )
R36
obj
row{ mustBeA( row, { 'slreq.modeling.RequirementRow', 'slreq.modeling.AssumptionRow' } ) }
end 

if ~isvalid( row.getInternalRequirement(  ) )
error( 'Slvnv:reqmgt:specBlock:InvalidRow',  ...
DAStudio.message( 'Slvnv:reqmgt:specBlock:InvalidRow' ) );
end 



numRows = [  ];
if row.Index == '1'
if isa( row, 'slreq.modeling.RequirementRow' )
numRows = numel( obj.getRequirementRows(  ) );
isReqTable = true;
else 
numRows = numel( obj.getAssumptionRows(  ) );
isReqTable = false;
end 
end 

if numRows == 1
removeChildren( row );
row.clear(  );
row.getInternalRequirement(  ).multipleLineLogic = uint8( 0 );
else 
if isa( row, 'slreq.modeling.RequirementRow' )
obj.InternalRequirement.requirementsTable.removeChild( row.getInternalRequirement(  ) );
else 
obj.InternalRequirement.assumptionsTable.removeChild( row.getInternalRequirement(  ) );
end 
end 

obj.refreshUI(  );

function removeChildren( row )
children = row.getChildren(  );
for child = children
if isReqTable
obj.InternalRequirement.requirementsTable.removeChild( child.getInternalRequirement(  ) );
else 
obj.InternalRequirement.assumptionsTable.removeChild( child.getInternalRequirement(  ) );
end 
end 
end 
end 

function assumption = addAssumptionRow( obj, options )
R36
obj
options.RowType{ mustBeTextScalar, mustBeMember( options.RowType, { 'normal', 'anyChildActive', 'allChildrenActive' } ) } = 'normal'
options.Preconditions cell
options.Postconditions cell
options.Summary{ mustBeTextScalar }
end 

if ( isfield( options, 'Preconditions' ) && numel( options.Preconditions ) > 1 ) ||  ...
( isfield( options, 'Postconditions' ) && numel( options.Postconditions ) > 1 )
error( 'Slvnv:reqmgt:specBlock:InvalidNumberOfPreconditionsOrPostconditions',  ...
DAStudio.message( 'Slvnv:reqmgt:specBlock:InvalidNumberOfPreconditionsOrPostconditions' ) );
end 

parent = obj.InternalRequirement.assumptionsTable;
assumption = slreq.modeling.AssumptionRow( parent, options.RowType, obj.ChartH.Id );
if isfield( options, 'Summary' )
assumption.Summary = options.Summary;
end 
if isfield( options, 'Preconditions' )
assumption.Preconditions = options.Preconditions;
end 
if isfield( options, 'Postconditions' )
assumption.Postconditions = options.Postconditions;
end 
obj.refreshUI(  );
end 

function requirement = addRequirementRow( obj, options )
R36
obj
options.RowType{ mustBeTextScalar, mustBeMember( options.RowType, { 'normal', 'anyChildActive', 'allChildrenActive', 'default' } ) } = 'normal'
options.Actions cell
options.Duration{ mustBeTextScalar }
options.Preconditions cell
options.Postconditions cell
options.Summary{ mustBeTextScalar }
end 
parent = obj.InternalRequirement.requirementsTable;
requirement = slreq.modeling.RequirementRow( parent, options.RowType, obj.ChartH.Id );
if isfield( options, 'Summary' )
requirement.Summary = options.Summary;
end 
if isfield( options, 'Preconditions' )
requirement.Preconditions = options.Preconditions;
end 
if isfield( options, 'Duration' )
requirement.Duration = options.Duration;
end 
if isfield( options, 'Postconditions' )
requirement.Postconditions = options.Postconditions;
end 
if isfield( options, 'Actions' )
requirement.Actions = options.Actions;
end 
obj.refreshUI(  );
end 

function requirements = getRequirementRows( obj )

table = obj.InternalRequirement.requirementsTable;
sfReqs = table.getChildrenInOrder(  );
numOfElements = numel( sfReqs );
requirements = slreq.modeling.RequirementRow(  );
requirements = repmat( requirements, 1, numOfElements );
for i = 1:numOfElements
sfReq = sfReqs( i );
slReqreq = slreq.modeling.RequirementRow.wrap( sfReq, obj.ChartH.Id );
requirements( i ) = slReqreq;
end 
end 

function assumptions = getAssumptionRows( obj )

table = obj.InternalRequirement.assumptionsTable;
sfReqs = table.getChildrenInOrder(  );
numOfElements = numel( sfReqs );
assumptions = slreq.modeling.AssumptionRow(  );
assumptions = repmat( assumptions, 1, numOfElements );
for i = 1:numOfElements
sfReq = sfReqs( i );
slReqreq = slreq.modeling.AssumptionRow.wrap( sfReq, obj.ChartH.Id );
assumptions( i ) = slReqreq;
end 
end 

function set.RequirementHeaders( obj, newVals )
oldVals = obj.RequirementHeaders;
fieldNames = fieldnames( oldVals );
mustBeMember( fieldnames( newVals ), fieldNames );
refreshUI = false;
for i = 1:numel( fieldNames )
fieldName = fieldNames{ i };
oldCell = oldVals.( fieldName );
newCell = newVals.( fieldName );
mustBeText( newCell );
if ~isequal( oldCell, newCell )
switch fieldName
case obj.PRECONDITION
columnName = 'preCondition';
case obj.POSTCONDITION
columnName = 'postCondition';
case obj.ACTION
columnName = 'action';
end 
obj.InternalRequirement.requirementsTable.addHeaderExprsByType( columnName, newCell );
refreshUI = true;
end 
end 
if refreshUI
obj.refreshUI(  );
end 
end 

function out = get.RequirementHeaders( obj )
requirementsTable = obj.InternalRequirement.requirementsTable;
columHeaders = requirementsTable.columnHeaders.toArray;

out.Preconditions = {  };
out.Postconditions = {  };
out.Actions = {  };

for columnHeader = columHeaders
columnType = columnHeader.type;
columnSubHeaders = columnHeader.columnSubHeaders.toArray(  );
for subHeader = columnSubHeaders
expression = subHeader.headerExpression;
switch columnType
case 'preCondition'
out.Preconditions{ end  + 1 } = expression;
case 'postCondition'
out.Postconditions{ end  + 1 } = expression;
case 'action'
if requirementsTable.actionVisible
out.Actions{ end  + 1 } = expression;
end 
end 
end 
end 
end 

function hideRequirementColumn( obj, columnName )
R36
obj
columnName char{ mustBeMember( columnName, { 'Duration', 'Actions', 'Postconditions' } ) }
end 
table = obj.InternalRequirement.requirementsTable;
toggleValue = false;
obj.showHideColumnHelper( table, columnName, toggleValue );
end 

function hideAssumptionColumn( obj )
columnName = 'Preconditions';
table = obj.InternalRequirement.assumptionsTable;
toggleValue = false;
obj.showHideColumnHelper( table, columnName, toggleValue );
end 

function showRequirementColumn( obj, columnName )
R36
obj
columnName char{ mustBeMember( columnName, { 'Duration', 'Actions', 'Postconditions' } ) }
end 
table = obj.InternalRequirement.requirementsTable;
toggleValue = true;
obj.showHideColumnHelper( table, columnName, toggleValue );
end 

function showAssumptionColumn( obj )
columnName = 'Preconditions';
table = obj.InternalRequirement.assumptionsTable;
toggleValue = true;
obj.showHideColumnHelper( table, columnName, toggleValue );
end 

end 

methods ( Access = private )
function refreshUI( obj )
Stateflow.ReqTable.internal.TableManager.dispatchUIRequest( obj.ChartH.Id, 'updateTable', { false, false, true }, false );
end 

function symbols = wrapSymbols( ~, dataHs )
symbol = slreq.modeling.Symbol(  );
numOfSymbols = numel( dataHs );
symbols = repmat( symbol, 1, numOfSymbols );
for i = 1:numOfSymbols
symbols( i ) = slreq.modeling.Symbol.wrap( dataHs( i ) );
end 
end 

function showHideColumnHelper( obj, table, columnName, toggleValue )
values = struct( 'Duration', { 'duration', 'durationVisible' },  ...
'Actions', { 'getActions', 'actionVisible' }, 'Postconditions',  ...
{ 'getPostconditions', 'postConditionVisible' },  ...
'Preconditions', { 'getPreconditions', 'preConditionVisible' } );

getterName = values( 1 ).( columnName );
toggleName = values( 2 ).( columnName );
if table.( toggleName ) ~= toggleValue && canToggle( table, getterName )
table.( toggleName ) = toggleValue;
obj.refreshUI(  );
end 

function tf = canToggle( table, call )
tf = true;
rows = table.getRowsInOrder(  );
for row = rows
if row.commentOut
continue ;
end 
content = row.( call );
if isempty( find( strcmp( content, '' ) ) )%#ok<EFIND>
tf = false;
return ;
end 

end 
end 
end 
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpI_rrzr.p.
% Please follow local copyright laws when handling this file.

