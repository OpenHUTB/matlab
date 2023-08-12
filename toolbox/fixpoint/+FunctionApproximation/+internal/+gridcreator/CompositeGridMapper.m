classdef ( Sealed )CompositeGridMapper < FunctionApproximation.internal.gridcreator.GridMapper






properties ( Dependent )
NumDimensions
end 

properties ( SetAccess = private )
ChildGridMappers( 1, : )FunctionApproximation.internal.gridcreator.GridToGridMapper
end 

methods 
function this = CompositeGridMapper( childGridMappers )
this.ChildGridMappers = childGridMappers;
end 

function n = get.NumDimensions( this )
n = numel( this.ChildGridMappers );
end 

function setKeyGrid( this, keyGrids, dimensions )
R36
this
keyGrids( 1, : )cell
dimensions( 1, : )double = getDefaultDimensions( this )
end 
for idx = 1:numel( dimensions )
d = dimensions( idx );
this.ChildGridMappers( d ).setKeyGrid( keyGrids{ idx } );
end 
end 

function setValueGrid( this, valueGrids, dimensions )
R36
this
valueGrids( 1, : )cell
dimensions( 1, : )double = getDefaultDimensions( this )
end 
for idx = 1:numel( dimensions )
d = dimensions( idx );
this.ChildGridMappers( d ).setValueGrid( valueGrids{ idx } );
end 
end 

function constructMap( this, dimensions )
R36
this
dimensions( 1, : )double = getDefaultDimensions( this )
end 
for idx = dimensions
this.ChildGridMappers( idx ).constructMap(  );
end 
end 

function indicesSet = getIndices( this, keyPairs, dimensions )
R36
this
keyPairs( 1, : )cell
dimensions( 1, : )double = getDefaultDimensions( this )
end 
indicesSet = cell( 1, numel( dimensions ) );
for idx = 1:numel( dimensions )
d = dimensions( idx );
indicesSet{ idx } = this.ChildGridMappers( d ).getIndices( keyPairs{ idx } );
end 
end 

function valuesSet = getValues( this, keyPairs, dimensions )
R36
this
keyPairs( 1, : )cell
dimensions( 1, : )double = getDefaultDimensions( this )
end 
indicesSet = getIndices( this, keyPairs, dimensions );
valuesSet = cell( 1, numel( dimensions ) );
for idx = 1:numel( dimensions )
d = dimensions( idx );
valuesSet{ idx } = this.ChildGridMappers( d ).ValueGrid( indicesSet{ idx } );
end 
end 

function indicesSet = getKeyGridIndicesWithMapping( this, dimensions )
R36
this
dimensions( 1, : )double = getDefaultDimensions( this )
end 
indicesSet = cell( 1, numel( dimensions ) );
for idx = 1:numel( dimensions )
d = dimensions( idx );
indicesSet{ idx } = this.ChildGridMappers( d ).getKeyGridIndicesWithMapping(  );
end 
end 
end 

methods ( Hidden )
function dimensions = getDefaultDimensions( this )
dimensions = 1:this.NumDimensions;
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpyAzxI3.p.
% Please follow local copyright laws when handling this file.

