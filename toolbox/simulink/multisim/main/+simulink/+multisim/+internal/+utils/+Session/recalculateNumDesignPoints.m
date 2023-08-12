function recalculateNumDesignPoints( parameterSpaces )





R36
parameterSpaces( 1, : )simulink.multisim.mm.design.ParameterSpace
end 

for parameterSpace = parameterSpaces
if isa( parameterSpace, "simulink.multisim.mm.design.CombinatorialParameterSpace" )
childParameterSpaces = parameterSpace.ParameterSpaces.toArray(  );
simulink.multisim.internal.utils.Session.recalculateNumDesignPoints( childParameterSpaces );
simulink.multisim.internal.utils.CombinatorialParameterSpace.updateNumDesignPoints( parameterSpace );

elseif strcmp( parameterSpace.ValueType, "Explicit" )
simulink.multisim.internal.utils.ExplicitValues.updateNumDesignPoints( parameterSpace );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpUunYFt.p.
% Please follow local copyright laws when handling this file.

