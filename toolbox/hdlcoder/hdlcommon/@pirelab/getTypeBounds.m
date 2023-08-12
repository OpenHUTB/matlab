function [ lowerBound, upperBound ] = getTypeBounds( pirType )





upperBound = '';
lowerBound = '';

if pirType.getDimensions > 1
pirType = pirType.BaseType;
end 

if pirType.is1BitType
upperBound = 1;
lowerBound = 0;
elseif pirType.isWordType
exVal = fi( 0, pirType.Signed, pirType.WordLength,  - pirType.FractionLength );
upperBound = exVal.upperbound;
lowerBound = exVal.lowerbound;
end 


end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpqdgbWs.p.
% Please follow local copyright laws when handling this file.

