classdef SignalResult < mlreportgen.finder.Result


































properties ( SetAccess = protected )



Object = [  ];
end 

properties ( Access = protected, Hidden )
Reporter = [  ];
end 

properties 




Tag;
end 

properties ( SetAccess = ?slreportgen.finder.SignalFinder )



Name string




SourceBlock string




SourcePortNumber






RelatedObject string










Relationship string
end 

methods ( Access = { ?slreportgen.finder.SignalFinder } )
function this = SignalResult( varargin )
this = this@mlreportgen.finder.Result( varargin{ : } );
mustBeNonempty( this.Object );
end 
end 

methods 
function reporter = getReporter( this )









if isempty( this.Reporter )
reporter = slreportgen.report.Signal( this.Object );
this.Reporter = reporter;
else 
reporter = this.Reporter;
end 
end 

function ports = getDestinationPorts( this )







[ ~, ports, ~ ] = slreportgen.utils.traceSignal( this.Object, "Nonvirtual", false );
end 

function ports = getNonvirtualDestinationPorts( this )










[ ~, ports, ~ ] = slreportgen.utils.traceSignal( this.Object, "Nonvirtual", true );
end 

function title = getDefaultSummaryTableTitle( ~, varargin )






title = string( getString( message( "slreportgen:report:SummaryTable:signalProperties" ) ) );
end 

function props = getDefaultSummaryProperties( ~, varargin )












props = [ "Name", "Description", "Source", "NonvirtualDestination", "DataType" ];
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


nProps = numel( propNames );
propVals = cell( 1, nProps );

rptr = getReporter( this );
for idx = 1:nProps

prop = strrep( propNames( idx ), " ", "" );
normProp = lower( prop );
switch normProp
case { "destination", "nonvirtualdestination" }


line = get_param( this.Object, "Line" );
val = createDestinationDOM( rptr, prop, line );
val = formatDOMPropertyValue( this, val,  ...
"ConvertToString", ~returnDOMValue );
case { "source", "parent" }


val = createSrcOrDstPara( rptr, this.Object );
val = formatDOMPropertyValue( this, val,  ...
"ConvertToString", ~returnDOMValue );
otherwise 
if isprop( this, prop )

val = this.( prop );
else 

[ val, isValid ] = slreportgen.utils.internal.getSignalProperty( this.Object, prop, ReturnRawValue = returnRawValue );
if ~isValid
val = "N/A";
end 
end 


if ~returnRawValue && ~isempty( val )
val = mlreportgen.utils.toString( val );
end 
end 

propVals{ idx } = val;
end 
end 

function id = getReporterLinkTargetID( this )







id = getReporterLinkTargetID@mlreportgen.finder.Result( this );
if isempty( id )
id = slreportgen.report.Signal.getLinkTargetID( this.Object );
end 
end 

function presenter = getPresenter( this )%#ok<MANU>
presenter = [  ];
end 
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpm9BbLp.p.
% Please follow local copyright laws when handling this file.

