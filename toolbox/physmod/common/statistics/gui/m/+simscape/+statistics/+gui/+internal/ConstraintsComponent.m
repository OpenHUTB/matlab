classdef ConstraintsComponent < simscape.statistics.gui.util.internal.GuiComponent
properties ( Constant )
Layout = lLayout(  );
ConstraintsTag = lTable(  );
SourcesTag = lSources(  );
end 
properties ( Access = private )
ConstraintsTable = [  ]
SourcesTable = [  ]
Data
SelectionListener
end 
properties ( SetAccess = private )
Description
end 
methods 
function obj = ConstraintsComponent( data )
obj.Data = data;
end 
function render( obj, figuresMap )


tableFig = figuresMap.( obj.ConstraintsTag );
tableParent = findobj( tableFig, 'Tag', obj.ConstraintsTag );
if isempty( tableParent )
tableParent = uigridlayout( tableFig, 'ColumnWidth', { '1x' }, 'RowHeight', { '1x' }, 'Tag', obj.ConstraintsTag );
end 
obj.ConstraintsTable = simscape.statistics.gui.internal.ConstraintsTable(  ...
obj.Data, tableParent );

obj.SelectionListener = addlistener( obj.ConstraintsTable,  ...
'SelectionChanged', @( varargin )selectionChangedCB( obj ) );


sourcesFig = figuresMap.( obj.SourcesTag );
sourcesParent = findobj( sourcesFig, 'Tag', obj.SourcesTag );
if isempty( sourcesParent )
sourcesParent = uigridlayout( sourcesFig, 'ColumnWidth', { '1x' }, 'RowHeight', { '1x' }, 'Tag', obj.SourcesTag );
end 
obj.SourcesTable = simscape.statistics.gui.internal.BlockSourcesTable(  ...
obj.ConstraintsTable.Sources, sourcesParent );


obj.selectionChangedCB(  );
end 

function out = get.Description( obj )
out = string( obj.Data.Properties.Description );
end 
function out = label( ~, tag )
out = tag;
switch tag
case lSources(  )
out = "Selected Variables";
case lTable(  )
out = "Constraints";
end 
end 
function out = description( obj )
R36
obj( 1, 1 )
end 
out = obj.Description;
end 
end 
methods ( Access = private )
function selectionChangedCB( obj )
obj.SourcesTable.Sources = obj.ConstraintsTable.Sources;
end 
end 
end 

function tag = lSources(  )
tag = "SelectedConstraint";
end 

function tag = lTable(  )
tag = "Constraints";
end 

function layout = lLayout(  )
layout = simscape.statistics.gui.util.internal.Layout( [ lTable(  );lSources(  ) ] );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpchXcJp.p.
% Please follow local copyright laws when handling this file.

