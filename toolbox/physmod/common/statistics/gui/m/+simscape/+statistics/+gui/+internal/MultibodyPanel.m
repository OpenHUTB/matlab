classdef MultibodyPanel < handle
events 
SelectionChanged
end 
properties ( SetAccess = private )
Data table = lDefaultData(  )
UITable
end 
properties ( Constant )
Tag = "MultibodyPanel"
end 
properties ( SetAccess = private )
Selection( 1, : )cell = cell( 1, 0 )
end 
properties ( Access = private )
RowIds
end 
methods 
function obj = MultibodyPanel( data, parent, args )
R36
data table = lDefaultData(  )
parent( 1, 1 )matlab.graphics.Graphics = uigridlayout( uifigure, 'RowHeight', { '1x' }, 'ColumnWidth', { '1x' } )
args( 1, : )cell = {  }
end 
obj.Data = data;
tbl = findobj( parent, 'Tag', obj.Tag );
if isempty( tbl )
obj.UITable = uitable( parent,  ...
'Data', [ obj.Data{ :, { 'Name', 'Value' } } ], args{ : },  ...
'ColumnFormat', { 'char', 'char' },  ...
'ColumnName', { 'Description', 'Value' },  ...
'Tag', obj.Tag );
obj.UITable.SelectionChangedFcn = @( varargin )broadcastSelectionChanged( obj, varargin );
obj.UITable.SelectionType = 'row';
addStyle( obj.UITable, uistyle( 'FontWeight', 'bold' ), 'column', 1 );
obj.UITable.ColumnSortable = [ true, true ];
obj.UITable.ColumnWidth = { 'fit', 'auto' };
else 
obj.UITable = tbl;
set( obj.UITable, 'Data', [ obj.Data{ :, { 'Name', 'Value' } } ] );
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
t = struct2table( struct( 'Description', {  }, 'ID', {  }, 'Name', {  }, 'Value', {  } ) );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpMX_Cuo.p.
% Please follow local copyright laws when handling this file.

