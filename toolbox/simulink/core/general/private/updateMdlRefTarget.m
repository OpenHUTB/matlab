function [ status, reason, mainObjFolder, slxcData ] = updateMdlRefTarget( mdl,  ...
pathToMdl,  ...
targetType,  ...
tmpUpdateCtrl,  ...
childStatus,  ...
iBuildArgs,  ...
iMdlRefSimModes,  ...
iTopTflChecksum,  ...
runningForExternalMode,  ...
verbose,  ...
parBDir,  ...
mdlRefs,  ...
clientFileGenCfg,  ...
masterAnchorFolder,  ...
skipRebuild )




updatePackagedArtifacts = false;
mainObjFolder = '';
slxcData = {  };
status = Simulink.ModelReference.internal.ModelRefStatusHelper.getDefaultStatus(  );


if ( bdIsLoaded( mdl ) )

if ( strcmp( get_param( mdl, 'IsHarness' ), 'on' ) )
DAStudio.error( 'Simulink:Harness:TestHarnessNotSupportedForMdlRefBuilds', mdl );
end 

if ( isempty( get_param( mdl, 'FileName' ) ) )
if strcmp( targetType, 'RTW' )
DAStudio.error( 'Simulink:modelReference:referencedModelNeverSavedCoder', mdl );
else 
DAStudio.error( 'Simulink:modelReference:referencedModelNeverSavedSIM', mdl );
end 
end 
end 


if skipRebuild



reason = DAStudio.message( 'Simulink:slbuild:skipPartOfRebuildManager', mdl );
sl_disp_info( reason, verbose );
return ;
end 



fullPathOnDisk = which( mdl );



if ( isempty( dir( fullPathOnDisk ) ) )
DAStudio.error( 'Simulink:modelReference:unableToFindMdlFile', fullPathOnDisk, mdl );
end 

[ ~, nameOnDisk ] = fileparts( fullPathOnDisk );
if ( strcmp( nameOnDisk, mdl ) == 0 )
DAStudio.error( 'Simulink:modelReference:unableToLoadBdBecauseOfCase',  ...
mdl, nameOnDisk );
end 

if ~isempty( pathToMdl )
msg = sl( 'construct_modelref_message',  ...
'Simulink:slbuild:checkingStatusOfModelCoder',  ...
'Simulink:slbuild:checkingStatusOfModelSIM',  ...
targetType, mdl, pathToMdl );
else 

msg = sl( 'construct_modelref_message',  ...
'Simulink:slbuild:checkingStatusOfTopModelCoder',  ...
'Simulink:slbuild:checkingStatusOfTopModelSIM',  ...
targetType, mdl );
end 
sl_disp_info( msg, verbose );


if strcmp( targetType, 'RTW' )
minfo_cache = coder.internal.infoMATFileMgr( 'load', 'minfo', mdl, targetType );
setPortableWordSizes ...
( iBuildArgs.XilInfo, minfo_cache.IsPortableWordSizesEnabled );
end 





skipSIMTarget = false;
if strcmp( targetType, 'SIM' ) && iBuildArgs.IsUpdatingSimForRTW
needsMDSSimTarget = ( slfeature( 'NoSimTargetForBuild' ) == 0 ) ||  ...
~Simulink.DistributedTarget.isOnlyMappedToSoftwareNodes( mdl, pathToMdl );

skipSIMTarget = ~needsMDSSimTarget;
end 

if skipSIMTarget

reason = '';
elseif ~Simulink.DistributedTarget.DistributedTargetUtils.requiresRTWBuild(  ...
mdl, pathToMdl, targetType )

reason = DAStudio.message( 'Simulink:mds:BlockIsMappedToHardwareNode', mdl );
binfoCache = coder.internal.infoMATFileMgr(  ...
'createEmptyBinfo', 'binfo', mdl, targetType );



fullMatFileName = coder.internal.infoMATFileMgr ...
( 'getMatFileName', 'binfo', mdl, targetType );
coder.internal.saveMinfoOrBinfo( binfoCache, fullMatFileName );




if loc_hasPIL( iMdlRefSimModes ) || loc_hasSIL( iMdlRefSimModes )
DAStudio.error( 'Simulink:modelReference:SILPILDistributedHardwareNotSupported',  ...
mdl,  ...
pathToMdl );
end 
else 


openMdls = find_system( 'SearchDepth', 0, 'type', 'block_diagram' );
[ rebuild, reason, useChecksum, needToInvokeCompile ] =  ...
configure_model_reference_target_status( mdl,  ...
targetType,  ...
verbose,  ...
childStatus,  ...
tmpUpdateCtrl,  ...
iTopTflChecksum,  ...
iBuildArgs );
openMdlsAfter = find_system( 'SearchDepth', 0, 'type', 'block_diagram' );
newlyOpenedMdls = setdiff( openMdlsAfter, openMdls );




if ~isempty( newlyOpenedMdls )
tmpModelName = Simulink.ModelReference.internal.NewSystemForGlobalVarChecksum.getInstanceModel(  );
newlyOpenedMdls = newlyOpenedMdls( ~strcmp( tmpModelName, newlyOpenedMdls ) );
end 

c = onCleanup( @(  )close_system( newlyOpenedMdls, 0 ) );


if ~rebuild





sl_disp_info( reason, true );
assert( ~needToInvokeCompile );
elseif ( isequal( tmpUpdateCtrl, 'AssumeUpToDate' ) ||  ...
( runningForExternalMode && ~useChecksum ) )



status.targetStatus = Simulink.ModelReference.internal.ModelRefTargetStatus.TARGET_UPDATED;
status.parentalAction = Simulink.ModelReference.internal.ModelRefParentalAction.CHECK_FOR_REBUILD;
status.artifactStatus = Simulink.ModelReference.internal.ModelRefArtifactStatus.CODE_GENERATED_AND_COMPILED;
status.pushParBuildArtifacts = Simulink.ModelReference.internal.ModelRefPushParBuildArtifacts.ALL;
else 
sl_disp_info( reason, verbose );


iBuildArgs.UseChecksum = useChecksum;






isParBuild = ~isempty( parBDir );
if isParBuild
locCopyRequiredStateflowArtifactsToWorker(  ...
targetType, mdlRefs, clientFileGenCfg, parBDir.useSeparateCacheAndCodeGen );
end 

[ codeWasUpToDate, infoStructChanged, wasCodeCompiled,  ...
wasInterfaceResaved, mainObjFolder ] =  ...
build_model_reference_target( mdl, iBuildArgs, iMdlRefSimModes,  ...
'RunningForExternalMode', runningForExternalMode,  ...
'ModelRefSkipCompile', ~needToInvokeCompile ...
 );

[ status, updatePackagedArtifacts ] = locSetupStatus( codeWasUpToDate,  ...
wasCodeCompiled, wasInterfaceResaved, infoStructChanged );






if runningForExternalMode && ~codeWasUpToDate
reason = DAStudio.message( 'Simulink:slbuild:modelReferenceChecksumChanged', mdl );
end 

if status.targetStatus == Simulink.ModelReference.internal.ModelRefTargetStatus.TARGET_WAS_UP_TO_DATE

msg = sl( 'construct_modelref_message',  ...
'Simulink:slbuild:modelReferenceCoderTargetUpToDate',  ...
'Simulink:slbuild:modelReferenceSIMTargetUpToDate',  ...
targetType, mdl );
sl_disp_info( msg, true );
end 

isSIMTarget = loc_isSIMTarget( targetType );
hasPIL = loc_hasPIL( iMdlRefSimModes );
hasSIL = loc_hasSIL( iMdlRefSimModes );


if ( slfeature( 'NoSimTargetForBuild' ) == 0 ) &&  ...
~isSIMTarget && ~iBuildArgs.IsRSim && ( hasPIL || hasSIL )



if ~isempty( parBDir )
codeGenDir = parBDir.primaryOutputDir;
else 
codeGenDir = '';
end 
lTopModelAccelWithProfiling =  ...
iBuildArgs.TopModelAccelWithProfiling;

Simulink.ModelReference.internal.XILSfunction.buildForModel(  ...
mdl,  ...
codeWasUpToDate,  ...
codeGenDir,  ...
masterAnchorFolder,  ...
iBuildArgs.TopOfBuildModel,  ...
lTopModelAccelWithProfiling,  ...
iBuildArgs.XilInfo.IsSilAndPws,  ...
hasSIL,  ...
hasPIL,  ...
iBuildArgs.BaDefaultCompInfo );
end 
end 
end 


if updatePackagedArtifacts
binfoCache = coder.internal.infoMATFileMgr( 'updateField', 'binfo', mdl, targetType,  ...
'rebuildReason', struct( 'date', datetime, 'reason', reason ) );


fullMatFileName = coder.internal.infoMATFileMgr ...
( 'getMatFileName', 'binfo', mdl, targetType );
coder.internal.saveMinfoOrBinfo( binfoCache, fullMatFileName );
end 

slxcData = coder.slxc.populateSLCacheData( mdl,  ...
iBuildArgs,  ...
updatePackagedArtifacts,  ...
runningForExternalMode,  ...
targetType,  ...
parBDir );

end 

function locCopyRequiredStateflowArtifactsToWorker( targetType, mdlRefs,  ...
clientFileGenCfg, useSeparateCacheAndCodeGen )

if isempty( mdlRefs )

return ;
end 

wkrFileGenConfig = Simulink.fileGenControl( 'getConfig' );

if strcmp( targetType, 'SIM' )



locCopyStateflowRtwFilesToWkr(  ...
mdlRefs,  ...
clientFileGenCfg.CacheFolder,  ...
wkrFileGenConfig.CacheFolder );
else 
assert( strcmp( targetType, 'RTW' ) );



locCopyStateflowRtwFilesToWkr(  ...
mdlRefs,  ...
clientFileGenCfg.CacheFolder,  ...
wkrFileGenConfig.CacheFolder );



if useSeparateCacheAndCodeGen
locCopyStateflowRtwFilesToWkr(  ...
mdlRefs,  ...
clientFileGenCfg.CodeGenFolder,  ...
wkrFileGenConfig.CodeGenFolder );
end 
end 
end 

function locCopyStateflowRtwFilesToWkr( mdlRefs, clientCacheOrCodeGen, wkrCacheOrCodeGen )


for i = 1:length( mdlRefs )

sfMdlRefSubdirs = Simulink.internal.io.FileSystem.dirContents(  ...
fullfile( clientCacheOrCodeGen, 'slprj', '_sfprj', mdlRefs{ i } ) );


for j = 1:length( sfMdlRefSubdirs )
stateflowRtwDir = fullfile( 'slprj', '_sfprj', mdlRefs{ i }, sfMdlRefSubdirs{ j }, 'rtw' );
src = fullfile( clientCacheOrCodeGen, stateflowRtwDir );
dst = fullfile( wkrCacheOrCodeGen, stateflowRtwDir );
if isfolder( src )
if ~isfolder( dst )


mkdir( dst );
end 
copyfile( src, dst );
end 
end 
end 
end 

function isSIMTarget = loc_isSIMTarget( targetType )
isSIMTarget = strcmp( targetType, 'SIM' );
end 

function hasPIL = loc_hasPIL( iMdlRefSimMode )
hasPIL = any( strcmp( iMdlRefSimMode,  ...
Simulink.ModelReference.internal.SimulationMode.SimulationModePIL ) );
end 

function hasSIL = loc_hasSIL( iMdlRefSimMode )
hasSIL = any( strcmp( iMdlRefSimMode,  ...
Simulink.ModelReference.internal.SimulationMode.SimulationModeSIL ) );
end 

function [ status, updatePackagedArtifacts ] = locSetupStatus( codeWasUpToDate,  ...
wasCodeCompiled, wasInterfaceResaved, infoStructChanged )

updatePackagedArtifacts = ( ~codeWasUpToDate ) || wasCodeCompiled || wasInterfaceResaved || infoStructChanged;
import Simulink.ModelReference.internal.ModelRefTargetStatus
import Simulink.ModelReference.internal.ModelRefParentalAction
import Simulink.ModelReference.internal.ModelRefArtifactStatus
import Simulink.ModelReference.internal.ModelRefPushParBuildArtifacts
if ~codeWasUpToDate
status.targetStatus = ModelRefTargetStatus.TARGET_UPDATED;
status.parentalAction = ModelRefParentalAction.CHECK_FOR_REBUILD;
status.artifactStatus = ModelRefArtifactStatus.CODE_GENERATED_AND_COMPILED;
status.pushParBuildArtifacts = ModelRefPushParBuildArtifacts.ALL;
else 
if wasCodeCompiled
status.targetStatus = ModelRefTargetStatus.TARGET_UPDATED;
status.parentalAction = ModelRefParentalAction.CHECK_FOR_REBUILD;
status.artifactStatus = ModelRefArtifactStatus.CODE_COMPILED;
status.pushParBuildArtifacts = ModelRefPushParBuildArtifacts.UPDATED;
elseif wasInterfaceResaved
status.targetStatus = ModelRefTargetStatus.TARGET_WAS_UP_TO_DATE;
status.parentalAction = ModelRefParentalAction.CHECK_FOR_REBUILD;
status.artifactStatus = ModelRefArtifactStatus.INTERFACE_INFO_RESAVED;
status.pushParBuildArtifacts = ModelRefPushParBuildArtifacts.UPDATED;
elseif infoStructChanged
status.targetStatus = ModelRefTargetStatus.TARGET_WAS_UP_TO_DATE;
status.parentalAction = ModelRefParentalAction.NO_ACTION_REQUIRED;
status.artifactStatus = ModelRefArtifactStatus.ONLY_INFOSTRUCT_CHANGED;
status.pushParBuildArtifacts = ModelRefPushParBuildArtifacts.UPDATED;
else 
status.targetStatus = ModelRefTargetStatus.TARGET_WAS_UP_TO_DATE;
status.parentalAction = ModelRefParentalAction.NO_ACTION_REQUIRED;
status.artifactStatus = ModelRefArtifactStatus.ALL_ARTIFACTS_UP_TO_DATE;
status.pushParBuildArtifacts = ModelRefPushParBuildArtifacts.NONE;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXWvcyk.p.
% Please follow local copyright laws when handling this file.

