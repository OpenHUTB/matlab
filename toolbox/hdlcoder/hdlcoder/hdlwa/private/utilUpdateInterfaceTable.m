function utilUpdateInterfaceTable( mdladvObj, hDI )





tablesetting = hDI.hTurnkey.hTable.drawGUITable;


targetInterfaceTaskID = utilGetTargetInterfaceTask( hDI );
tableInputParams = mdladvObj.getInputParameters( targetInterfaceTaskID );
interfaceTable = utilGetInputParameter( tableInputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAInputTargetPlatformInterfaceTable' ) );

interfaceTable.TableSetting.Size = tablesetting.Size;
interfaceTable.TableSetting.Data = tablesetting.Data;
interfaceTable.TableSetting.ColHeader = tablesetting.ColHeader;
interfaceTable.TableSetting.ColumnCharacterWidth = tablesetting.ColumnCharacterWidth;


interfaceTable.TableSetting.ColumnHeaderHeight = tablesetting.ColumnHeaderHeight;
interfaceTable.TableSetting.HeaderVisibility = tablesetting.HeaderVisibility;
interfaceTable.TableSetting.ReadOnlyColumns = tablesetting.ReadOnlyColumns;
interfaceTable.TableSetting.MinimumSize = tablesetting.MinimumSize;


dcPorts = hDI.hTurnkey.hTable.hTableMap.getConnectedPortList( 'FPGA Data Capture' );
targetObj = mdladvObj.getTaskObj( 'com.mathworks.HDL.GenerateIPCore' );
inputParams = mdladvObj.getInputParameters( targetObj.MAC );
bufferSizeOpt = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAIPDataCaptureBufferSize' ) );
bufferSizeOpt.Enable = numel( dcPorts ) > 0;
sequenceDepthOpt = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAIPDataCaptureSequenceDepth' ) );
sequenceDepthOpt.Enable = numel( dcPorts ) > 0;
includeCaptureControlOpt = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAIncludeDataCaptureControlLogicEnable' ) );
includeCaptureControlOpt.Enable = numel( dcPorts ) > 0;



% Decoded using De-pcode utility v1.2 from file /tmp/tmpnkXPRG.p.
% Please follow local copyright laws when handling this file.

