function recalculateNumDesignPoints( parameterSpaces )

arguments
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


