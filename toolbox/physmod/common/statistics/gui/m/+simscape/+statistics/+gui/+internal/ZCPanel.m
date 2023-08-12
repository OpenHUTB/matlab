classdef ZCPanel < handle
events 
SelectionChanged
end 
properties ( SetAccess = private )
Data table = lDefaultData(  )
UITable
end 
properties ( Access = private )
Tag = "ZeroCrossingSignals"
end 
properties ( SetAccess = private )
Selection( 1, : )cell = cell( 1, 0 )
end 
properties ( Access = private )
RowIds
end 
methods 
function obj = ZCPanel( data, parent, args )
R36
data table = lDefaultData(  )
parent( 1, 1 )matlab.graphics.Graphics = uigridlayout( uifigure, 'RowHeight', { '1x' }, 'ColumnWidth', { '1x' } )
args( 1, : )cell = {  }
end 
obj.Data = data;
tbl = findobj( parent, 'Tag', obj.Tag );
if ( isempty( obj.Data ) )
ln = {  };
col = {  };
else 
ln = arrayfun( @( l )lVal1( l ), obj.Data.Line, 'UniformOutput', false );
col = arrayfun( @( c )lVal1( c ), obj.Data.Column, 'UniformOutput', false );
end 
tblData = [ num2cell( obj.Data.nSignals ), obj.Data{ :, { 'BlockName', 'ComponentName' } }, ln, col ];
if isempty( tbl )

obj.UITable = uitable( parent, 'Data', tblData, args{ : }, 'Tag', obj.Tag );
obj.UITable.SelectionChangedFcn = @( varargin )broadcastSelectionChanged( obj, varargin );
obj.UITable.SelectionType = 'row';
obj.UITable.ColumnSortable = [ true, true ];
obj.UITable.ColumnWidth = { 'fit', 'auto', 'auto', 'fit', 'fit' };
obj.UITable.ColumnName = { '# Signals', 'Block', 'Component', 'Ln', 'Col' };
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
obj.Selection = obj.Data{ obj.UITable.Selection, 'SignalName' };
notify( obj, 'SelectionChanged' );
end 
end 
end 

function n = lVal1( d )
n = [  ];
if iscell( d )
d = d{ 1 };
end 
if ~isempty( d )
n = d( 1 );
end 
end 

function t = lDefaultData(  )
t = struct2table( struct( 'BlockName', {  }, 'ComponentName', {  }, 'File', {  }, 'Line', {  }, 'Column', {  } ) );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmprM6ujp.p.
% Please follow local copyright laws when handling this file.

