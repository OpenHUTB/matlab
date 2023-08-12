classdef DiagramElementResult < mlreportgen.finder.Result


































properties ( SetAccess = protected )



Object = [  ];
end 

properties ( SetAccess = { ?mlreportgen.finder.Result } )




Type string = string.empty(  );




Name string = string.empty(  );




DiagramPath string = string.empty(  );

end 

properties 





Tag = [  ];
end 

properties ( Access = private )


ObjectPropertiesReporter = [  ];
end 

methods 
function h = DiagramElementResult( varargin )
h = h@mlreportgen.finder.Result( varargin{ : } );
initObject( h );
initType( h );
initName( h );
initDiagramPath( h );
end 

function reporter = getReporter( h )



reporter = [  ];



obj = h.Object;
if isValidSlObject( slroot, obj )
type = string( get_param( obj, 'Type' ) ).lower;
if ( type == "block" ) || ( type == "annotation" ) || ( type == "port" ) ||  ...
( type == "line" )
if slreportgen.utils.isLookupTable( obj )
reporter = slreportgen.report.LookupTable(  ...
"Object", obj );
elseif slreportgen.utils.isMATLABFunction( obj )
reporter = slreportgen.report.MATLABFunction(  ...
"Object", obj );
elseif slreportgen.utils.isTruthTable( obj )
reporter = slreportgen.report.TruthTable(  ...
"Object", obj );
elseif slreportgen.utils.isDocBlock( obj )
reporter = slreportgen.report.DocBlock(  ...
"Object", obj );
elseif slreportgen.utils.isTestSequence( obj )
reporter = slreportgen.report.TestSequence(  ...
"Object", obj );
elseif slreportgen.utils.isStateTransitionTable( obj )
reporter = slreportgen.report.StateTransitionTable(  ...
"Object", obj );
elseif strcmp( type, "block" ) && strcmp( get_param( obj, 'blocktype' ), "CFunction" )
reporter = slreportgen.report.CFunction(  ...
"Object", obj );
elseif strcmp( type, "block" ) && strcmp( get_param( obj, 'blocktype' ), "CCaller" )
reporter = slreportgen.report.CCaller(  ...
"Object", obj );
elseif strcmp( type, "annotation" )
reporter = slreportgen.report.Annotation(  ...
"Object", obj );
else 
reporter = slreportgen.report.SimulinkObjectProperties(  ...
"Object", obj );
end 
end 

elseif isa( obj, "Stateflow.Object" )
if slreportgen.utils.isMATLABFunction( obj )
reporter = slreportgen.report.MATLABFunction(  ...
"Object", obj );
elseif slreportgen.utils.isTruthTable( obj )
reporter = slreportgen.report.TruthTable(  ...
"Object", obj );
elseif slreportgen.utils.isTestSequence( obj )
reporter = slreportgen.report.TestSequence(  ...
"Object", obj );
elseif slreportgen.utils.isStateTransitionTable( obj )
reporter = slreportgen.report.StateTransitionTable(  ...
"Object", obj );
else 
reporter = slreportgen.report.StateflowObjectProperties(  ...
"Object", obj );
end 
end 
end 

function reporter = getDiagramReporter( this )






try 

reporter = slreportgen.report.Diagram(  ...
"Source", this.Object );

if ~isempty( this.Name )
reporter.Snapshot.Caption =  ...
mlreportgen.utils.normalizeString( this.Name );
end 
catch 

reporter = [  ];
end 
end 

function title = getDefaultSummaryTableTitle( this, options )












R36
this
options.TypeSpecificTitle( 1, 1 )logical = true
end 

if options.TypeSpecificTitle
objType = slreportgen.utils.getObjectType( this.Object );
if strcmp( objType, 'TruthTable' ) || strcmp( objType, 'MATLABFunction' ) || strcmp( objType, 'StateTransitionTableBlock' )
objType = 'Block';
end 
title = strcat( objType, " ",  ...
getString( message( "slreportgen:report:SummaryTable:properties" ) ) );
else 
title = string( getString( message( "slreportgen:report:SummaryTable:objectProperties" ) ) );
end 

end 

function props = getDefaultSummaryProperties( this, options )
















R36
this
options.TypeSpecificProperties( 1, 1 )logical = true
end 

if options.TypeSpecificProperties

handle = slreportgen.utils.getSlSfHandle( this.Object );
objType = slreportgen.utils.getObjectType( handle );
if strcmp( objType, 'TruthTable' ) || strcmp( objType, 'MATLABFunction' ) || strcmp( objType, 'StateTransitionTableBlock' )
objType = 'Block';
end 





switch objType
case { "Block", "ModelReference" }



props = [ "Name", "Block Type", "Parent" ];
case "Port"
props = [ "Name", "Parent" ];
otherwise 

rptr = getObjectPropertiesReporter( this );
props = [ "Name", rptr.getReportedProperties( handle, objType ) ];
end 
else 


props = [ "Name", "Type" ];
end 
end 

function propVals = getPropertyValues( this, propNames, options )


























R36
this
propNames string
options.ReturnType( 1, 1 )string ...
{ mustBeMember( options.ReturnType, [ "native", "string", "DOM" ] ) } = "native"
end 

returnRawValue = strcmp( options.ReturnType, "native" );
returnDOMValue = strcmp( options.ReturnType, "DOM" );


rptr = getObjectPropertiesReporter( this );
handle = slreportgen.utils.getSlSfHandle( this.Object );
objType = slreportgen.utils.getObjectType( handle );
if strcmp( objType, 'TruthTable' ) || strcmp( objType, 'MATLABFunction' ) || strcmp( objType, 'StateTransitionTableBlock' )
objType = 'Block';
end 

nProps = numel( propNames );
propVals = cell( 1, nProps );
for idx = 1:nProps

prop = strrep( propNames( idx ), " ", "" );

if isprop( this, prop )

val = this.( prop );
else 

val = rptr.getObjectProperty( handle, objType, prop, returnRawValue );
if iscell( val )
val = val{ 1 };
end 
end 


if isa( val, "mlreportgen.dom.Element" )
val = formatDOMPropertyValue( this, val, "ConvertToString", ~returnDOMValue );
elseif ~returnRawValue
if isempty( val )
val = "";
else 

val = mlreportgen.utils.toString( val );
end 
end 

propVals{ idx } = val;
end 
end 

function id = getReporterLinkTargetID( this )







id = getReporterLinkTargetID@mlreportgen.finder.Result( this );
if isempty( id )
id = slreportgen.utils.getObjectID( this.Object );
end 
end 
end 

methods ( Hidden )
function presenter = getPresenter( h )%#ok<MANU>
presenter = [  ];
end 
end 

methods ( Access = protected )
function initObject( h )
mustBeNonempty( h.Object );
h.Object = slreportgen.utils.getSlSfHandle( h.Object );
end 

function initType( h )
if isempty( h.Type )
obj = h.Object;

if isa( obj, 'Stateflow.Object' )
type = class( obj );
else 
objH = get_param( obj, 'Object' );
if isa( objH, 'Simulink.Block' )
type = 'Simulink.Block';
else 
type = class( objH );
end 
end 
h.Type = string( type );
end 
end 

function initName( h )
if isempty( h.Name )
obj = h.Object;
try 
name = string( get( obj, 'Name' ) );
catch 
name = "";
end 
if name == "" && isa( obj, "Stateflow.Object" )
name = getSFName( obj );
end 
h.Name = name;
end 
end 

function initDiagramPath( h )
if isempty( h.DiagramPath )
obj = h.Object;
try 
diagramPath = mlreportgen.utils.normalizeString( get( obj, 'Path' ) );
catch 
diagramPath = "";
end 
h.DiagramPath = diagramPath;
end 
end 

function rptr = getObjectPropertiesReporter( h )




if ~isempty( h.ObjectPropertiesReporter )
rptr = h.ObjectPropertiesReporter;
elseif isa( h.Object, "Stateflow.Object" )
rptr = slreportgen.report.StateflowObjectProperties( h.Object );
h.ObjectPropertiesReporter = rptr;
else 
rptr = slreportgen.report.SimulinkObjectProperties( h.Object );
h.ObjectPropertiesReporter = rptr;
end 
end 
end 
end 

function name = getSFName( obj )

objType = extractAfter( class( obj ), "Stateflow." );
name = "";
switch objType
case "Transition"
name = strrep( obj.LabelString, newline, "" );
if strcmp( name, "?" )
name = "";
end 
if ( isempty( name ) || name == "" ) && sf( 'get', get( obj, 'ID' ), '.isDefault' )
name = "DefaultTransition";
end 
case "Junction"
name = "Junction" + num2str( obj.SSIdNumber );
case "Annotation"
name = mlreportgen.utils.getFirstLine( obj.Text );
case "Port"
name = strrep( obj.LabelString, newline, "" );
end 


if isempty( name ) || name == ""
if ~isprop( obj, "ID" )
name = objType;
else 
name = sprintf( "%s%i", objType, get( obj, 'SSIdNumber' ) );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpv2n9xQ.p.
% Please follow local copyright laws when handling this file.

