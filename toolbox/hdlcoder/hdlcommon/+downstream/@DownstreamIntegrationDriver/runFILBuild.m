function runFILBuild( obj )





dut = obj.getDutName;



[ hDriver, params ] = hdlcoderargs( dut );
hDriver.updateCmdLineHDLSubsystem( hDriver.OrigStartNodeName );

state = hDriver.initMakehdl( hDriver.ModelName(  ) );
oldDriver = state.oldDriver;
oldMode = state.oldMode;
oldAutosaveState = state.oldAutosaveState;

onCleanupObj = onCleanup( @(  )hDriver.baseCleanup( oldDriver, oldMode, oldAutosaveState ) );



if ( hDriver.isIndustryStandardMode(  ) )
hDriver.updateIndustryStandardParams( hDriver.ModelName(  ) );
end 


obj.hFilBuildInfo.setOutputFolder( obj.getFullFILDir );

if ~hDriver.isCodeGenSuccessful
hDriver.makehdl( params );
end 


newFilBuildInfo = eda.internal.workflow.FILBuildInfo;
newFilBuildInfo.Board = obj.hFilBuildInfo.Board;
newFilBuildInfo.BoardObj = obj.hFilBuildInfo.BoardObj;
newFilBuildInfo.IPAddress = obj.hFilBuildInfo.IPAddress;
newFilBuildInfo.MACAddress = obj.hFilBuildInfo.MACAddress;
newFilBuildInfo.EnableHWBuffer = obj.hFilBuildInfo.EnableHWBuffer;
for ii = 1:numel( obj.hFilBuildInfo.SourceFiles.FilePath )
newFilBuildInfo.addSourceFile(  ...
obj.hFilBuildInfo.SourceFiles.FilePath{ ii },  ...
obj.hFilBuildInfo.SourceFiles.FileType{ ii } );
end 
newFilBuildInfo.setOutputFolder( obj.hFilBuildInfo.OutputFolder );

hDriver.connectToModel;
hDriver.closeConnection;

hPir = hDriver.PirInstance;
cosimSetup = 'CosimBlockAndDut';
gc = cosimtb.genfiltb( cosimSetup, hDriver, hPir, newFilBuildInfo );

if isempty( obj.hFilWizardDlg.buildOptions )
gc.doIt;
else 
gc.doIt( obj.hFilWizardDlg.buildOptions{ : } );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmplPrOMD.p.
% Please follow local copyright laws when handling this file.

