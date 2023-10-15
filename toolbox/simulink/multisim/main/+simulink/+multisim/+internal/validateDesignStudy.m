function validateDesignStudy( designStudy )




arguments
    designStudy( 1, 1 )simulink.multisim.mm.design.DesignStudy
end

validateChildrenParameterSpaces( designStudy.ParameterSpace );
end

function validateChildrenParameterSpaces( parameterSpace )
arguments
    parameterSpace( 1, 1 )simulink.multisim.mm.design.CombinatorialParameterSpace
end

parameterSpaces = parameterSpace.ParameterSpaces;
for parameterSpaceIdx = 1:parameterSpaces.Size
    childParameterSpace = parameterSpaces( parameterSpaceIdx );
    if isa( childParameterSpace, "simulink.multisim.mm.design.CombinatorialParameterSpace" )
        validateChildrenParameterSpaces( childParameterSpace );
    elseif isa( childParameterSpace, "simulink.multisim.mm.design.SingleParameterSpace" )
        validateSingleParameterSpace( childParameterSpace );
    end
end
end

function validateSingleParameterSpace( singleParameterSpace )
arguments
    singleParameterSpace( 1, 1 )simulink.multisim.mm.design.SingleParameterSpace
end

paramSpaceType = singleParameterSpace.Type;

switch ( class( paramSpaceType ) )
    case "simulink.multisim.mm.design.BlockParameter"
        validateBlockParameter( paramSpaceType, singleParameterSpace.Label );

    case "simulink.multisim.mm.design.Variable"

end
end

function validateBlockParameter( blockParameter, parameterSpaceLabel )
arguments
    blockParameter( 1, 1 )simulink.multisim.mm.design.BlockParameter
    parameterSpaceLabel( 1, 1 )string
end

blockPath = blockParameter.BlockPath;

blockHandle = getSimulinkBlockHandle( blockPath, true );
if ( blockHandle ==  - 1 )
    error( message( "multisim:SetupGUI:InvalidBlockPath", blockPath, parameterSpaceLabel ) );
else
    blockParamName = blockParameter.Name;
    try
        get_param( blockHandle, blockParamName );
    catch
        error( message( "multisim:SetupGUI:InvalidBlockParameterName", blockParamName, parameterSpaceLabel ) );
    end
end
end
