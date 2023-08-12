function updateInfoMATFile( modelName, lModelReferenceTargetType,  ...
templateMakefile, lBuildInfo, lStartDirToRestore,  ...
lRapidAcceleratorIsActive )




[ ~, lModelLibName ] = findBuildArg( lBuildInfo, 'MODELLIB' );
coder.internal.infoMATFileMgr( 'updateModelLibName',  ...
'binfo',  ...
modelName,  ...
lModelReferenceTargetType,  ...
lModelLibName );



clientBlockOperationNames = locGetAUTOSARClientBlockOperationNames ...
( modelName, lModelReferenceTargetType );

if strcmp( get_param( modelName, 'AutosarCompliant' ), 'on' )


invokeOperationConfigSubsystems = locGetAUTOSARInvokeOperationConfigSubsystems ...
( modelName, lModelReferenceTargetType );




isAutosarRTEHeaderFileGenerationEnabled = true;
else 
invokeOperationConfigSubsystems = {  };
isAutosarRTEHeaderFileGenerationEnabled = false;
end 

tmfNoMATLABRoot = strrep( templateMakefile, matlabroot, '' );
tmfNoMATLABRoot = tmfNoMATLABRoot( 2:end  );
coder.internal.infoMATFileMgr(  ...
'updateField', 'binfo',  ...
modelName,  ...
lModelReferenceTargetType,  ...
'SystemMap', rtwprivate( 'rtwattic', 'getSystemMap' ),  ...
'SourceSubsystemName', coder.internal.SubsystemBuild.getSourceSubsysName,  ...
'ParameterArgumentNames', get_param( modelName, 'ParameterArgumentNames' ),  ...
'TemplateMakefile', tmfNoMATLABRoot,  ...
'AUTOSARInvokeOperationConfigSubsystems', invokeOperationConfigSubsystems,  ...
'IsAutosarRTEHeaderFileGenerationEnabled', isAutosarRTEHeaderFileGenerationEnabled,  ...
'AUTOSARClientBlockOperationNames', clientBlockOperationNames );


sfcnSourceFileMap = slprivate( 'build_sfcn_source_file_map', lBuildInfo );
coder.internal.infoMATFileMgr( 'computeAndSaveSfcnChecksums', 'binfo', modelName,  ...
lModelReferenceTargetType,  ...
sfcnSourceFileMap, lStartDirToRestore,  ...
true, lRapidAcceleratorIsActive );


coder.internal.infoMATFileMgr( 'addInternalDependencyChecksums', 'binfo', modelName,  ...
lModelReferenceTargetType );


coder.internal.infoMATFileMgr ...
( 'updateIncludeDirs', 'binfo', modelName,  ...
lModelReferenceTargetType,  ...
lBuildInfo.getIncludePaths( false, {  }, { 'Standard' } ),  ...
lBuildInfo.getSourcePaths( false, 'MDLREF' ) );



function clientBlockOperationNames = locGetAUTOSARClientBlockOperationNames ...
( modelName, lModelReferenceTargetType )



clientBlockOperationNames = {  };
if ~strcmp( lModelReferenceTargetType, 'SIM' )
AUTOSARClientBlocks = arblk.findAUTOSARClientBlks( modelName );
for ii = 1:numel( AUTOSARClientBlocks )
obj = get_param( AUTOSARClientBlocks{ ii }, 'object' );
if strcmp( get_param( modelName, 'AutosarCompliant' ), 'on' )
maxShortNameLength = get_param( modelName, 'AutosarMaxShortNameLength' );
args = { obj.operationPrototype, maxShortNameLength };
else 
args = { obj.operationPrototype };
end 
[ fcn, isvalid, ~, errMsg ] = arblk.parseOperationPrototype( args{ : } );
assert( isvalid, errMsg );
clientBlockOperationNames = [ clientBlockOperationNames; ...
cellstr( fcn.name ); ...
 ];%#ok<AGROW>
end 
end 


function configSubsystems = locGetAUTOSARInvokeOperationConfigSubsystems ...
( modelName, lModelReferenceTargetType )


configSubsystems = {  };
if ~strcmp( lModelReferenceTargetType, 'SIM' )
configSubsystems =  ...
coder.internal.connectivity.AutosarInterfaceStrategy.findAUTOSARInvokeOperationConfigSubsystems( modelName );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpwh4FE8.p.
% Please follow local copyright laws when handling this file.

