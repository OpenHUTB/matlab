function [ checksum, varChecksums ] = get_modelref_global_variable_checksum( modelName,  ...
targetType, globalParamInfo, inlineParameters, ignoreCSCs, designDataLocation, toCleanup,  ...
computeIndividualVarChecksums, varargin )










paramName = 'GlobalParamsListForChecksumCheckIgnoreTunablePrmTbl';


forTopModel = strcmp( targetType, 'NONE' );
if ( forTopModel )






hModelForCheck = get_param( modelName, 'handle' );

infoStruct = coder.internal.infoMATFileMgr( 'load', 'minfo', modelName, targetType );
if isempty( infoStruct.modelRefs )
paramName = 'GlobalParamsListForChecksumCheckCheckTunablePrmTbl';
end 
else 



if toCleanup
oc1 = onCleanup( @(  )Simulink.ModelReference.internal.NewSystemForGlobalVarChecksum.getInstance( 'delete' ) );
end 


hModelForCheck = Simulink.ModelReference.internal.NewSystemForGlobalVarChecksum.getInstance( 'create' ).getModelName;
hConfigSet = Simulink.ModelReference.internal.NewSystemForGlobalVarChecksum.getInstance( 'create' ).getConfigSet;

if inlineParameters == 0
hConfigSet.set_param( 'InlineParams', 'off' );
else 
hConfigSet.set_param( 'InlineParams', 'on' );
end 

if ( strcmp( targetType, 'RTW' ) )


hConfigSet.set_param( 'IgnoreCustomStorageClasses', ignoreCSCs );
else 




hConfigSet.set_param( 'IgnoreCustomStorageClasses', 'on' );
end 

if ( ~strcmp( designDataLocation, 'base' ) )
set_param( hModelForCheck, 'DataDictionary', designDataLocation );
end 
end 



globalVarList = globalParamInfo.VarList;
collapsedTunableVarList = globalParamInfo.CollapsedTunableList;
globalVarCell{ 1 } = {  };

set_param( hModelForCheck, 'ChecksumReleaseInformation',  ...
locConstructChecksumReleaseInfo( modelName ) );



if ~isempty( globalVarList )
globalVarCell = textscan( globalVarList, '%s', 'delimiter', ',' );
end 




wksVars.VarList = globalVarCell{ 1 };
wksVars.CollapsedVarList = cellfun( @( var )any( strcmp( var, collapsedTunableVarList ) ), wksVars.VarList );

if slfeature( 'SLModelAllowedBaseWorkspaceAccess' ) > 0









set_param( hModelForCheck, 'EnableAccessToBaseWorkspace', varargin{ 1 } );
end 


values = { 'off', 'on' };
set_param( hModelForCheck, 'ModelRefComputeGlobalVarIndividualChecksum',  ...
values{ computeIndividualVarChecksums + 1 } );











if ( slfeature( 'InlinePrmsAsCodeGenOnlyOption' ) == 1 &&  ...
( strcmp( targetType, 'RTW' ) || strcmp( targetType, 'NONE' ) ) )







set_param( hModelForCheck, 'HonorInlineParamsSpec', 1 );
set_param( hModelForCheck, paramName, wksVars );
set_param( hModelForCheck, 'HonorInlineParamsSpec', 0 );
else 
set_param( hModelForCheck, paramName, wksVars );
end 


checksum = get_param( hModelForCheck, 'ChecksumForGlobalParamsList' );
varChecksums = get_param( hModelForCheck, 'ModelRefGlobalVarIndividualChecksum' );
end 

function checksumReleaseInfo = locConstructChecksumReleaseInfo( modelName )
checksumReleaseInfo = [  ];
isProtected = slInternal( 'getReferencedModelFileInformation', modelName );
if ~isProtected
return ;
end 

try 
mdlInfo = Simulink.MDLInfo( modelName );
checksumReleaseInfo.Release = mdlInfo.ReleaseName;
checksumReleaseInfo.ReleaseUpdateLevel = uint32( mdlInfo.ReleaseUpdateLevel );
catch 

end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpzlUxuK.p.
% Please follow local copyright laws when handling this file.

