classdef CodeInterfaceBase < coder.report.ReportPageBase






properties 
ModelName
BuildDir
ReportCodeIdentifier = true
end 

properties ( Transient, Access = private )
CodeDescriptor
end 


methods 
function obj = CodeInterfaceBase( modelName, buildDir, options )

R36
modelName
buildDir
options.CodeDescriptor
end 
obj.ModelName = modelName;
obj.BuildDir = buildDir;
if isfield( options, 'CodeDescriptor' )
obj.CodeDescriptor = options.CodeDescriptor;
end 
end 

function out = getDefaultReportFileName( ~ )

out = 'interface.html';
end 
end 


methods 
function out = getFunctionDescription( ~, ~ )
out = '';
end 

function out = getFunctionTiming( ~, ~ )
out = '';
end 
end 


methods 
function out = getCodeDescriptor( obj )
if isempty( obj.CodeDescriptor )

obj.CodeDescriptor = coder.getCodeDescriptor(  ...
obj.BuildDir, obj.ModelName, 247362 );
end 
out = obj.CodeDescriptor;
end 

function out = getRelevantType( ~, portData )




out = portData.Implementation.Type;
end 

function [ contents, title ] = getEntryPointFunctions( obj )
[ contents, title ] = coder.internal.codeinfo( 'getHTMLFunctions',  ...
obj.getCodeDescriptor.getComponentInterface,  ...
obj.getCodeDescriptor.getExpInports,  ...
obj.getIncludeHyperlinkInReport,  ...
obj );
end 

function out = getFunctionContents( obj, f )

captions = arrayfun( @( x )obj.getFunctionTableCaption( x ), f );
tables = arrayfun( @( x )obj.getFunctionTable( x ), f );
out = reshape( [ captions;tables ], 1, length( captions ) * 2 );
end 

function out = getInportTable( obj )

out = obj.getDataInterfaceTable( 'Inports',  ...
message( 'RTW:codeInfo:reportBlockName' ).getString );
end 

function out = getOutportTable( obj )

out = obj.getDataInterfaceTable( 'Outports',  ...
message( 'RTW:codeInfo:reportBlockName' ).getString );
end 

function out = getParameterTable( obj )

out = obj.getDataInterfaceTable( 'Parameters',  ...
message( 'RTW:codeInfo:reportParameterSource' ).getString );
end 

function out = getDataStoreTable( obj )

out = obj.getDataInterfaceTable( 'DataStores',  ...
message( 'RTW:codeInfo:reportBlockName' ).getString );
end 

function out = getFunctionTableCaption( ~, f )




out = Advisor.Paragraph( message( 'RTW:codeInfo:reportFunctionHeading', f.Prototype.Name ).getString );
end 
end 


methods ( Access = protected )
function out = getIncludeHyperlinkInReport( obj )

out = false;
manager = obj.getLinkManager;
if isa( manager, 'Simulink.report.HTMLLinkManager' )
out = manager.IncludeHyperlinkInReport;
end 
end 

function out = getCodeHyperlink( ~, contents )
if ~isempty( contents )
out = [ '<a href="javascript: void(0)" onclick="' ...
, coder.report.internal.getPostParentWindowMessageCall( 'jumpToCode', contents ), '">', contents, '</a>' ...
 ];
else 
out = '';
end 
end 

function out = getGraphicalPath( obj, data )
out = coder.internal.codeinfo( 'getGraphicalPath', data,  ...
obj.getIncludeHyperlinkInReport, obj );
end 

function out = getDataInterfaceTable( obj, field, columnHeader )

codeInfo = obj.getCodeDescriptor.getComponentInterface;
out = coder.internal.codeinfo( 'getHTMLDataInterface',  ...
codeInfo.( field ), columnHeader,  ...
obj.getLinkManager.IncludeHyperlinkInReport,  ...
obj );
end 

function out = newTable( ~, contents, width )

dim = size( contents );
if nargin < 3
width = [  ];
end 
out = Advisor.Table( dim( 1 ), dim( 2 ) );
out.setBorder( 1 );
out.setStyle( 'AltRow' );
out.setAttribute( 'width', '100%' );

arrayfun( @( x )out.setColWidth( x, width( x ) ), 1:length( width ) );
out.setEntries( contents );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpd0veBb.p.
% Please follow local copyright laws when handling this file.

