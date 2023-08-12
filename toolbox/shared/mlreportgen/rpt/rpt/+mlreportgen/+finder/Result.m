classdef ( Abstract, Hidden )Result < matlab.mixin.SetGet & matlab.mixin.Heterogeneous






properties ( Abstract, SetAccess = protected )


Object;
end 

properties ( Abstract )
Tag;
end 

properties ( Access = protected, Constant )
SummaryTableListStyle = "SummaryTableList";
end 

methods 
function h = Result( varargin )
if ( nargin == 1 )
args = { "Object", varargin{ 1 } };
else 
args = varargin;
end 

nargs = numel( args );
for i = 1:2:nargs
pName = char( args{ i } );
pValue = args{ i + 1 };
h.( pName ) = pValue;
end 
end 

function id = getReporterLinkTargetID( this )


rptr = getReporter( this );
id = rptr.LinkTarget;
if isa( id, "mlreportgen.dom.LinkTarget" )
id = id.Name;
end 
end 
end 

methods ( Abstract )

title = getDefaultSummaryTableTitle( ~, varargin )



props = getDefaultSummaryProperties( ~, varargin )




propVals = getPropertyValues( ~, ~, varargin )
end 

methods ( Access = protected )
function content = formatDOMPropertyValue( this, domObj, options )







R36
this
domObj
options.ConvertToString( 1, 1 )logical = true
end 

if ~options.ConvertToString
content = domObj;
if isa( domObj, "mlreportgen.dom.List" )

domObj.StyleName = this.SummaryTableListStyle;
else 

domObj.StyleName = "";
end 
else 
if isa( domObj, "mlreportgen.dom.List" )
entries = domObj.Children;
nEntries = numel( entries );


content = strings( 1, nEntries );
for idx = 1:nEntries
content( idx ) = mlreportgen.utils.internal.getDOMContentString( entries( idx ) );
end 
else 

content = mlreportgen.utils.internal.getDOMContentString( domObj );
end 
end 
end 
end 

methods ( Abstract )
reporter = getReporter( h );
end 

methods ( Abstract, Hidden )
presenter = getPresenter( h );
end 

methods ( Static, Sealed, Access = protected )
function out = getDefaultScalarElement(  )
out = mlreportgen.finder.NullResult(  );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpO6EthJ.p.
% Please follow local copyright laws when handling this file.

