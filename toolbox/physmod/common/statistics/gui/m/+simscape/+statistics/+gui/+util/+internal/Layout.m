classdef Layout






properties ( SetAccess = private )
Tiling( :, : )string{ lValidVariableNames }
ColumnWidth( 1, : )double{ lSumToOne }
RowHeight( 1, : )double{ lSumToOne }
end 


properties ( Dependent )
Tags( 1, : )string{ mustBeValidVariableName }
end 

methods 

function obj = Layout( tiling, args )
R36
tiling( :, : )string{ lValidVariableNames } = [  ]
args.ColumnWidth( 1, : )double = ones( 1, size( tiling, 2 ) ) ./ size( tiling, 2 )
args.RowHeight( 1, : )double = ones( 1, size( tiling, 1 ) ) ./ size( tiling, 1 )
end 
assert( size( tiling, 1 ) == numel( args.RowHeight ),  ...
'RowHeight must be a vector whose lenght matches number of rows in TILING.' )
assert( size( tiling, 2 ) == numel( args.ColumnWidth ),  ...
'ColumnWidth must be a vector whose lenght matches number of columns in TILING.' )
obj.Tiling = tiling;
obj.RowHeight = args.RowHeight;
obj.ColumnWidth = args.ColumnWidth;
end 


function out = get.Tags( obj )
R36
obj( 1, 1 )
end 
out = unique( obj.Tiling );
end 

end 
end 

function lValidVariableNames( str )
arrayfun( @mustBeValidVariableName, str );
end 

function lSumToOne( val )
if ~isempty( val )
assert( abs( sum( val ) - 1 ) < 1e-5, 'Elements must sum to 1.' );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpUeagke.p.
% Please follow local copyright laws when handling this file.

