classdef MultibodyComponent < simscape.statistics.gui.util.internal.GuiComponent
properties ( Constant )
Layout = lLayout(  );
Tag = lPanel(  );
end 
properties ( Access = private )
Panel = [  ]
Data
end 
properties ( SetAccess = private )
Name
Description
end 
methods 
function obj = MultibodyComponent( data )
obj.Data = data;
end 
function render( obj, figuresMap )
import simscape.statistics.gui.internal.MultibodyPanel
fig = figuresMap.( lPanel(  ) );
parent = findobj( fig, 'Tag', obj.Tag );
if isempty( parent )
parent = uigridlayout( fig,  ...
'RowHeight', { '1x' },  ...
'ColumnWidth', { '1x' },  ...
'Tag', obj.Tag );
end 
obj.Panel = MultibodyPanel( obj.Data, parent );
end 
function out = get.Name( ~ )
out = "3-D Multibody System";
end 
function out = get.Description( obj )
out = string( obj.Data.Description );
end 
function out = label( obj, tag )
out = "";
if strcmp( tag, obj.Tag )
out = "Multibody Statistics";
end 
end 
function out = description( obj )
R36
obj( 1, 1 )
end 
out = obj.Data.Description;
end 
end 
methods ( Access = private )
function selectionChangedCB( obj, varargin )
s = obj.VariablesTree.Selection;
if isempty( s )
obj.SourcesTable.Sources = lDefaultSources(  );
return 
end 
s = obj.VariablesTree.Selection{ 1 }( 2:end  );
d = obj.Data;
for idx = 1:numel( s )
bMatch = strcmp( { d.Children.ID }, s{ idx } );
d = d.Children( bMatch );
end 
obj.SourcesTable.Sources = d.Sources;
end 
end 
end 

function tag = lPanel(  )
tag = "Statistics";
end 

function layout = lLayout(  )
layout = simscape.statistics.gui.util.internal.Layout( lPanel(  ) );
end 
function d = lDefaultSources(  )
d = struct2table( struct( 'VariablePath', {  }, 'Description', {  }, 'SID', {  } ) );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpuVzIvM.p.
% Please follow local copyright laws when handling this file.

