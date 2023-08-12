function [ oReason, oBSCause ] = get_model_dependency_type_message( aType, iTargetType, tgtShortName, iMdl, aDep )




desiredType = 'Simulink.ModelReference.internal.ModelDependencyType';
assert( isa( aType, desiredType ) );

switch ( aType )
case 'MODELDEP_WORKSPACE_FILE'
coderID = 'Simulink:slbuild:mdlWkspaceDependencyUpdatedSinceLastBuildCoder';
simID = 'Simulink:slbuild:mdlWkspaceDependencyUpdatedSinceLastBuildSIM';
causeID = 'Simulink:slbuild:bs2mdlWkspaceDependencyChange';
case 'MODELDEP_MCOS_ENUM'
coderID = 'Simulink:slbuild:internalDependencyUpdatedSinceLastBuildCoderMCOSEnum';
simID = 'Simulink:slbuild:internalDependencyUpdatedSinceLastBuildSIMMCOSEnum';
causeID = 'Simulink:slbuild:bs3MCOSEnumDependencyChange';
case 'MODELDEP_REQUIREMENT'
coderID = 'Simulink:slbuild:internalDependencyUpdatedSinceLastBuildCoderRequirement';
simID = 'Simulink:slbuild:internalDependencyUpdatedSinceLastBuildSIMRequirement';
causeID = 'Simulink:slbuild:bs3RequirementDependencyChange';
otherwise 
assert( false, [ 'Message for ', aType.char, ' is not defined' ] );
end 

if ~strcmpi( iTargetType, 'NONE' )
oReason = construct_modelref_message( coderID, simID,  ...
iTargetType, tgtShortName, iMdl, aDep );
else 
oReason = '';
end 
oBSCause = DAStudio.message( causeID, aDep );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp8gXWVQ.p.
% Please follow local copyright laws when handling this file.

