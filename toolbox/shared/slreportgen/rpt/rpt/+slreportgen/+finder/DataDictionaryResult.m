classdef DataDictionaryResult < mlreportgen.finder.Result






























properties ( SetAccess = protected )



Object




Name string
end 

properties ( Access = protected, Hidden )
Reporter = [  ];
end 

properties 




Tag;
end 

methods ( Access = { ?slreportgen.finder.DataDictionaryFinder } )
function this = DataDictionaryResult( varargin )
this = this@mlreportgen.finder.Result( varargin{ : } );
mustBeNonempty( this.Object );


[ ~, name, ext ] = fileparts( this.Object );
this.Name = strcat( name, ext );
end 
end 

methods 
function reporter = getReporter( this )









if isempty( this.Reporter )
reporter = slreportgen.report.DataDictionary( "Name", this.Name, "Dictionary", this.Object );
this.Reporter = reporter;
else 
reporter = this.Reporter;
end 
end 

function title = getDefaultSummaryTableTitle( ~, varargin )






title = string( getString( message( "slreportgen:report:SummaryTable:dataDictionaries" ) ) );
end 

function props = getDefaultSummaryProperties( ~, varargin )









props = [ "Name", "DataSources" ];
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

dict = Simulink.data.dictionary.open( this.Object );
for idx = 1:nProps

prop = strrep( propNames( idx ), " ", "" );
normProp = lower( prop );
switch normProp
case "path"
val = this.Object;
case "datasources"

val = string( dict.DataSources );
if returnDOMValue && numel( val ) > 1
val = mlreportgen.dom.UnorderedList( val );
val.StyleName = this.SummaryTableListStyle;
end 
otherwise 
if isprop( this, prop )

val = this.( prop );
elseif isprop( dict, prop )

val = dict.( prop );
else 
val = "N/A";
end 

if ~returnRawValue
val = mlreportgen.utils.toString( val );
end 
end 

propVals{ idx } = val;
end 
end 

function id = getReporterLinkTargetID( this )







id = getReporterLinkTargetID@mlreportgen.finder.Result( this );
if isempty( id )
id = slreportgen.report.DataDictionary.getLinkTargetID( this.Object );
end 
end 

function presenter = getPresenter( this )%#ok<MANU>
presenter = [  ];
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpGlPCik.p.
% Please follow local copyright laws when handling this file.

