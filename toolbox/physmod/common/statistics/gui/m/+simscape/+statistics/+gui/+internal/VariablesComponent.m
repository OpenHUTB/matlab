classdef VariablesComponent < simscape.statistics.gui.util.internal.GuiComponent




properties ( Constant )
Layout = lLayout(  );
end 
properties ( Constant, Access = private )
TreeTag = lTree(  );
SourcesTag = lSources(  );
end 
properties ( Access = private )
VariablesView = [  ]
SourcesView = [  ]
Data
SelectionListener
end 
methods 
function obj = VariablesComponent( data )
obj.Data = struct2table( lFlattenData( data, "" ),  ...
'AsArray', true );
end 
function render( obj, figuresMap )


treeFig = figuresMap.( obj.TreeTag );
treeParent = findobj( treeFig, 'Tag', obj.TreeTag );
if isempty( treeParent )
treeParent = uigridlayout( treeFig, 'ColumnWidth', { '1x' }, 'RowHeight', { '1x' }, 'Tag', obj.TreeTag );
end 
obj.VariablesView = simscape.statistics.gui.internal.VariablesTree(  ...
obj.Data( :, { 'Path', 'Name', 'Value' } ), treeParent );

obj.SelectionListener = addlistener( obj.VariablesView,  ...
'SelectionChanged', @( varargin )selectionChangedCB( obj ) );


sourcesFig = figuresMap.( obj.SourcesTag );
sourcesParent = findobj( sourcesFig, 'Tag', obj.SourcesTag );
if isempty( sourcesParent )
sourcesParent = uigridlayout( sourcesFig, 'ColumnWidth', { '1x' }, 'RowHeight', { '1x' }, 'Tag', obj.SourcesTag );
end 
obj.SourcesView =  ...
simscape.statistics.gui.internal.BlockSourcesTable(  ...
obj.currentSource(  ), sourcesParent );
end 

function out = label( ~, tag )
out = tag;
switch tag
case lSources(  )
out = "Selected Variables";
case lTree(  )
out = "Catagories";
end 
end 
function out = description( obj )
R36
obj( 1, 1 )
end 
out = obj.Data{ 1, 'Description' };
end 
end 
methods ( Access = private )
function src = currentSource( obj )
s = obj.VariablesView.Selection;
if ~ismissing( s )
iData = strcmp( [ obj.Data.Path ], s );
assert( nnz( iData ) == 1, 'Cannot find path %s', s );
src = obj.Data{ iData, 'Sources' }{ 1 };
else 
src = lDefaultSources(  );
end 
end 
function selectionChangedCB( obj )
obj.SourcesView.Sources = obj.currentSource(  );
end 
end 
end 

function d = lFlattenData( data, parent )
p = strjoin( [ parent, data.ID ], '.' );
d.Path = p;
d.Name = data.Name;
d.Value = data.Value;
d.Sources = data.Sources;
d.Description = data.Description;
for idx = 1:numel( data.Children )
d = [ d;lFlattenData( data.Children( idx ), p ) ];%#ok<AGROW> 
end 
end 

function tag = lSources(  )
tag = "SelectedVariables";
end 

function tag = lTree(  )
tag = "Categories";
end 

function layout = lLayout(  )
layout = simscape.statistics.gui.util.internal.Layout( [ lTree(  );lSources(  ) ] );
end 

function d = lDefaultSources(  )
d = struct2table( struct( 'VariablePath', {  }, 'Description', {  }, 'SID', {  } ) );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpGKLkCc.p.
% Please follow local copyright laws when handling this file.

