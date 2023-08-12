function validateSimulinkObjsAndMRHierarchy( topModel, subsys, isInUIMode )




R36
topModel;
subsys;
isInUIMode = false;
end 

topModel = string( topModel );
subsys = string( subsys );
referencedModels = loadMdlRefHierarchyIfNotLoaded( topModel );
MRHeirarchy = cell2mat( get_param( referencedModels, "Handle" ) );
assert( all( MRHeirarchy ~=  - 1 ) );
subsystemHandles = getSimulinkBlockHandle( cellstr( subsys ) );

for i = 1:numel( referencedModels )
subsystemHandles( subsys == referencedModels{ i } ) = MRHeirarchy( i );
end 
invalidInds = subsystemHandles ==  - 1;
if any( invalidInds )
if ~isInUIMode
stm.internal.TestForSubsystem.throwInvSimulinkObjError( invalidInds );
else 
stm.internal.TestForSubsystem.throwInvBlkErrorForUI( strjoin( subsys( invalidInds ), ", " ) )
end 
end 
subModelHandles = bdroot( subsystemHandles );
compIndsNotInMRHeirarchy = ~ismember( subModelHandles, MRHeirarchy );
if any( compIndsNotInMRHeirarchy )
eID = "stm:general:SubsystemCanNotBeFoundInTopModel";
baseMex = MException( eID, message( eID ).getString );
offendingInds = strjoin( string( find( compIndsNotInMRHeirarchy ) ), ", " );
eID = "stm:TestForSubsystem:BadModelReferenceHeirarchy";
causeMex = MException( eID, message( eID, offendingInds ).getString );
baseMex = baseMex.addCause( causeMex );
throw( baseMex );
end 
end 

function referencedModels = loadMdlRefHierarchyIfNotLoaded( topModel )
if ~bdIsLoaded( topModel )
load_system( topModel );
end 


referencedModels = find_mdlrefs( topModel, 'KeepModelsLoaded', true,  ...
'MatchFilter', @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp51yUwS.p.
% Please follow local copyright laws when handling this file.

