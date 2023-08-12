function updateNumDesignPoints( singleParameterSpace )





R36
singleParameterSpace( 1, 1 )simulink.multisim.mm.design.SingleParameterSpace
end 

try 
paramSpaceSampler = simulink.multisim.internal.sampler.SingleParameterSpace( singleParameterSpace );
numDesignPoints = paramSpaceSampler.getNumDesignPoints(  );
singleParameterSpace.Values.ErrorText = "";
singleParameterSpace.NumDesignPoints = numDesignPoints;
catch 
singleParameterSpace.Values.ErrorText = "Invalid expression";
validDesignPoints = 0;
singleParameterSpace.NumDesignPoints = validDesignPoints;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpZpFnDI.p.
% Please follow local copyright laws when handling this file.

