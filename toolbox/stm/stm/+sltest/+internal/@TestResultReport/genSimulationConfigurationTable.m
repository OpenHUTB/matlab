function simCfgTable = genSimulationConfigurationTable( obj, result, simIndex )














R36
obj( 1, 1 ){ mustBeA( obj, [ "sltest.internal.TestResultReport", "sltest.testmanager.TestResultReport" ] ) };
result sltest.testmanager.ReportUtility.ReportResultData;
simIndex( 1, 1 )double{ mustBeMember( simIndex, [ 1, 2 ] ) };
end 

import mlreportgen.dom.*;
resultObj = result.Data;

metaData = resultObj.SimulationMetadata( simIndex );

simCfgTable = FormalTable( 2 );
simCfgTable.TableEntriesStyle = { OuterMargin( '0mm' ) };
simCfgTable.Style = [ simCfgTable.Style, { ResizeToFitContents( false ),  ...
OuterMargin( obj.ChapterIndentL2, '0mm', '0mm', '2mm' ) } ];

groups = sltest.testmanager.ReportUtility.genTableColSpecGroup( [ { '5cm' }, { '10cm' } ] );
simCfgTable.ColSpecGroups = groups;

onerow = TableRow(  );
str = getString( message( 'stm:ReportContent:Label_ModelInformation' ) );
text = Text( str );
sltest.testmanager.ReportUtility.setTextStyle( text, obj.BodyFontName, obj.BodyFontSize, obj.BodyFontColor, true, false );
entryPara = Paragraph( text );
entry = TableEntry( entryPara );
entry.ColSpan = 2;
onerow.append( entry );
onerow.Style = { RowHeight( '0.3in' ) };
simCfgTable.append( onerow );

strList1 = { getString( message( 'stm:ReportContent:Field_ModelName' ) ) };
strList2 = { metaData.modelName };

if ( isfield( metaData, 'harnessName' ) && ~isempty( metaData.harnessName ) )
ind = strfind( metaData.harnessName, '%%%' );
if ( ~isempty( ind ) )
harnessName = metaData.harnessName( 1:ind( 1 ) - 1 );
ownerName = metaData.harnessName( ind( 1 ) + 3:end  );

strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_HarnessName' ) ) } ];
strList2 = [ strList2, { harnessName } ];

strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_HarnessOwner' ) ) } ];
strList2 = [ strList2, { ownerName } ];
else 
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_HarnessName' ) ) } ];
strList2 = [ strList2, { metaData.harnessName } ];

if ( ~isempty( metaData.harnessOwner ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_HarnessOwner' ) ) } ];
strList2 = [ strList2, { metaData.harnessOwner } ];
end 
end 
end 



releaseStr = '';
try 
if ( strcmp( resultObj.TestCaseType,  ...
getString( message( 'stm:toolstrip:EquivalenceTest' ) ) ) )
rIds = stm.internal.getPermutationResultIDList( resultObj.getID(  ) );
simResult = stm.internal.getPermutationResult( rIds( simIndex ) );
releaseStr = simResult.releaseName;
else 
releaseStr = char( resultObj.Release );
end 
if ( isempty( releaseStr ) )
releaseStr = getString( message( 'stm:MultipleReleaseTesting:CurrentRelease' ) );
end 



if ~sltest.internal.isRunningOnCurrentReleaseOnly( resultObj.getTestCase )
actualRelease = metaData.simulinkRelease;
releaseStr = char( strcat( releaseStr, " ", actualRelease ) );
end 
catch 
end 
if ( ~isempty( releaseStr ) )
str = getString( message( 'stm:MultipleReleaseTesting:ReleaseField' ) );
strList1 = [ strList1, str ];
strList2 = [ strList2, { releaseStr } ];
end 

if ( isfield( metaData, 'simulationMode' ) && ~isempty( metaData.simulationMode ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_SimulationMode' ) ) } ];
strList2 = [ strList2, { metaData.simulationMode } ];
end 
if isfield( metaData, 'overrideSILPILMode' )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_OverrideSILPILMode' ) ) } ];
strList2 = [ strList2, { metaData.overrideSILPILMode } ];
end 
if ( isfield( metaData, 'configSetName' ) && ~isempty( metaData.configSetName ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_ConfigSet' ) ) } ];
strList2 = [ strList2, { metaData.configSetName } ];
end 

[ strList1, strList2 ] = sltest.internal.TestResultReport.getSignalBuilderOrEditor(  ...
resultObj.SignalBuilderGroup( simIndex ), strList1, strList2 );

testSeqStruct = resultObj.TestSequenceScenario( simIndex );
if ( ~isempty( testSeqStruct.TestSequenceBlock ) )
strList1 = [ strList1, { getString( message( 'stm:InputsView:TestSequenceBlockLabel' ) ) },  ...
{ [ getString( message( 'stm:objects:TestSequenceScenario' ) ), ':' ] } ];
strList2 = [ strList2, { testSeqStruct.TestSequenceBlock }, { testSeqStruct.TestSequenceScenario } ];

end 

if ( ~isempty( resultObj.ExternalInput( simIndex ).ExternalInputName ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_ExternalInputName' ) ) } ];
strList2 = [ strList2, { resultObj.ExternalInput( simIndex ).ExternalInputName } ];

if ( ~isempty( resultObj.ExternalInput( simIndex ).ExternalInputFile ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_ExternalInputFile' ) ) } ];
strList2 = [ strList2, { resultObj.ExternalInput( simIndex ).ExternalInputFile } ];
end 
end 

if ( slfeature( 'STMOutputTriggering' ) > 0 )
[ strList1, strList2 ] = genOutputTriggerSection( resultObj, strList1, strList2, simIndex );
end 

if ( isfield( metaData, 'startTime' ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_StartTime' ) ) } ];
strList2 = [ strList2, { metaData.startTime } ];
end 
if ( isfield( metaData, 'stopTime' ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_StopTime' ) ) } ];
strList2 = [ strList2, { metaData.stopTime } ];
end 
if ( isfield( metaData, 'modelChecksum' ) )
if ( length( metaData.modelChecksum ) == 4 )

if ( max( metaData.modelChecksum ) > 0 )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_ModelChecksum' ) ) } ];
str = sprintf( '%d %d %d %d', metaData.modelChecksum( 1 ), metaData.modelChecksum( 2 ),  ...
metaData.modelChecksum( 3 ), metaData.modelChecksum( 4 ) );
strList2 = [ strList2, { str } ];
end 
end 
end 

if ( obj.IncludeSimulationMetadata == true )
if ( isfield( metaData, 'simulinkVersion' ) && ~isempty( metaData.simulinkVersion ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_SimulinkVersion' ) ) } ];
strList2 = [ strList2, { metaData.simulinkVersion } ];
end 
if ( isfield( metaData, 'modelVersion' ) && ~isempty( metaData.modelVersion ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_ModelVersion' ) ) } ];
strList2 = [ strList2, { metaData.modelVersion } ];
end 
if ( isfield( metaData, 'modelAuthor' ) && ~isempty( metaData.modelAuthor ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_ModelAuthor' ) ) } ];
strList2 = [ strList2, { metaData.modelAuthor } ];
end 
if ( isfield( metaData, 'modelDate' ) && ~isempty( metaData.modelDate ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_ModelDate' ) ) } ];
strList2 = [ strList2, { metaData.modelDate } ];
end 
if ( isfield( metaData, 'modelUserID' ) && ~isempty( metaData.modelUserID ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_ModelUserID' ) ) } ];
strList2 = [ strList2, { metaData.modelUserID } ];
end 
if ( isfield( metaData, 'modelFilePath' ) && ~isempty( metaData.modelFilePath ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_ModelFilePath' ) ) } ];
strList2 = [ strList2, { metaData.modelFilePath } ];
end 
if ( isfield( metaData, 'machineName' ) && ~isempty( metaData.machineName ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_MachineName' ) ) } ];
strList2 = [ strList2, { metaData.machineName } ];
end 
if ( isfield( metaData, 'solverName' ) && ~isempty( metaData.solverName ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_SolverName' ) ) } ];
strList2 = [ strList2, { metaData.solverName } ];
end 
if ( isfield( metaData, 'solverType' ) && ~isempty( metaData.solverType ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_SolverType' ) ) } ];
strList2 = [ strList2, { metaData.solverType } ];

if ( isfield( metaData, 'solverMaxStepSize' ) )
if ( strcmp( metaData.solverType, 'Variable-Step' ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_SolverMaxStepSize' ) ) } ];
else 
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_FixedStepSize' ) ) } ];
end 
strList2 = [ strList2, { metaData.solverMaxStepSize } ];
end 
end 
if ( isfield( metaData, 'timeStampStart' ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_SimulationStartTime' ) ) } ];
strList2 = [ strList2, { metaData.timeStampStart } ];
end 
if ( isfield( metaData, 'timeStampStop' ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_SimulationStopTime' ) ) } ];
strList2 = [ strList2, { metaData.timeStampStop } ];
end 
if ( isfield( metaData, 'platform' ) && ~isempty( metaData.platform ) )
strList1 = [ strList1, { getString( message( 'stm:ReportContent:Field_Platform' ) ) } ];
strList2 = [ strList2, { metaData.platform } ];
end 
end 

for k = 1:length( strList1 )
onerow = TableRow(  );

text = Text( strList1{ k } );
sltest.testmanager.ReportUtility.setTextStyle( text, obj.BodyFontName, obj.BodyFontSize, obj.BodyFontColor, false, false );
entryPara = Paragraph( text );
entry = TableEntry( entryPara );
onerow.append( entry );

text = Text( strList2{ k } );
sltest.testmanager.ReportUtility.setTextStyle( text, obj.BodyFontName, obj.BodyFontSize, obj.BodyFontColor, false, false );
entryPara = Paragraph( text );
entry = TableEntry( entryPara );
onerow.append( entry );
simCfgTable.append( onerow );
end 
end 

function [ strList1, strList2 ] = genOutputTriggerSection( resultObj, strList1, strList2, simIndex )
outputTriggerObjs = resultObj.getOutputTriggerResults(  );
outputTriggerObj = outputTriggerObjs( simIndex );
if outputTriggerObj.StartLoggingMode ~= sltest.testmanager.TriggerMode.SameAsSim ||  ...
outputTriggerObj.StopLoggingMode ~= sltest.testmanager.TriggerMode.SameAsSim
strList1 = [ strList1, { getString( message( 'stm:OutputView:Label_StartTrigger' ) ) } ];

if outputTriggerObj.StartLoggingMode == sltest.testmanager.TriggerMode.Condition
strList2 = [ strList2 ...
, { getString( message( 'stm:ReportContent:Field_TriggerOnSignal', outputTriggerObj.StartLoggingCondition ) ) } ];
elseif outputTriggerObj.StartLoggingMode == sltest.testmanager.TriggerMode.Duration
strList2 = [ strList2 ...
, { getString( message( 'stm:ReportContent:Field_TriggerAfterDuration', outputTriggerObj.StartLoggingDuration ) ) } ];
else 
strList2 = [ strList2 ...
, { getString( message( 'stm:OutputView:ComboBox_StartNoTriggering' ) ) } ];
end 

strList1 = [ strList1, { getString( message( 'stm:OutputView:Label_StopTrigger' ) ) } ];

if outputTriggerObj.StopLoggingMode == sltest.testmanager.TriggerMode.Condition
strList2 = [ strList2 ...
, { getString( message( 'stm:ReportContent:Field_TriggerOnSignal', outputTriggerObj.StopLoggingCondition ) ) } ];
elseif outputTriggerObj.StopLoggingMode == sltest.testmanager.TriggerMode.Duration
strList2 = [ strList2 ...
, { getString( message( 'stm:ReportContent:Field_TriggerAfterDuration', outputTriggerObj.StopLoggingDuration ) ) } ];
else 
strList2 = [ strList2 ...
, { getString( message( 'stm:OutputView:ComboBox_StopNoTriggering' ) ) } ];
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpAB_zbE.p.
% Please follow local copyright laws when handling this file.

