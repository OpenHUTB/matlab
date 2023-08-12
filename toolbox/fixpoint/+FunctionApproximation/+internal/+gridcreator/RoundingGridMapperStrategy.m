classdef RoundingGridMapperStrategy < FunctionApproximation.internal.gridcreator.GridMapperStrategy







































properties ( SetAccess = protected )
Rounding( 1, : )char{ mustBeMember( Rounding, { 'previous', 'nearest', 'next' } ) } = 'previous'
end 

methods 
function this = RoundingGridMapperStrategy( rounding )
R36
rounding = 'previous'
end 
this.Rounding = rounding;
end 

function mapGrid( this, keyGrid, valueGrid )
g = griddedInterpolant(  );
g.GridVectors = { keyGrid };
g.Values = 1:numel( keyGrid );
g.Method = this.Rounding;
g.ExtrapolationMethod = 'nearest';

keyGridIndices = g( valueGrid );
nKey = numel( keyGrid );
gridMap = zeros( 2, nKey );
nValue = numel( keyGridIndices );
iKey = 0;
lastValueIndex = 0;
for iValue = 1:nValue
if keyGridIndices( iValue ) > iKey
if iKey > 0
gridMap( 2, iKey ) = iValue - 1;
end 
iKey = keyGridIndices( iValue );
gridMap( 1, iKey ) = iValue;
gridMap( 2, iKey ) = iValue;
lastValueIndex = iValue;
end 
end 
if lastValueIndex < nValue
gridMap( 2, iKey ) = nValue;
end 
this.GridMap = gridMap;
end 

function indices = getIndices( this, keyPair )
start = [  ];
stop = [  ];
key1 = max( keyPair( 1 ), 1 );
nKey = size( this.GridMap, 2 );
key2 = min( keyPair( 2 ), nKey );
if key1 <= key2
starts = this.GridMap( 1, key1:key2 );
stops = this.GridMap( 2, key1:key2 );
start = min( starts( starts > 0 ) );
stop = max( stops( stops > 0 ) );
end 
indices = start:stop;
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpXW6gUy.p.
% Please follow local copyright laws when handling this file.

