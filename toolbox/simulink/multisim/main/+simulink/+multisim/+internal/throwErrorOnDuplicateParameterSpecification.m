function throwErrorOnDuplicateParameterSpecification( designStudy )




R36
designStudy( 1, 1 )simulink.multisim.mm.design.DesignStudy
end 

parameterMap = containers.Map;
checkForDuplicateSpecificationInHierarchy( designStudy.ParameterSpace, parameterMap );
end 

function checkForDuplicateSpecificationInHierarchy( parameterSpace, parameterMap )
R36
parameterSpace( 1, 1 )simulink.multisim.mm.design.CombinatorialParameterSpace
parameterMap containers.Map
end 

if parameterSpace.CombinationType == simulink.multisim.mm.design.ParameterSpaceCombinationType.SimulationGroup
checkForDuplicateSpecificationInSimulationGroupHierarchy( parameterSpace, parameterMap );
return ;
end 

parameterSpaces = parameterSpace.ParameterSpaces;
for parameterSpaceIdx = 1:parameterSpaces.Size
childParameterSpace = parameterSpaces( parameterSpaceIdx );
if isa( childParameterSpace, "simulink.multisim.mm.design.CombinatorialParameterSpace" )
checkForDuplicateSpecificationInHierarchy( childParameterSpace, parameterMap );
elseif isa( childParameterSpace, "simulink.multisim.mm.design.SingleParameterSpace" )
checkForDuplicateSpecification( childParameterSpace, parameterMap );
end 
end 
end 

function checkForDuplicateSpecification( singleParameterSpace, parameterMap )
R36
singleParameterSpace( 1, 1 )simulink.multisim.mm.design.SingleParameterSpace
parameterMap containers.Map
end 

paramSpaceType = singleParameterSpace.Type;

switch ( class( paramSpaceType ) )
case "simulink.multisim.mm.design.BlockParameter"
checkForDuplicateBlockParameter( paramSpaceType, parameterMap, singleParameterSpace.Label );

case "simulink.multisim.mm.design.Variable"
checkForDuplicateVariable( paramSpaceType, parameterMap, singleParameterSpace.Label );


end 
end 

function checkForDuplicateBlockParameter( blockParameter, parameterMap, parameterSpaceLabel )
R36
blockParameter( 1, 1 )simulink.multisim.mm.design.BlockParameter
parameterMap containers.Map
parameterSpaceLabel( 1, 1 )string
end 

uniqueIdentifier = blockParameter.BlockPath + ":" + blockParameter.Name;
if parameterMap.isKey( uniqueIdentifier )
error( message( "multisim:SetupGUI:MultipleSpecificationsForBlockParam",  ...
blockParameter.Name, blockParameter.BlockPath, parameterSpaceLabel, parameterMap( uniqueIdentifier ).Label ) );
else 
singleParameterSpace = blockParameter.Container;
parameterMap( uniqueIdentifier ) = singleParameterSpace;
end 
end 

function checkForDuplicateVariable( variableParameter, parameterMap, parameterSpaceLabel )
R36
variableParameter( 1, 1 )simulink.multisim.mm.design.Variable
parameterMap containers.Map
parameterSpaceLabel( 1, 1 )string
end 

uniqueIdentifier = variableParameter.Name + ":" + variableParameter.Workspace;
if parameterMap.isKey( uniqueIdentifier )
error( message( "multisim:SetupGUI:MultipleSpecificationsForVariable",  ...
variableParameter.Name, variableParameter.Workspace, parameterSpaceLabel, parameterMap( uniqueIdentifier ).Label ) );
else 
singleParameterSpace = variableParameter.Container;
parameterMap( uniqueIdentifier ) = singleParameterSpace;
end 
end 

function checkForDuplicateSpecificationInSimulationGroupHierarchy( parameterSpace, oldParameterMap )
R36
parameterSpace( 1, 1 )simulink.multisim.mm.design.CombinatorialParameterSpace
oldParameterMap containers.Map
end 

allChildrenParameterMap = containers.Map;

parameterSpaces = parameterSpace.ParameterSpaces;
for parameterSpaceIdx = 1:parameterSpaces.Size
childParameterMap = containers.Map;
childParameterSpace = parameterSpaces( parameterSpaceIdx );
if isa( childParameterSpace, "simulink.multisim.mm.design.CombinatorialParameterSpace" )
checkForDuplicateSpecificationInHierarchy( childParameterSpace, childParameterMap );
elseif isa( childParameterSpace, "simulink.multisim.mm.design.SingleParameterSpace" )
checkForDuplicateSpecification( childParameterSpace, childParameterMap );
end 

childUniqueIdentifiers = keys( childParameterMap );
for uniqueIdentifierIdx = 1:length( childUniqueIdentifiers )
uniqueIdentifier = childUniqueIdentifiers{ uniqueIdentifierIdx };
if ~allChildrenParameterMap.isKey( uniqueIdentifier )
allChildrenParameterMap( uniqueIdentifier ) = childParameterMap( uniqueIdentifier );
end 
end 
end 

childSingleParameterSpaces = values( allChildrenParameterMap );
for singleParameterSpaceIdx = 1:length( childSingleParameterSpaces )
singleParameterSpace = childSingleParameterSpaces{ singleParameterSpaceIdx };
checkForDuplicateSpecification( singleParameterSpace, oldParameterMap );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpfkq5qF.p.
% Please follow local copyright laws when handling this file.

