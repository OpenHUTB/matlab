classdef ZCComponent < simscape.statistics.gui.util.internal.GuiComponent
properties ( Constant )
Layout = lLayout(  );
Tag = lPanel(  );
end 
properties ( Access = private )
ZCPanel = [  ]
Data
end 
methods 
function obj = ZCComponent( data )
obj.Data = data;
end 
function render( obj, figuresMap )
if isempty( obj.ZCPanel )
fig = figuresMap.( lPanel(  ) );
parent = findobj( fig, 'Tag', obj.Tag );
if isempty( parent )
parent = uigridlayout( fig, 'ColumnWidth', { '1x' }, 'RowHeight', { '1x' }, 'Tag', obj.Tag );
end 
obj.ZCPanel = simscape.statistics.gui.internal.ZCPanel(  ...
obj.Data, parent );
end 
end 
function out = label( ~, tag )
out = "";
if strcmp( tag, lPanel(  ) )
out = "Zero Crossing Signals";
end 
end 
function out = description( obj )
R36
obj( 1, 1 )
end 
out = obj.Data.Properties.Description;
end 
end 
end 

function tag = lPanel(  )
tag = "ZeroCrossings";
end 

function layout = lLayout(  )
layout = simscape.statistics.gui.util.internal.Layout( lPanel(  ) );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpntUPi1.p.
% Please follow local copyright laws when handling this file.

