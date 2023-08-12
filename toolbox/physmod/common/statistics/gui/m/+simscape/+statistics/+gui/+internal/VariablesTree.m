classdef VariablesTree < handle




properties ( Dependent, SetAccess = private )
Selection
end 
events 
SelectionChanged
end 
properties ( Access = private )
UITable
Paths
end 
properties ( Access = private, Constant )
Tag = "VariableTree";
end 
methods 
function obj = VariablesTree( data, parent )
R36
data( :, 3 )table = cell2table( cell( 0, 2 ), 'VariableNames',  ...
{ 'Path', 'Name', 'Value' } );
parent( 1, 1 )matlab.graphics.Graphics = uigridlayout(  ...
uifigure, 'RowHeight', { '1x' }, 'ColumnWidth', { '1x' } )
end 

obj.Paths = data{ :, 'Path' };
[ names, isParent ] = lNames( data );
tblData = [ names, num2cell( data{ :, 'Value' } ) ];
maybeTree = findobj( parent, 'Tag', obj.Tag );
if isempty( maybeTree )
obj.UITable = uitable( parent,  ...
'Data', tblData,  ...
'ColumnFormat', { 'char', 'char' },  ...
'SelectionType', 'row',  ...
'RowStriping', false,  ...
'Tag', obj.Tag );
obj.UITable.ColumnName = { 'Description', 'Value' };
obj.UITable.ColumnWidth = { 'fit', 'auto' };
obj.UITable.RowName = {  };
obj.UITable.Multiselect = 'off';
else 
obj.UITable = maybeTree;
set( obj.UITable, 'Data', tblData );
end 
obj.UITable.SelectionChangedFcn = @( varargin )obj.broadcastSelectionChanged;
b = uistyle( 'FontWeight', 'bold' );
removeStyle( obj.UITable );
addStyle( obj.UITable, b, 'row', find( isParent ) );
end 
function out = get.Selection( obj )
s = obj.UITable.Selection;
if ~isempty( s )
out = obj.Paths( s );
else 
out = string( missing );
end 
end 
end 
methods ( Access = private )
function broadcastSelectionChanged( obj )
notify( obj, 'SelectionChanged' );
end 
end 
end 

function [ names, isParent ] = lNames( data )
depth = count( data{ :, 'Path' }, '.' );
names = string( data{ :, 'Name' } );
for idx = 1:numel( names )
prefix = string( repmat( char( 160 ), 1, 2 * ( depth( idx ) - 1 ) ) );
names( idx ) = strcat( prefix, lClean( names( idx ) ) );
end 
isParent = depth < max( depth );
end 

function s = lClean( s )
s = strrep( s, "Number of ", "" );
s = char( s );
s( 1 ) = upper( s( 1 ) );
s = string( s );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp0kqse7.p.
% Please follow local copyright laws when handling this file.

