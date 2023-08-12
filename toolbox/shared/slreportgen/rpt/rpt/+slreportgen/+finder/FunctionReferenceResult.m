classdef FunctionReferenceResult < mlreportgen.finder.Result




































properties ( SetAccess = protected )



Object = [  ];
end 

properties ( SetAccess = { ?mlreportgen.finder.Result } )











CallingBlocks string





FilePath string = string.empty(  );






BlockParameters string






CallingExpressions string









FunctionType string
end 

properties ( Access = protected, Hidden )
Reporter = [  ];
end 

properties 




Tag;
end 

methods ( Access = { ?slreportgen.finder.FunctionReferenceFinder } )
function this = FunctionReferenceResult( varargin )
this = this@mlreportgen.finder.Result( varargin{ : } );

mustBeNonempty( this.Object );
mustBeTextScalar( this.Object );
end 
end 

methods 
function set.Object( this, value )

this.Object = string( value );
end 

function reporter = getReporter( this )









if isempty( this.Reporter )
reporter = slreportgen.report.FunctionReference( "Object", this );
this.Reporter = reporter;
else 
reporter = this.Reporter;
end 
end 

function title = getDefaultSummaryTableTitle( ~, varargin )






title = string( getString( message( "slreportgen:report:SummaryTable:functions" ) ) );
end 

function props = getDefaultSummaryProperties( ~, varargin )











props = [ "Name", "Calling Blocks", "Calling Expressions" ];
end 

function propVals = getPropertyValues( this, propNames, options )
























R36
this
propNames string
options.ReturnType( 1, 1 )string ...
{ mustBeMember( options.ReturnType, [ "native", "string", "DOM" ] ) } = "native"
end 


returnDOMValue = strcmp( options.ReturnType, "DOM" );


nProps = numel( propNames );
propVals = cell( 1, nProps );

for idx = 1:nProps

prop = strrep( propNames( idx ), " ", "" );
normProp = lower( prop );
switch normProp
case { "object", "functionname", "name" }
val = this.Object;
case "callingblocks"
if returnDOMValue

users = this.CallingBlocks;
nUsers = numel( users );
val = mlreportgen.dom.InternalLink.empty( 0, nUsers );
for userIdx = 1:nUsers
currUser = users( userIdx );
val( userIdx ) = mlreportgen.dom.InternalLink(  ...
slreportgen.utils.getObjectID( currUser ),  ...
currUser );
end 
else 
val = this.CallingBlocks;
end 
otherwise 
if isprop( this, prop )

val = this.( prop );
else 
val = "N/A";
end 
end 


if returnDOMValue && numel( val ) > 1
val = mlreportgen.dom.UnorderedList( val );
val.StyleName = this.SummaryTableListStyle;
end 

propVals{ idx } = val;
end 
end 

function id = getReporterLinkTargetID( this )







id = getReporterLinkTargetID@mlreportgen.finder.Result( this );
if isempty( id )
id = slreportgen.report.FunctionReference.getLinkTargetID( this.Object, this.FilePath );
end 
end 

function presenter = getPresenter( this )%#ok<MANU>
presenter = [  ];
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpHWoVx8.p.
% Please follow local copyright laws when handling this file.

