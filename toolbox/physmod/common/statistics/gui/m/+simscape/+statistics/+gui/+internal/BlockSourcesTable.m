classdef BlockSourcesTable < handle





properties 
Sources( :, 3 )table = lDefaultSources(  )
end 
properties ( SetAccess = private )
UITable
end 
properties ( Constant )
Tag = "BlockSourcesTable"
end 
methods 
function obj = BlockSourcesTable( sources, parent )
R36
sources( :, 3 )table = lDefaultSources(  )
parent( 1, 1 )matlab.graphics.Graphics = uigridlayout( uifigure, 'RowHeight', { '1x' }, 'ColumnWidth', { '1x' } )
end 
obj.Sources = sources;
tbl = findobj( parent, 'Tag', obj.Tag );
if isempty( tbl )
obj.UITable = uitable( parent, 'Data', obj.Sources{ :, { 'VariablePath', 'Description' } } );
obj.UITable.ColumnName = { 'Variable Path', 'Label' };
obj.UITable.ColumnSortable = [ true, true ];
obj.UITable.ColumnWidth = { 'auto', 'auto' };
obj.UITable.RowName = {  };
obj.UITable.RowStriping = false;
obj.UITable.Multiselect = "off";
obj.UITable.Tag = obj.Tag;
b = uistyle( 'FontColor', 'b' );
addStyle( obj.UITable, b, 'column', 1 );





else 
obj.UITable = tbl;
obj.update(  );
end 


obj.UITable.CellSelectionCallback = @( varargin )cellCallback( obj, varargin );
end 

function set.Sources( obj, srces )
obj.Sources = srces;
obj.update(  );
end 
end 
methods ( Access = private )
function update( obj )
R36
obj( 1, 1 )
end 
set( obj.UITable, 'Data', obj.Sources{ :, { 'VariablePath', 'Description' } } );
end 
function cellCallback( obj, varargin )



fcn = @ds.sli.internal.openSource;
s = obj.UITable.Selection;
if ~isempty( s ) && s( 2 ) == 1
sid = obj.Sources{ s( 1 ), 'SID' };
status = fcn( sid );
end 
end 
end 
end 

function d = lDefaultSources(  )
d = struct2table( struct( 'VariablePath', {  }, 'Description', {  }, 'SID', {  } ) );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp7ZSLJP.p.
% Please follow local copyright laws when handling this file.

