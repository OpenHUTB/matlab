classdef GridMapperFactory < handle




methods 
function compositeMapper = getCompositeGridMapper( this, mapperStrategies )
R36
this %#ok<INUSA>
mapperStrategies( 1, : )FunctionApproximation.internal.gridcreator.GridMapperStrategy{ mustBeNonempty( mapperStrategies ) }
end 

for idx = numel( mapperStrategies ): - 1:1
gridMappers( idx ) = FunctionApproximation.internal.gridcreator.GridToGridMapper( mapperStrategies( idx ) );
end 
compositeMapper = FunctionApproximation.internal.gridcreator.CompositeGridMapper( gridMappers );
end 

function mapper = getGridToGridMapper( this, mapperStrategy )
R36
this %#ok<INUSA>
mapperStrategy( 1, 1 )FunctionApproximation.internal.gridcreator.GridMapperStrategy
end 
mapper = FunctionApproximation.internal.gridcreator.GridToGridMapper( mapperStrategy );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpQ5gLiU.p.
% Please follow local copyright laws when handling this file.

