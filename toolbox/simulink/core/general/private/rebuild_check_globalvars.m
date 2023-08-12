function [ forceRebuild, oReasonMdlRef, changedVar ] = rebuild_check_globalvars( binfo_cache, iTargetType, iMdl, tgtShortName )






forceRebuild = false;
oReasonMdlRef = '';
changedVar = '';

isCksEq = true;

globalParamInfo = binfo_cache.globalsInfo.GlobalParamInfo;
globalVarList = globalParamInfo.VarList;

if ~isempty( globalVarList )
checksum = globalParamInfo.Checksum;
varChecksums = globalParamInfo.VarChecksums;


toPerformCleanup = false;

[ currentChecksum, currentVarChecksums ] = loc_doCheck( iMdl,  ...
iTargetType, globalParamInfo, binfo_cache, toPerformCleanup );
isCksEq = isequal( currentChecksum, checksum );



if ~isCksEq
mdlsLoaded = load_model( iMdl );

if ~isempty( mdlsLoaded )
[ currentChecksum, currentVarChecksums ] = loc_doCheck( iMdl,  ...
iTargetType, globalParamInfo, binfo_cache, toPerformCleanup );
isCksEq = isequal( currentChecksum, checksum );

if isCksEq
close_models( mdlsLoaded );
end 
end 
end 
end 

if ~isCksEq
forceRebuild = true;
[ changedVar, oReasonMdlRef ] = loc_getChangedVarsAndRebuildReason(  ...
iTargetType, tgtShortName, iMdl, varChecksums, currentVarChecksums,  ...
globalVarList );
end 
end 

function [ checksum, varChecksums ] = loc_doCheck( iMdl, iTargetType, globalParamInfo, binfo_cache, toPerformCleanup )
[ checksum, varChecksums ] = getGlobalParamChecksum( iMdl,  ...
iTargetType,  ...
globalParamInfo,  ...
binfo_cache.globalsInfo.InlineParameters,  ...
binfo_cache.globalsInfo.IgnoreCustomStorageClasses,  ...
binfo_cache.designDataLocation,  ...
toPerformCleanup,  ...
true,  ...
binfo_cache.enableAccessToBaseWorkspace );
end 

function [ changedVar, oReasonMdlRef ] = loc_getChangedVarsAndRebuildReason( iTargetType,  ...
tgtShortName, iMdl, varChecksums, currentVarChecksums, globalVarList )

oReasonMdlRef = '';


[ varList, changedVar ] = getChangedGlobalVariablesFromChecksums( globalVarList,  ...
varChecksums, currentVarChecksums );


if strcmp( iTargetType, 'NONE' )
return ;
end 


oReasonMdlRef = sl( 'construct_modelref_message',  ...
'Simulink:slbuild:incompatibleGlobalVariablesCoder',  ...
'Simulink:slbuild:incompatibleGlobalVariablesSIM',  ...
iTargetType, tgtShortName, iMdl, varList );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpF7Wv4L.p.
% Please follow local copyright laws when handling this file.

