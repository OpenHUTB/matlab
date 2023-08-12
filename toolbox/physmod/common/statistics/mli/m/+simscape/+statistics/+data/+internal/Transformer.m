classdef Transformer





properties ( Access = private )
Data( 1, 1 )struct
end 
properties ( Dependent, SetAccess = private )
Paths( :, 1 )string
end 
properties ( Access = private )
Transforms = simscape.statistics.data.internal.TransformRegistry.Transforms(  );
end 
methods 
function obj = Transformer( rawStats )
R36
rawStats struct
end 
if ~isempty( rawStats )
obj.Data = rawStats;
end 
end 
function out = transform( obj, paths )
R36
obj( 1, 1 )
paths string
end 
import simscape.statistics.data.internal.Statistic
if isempty( paths )
out = repmat( Statistic(  ), size( paths ) );
else 
out = arrayfun( @lTransform, paths );
end 
function out = lTransform( p )
out = repmat( Statistic, 0, 0 );
iPath = strcmp( obj.Paths, p );
xform = obj.Transforms( iPath );
if ~isempty( xform )
d = lFetch( obj.Data, p );
if ~isempty( d )
out = xform.Function( d );
end 
end 
end 
end 
function out = get.Paths( obj )

R36
obj( 1, 1 )
end 
out = [ obj.Transforms.Path ]';
end 
function out = hasData( obj, p )


R36
obj( 1, 1 )
p( 1, : )string
end 
out = arrayfun( @( p )~isempty( lFetch( obj.Data, p ) ), p );
end 
end 
end 

function data = lFetch( data, p )


R36
data( 1, 1 )struct
p( 1, 1 )string
end 
ids = strsplit( p, "." );
for idx = 1:numel( ids )
if ~isfield( data, 'Children' ) ||  ...
~isstruct( data.Children ) ||  ...
~isfield( data.Children, 'ID' )
data = [  ];
return ;
end 
r = strcmp( { data.Children.ID }, ids( idx ) );
data = data.Children( r );
if isempty( data )
return 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpt3KQB9.p.
% Please follow local copyright laws when handling this file.

