classdef MATLABCoderInstrumenter < codeinstrum.internal.CodeInstrumenterFEHandler










properties ( GetAccess = public, SetAccess = protected )
ProbeRegistry = [  ]
end 

methods ( Access = public )



function this = MATLABCoderInstrumenter( instrFolder, probeRegistry, isPerFileTRData, isForPSTest )
R36
instrFolder
probeRegistry
isPerFileTRData = false
isForPSTest = false
end 

dbFilePath = probeRegistry.DbFilePath;

if isPerFileTRData
dirDB = fileparts( dbFilePath );
dbFilePath = tempname( dirDB );
end 
if exist( dbFilePath, 'file' )
delete( dbFilePath );
end 
instrumObj = codeinstrum.internal.Instrumenter( dbFilePath, probeRegistry.InstrumOptions, isPerFileTRData );

if isForPSTest
try 
internal.pstest.testgen.addPstestMacroEmitter( instrumObj.InstrumImpl );
catch 


end 
end 
instrumObj.anchorDir = fileparts( fileparts( fileparts( fileparts( instrFolder ) ) ) );
instrumObj.moduleName = probeRegistry.ComponentName;
instrumObj.outDir = instrFolder;
instrumObj.codeCovProbeComponentRegistry = probeRegistry;

suffix = codeinstrum.internal.MATLABCoderInstrumenter.parseModuleName( probeRegistry.ComponentName );
instrumObj.InstrVarRadix = [ instrumObj.InstrVarRadix, '_', suffix ];
instrumObj.InstrFcnRadix = [ instrumObj.InstrFcnRadix, '_', suffix ];
instrumObj.InstrFcnSuffix = [ '_', suffix ];

instrumObj.prepareModuleInstrumentation(  );
if isForPSTest
instrumObj.setSourceKind( internal.cxxfe.instrum.SourceKind.PSTest );
else 
instrumObj.setSourceKind( internal.cxxfe.instrum.SourceKind.MCoder );
end 
this@codeinstrum.internal.CodeInstrumenterFEHandler( instrumObj );
this.ProbeRegistry = probeRegistry;
end 




function afterPreprocessing( ~, ~, ~, ~, ~ )

end 




function afterParsing( this, ilPtr, ~, ~, ~ )
this.Instrumenter.traceabilityData.commitTransaction(  );
clrObj = onCleanup( @(  )this.Instrumenter.traceabilityData.beginTransaction(  ) );

this.fillInstrumOptions(  );
codeinstrum_mex( codeinstrum.internal.CodeInstrumenterFEHandler.CODEINSTRUM_AFTER_PARSING,  ...
ilPtr, this.Instrumenter.Options, this.Instrumenter.traceabilityData, this.IsForSfcn, this.Code2ModelRecords );
end 




function registerInstrumentedFile( this, fileIn, fileOut, feOpts )
if ~isempty( this.Instrumenter )
if ~isempty( this.Instrumenter.traceabilityData )
this.Instrumenter.traceabilityData.beginTransaction(  );

fileIn = polyspace.internal.getAbsolutePath( fileIn );
fileOut = polyspace.internal.getAbsolutePath( fileOut );

this.Instrumenter.InstrumImpl.setBuildOptions( fileIn, feOpts, {  } );

this.Instrumenter.traceabilityData.commitTransaction(  );

this.Instrumenter.InstrumImpl.finalizeFileInstrumentation( fileOut, fileIn, feOpts );

end 
end 
end 




function unregisterInstrumentedFile( this, fileIn, fileOut )


copyfile( fileIn, fileOut, 'f' );

if ~isempty( this.Instrumenter ) &&  ...
~isempty( this.Instrumenter.traceabilityData )

fileIn = polyspace.internal.getAbsolutePath( fileIn );
this.Instrumenter.traceabilityData.insertFile( fileIn,  ...
internal.cxxfe.instrum.FileKind.SOURCE,  ...
internal.cxxfe.instrum.FileStatus.FAILED );
this.Instrumenter.traceabilityData.addFileToModule( fileIn,  ...
this.Instrumenter.moduleName );
end 
end 




function finalizeInstrumentation( this, dbFilePath )
R36
this
dbFilePath = ''
end 
this.Instrumenter.finalizeModuleInstrumentation(  );
[ maxCovId, hTableSize ] = this.Instrumenter.getCovTableSize(  );
this.ProbeRegistry.SetCovTableSize( maxCovId, hTableSize );

if ~isempty( dbFilePath ) && this.Instrumenter.isPerFileTRData
this.Instrumenter.setFinalDBName(  );
covRslt = internal.cxxfe.instrum.runtime.ResultHitsManager.tryImport( dbFilePath );
[ ~, hTableSize ] = this.Instrumenter.getCovTableSize(  );
instrDataInfo = this.Instrumenter.getInstrumDataInfo(  );
uniqueId = codeinstrum.internal.Instrumenter.computeUniqueID( this.Instrumenter.SrcFileName, this.Instrumenter.structuralChecksum );
covRslt.addFileDef( uniqueId,  ...
instrDataInfo.tchunkNumBits,  ...
hTableSize );
end 
end 
end 

methods ( Access = public, Static = true )



function moduleName = buildModuleName( projectName, varargin )
moduleName = codeinstrum.internal.codecov.ModuleUtils.buildModuleName(  ...
true, projectName, varargin{ : } );
end 




function [ projectName, covMode ] = parseModuleName( moduleName )
[ projectName, covMode ] = codeinstrum.internal.codecov.ModuleUtils.parseModuleName( moduleName );
end 




function [ trDataFile, resHitsFile, buildDir ] = getCodeCovDataFiles( moduleName, varargin )
[ trDataFile, resHitsFile, buildDir ] = codeinstrum.internal.codecov.ModuleUtils.getCodeCovDataFiles(  ...
moduleName, varargin{ : } );
end 




function covCompRegistry = buildCodeCovProbeRegistry( projectName, covMode, instrumOptions, buildDir, wordSize, idSize )
if covMode == "None"
covCompRegistry = [  ];
return 
end 
moduleName = codeinstrum.internal.MATLABCoderInstrumenter.buildModuleName( projectName, covMode );
covCompRegistry = codeinstrum.internal.codecov.MATLABCoderProbeComponentRegistry(  ...
moduleName,  ...
instrumOptions,  ...
wordSize,  ...
idSize,  ...
codeinstrum.internal.MATLABCoderInstrumenter.getCodeCovDataFiles( moduleName, buildDir ) );
end 




function flushRecord( dbFilePath, clearData )
if nargin < 2
clearData = false;
end 
internal.cxxfe.instrum.runtime.ResultHitsManager.flushRecord( dbFilePath, '', clearData );
end 




function [ trDataFile, isPerFileTRData, resFile ] = startRecord( filePath )
trDataFile = '';
isPerFileTRData = false;
resFile = '';
if isempty( coder.profile.CoderInstrumentationInfo.getTargetInfo( filePath, false ) )
return 
end 
allProbes = coder.profile.CoderInstrumentationInfo.getProbesFromRegistries( filePath, false );
for ii = 1:numel( allProbes )
covType = allProbes{ ii }{ 1 };
if covType == "CODECOV_PROBE"
moduleName = allProbes{ ii }{ 2 }{ 2 };
[ trDataFile, resFile ] = codeinstrum.internal.MATLABCoderInstrumenter.getCodeCovDataFiles( moduleName );
if ~internal.cxxfe.instrum.runtime.CovResultHits.isBinCovFormat( trDataFile )
internal.cxxfe.instrum.runtime.ResultHitsManager.startRecord( trDataFile, resFile );
isPerFileTRData = false;
else 
internal.cxxfe.instrum.runtime.ResultHitsManager.startRecord( '', trDataFile );
isPerFileTRData = true;
end 
return 
end 
end 
end 




function stopRecord( dbFilePath )
internal.cxxfe.instrum.runtime.ResultHitsManager.stopRecord( dbFilePath );
end 
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp_LOZW_.p.
% Please follow local copyright laws when handling this file.

