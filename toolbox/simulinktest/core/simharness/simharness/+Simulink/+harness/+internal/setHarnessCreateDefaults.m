function setHarnessCreateDefaults( NameValueArgs )
R36
NameValueArgs.Name( 1, 1 )string
NameValueArgs.LogOutputs( 1, 1 )logical
NameValueArgs.LogHarnessOutputs( 1, 1 )logical
NameValueArgs.SaveExternally( 1, 1 )logical
NameValueArgs.PostCreateCallback( 1, 1 )string
NameValueArgs.Source( 1, 1 )string{ srcMustBeMember( NameValueArgs.Source ) }
NameValueArgs.Sink( 1, 1 )string{ sinkMustBeMember( NameValueArgs.Sink ) }
NameValueArgs.SynchronizationMode( 1, 1 )string ...
{ validateFcn( "SynchronizationMode", NameValueArgs.SynchronizationMode,  ...
[ "SyncOnOpenAndClose", "SyncOnOpen", "SyncOnPushRebuildOnly" ] ) }
NameValueArgs.Description( 1, 1 )string
NameValueArgs.SeparateAssessment( 1, 1 )logical
NameValueArgs.CreateWithoutCompile( 1, 1 )logical
NameValueArgs.RebuildOnOpen( 1, 1 )logical
NameValueArgs.RebuildModelData( 1, 1 )logical
NameValueArgs.HarnessPath( 1, 1 )string
NameValueArgs.PostRebuildCallback( 1, 1 )string
NameValueArgs.ScheduleInitTermReset( 1, 1 )logical
NameValueArgs.SchedulerBlock( 1, 1 )string ...
{ validateFcn( "SchedulerBlock", NameValueArgs.SchedulerBlock,  ...
[ "None", "Test Sequence", "MATLAB Function", "Schedule Editor", "Chart" ] ) }
NameValueArgs.AutoShapeInputs( 1, 1 )logical
NameValueArgs.CustomSourcePath( 1, 1 )string
NameValueArgs.CustomSinkPath( 1, 1 )string
NameValueArgs.VerificationMode( 1, 1 )string ...
{ validateFcn( "VerificationMode", NameValueArgs.VerificationMode,  ...
[ "Normal", "SIL", "PIL" ] ) }
end 
cm = DAStudio.CustomizationManager;
if slfeature( 'SLT_HarnessCustomizationRegistration' ) == 0

DAStudio.error( 'Simulink:Harness:DefaultRegistrationsDisallowed' );
end 








cObj = cm.SimulinkTestCustomizer;
cObj.setHarnessCreateDefaults( NameValueArgs );

end 


function validateFcn( param, input, inputList )
if ~any( strcmpi( input, inputList ) )
DAStudio.error( 'Simulink:Harness:InvalidInputArgumentForHarnessDefaults',  ...
param, strjoin( inputList, ''', ''' ), input );
end 
end 

function srcMustBeMember( srcInput )
import Simulink.harness.internal.TestHarnessSourceTypes;
testingSources = Simulink.harness.internal.getTestingSourcesList(  ...
"IncludeSigBuilder", false );
validateFcn( 'Source', srcInput, testingSources );
end 

function sinkMustBeMember( sinkInput )
import Simulink.harness.internal.TestHarnessSinkTypes;
testingSinks =  ...
Simulink.harness.internal.getTestingSinksList( 'IncludeChartAndAssmt', 0 );
validateFcn( 'Sink', sinkInput, testingSinks );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp4wW04c.p.
% Please follow local copyright laws when handling this file.

