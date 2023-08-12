function validateDesignStudy( designStudy )




R36
designStudy( 1, 1 )simulink.multisim.mm.design.DesignStudy
end 

validateChildrenParameterSpaces( designStudy.ParameterSpace );
end 

function validateChildrenParameterSpaces( parameterSpace )
R36
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
R36
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
R36
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmpBRo8sW.p.
% Please follow local copyright laws when handling this file.

