function [ varargout ] = update_model_reference_targets( iMdl, iBuildArgs, parBuildContext )





































oc1 = onCleanup( @(  )Simulink.ModelReference.internal.NewSystemForGlobalVarChecksum.getInstance( 'delete' ) );


oc2 = onCleanup( @(  )set_param( iMdl, 'StatusString', '' ) );

dataId = 'SL_SimulationInputInfo';
modelHandle = get_param( iMdl, 'Handle' );
if Simulink.BlockDiagramAssociatedData.isRegistered( modelHandle, dataId )
simulationInputInfo = Simulink.BlockDiagramAssociatedData.get( modelHandle, dataId );
else 
simulationInputInfo = Simulink.internal.getDefaultSimulationInputInfo(  );
end 
iBuildArgs.SimulationInputInfo = simulationInputInfo;

[ topStatus, buildStatusMgr ] = do_update_model_reference_targets( iMdl, iBuildArgs, parBuildContext );
if ( nargout > 0 )
varargout{ 1 } = topStatus;
varargout{ 2 } = buildStatusMgr;
end 

end 

function [ oTopStatus, buildStatusMgr ] = do_update_model_reference_targets( iMdl, iBuildArgs, parBuildContext )

if iBuildArgs.IsRapidAccelerator
iBuildArgs.ModelReferenceTargetType = 'SIM';
end 
targetType = iBuildArgs.ModelReferenceTargetType;
buildStatusMgr = coder.internal.buildstatus.BuildStatusUIMgr( iMdl, [  ] );







savePWD = pwd;

mdlrefUpdateCtrl = get_param( iMdl, 'UpdateModelReferenceTargets' );

if strcmp( targetType, 'RTW' )




hTflControl = get_param( iMdl, 'TargetFcnLibHandle' );





origModelReferenceTargetType = iBuildArgs.ModelReferenceTargetType;
origGenerateCodeOnly = iBuildArgs.BaGenerateCodeOnly;
origVerbose = iBuildArgs.Verbose;

iBuildArgs.ModelReferenceTargetType = 'SIM';
iBuildArgs.BaGenerateCodeOnly = false;
iBuildArgs.IsUpdatingSimForRTW = true;


iBuildArgs.Verbose = iBuildArgs.SimVerbose;



fileGenCfg = Simulink.fileGenControl( 'getConfig' );
if ~strcmp( pwd, fileGenCfg.CacheFolder )
if ~contains( matlabpath, pwd )
addpath( pwd );
onCleanupPath = onCleanup( @(  )rmpath( savePWD ) );
end 
cd( fileGenCfg.CacheFolder );
rtw_checkdir;
end 


hTflControlSim = get_param( iMdl, 'SimTargetFcnLibHandle' );
set_param( iMdl, 'TargetFcnLibHandle', hTflControlSim );
topTflChecksum = hTflControlSim.getIncrBuildNum(  );











isMDS = strcmp( get_param( iMdl, 'ConcurrentTasks' ), 'on' ) &&  ...
strcmp( get_param( iMdl, 'ExplicitPartitioning' ), 'on' );
simTargetsRequested = iBuildArgs.IncludeModelReferenceSimulationTargets;
if ( slfeature( 'NoSimTargetForBuild' ) == 0 ) || isMDS || simTargetsRequested

if iBuildArgs.OkayToPushNags
target_update_mv_hdr_stage = Simulink.output.Stage(  ...
DAStudio.message( 'Simulink:modelReference:MessageViewer_UpdatingSIMTargets' ),  ...
'ModelName', iMdl, 'UIMode', true );%#ok<NASGU>
end 

[ ~, buildStatusMgr ] = loc_update_model_reference_targets( iMdl,  ...
iBuildArgs,  ...
topTflChecksum,  ...
[  ],  ...
{  },  ...
mdlrefUpdateCtrl,  ...
buildStatusMgr,  ...
parBuildContext );
end 


clear target_update_mv_hdr_stage;


set_param( iMdl, 'TargetFcnLibHandle', hTflControl );
topTflChecksum = hTflControl.getIncrBuildNum(  );


iBuildArgs.ModelReferenceTargetType = origModelReferenceTargetType;
iBuildArgs.BaGenerateCodeOnly = origGenerateCodeOnly;
iBuildArgs.Verbose = origVerbose;
else 
assert( isequal( targetType, 'SIM' ) );

hTflControl = get_param( iMdl, 'SimTargetFcnLibHandle' );
set_param( iMdl, 'TargetFcnLibHandle', hTflControl );
topTflChecksum = hTflControl.getIncrBuildNum(  );
end 


if ~strcmp( pwd, savePWD )
cd( savePWD );
end 
iBuildArgs.IsUpdatingSimForRTW = false;


if iBuildArgs.OkayToPushNags
if strcmp( iBuildArgs.ModelReferenceTargetType, 'RTW' )
msgID = 'Simulink:modelReference:MessageViewer_UpdatingCoderTargets';
else 
msgID = 'Simulink:modelReference:MessageViewer_UpdatingSIMTargets';
end 
target_update_mv_hdr_stage = Simulink.output.Stage(  ...
DAStudio.message( msgID ),  ...
'ModelName', iMdl, 'UIMode', true );%#ok<NASGU>
end 

[ oTopStatus, buildStatusMgr ] =  ...
loc_update_model_reference_targets( iMdl,  ...
iBuildArgs,  ...
topTflChecksum,  ...
[  ],  ...
{  },  ...
mdlrefUpdateCtrl,  ...
buildStatusMgr,  ...
parBuildContext );


clear target_update_mv_hdr_stage;





if iBuildArgs.XilInfo.IsModelBlockXil



fileGenCfg = Simulink.fileGenControl( 'getConfig' );
if ~strcmp( pwd, fileGenCfg.CodeGenFolder )
cd( fileGenCfg.CodeGenFolder );
rtw_checkdir;
end 

silMdlBlks = [ iBuildArgs.XilInfo.SilModelReferences ];
pilMdlBlks = [ iBuildArgs.XilInfo.PilModelReferences ];

if ~isempty( silMdlBlks ) || ~isempty( pilMdlBlks )
if iBuildArgs.OkayToPushNags

target_update_mv_hdr_stage = Simulink.output.Stage(  ...
DAStudio.message( 'Simulink:modelReference:MessageViewer_UpdatingCoderTargets' ),  ...
'ModelName', iMdl, 'UIMode', true );%#ok<NASGU>
end 
loc_PIL_Update( iMdl, iBuildArgs, silMdlBlks, pilMdlBlks, buildStatusMgr, parBuildContext );
end 


clear target_update_mv_hdr_stage;


if ~strcmp( pwd, savePWD )
cd( savePWD );
end 
end 
end 




function [ topStatus, buildStatusMgr ] =  ...
loc_update_model_reference_targets( iMdl,  ...
iBuildArgs, iTopTflChecksum,  ...
iOrderedMdlRefs,  ...
iparMdlRefs,  ...
mdlrefUpdateCtrl,  ...
buildStatusMgr,  ...
parBuildContext )

targetType = iBuildArgs.ModelReferenceTargetType;

targetName = perf_logger_target_resolution( targetType, iMdl, false, false );

PerfTools.Tracer.logSimulinkData( 'Performance Advisor Stats', iMdl,  ...
targetName,  ...
'update_model_reference_targets', true );

PerfTools.Tracer.logSimulinkData( 'SLbuild', iMdl,  ...
targetName,  ...
'update_model_reference_targets', true );

onCleanupTracer1 = onCleanup( @(  )PerfTools.Tracer.logSimulinkData(  ...
'SLbuild', iMdl,  ...
targetName,  ...
'update_model_reference_targets', false ) );

onCleanupTracer2 = onCleanup( @(  )PerfTools.Tracer.logSimulinkData(  ...
'Performance Advisor Stats', iMdl,  ...
targetName,  ...
'update_model_reference_targets', false ) );

topStatus = false;



loc_refresh_model_blocks( iMdl );

if strcmp( targetType, 'SIM' )

set_param( iMdl, 'ModelRefsAccel', {  } );
end 
verbose = iBuildArgs.Verbose;


simMode = get_param( iMdl, 'SimulationMode' );
simStatus = get_param( iMdl, 'SimulationStatus' );
raccelSS = get_param( iMdl, 'RapidAcceleratorSimStatus' );
runningForExternalMode = ( ~isequal( raccelSS, 'initializing' ) &&  ...
strcmp( simMode, 'external' ) &&  ...
strcmp( simStatus, 'initializing' ) );




if ~strcmp( iMdl, iBuildArgs.TopOfBuildModel )
if iBuildArgs.XilInfo.IsTopModelSil
simMode = Simulink.ModelReference.internal.SimulationMode.SimulationModeSIL;
elseif iBuildArgs.XilInfo.IsTopModelPil
simMode = Simulink.ModelReference.internal.SimulationMode.SimulationModePIL;
end 
end 

thisMdlUpdateCtrl = iBuildArgs.UpdateThisModelReferenceTarget;






errIfOutOfDate = false;



if iBuildArgs.XilInfo.UpdatingRTWTargetsForXil
lModelForCheckModelReferenceTargetMessage = iBuildArgs.TopOfBuildModel;
else 
lModelForCheckModelReferenceTargetMessage = iMdl;
end 

if isequal( mdlrefUpdateCtrl, 'AssumeUpToDate' )
updateMsg = get_param( lModelForCheckModelReferenceTargetMessage, 'CheckModelReferenceTargetMessage' );
if strcmpi( updateMsg, 'error' )
errIfOutOfDate = true;
end 



if strcmpi( updateMsg, 'none' ) && isempty( thisMdlUpdateCtrl )
Simulink.packagedmodel.unpackCoderTargetNeverRebuild( iMdl, iBuildArgs );

msg = DAStudio.message( 'Simulink:slbuild:rebuildSetToNever' );
sl_disp_info( msg, verbose );
return ;
end 
else 
updateMsg = '';
end 













updateTopMdlRefTgt = iBuildArgs.UpdateTopModelReferenceTarget;

if ( iBuildArgs.ModelReferenceRTWTargetOnly &&  ...
strcmp( targetType, 'SIM' ) )


updateTopMdlRefTgt = false;
end 

if isequal( mdlrefUpdateCtrl, 'AssumeUpToDate' ) && strcmpi( updateMsg, 'none' )


assert( ~isempty( thisMdlUpdateCtrl ) );


allMdlRef = false;
else 
allMdlRef = true;
end 

statusMsg = DAStudio.message( 'Simulink:modelReference:searchingRefMdlsStatus' );
set_param( iMdl, 'StatusString', statusMsg );

protectedOrderedMdlRefs = [  ];
if ~isempty( iOrderedMdlRefs )
orderedMdlRefs = iOrderedMdlRefs;
orderedMdlRefsWithIMdl = orderedMdlRefs;
orderedMdlRefsIncludingXIL = orderedMdlRefs;
parMdlRefs = iparMdlRefs;
else 
[ orderedMdlRefs, parMdlRefs, protectedOrderedMdlRefs, allMdlRefs ] =  ...
get_ordered_model_references ...
( iMdl,  ...
allMdlRef,  ...
'ModelReferenceRTWTargetOnly', iBuildArgs.ModelReferenceRTWTargetOnly,  ...
'ModelReferenceTargetType', iBuildArgs.ModelReferenceTargetType,  ...
'OnlyCheckConfigsetMismatch', iBuildArgs.OnlyCheckConfigsetMismatch,  ...
'TopOfBuildModel', iBuildArgs.TopOfBuildModel,  ...
'UpdateTopModelReferenceTarget', iBuildArgs.UpdateTopModelReferenceTarget,  ...
'Verbose', iBuildArgs.Verbose,  ...
'XilInfo_IsModelBlockXil', iBuildArgs.XilInfo.IsModelBlockXil,  ...
'XilInfo_UpdatingRTWTargetsForXil', iBuildArgs.XilInfo.UpdatingRTWTargetsForXil,  ...
'isUpdatingSimForRTW', iBuildArgs.IsUpdatingSimForRTW,  ...
'IsRapidAccelerator', iBuildArgs.IsRapidAccelerator,  ...
'IsRSim', iBuildArgs.IsRSim,  ...
'ConfigSetActivator', iBuildArgs.ConfigSetActivator,  ...
'SimModeIn', simMode,  ...
'GenerateCodeOnly', iBuildArgs.BaGenerateCodeOnly,  ...
'ModelCompInfo', iBuildArgs.BaModelCompInfo,  ...
'DefaultCompInfo', iBuildArgs.BaDefaultCompInfo );





orderedMdlRefsIncludingXIL = allMdlRefs;



orderedMdlRefsWithIMdl = allMdlRefs;

if ~updateTopMdlRefTgt

orderedMdlRefs = orderedMdlRefs( 1:end  - 1 );
orderedMdlRefsIncludingXIL = orderedMdlRefsIncludingXIL( 1:end  - 1 );
parMdlRefs = parMdlRefs( 1:end  - 1 );
end 
end 




mdlRefSimModeMap = Simulink.ModelReference.internal.getSimulationModeMap( [ orderedMdlRefsWithIMdl, protectedOrderedMdlRefs ] );



protectedMdlRefSimModeMap = Simulink.ModelReference.internal.getSimulationModeMap( protectedOrderedMdlRefs );















[ ~, uniqueIdx ] = unique( { orderedMdlRefs.modelName }, 'stable' );
orderedMdlRefs = orderedMdlRefs( uniqueIdx );

mdlRefNames = { orderedMdlRefs.modelName };
if strcmp( targetType, 'SIM' )


mdlRefsAccel.unprotected = mdlRefNames;
mdlRefsAccel.protected = { protectedOrderedMdlRefs.modelName };
set_param( iMdl, 'ModelRefsAccel', mdlRefsAccel );


accelMdlRefs = [ orderedMdlRefs, protectedOrderedMdlRefs ];
SlCov.CoverageAPI.setupModelRefs( accelMdlRefs, allMdlRefs );
end 

nTotalMdls = length( mdlRefNames );
iBuildArgs.Bsn = Simulink.ModelReference.internal.BuildStatusNotifier( iMdl, nTotalMdls, targetType );


Simulink.ModelReference.ProtectedModel.runBuildProcessChecks(  ...
iMdl,  ...
protectedOrderedMdlRefs,  ...
orderedMdlRefsWithIMdl,  ...
runningForExternalMode,  ...
simMode,  ...
iBuildArgs );




if ~isempty( protectedOrderedMdlRefs ) &&  ...
~isequal( mdlrefUpdateCtrl, 'AssumeUpToDate' )
locUnpackProtectedModels( protectedOrderedMdlRefs, iMdl, iBuildArgs, targetType, simMode, mdlRefSimModeMap, protectedMdlRefSimModeMap );
end 



if Simulink.ModelReference.ProtectedModel.protectingModel( iMdl )
pmCreator = get_param( iMdl, 'ProtectedModelCreator' );




VerifyNestedProtectionConditions( pmCreator, protectedOrderedMdlRefs );

for subMdlIt = 1:length( protectedOrderedMdlRefs )
opts = Simulink.ModelReference.ProtectedModel.getOptions ...
( protectedOrderedMdlRefs( subMdlIt ).modelName );
pmCreator.SubModels = [ pmCreator.SubModels, opts.subModels ];
pmCreator.SubModelsWithFile = [ pmCreator.SubModelsWithFile, protectedOrderedMdlRefs( subMdlIt ).modelName ];
end 
for subMdlIt = 1:length( orderedMdlRefs )
pmCreator.SubModels = [ pmCreator.SubModels, orderedMdlRefs( subMdlIt ).modelName ];
pmCreator.SubModelsWithFile = [ pmCreator.SubModelsWithFile, orderedMdlRefs( subMdlIt ).modelName ];
end 
pmCreator.SubModels = RTW.unique( pmCreator.SubModels );
pmCreator.SubModelsWithFile = RTW.unique( pmCreator.SubModelsWithFile );



if pmCreator.guiEntry
iBuildArgs.Bsn.iMdl = pmCreator.parentModel;
end 
end 





if isempty( orderedMdlRefsIncludingXIL )
return ;
end 

mdlsHaveUnsavedChanges = loc_checkForUnsavedChanges( iMdl, mdlRefNames,  ...
iBuildArgs, orderedMdlRefsIncludingXIL );

if isequal( mdlrefUpdateCtrl, 'AssumeUpToDate' )
msg = DAStudio.message( 'Simulink:slbuild:rebuildSetToNever' );
sl_disp_info( msg, verbose );
end 




if isempty( orderedMdlRefs )
return ;
end 


modelsScheduledToBuild = [ parMdlRefs{ : } ];
modelsScheduledToBuild = { modelsScheduledToBuild( : ).modelName };
iBuildArgs.BuildSummary.addEntriesForScheduledModels( modelsScheduledToBuild, targetType );


libsToClose = containers.Map( { orderedMdlRefs.modelName }, { orderedMdlRefs.libsToClose } );







iBuildArgs.FirstModel = orderedMdlRefs( 1 ).modelName;

buildStatusMgr.setBuildStatusDB( [  ] );




nLevels = length( parMdlRefs );
[ doParallelBuild, pool ] = parBuildContext.prepareForBuild(  ...
iMdl,  ...
nTotalMdls,  ...
nLevels,  ...
targetType,  ...
iBuildArgs.RequiredLicenses,  ...
mdlsHaveUnsavedChanges );

if doParallelBuild



[ status, reason, buildStatusMgr ] =  ...
coder.parallel.buildModelRefs(  ...
pool,  ...
iMdl, mdlRefNames, parMdlRefs, orderedMdlRefs,  ...
iTopTflChecksum,  ...
iBuildArgs, verbose, mdlrefUpdateCtrl, thisMdlUpdateCtrl, runningForExternalMode, targetType,  ...
mdlRefSimModeMap, buildStatusMgr, libsToClose, updateMsg );
else 



[ status, reason, buildStatusMgr ] =  ...
coder.serial.buildModelRefs(  ...
iMdl, mdlRefNames, parMdlRefs, orderedMdlRefs,  ...
iTopTflChecksum,  ...
iBuildArgs, verbose, mdlrefUpdateCtrl, thisMdlUpdateCtrl, runningForExternalMode, targetType,  ...
mdlRefSimModeMap, buildStatusMgr, libsToClose, updateMsg );
end 

topStatus = any( [ status.parentalAction ] ==  ...
Simulink.ModelReference.internal.ModelRefParentalAction.CHECK_FOR_REBUILD );



if isequal( evalin( 'base', 'exist(''mathworks_slbuild_testing'');' ), 1 )
slbuildTesting.status = [ status.targetStatus ]';
slbuildTesting.reason = reason;
slbuildTesting.mdlrefs = mdlRefNames;
slbuildTesting.orderedMdlRefs = orderedMdlRefs;
slbuildTesting.parentalAction = [ status.parentalAction ]';
slbuildTesting.artifactStatus = [ status.artifactStatus ]';
slbuildTesting.pushParBuildArtifacts = [ status.pushParBuildArtifacts ]';







tempParam = [ 'mathworks_slbuild_testing_', targetType ];
assignin( 'base', tempParam, slbuildTesting );
evalin( 'base', [ 'mathworks_slbuild_testing.', targetType, ' = ', tempParam, ';' ] );
evalin( 'base', [ 'clear ', tempParam, ';' ] );
end 



if isequal( mdlrefUpdateCtrl, 'AssumeUpToDate' ) || runningForExternalMode

if ~isempty( thisMdlUpdateCtrl )

status( end  ).targetStatus = Simulink.ModelReference.internal.ModelRefTargetStatus.TARGET_WAS_UP_TO_DATE;
end 





if runningForExternalMode
outOfDateIdx = find( [ status.artifactStatus ] == Simulink.ModelReference.internal.ModelRefArtifactStatus.CODE_GENERATED_AND_COMPILED );
else 
outOfDateIdx = find( [ status.targetStatus ] ~= Simulink.ModelReference.internal.ModelRefTargetStatus.TARGET_WAS_UP_TO_DATE );
end 
nOutOfDate = length( outOfDateIdx );

if nOutOfDate == 0
if isequal( mdlrefUpdateCtrl, 'AssumeUpToDate' )
msg = sl( 'construct_modelref_message',  ...
'Simulink:slbuild:allCoderTargetsUpToDate',  ...
'Simulink:slbuild:allSIMTargetsUpToDate', targetType );
sl_disp_info( msg, verbose );
end 

return ;
end 

if errIfOutOfDate || runningForExternalMode





msgType = 'Error';
else 
msgType = 'Warning';
end 


if runningForExternalMode
msgId = 'Simulink:modelReference:ExtModeOutOfDate';
outOfDateMsg = DAStudio.message( msgId, iMdl, iMdl );
else 
msgId = 'Simulink:modelReference:OutOfDate';
outOfDateMsg = DAStudio.message( msgId, lModelForCheckModelReferenceTargetMessage );
end 

outOfDateException = MException( msgId, '%s', outOfDateMsg );

for i = 1:nOutOfDate
idx = outOfDateIdx( i );
reasonException = MException( 'Simulink:modelReference:OutOfDateReason',  ...
'%s', reason{ idx } );

outOfDateException = addCause( outOfDateException, reasonException );
end 

if strcmp( msgType, 'Warning' )
warning( msgId, '%s', outOfDateException.getReport );
else 
throw( outOfDateException );
end 
return ;
end 
end 




function mdlsHaveUnsavedChanges = loc_checkForUnsavedChanges( iMdl,  ...
iMdlRefNames, iBuildArgs, iOrderedMdlRefsIncludingXIL )

targetType = iBuildArgs.ModelReferenceTargetType;
dirtyFlags = [ iOrderedMdlRefsIncludingXIL.dirty ];
wsDirtyFlags = [ iOrderedMdlRefsIncludingXIL.wsDirty ];
simprmDirtyFlags = [ iOrderedMdlRefsIncludingXIL.simPrmDirty ];


baseDiagnostic = MSLDiagnostic( message( 'Simulink:slbuild:unsavedMdlRefsAllowed', iMdl ) );


if any( dirtyFlags ) || any( wsDirtyFlags ) || any( simprmDirtyFlags )
for idx = 1:length( iOrderedMdlRefsIncludingXIL )
warningMessageId = '';


if iOrderedMdlRefsIncludingXIL( idx ).simPrmDirty










isMenuSim = iBuildArgs.OkayToPushNags;
if isMenuSim || iBuildArgs.IsUpdatingSimForRTW ||  ...
( ( slfeature( 'NoSimTargetForBuild' ) > 0 ) && strcmp( iBuildArgs.ModelReferenceTargetType, 'RTW' ) )

mdl = iOrderedMdlRefsIncludingXIL( idx ).modelName;



activeConfigSet = getActiveConfigSet( mdl );
if isa( activeConfigSet, 'Simulink.ConfigSetRef' )
activeConfigSet.refresh;
end 

proceed = slprivate( 'checkSimPrm', activeConfigSet );
if ( ~proceed )

throw( MSLException( message( 'Simulink:Commands:SimAborted' ) ) );
end 
end 
end 






if iOrderedMdlRefsIncludingXIL( idx ).wsDirty
warningMessageId = 'Simulink:slbuild:unsavedMdlRefsWorkspaceCause';
elseif iOrderedMdlRefsIncludingXIL( idx ).dirty
warningMessageId = 'Simulink:slbuild:unsavedMdlRefsCause';
end 


mdl = iOrderedMdlRefsIncludingXIL( idx ).modelName;

if ~isempty( warningMessageId )
cause = MSLDiagnostic( message( warningMessageId, mdl ) );
baseDiagnostic = addCause( baseDiagnostic, cause );
end 
end 
end 


baseDiagnostic = loc_check_for_dirty_libraries( iMdlRefNames, targetType, baseDiagnostic );



if ~isempty( baseDiagnostic.cause )
baseDiagnostic.reportAsWarning(  );
mdlsHaveUnsavedChanges = true;
else 
mdlsHaveUnsavedChanges = false;
end 
end 


function baseDiagnostic = loc_check_for_dirty_libraries( iMdls, iTargetType, baseDiagnostic )

nMdls = length( iMdls );

for i = 1:nMdls
mdl = iMdls{ i };
cache = coder.internal.infoMATFileMgr( 'load', 'minfo',  ...
mdl, iTargetType );

libMdls = cache.libDeps;
nLibMdls = length( libMdls );
for j = 1:nLibMdls
lib = libMdls{ j };
if bdIsLoaded( lib ) && isequal( get_param( lib, 'Dirty' ), 'on' )

cause = MSLDiagnostic( message( 'Simulink:slbuild:unsavedMdlLibCause', lib ) );
baseDiagnostic = addCause( baseDiagnostic, cause );
end 
end 
end 
end 







function loc_refresh_model_blocks( iMdl )
io = get_param( iMdl, 'ModelReferenceIOMismatchMessage' );
ver = get_param( iMdl, 'ModelReferenceVersionMismatchMessage' );


if strcmpi( io, 'error' ) || strcmpi( ver, 'error' )
object = get_param( iMdl, 'Object' );
sysTargetFile = get_param( iMdl, 'SystemTargetFile' );
if ~strcmpi( sysTargetFile, 'accel.tlc' )
object.refreshModelBlocks(  );
end 
end 
end 





function loc_PIL_Update( iMdl, iBuildArgs, iSilMdlBlks, iPilMdlBlks, buildStatusMgr, parallelBuildContext )




origModelReferenceTargetType = iBuildArgs.ModelReferenceTargetType;
origUpdateTopModelReferenceTarget = iBuildArgs.UpdateTopModelReferenceTarget;
origBaModelCompInfo = iBuildArgs.BaModelCompInfo;
origBaGenerateMakefile = iBuildArgs.BaGenerateMakefile;

resetBuildArgsCleanup = onCleanup( @(  )locResetBuildArgsAfterPILUpdate( iBuildArgs,  ...
origUpdateTopModelReferenceTarget, origModelReferenceTargetType, origBaModelCompInfo, origBaGenerateMakefile ) );

iBuildArgs.XilInfo.UpdatingRTWTargetsForXil = true;







iBuildArgs.UpdateTopModelReferenceTarget = true;





iPilMdlBlks = iPilMdlBlks( strcmp( get_param( iPilMdlBlks, 'ProtectedModel' ), 'off' ) );
iSilMdlBlks = iSilMdlBlks( strcmp( get_param( iSilMdlBlks, 'ProtectedModel' ), 'off' ) );
pilMdlRefs = unique( get_param( iPilMdlBlks, 'ModelName' ) );
silMdlRefs = unique( get_param( iSilMdlBlks, 'ModelName' ) );



[ silMdlRefs, pilMdlRefs, silPilMdlRefs ] =  ...
coder.connectivity.XILSubsystemUtils.updateModelRefList( iMdl,  ...
silMdlRefs, pilMdlRefs );




if isempty( silPilMdlRefs )
return ;
end 

import Simulink.ModelReference.internal.SimulationMode;
simMode = [ repmat( { SimulationMode.SimulationModeSIL }, size( silMdlRefs ) ) ...
, repmat( { SimulationMode.SimulationModePIL }, size( pilMdlRefs ) ) ];






[ ~, lGenSettings ] = coder.internal.getSTFInfo ...
( silPilMdlRefs{ 1 },  ...
'noTLCSettings', true,  ...
'modelreferencetargettype', 'RTW' );



cleanupGenSettingsCache = coder.internal.infoMATFileMgr ...
( [  ], [  ], [  ], [  ],  ...
'InitializeGenSettings', lGenSettings );%#ok<NASGU>



isSIL = ~isempty( silMdlRefs );
assert( xor( isSIL, ~isempty( pilMdlRefs ) ), 'Must be either SIL or PIL' )





orderedMdlRefs = cell( size( silPilMdlRefs ) );
parMdlRefs = cell( size( silPilMdlRefs ) );
for i = 1:length( silPilMdlRefs )

silPilMdlRef = silPilMdlRefs{ i };


if any( strcmp( silPilMdlRef, orderedMdlRefs ) )
continue ;
end 

[ tmpOrderedMdlRefs, tmpParMdlRefs ] =  ...
get_ordered_model_references ...
( silPilMdlRef,  ...
true,  ...
'ModelReferenceRTWTargetOnly', iBuildArgs.ModelReferenceRTWTargetOnly,  ...
'ModelReferenceTargetType', iBuildArgs.ModelReferenceTargetType,  ...
'OnlyCheckConfigsetMismatch', iBuildArgs.OnlyCheckConfigsetMismatch,  ...
'TopOfBuildModel', iBuildArgs.TopOfBuildModel,  ...
'UpdateTopModelReferenceTarget', iBuildArgs.UpdateTopModelReferenceTarget,  ...
'Verbose', iBuildArgs.Verbose,  ...
'XilInfo_IsModelBlockXil', iBuildArgs.XilInfo.IsModelBlockXil,  ...
'XilInfo_UpdatingRTWTargetsForXil', iBuildArgs.XilInfo.UpdatingRTWTargetsForXil,  ...
'isUpdatingSimForRTW', iBuildArgs.IsUpdatingSimForRTW,  ...
'IsRapidAccelerator', iBuildArgs.IsRapidAccelerator,  ...
'IsRSim', iBuildArgs.IsRSim,  ...
'ConfigSetActivator', iBuildArgs.ConfigSetActivator,  ...
'SimModeIn', simMode{ i } );

orderedMdlRefs{ i } = tmpOrderedMdlRefs;
parMdlRefs{ i } = tmpParMdlRefs;

end 











iBuildArgs.ModelReferenceTargetType = 'RTW';
iBuildArgs.UpdateTopModelReferenceTarget = true;



mdlrefUpdateCtrl = get_param( iMdl, 'UpdateModelReferenceTargets' );

[ ~, idx ] = unique( silPilMdlRefs );
silPilTopRefs = silPilMdlRefs( idx );
orderedMdlRefs = orderedMdlRefs( idx );
parMdlRefs = parMdlRefs( idx );

for i = 1:length( silPilTopRefs )

topRefModel = silPilTopRefs{ i };


allowLcc = true;
lModelCompInfo = coder.internal.ModelCompInfo.createModelCompInfo ...
( topRefModel,  ...
iBuildArgs.BaDefaultCompInfo.DefaultMexCompInfo,  ...
allowLcc );
iBuildArgs.BaModelCompInfo = lModelCompInfo;
iBuildArgs.BaGenerateMakefile = true;

updatedHooks = coder.coverage.updateHooksFromTopOfXil ...
( iBuildArgs.BuildHooks, iBuildArgs.BuildHooksOnlyForERT, topRefModel );
iBuildArgs.BuildHooks = updatedHooks;

iBuildArgs.XilTopModel = topRefModel;
hTflControlRTW = get_param( topRefModel, 'RTWTargetFcnLibHandle' );
locTopTflChecksum = hTflControlRTW.getIncrBuildNum(  );
loc_update_model_reference_targets( topRefModel,  ...
iBuildArgs,  ...
locTopTflChecksum,  ...
orderedMdlRefs{ i },  ...
parMdlRefs{ i },  ...
mdlrefUpdateCtrl,  ...
buildStatusMgr,  ...
parallelBuildContext );
end 

iBuildArgs.XilInfo.UpdatingRTWTargetsForXil = false;
end 

function locResetBuildArgsAfterPILUpdate( iBuildArgs,  ...
origUpdateTopModelReferenceTarget, origModelReferenceTargetType, origBaModelCompInfo, origBaGenerateMakefile )

iBuildArgs.UpdateTopModelReferenceTarget = origUpdateTopModelReferenceTarget;
iBuildArgs.ModelReferenceTargetType = origModelReferenceTargetType;
iBuildArgs.BaModelCompInfo = origBaModelCompInfo;
iBuildArgs.BaGenerateMakefile = origBaGenerateMakefile;
end 

function locUnpackProtectedModels( protectedOrderedMdlRefs, iMdl, iBuildArgs,  ...
targetType, topSimMode, allMdlRefSimModeMap, protectedMdlRefSimModeMap )

isMenuSim = iBuildArgs.OkayToPushNags;



simTargetsUnpackedList = [  ];
simTargetsForCodeGenUnpackedList = [  ];
codeGenTargetsUnpackedList = [  ];
protectedModelsToPrepareForXIL = {  };
protectedModelsToPrepareForXILIsSIL = [  ];

statusMsg = DAStudio.message( 'Simulink:modelReference:unpackingProtectedModel' );
set_param( iMdl, 'StatusString', statusMsg );
if slsvTestingHook( 'ProtectedModelTestProgressStatus' ) > 0
disp( statusMsg );
end 
for i = 1:length( protectedOrderedMdlRefs )
protectedOrderedMdlRef = protectedOrderedMdlRefs( i );
currentProtectedModel = protectedOrderedMdlRef.modelName;










isDoingSimForRTWBuild = iBuildArgs.IsUpdatingSimForRTW;
[ needsRTWArtifacts,  ...
isRunningXILSimForProtectedModel,  ...
isRunningSILSimForProtectedModel,  ...
isRunningPILSimForProtectedModel ] =  ...
Simulink.ModelReference.ProtectedModel.buildNeedsRTWArtifacts(  ...
isDoingSimForRTWBuild,  ...
iBuildArgs.ModelReferenceTargetType,  ...
protectedMdlRefSimModeMap( currentProtectedModel ) );



simModeNeedsSimTarget = ( strcmp( topSimMode, 'accelerator' ) ||  ...
strcmp( topSimMode, 'rapid-accelerator' ) );


needsSIMArtifacts = strcmp( targetType, 'SIM' ) &&  ...
~needsRTWArtifacts &&  ...
~any( strcmp( currentProtectedModel, simTargetsUnpackedList ) );
if needsSIMArtifacts
Simulink.ModelReference.ProtectedModel.getPasswordFromDialog( currentProtectedModel, iMdl, 'SIM', isMenuSim );
elseif needsRTWArtifacts

Simulink.ModelReference.ProtectedModel.getPasswordFromDialog( currentProtectedModel, iMdl, 'RTW', isMenuSim );
end 





Simulink.filegen.internal.FolderConfiguration.updateCache( currentProtectedModel );

if needsSIMArtifacts

fileDeleter = Simulink.ModelReference.ProtectedModel.FileDeleter.Instance;
fileDeleter.setCurrentTopModel( iBuildArgs.TopOfBuildModel );

[ opts, fullName ] = Simulink.ModelReference.ProtectedModel.getOptions( currentProtectedModel );

needToUnpackSimTarget = false;
if simModeNeedsSimTarget
protectedModelFromcurrentRelease = slInternal( 'isProtectedModelFromThisSimulinkVersion', fullName );
accelSimulationOfImmediateParent = strcmpi( topSimMode, 'accelerator' ) &&  ...
all( strcmp( iBuildArgs.TopOfBuildModel, protectedOrderedMdlRef.directParents ) == 1 );
needToUnpackSimTarget = protectedModelFromcurrentRelease ||  ...
Simulink.ModelReference.ProtectedModel.protectingModel( iMdl ) ||  ...
~( accelSimulationOfImmediateParent );
elseif strcmp( topSimMode, 'normal' )





if iBuildArgs.UpdateTopModelReferenceTarget
if Simulink.ModelReference.ProtectedModel.supportsAccel( opts )
needToUnpackSimTarget = true;
end 
end 
end 

if needToUnpackSimTarget

Simulink.ModelReference.ProtectedModel.unpack( currentProtectedModel, 'SIM', iMdl );
simTargetsUnpackedList{ end  + 1 } = currentProtectedModel;%#ok<AGROW>
elseif slfeature( 'ProtectedModelValidateCertificatePreferences' ) > 0

Simulink.ProtectedModel.internal.checkCertificate( fullName );
end 




elseif needsRTWArtifacts

fileDeleter = Simulink.ModelReference.ProtectedModel.FileDeleter.Instance;
fileDeleter.setCurrentTopModel( iBuildArgs.TopOfBuildModel );


lXilInfo = iBuildArgs.XilInfo;

componentSuffix = '_mdlref';
if isRunningXILSimForProtectedModel
opts = Simulink.ModelReference.ProtectedModel.getOptions( currentProtectedModel );
if strcmp( opts.codeInterface, 'Top model' )
componentSuffix = '_stdalone';
assert( ~isDoingSimForRTWBuild,  ...
[ 'Cannot be building a top model containing a',  ...
' protected model with "Top model" code interface!' ] );









lIsTopModelXILSim = false;
lTopModelSilOrPilBuild = true;
lTopModelIsSilMode = isRunningSILSimForProtectedModel;
lSILModelReferences = [  ];
lPILModelReferences = [  ];
lSILModelReferencesTopModel = [  ];
lPILModelReferencesTopModel = [  ];
isStandalone = true;
lIsSILDebuggingEnabled = strcmp( get_param( iMdl, 'SILDebugging' ), 'on' );
lModelProfilingAllowed = true;
lXilInfo = rtw.pil.XilBuildArgs ...
( lIsTopModelXILSim,  ...
lTopModelSilOrPilBuild,  ...
lTopModelIsSilMode,  ...
lSILModelReferences,  ...
lPILModelReferences,  ...
lSILModelReferencesTopModel,  ...
lPILModelReferencesTopModel,  ...
isStandalone,  ...
iMdl,  ...
lIsSILDebuggingEnabled,  ...
lModelProfilingAllowed );
end 
end 






compileCodeIfNecessary = ~iBuildArgs.IsUpdateDiagramOnly;









isUpdatingSimForRTW = iBuildArgs.IsUpdatingSimForRTW;
hasInstanceInAccelMode =  ...
any( strcmpi( protectedMdlRefSimModeMap( currentProtectedModel ), 'Accelerator' ) );
updateTopModelReferenceTarget = iBuildArgs.UpdateTopModelReferenceTarget;
topIsAccelOrRapid = ( strcmp( topSimMode, 'accelerator' ) || strcmp( topSimMode, 'rapid-accelerator' ) );
needToUnpackSimTarget = ( isUpdatingSimForRTW || updateTopModelReferenceTarget || topIsAccelOrRapid ) && hasInstanceInAccelMode;
if strcmp( targetType, 'SIM' )

if ~any( strcmp( currentProtectedModel, simTargetsForCodeGenUnpackedList ) ) && needToUnpackSimTarget
Simulink.ModelReference.ProtectedModel.unpack(  ...
currentProtectedModel, 'SIM_FOR_CODEGEN', iMdl );
simTargetsForCodeGenUnpackedList{ end  + 1 } = currentProtectedModel;%#ok<AGROW>
end 
end 



if ~strcmp( targetType, 'SIM' ) || isRunningXILSimForProtectedModel



fullUnpackedCodeGenName = [ currentProtectedModel, componentSuffix ];
if ~any( strcmp( fullUnpackedCodeGenName, codeGenTargetsUnpackedList ) )




opts = Simulink.ModelReference.ProtectedModel.getOptions( currentProtectedModel );
if ~Simulink.ModelReference.ProtectedModel.supportsCodeGen( opts )
DAStudio.error( 'Simulink:protectedModel:ProtectedModelUnsupportedModeRTW',  ...
opts.modelName );
end 



Simulink.filegen.internal.Helpers.validateProtectedModelCodeGenFolderStructure( currentProtectedModel );


lGenerateCodeOnly = iBuildArgs.BaGenerateCodeOnly;

Simulink.ModelReference.ProtectedModel.unpack( currentProtectedModel, 'CODEGEN',  ...
iMdl, iBuildArgs,  ...
compileCodeIfNecessary, lXilInfo, lGenerateCodeOnly, iBuildArgs.Verbose );
codeGenTargetsUnpackedList{ end  + 1 } = fullUnpackedCodeGenName;%#ok<AGROW>

if ( slfeature( 'NoSimTargetForBuild' ) == 0 )
















matchName = strcmp( protectedModelsToPrepareForXIL, currentProtectedModel );
matchSIL = protectedModelsToPrepareForXILIsSIL == isRunningSILSimForProtectedModel;



lParentsInMap = intersect( protectedOrderedMdlRef.directParents, allMdlRefSimModeMap.keys );
lDirectParentSimModes = cellfun( @( x )allMdlRefSimModeMap( x ),  ...
lParentsInMap,  ...
'UniformOutput', false );


lUniqueDirectParentSimModes = unique( [ lDirectParentSimModes{ : } ] );


lDirectParentNeedsXILSFcn = ~isempty( lUniqueDirectParentSimModes ) &&  ...
any(  ...
ismember( lUniqueDirectParentSimModes, {  ...
Simulink.ModelReference.internal.SimulationMode.SimulationModeSIL,  ...
Simulink.ModelReference.internal.SimulationMode.SimulationModePIL } ) );

if isRunningXILSimForProtectedModel












isTopModelCodeInterface = strcmp( opts.codeInterface, 'Top model' );
lNeedToBuildSFunctionNow = ~isTopModelCodeInterface &&  ...
( isDoingSimForRTWBuild || lDirectParentNeedsXILSFcn );



lAlreadyInList = any( matchName & matchSIL );

if lNeedToBuildSFunctionNow && ~lAlreadyInList


if isRunningSILSimForProtectedModel
protectedModelsToPrepareForXIL{ end  + 1 } = currentProtectedModel;%#ok<AGROW>
protectedModelsToPrepareForXILIsSIL( end  + 1 ) = true;%#ok<AGROW>
end 
if isRunningPILSimForProtectedModel
protectedModelsToPrepareForXIL{ end  + 1 } = currentProtectedModel;%#ok<AGROW>
protectedModelsToPrepareForXILIsSIL( end  + 1 ) = false;%#ok<AGROW>
end 
end 
end 
end 
end 
end 
end 
end 



if ~isempty( protectedModelsToPrepareForXIL )
lTopModelAccelWithProfiling = iBuildArgs.TopModelAccelWithProfiling;

Simulink.ModelReference.internal.XILSfunction.buildForProtectedModels(  ...
iMdl, lTopModelAccelWithProfiling,  ...
iBuildArgs.XilInfo.IsSilAndPws, protectedModelsToPrepareForXIL,  ...
protectedModelsToPrepareForXILIsSIL,  ...
iBuildArgs.BaDefaultCompInfo );
end 
end 


function VerifyNestedProtectionConditions( pmCreator, protectedOrderedMdlRefs )

protectingModel = pmCreator.ModelName;

for subMdlIt = 1:length( protectedOrderedMdlRefs )
protectedChildModel = protectedOrderedMdlRefs( subMdlIt ).modelName;
opts = Simulink.ModelReference.ProtectedModel.getOptions( protectedChildModel );


if slfeature( 'ProtectedModelTunableParameters' ) > 1
if ~pmCreator.areAllParametersTunable(  )
conflictingParams = setdiff( opts.tunableParameters, pmCreator.TunableVarNames );
if ~isempty( conflictingParams )
throwAsCaller( MSLException( [  ],  ...
message( 'Simulink:protectedModel:NestedProtectionTunableParametersConflict',  ...
strjoin( conflictingParams, ', ' ), protectedChildModel ) ) );
end 
end 
end 






if strcmp( opts.modes, 'ViewOnly' )
throwAsCaller( MSLException( [  ],  ...
message( 'Simulink:protectedModel:NestedSubProtectedModelIsWebviewOnly', protectingModel, protectedChildModel ) ) );
end 


if ( ~pmCreator.isViewOnly )

if ( opts.isSimEncrypted )
throwAsCaller( MSLException( [  ],  ...
message( 'Simulink:protectedModel:NestedSubProtectedModelIsSimulationPasswordProtected', protectingModel, protectedChildModel ) ) );
end 


if ~isempty( opts.callbackMgr.Callbacks )
throwAsCaller( MSLException( [  ],  ...
message( 'Simulink:protectedModel:NestedSubProtectedModelCallbacks', protectingModel, protectedChildModel ) ) );
end 



if ( pmCreator.supportsCodeGen )

if ( ~Simulink.ModelReference.ProtectedModel.supportsCodeGen( opts ) )
throwAsCaller( MSLException( [  ],  ...
message( 'Simulink:protectedModel:NestedSubProtectedModelWithoutCodeGen', protectingModel, protectedChildModel ) ) );

end 

if ( opts.isRTWEncrypted )
throwAsCaller( MSLException( [  ],  ...
message( 'Simulink:protectedModel:NestedSubProtectedModelIsCodeGenPasswordProtected', protectingModel, protectedChildModel ) ) );
end 


if ( opts.binariesAndHeadersOnly && ~pmCreator.BinariesAndHeadersOnly )
throwAsCaller( MSLException( [  ],  ...
message( 'Simulink:protectedModel:NestedSubProtectedModelBinaryCodeGen', protectingModel, protectedChildModel ) ) );


elseif ( ~opts.obfuscateCode ) && ( pmCreator.ObfuscateCode )
throwAsCaller( MSLException( [  ],  ...
message( 'Simulink:protectedModel:NestedSubProtectedModelReadableCodeGen', protectingModel, protectedChildModel ) ) );
end 
end 
end 
end 
end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmpXy0M64.p.
% Please follow local copyright laws when handling this file.

