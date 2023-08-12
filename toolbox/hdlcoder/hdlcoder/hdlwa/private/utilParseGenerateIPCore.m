function isReset = utilParseGenerateIPCore( mdladvObj, hDI )




hdlwaDriver = hdlwa.hdlwaDriver.getHDLWADriverObj;
taskObj = hdlwaDriver.getTaskObj( 'com.mathworks.HDL.GenerateIPCore' );


inputParams = mdladvObj.getInputParameters( taskObj.MAC );
ipNameOption = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAIPCoreName' ) );
ipVerOption = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAIPCoreVersion' ) );
ipRepositoryOption = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAIPRepository' ) );
ipCustomFileOption = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAInputAdditionalSourceFiles' ) );
ipReportOption = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAIPCoreReport' ) );
axi4ReadbackEnableOption = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAEnableAXI4SlaveReadback' ) );
exposeDUTClockEnable = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAEnableDUTClockEnable' ) );
exposeDUTCEOut = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAEnableCEOut' ) );
axi4SlavePortToPipelineRegisterRatioOption = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAAXI4SlavePortToPipelineRegisterRatio' ) );
ipBufferSize = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAIPDataCaptureBufferSize' ) );
ipSequenceDepth = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAIPDataCaptureSequenceDepth' ) );
includeCaptureControl = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAIncludeDataCaptureControlLogicEnable' ) );
IDWidthBox = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAInputAXISlaveIDWidth' ) );
isReset = false;

try 

if ~strcmp( ipNameOption.Value, hDI.hIP.getIPCoreName )
hDI.hIP.setIPCoreName( ipNameOption.Value );
end 
if ~strcmp( ipVerOption.Value, hDI.hIP.getIPCoreVersion )
hDI.hIP.setIPCoreVersion( ipVerOption.Value );
end 
if ~strcmp( ipRepositoryOption.Value, hDI.hIP.getIPRepository )
hDI.hIP.setIPRepository( ipRepositoryOption.Value );
end 
if ~isequal( ipCustomFileOption.Value, hDI.hIP.getIPCoreCustomFile )
hDI.hIP.setIPCoreCustomFile( ipCustomFileOption.Value );
end 
if ~isequal( ipReportOption.Value, hDI.hIP.getIPCoreReportStatus )
hDI.hIP.setIPCoreReportStatus( ipReportOption.Value );
end 
if ~isequal( axi4ReadbackEnableOption.Value, hDI.hIP.getAXI4ReadbackEnable )
hDI.hIP.setAXI4ReadbackEnable( axi4ReadbackEnableOption.Value );
end 
if ~isequal( exposeDUTClockEnable.Value, hDI.hIP.getDUTClockEnable )
hDI.hIP.setDUTClockEnable( exposeDUTClockEnable.Value );
end 
if ~isequal( exposeDUTCEOut.Value, hDI.hIP.getDUTCEOut )
hDI.hIP.setDUTCEOut( exposeDUTCEOut.Value );
end 
if ~isequal( axi4SlavePortToPipelineRegisterRatioOption.Value, hDI.hIP.getInsertAXI4PipelineRegisterEnable )
hDI.hIP.setInsertAXI4PipelineRegisterEnable( axi4SlavePortToPipelineRegisterRatioOption.Value );
end 
if ~isequal( ipBufferSize.Value, hDI.hIP.getIPDataCaptureBufferSize )
hDI.hIP.setIPDataCaptureBufferSize( ipBufferSize.Value );
end 
if ~isequal( ipSequenceDepth.Value, hDI.hIP.getIPDataCaptureSequenceDepth )
hDI.hIP.setIPDataCaptureSequenceDepth( ipSequenceDepth.Value );
end 
if ~isequal( includeCaptureControl.Value, hDI.hIP.getIncludeDataCaptureControlLogicEnable )
hDI.hIP.setIncludeDataCaptureControlLogicEnable( includeCaptureControl.Value );
end 
if ~isequal( IDWidthBox.Value, hDI.hIP.getIDWidth )
hDI.hIP.setIDWidth( IDWidthBox.Value );
end 
catch ME

taskObj.reset;
isReset = true;

errorMsg = sprintf( [ 'Error occurred in Task 3.2 when loading Restore Point.\n',  ...
'The error message is:\n%s\n' ],  ...
ME.message );
hf = errordlg( errorMsg, 'Error', 'modal' );

set( hf, 'tag', 'Load Generate IP Core error dialog' );
setappdata( hf, 'MException', ME );
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp3NaCLa.p.
% Please follow local copyright laws when handling this file.

