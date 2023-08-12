classdef ( ConstructOnLoad = true, UseClassDefaultsOnLoad = true, Sealed )Scatter ...
 < matlab.graphics.chart.primitive.internal.AbstractScatter




properties ( SetObservable, Dependent )
Marker matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle = 'o';
MarkerFaceColor matlab.internal.datatype.matlab.graphics.datatype.MarkerColor = 'none';
MarkerFaceAlpha matlab.internal.datatype.matlab.graphics.datatype.MarkerAlpha = 1;
end 
properties ( Hidden )
MarkerMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto';
MarkerFaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto';
MarkerFaceAlphaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto';
end 
properties ( AffectsObject, AffectsLegend, AbortSet, Hidden )
Marker_I matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle = 'o';
MarkerFaceColor_I matlab.internal.datatype.matlab.graphics.datatype.MarkerColor = 'none';
MarkerFaceAlpha_I matlab.internal.datatype.matlab.graphics.datatype.MarkerAlpha = 1;
end 


methods ( Access = 'protected', Hidden = true )
function doSetup( hObj )

hObj.Type = 'scatter';
addDependencyConsumed( hObj, { 'figurecolormap', 'colorspace', 'colororder_linestyleorder', 'hintconsumer' } );



internalModeStorage = true;
hObj.linkDataPropertyToChannel( 'XData', 'X', internalModeStorage );
hObj.linkDataPropertyToChannel( 'YData', 'Y', internalModeStorage );
hObj.linkDataPropertyToChannel( 'ZData', 'Z', internalModeStorage );
hObj.linkDataPropertyToChannel( 'SizeData', 'Size', internalModeStorage );
hObj.linkDataPropertyToChannel( 'CData', 'Color', internalModeStorage );
hObj.linkDataPropertyToChannel( 'AlphaData', 'Alpha', internalModeStorage );



addlistener( hObj, { 'XJitter', 'YJitter', 'ZJitter',  ...
'XJitterWidth', 'YJitterWidth', 'ZJitterWidth' },  ...
'PostSet', @( ~, ~ )hObj.setJitterDirty(  ) );


hgfilter( 'MarkerStyleToPrimMarkerStyle', hObj.MarkerHandle, hObj.Marker_I );
hgfilter( 'MarkerStyleToPrimMarkerStyle', hObj.MarkerHandleNaN, hObj.Marker_I );


hObj.CurrentIconColorInfo = matlab.graphics.chart.primitive.internal.abstractscatter.IconColorInfoCache;
end 

function setJitterDirty( hObj )
hObj.JitterDirty_I = true;
end 

[ order, x, y, z, s, a, c ] = getCleanData( hObj, x, y, z, s, a, c, stripnanc )
end 


methods ( Static, Hidden )
function validateData( dataMap )
R36
dataMap( 1, 1 )matlab.graphics.data.DataMap
end 

channels = string( fieldnames( dataMap.Map ) );
keep = ismember( channels, [ "X", "Y", "Z", "Size", "Color", "Alpha" ] );
channels = channels( keep );
for c = channels'
subscript = dataMap.Map.( c );
data = dataMap.DataSource.getData( subscript );
for d = 1:numel( data )
matlab.graphics.chart.primitive.Scatter.validateDataPropertyValue( c, data{ d } );
end 
end 
end 
end 


methods 
function val = get.Marker( hObj )
val = hObj.Marker_I;
end 
function set.Marker( hObj, val )
hObj.MarkerMode = 'manual';
hObj.Marker_I = val;
end 
function storedValue = get.MarkerMode( hObj )
storedValue = hObj.MarkerMode;
end 
function set.MarkerMode( hObj, val )
hObj.MarkerMode = val;
end 
function set.Marker_I( hObj, val )

fanChild = hObj.MarkerHandle;
if ~isempty( fanChild ) && isvalid( fanChild )

hgfilter( 'MarkerStyleToPrimMarkerStyle', fanChild, val );
end 
fanChild = hObj.MarkerHandleNaN;
if ~isempty( fanChild ) && isvalid( fanChild )

hgfilter( 'MarkerStyleToPrimMarkerStyle', fanChild, val );
end 
hObj.Marker_I = val;
end 
function val = get.MarkerFaceColor( hObj )
val = hObj.MarkerFaceColor_I;
end 
function set.MarkerFaceColor( hObj, val )
hObj.MarkerFaceColorMode = 'manual';
hObj.MarkerFaceColor_I = val;
end 
function set.MarkerFaceColorMode( hObj, val )
hObj.MarkerFaceColorMode = val;
end 
function val = get.MarkerFaceAlpha( hObj )
val = hObj.MarkerFaceAlpha_I;
end 
function set.MarkerFaceAlpha( hObj, val )
hObj.MarkerFaceAlphaMode = 'manual';
hObj.MarkerFaceAlpha_I = val;
end 
function set.MarkerFaceAlphaMode( hObj, val )
hObj.MarkerFaceAlphaMode = val;
end 
end 
methods ( Hidden )
mcodeConstructor( this, code )
varargout = mapSize( hObj, sz, us )
end 
methods ( Static, Access = protected )
function data = validateDataPropertyValue( channelName, data )
if strcmp( channelName, 'Size' )

try 
hgcastvalue( 'matlab.graphics.datatype.PositiveOrNanVectorData', data );
catch 
error( message( 'MATLAB:hg:shaped_arrays:PositiveOrNanVectorDataPredicate' ) )
end 
end 
data = validateDataPropertyValue@matlab.graphics.chart.primitive.internal.AbstractScatter( channelName, data );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpfTmFS0.p.
% Please follow local copyright laws when handling this file.

