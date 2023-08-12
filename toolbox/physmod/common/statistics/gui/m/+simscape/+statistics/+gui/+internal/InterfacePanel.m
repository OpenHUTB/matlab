classdef InterfacePanel < handle
events 
SelectionChanged
end 
properties ( SetAccess = private )
Data table = lDefaultData(  )
UITable
end 
properties ( Access = private )
Tag = "InterfaceSignals"
end 
properties ( SetAccess = private )
Selection( 1, : )cell = cell( 1, 0 )
end 
properties ( Access = private )
RowIds
end 
methods 
function obj = InterfacePanel( data, parent, args )
R36
data table = lDefaultData(  )
parent( 1, 1 )matlab.graphics.Graphics = uigridlayout( uifigure, 'RowHeight', { '1x' }, 'ColumnWidth', { '1x' } )
args( 1, : )cell = {  }
end 
obj.Data = data;
tbl = findobj( parent, 'Tag', obj.Tag );
[ src, dest ] = lSrcDest( obj.Data{ :, 'Sources' } );
tblData = [ src, dest, obj.Data{ :, { 'filterOrder', 'timeConstant' } } ];
obj.RowIds = obj.Data{ :, 'ID' };
if isempty( tbl )
obj.UITable = uitable( parent, 'Data', tblData, args{ : }, 'Tag', obj.Tag );
obj.UITable.SelectionChangedFcn = @( varargin )broadcastSelectionChanged( obj, varargin );
obj.UITable.SelectionType = 'row';
obj.UITable.ColumnSortable = [ true, true ];
obj.UITable.ColumnWidth = { 'auto', 'auto', 'fit', 'fit' };
obj.UITable.ColumnName = { 'Source', 'Destination', 'Filter Order', 'Time Constant' };
obj.UITable.RowName = {  };
obj.UITable.RowStriping = false;
else 
obj.UITable = tbl;
set( obj.UITable, 'Data', tblData );
end 
end 

end 
methods ( Access = private )
function broadcastSelectionChanged( obj, varargin )
obj.Selection = obj.Data{ obj.UITable.Selection, 'ID' };
notify( obj, 'SelectionChanged' );
end 
end 
end 

function t = lDefaultData(  )
t = struct2table( struct(  ...
'ID', {  },  ...
'Name', {  },  ...
'Sources', {  },  ...
'filterUsed', {  },  ...
'filterOrder', {  },  ...
'timeConstant', {  } ) );
end 

function [ src, dst ] = lSrcDest( srces )
src = cellfun( @( t )t{ 1, 'Path' }{ 1 }, srces, 'UniformOutput', false );
dst = cellfun( @( t )t{ 2, 'Path' }{ 1 }, srces, 'UniformOutput', false );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp6NA8bC.p.
% Please follow local copyright laws when handling this file.

