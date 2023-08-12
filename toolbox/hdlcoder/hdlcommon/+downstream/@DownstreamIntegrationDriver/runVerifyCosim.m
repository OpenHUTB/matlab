function [ Result, logTxt ] = runVerifyCosim( obj, dut )





hDriver = hdlcoderargs( dut );

HdlPid =  - 1;
RestoreConfig = false;
Result = false;
logTxt = '';
CosimDirName = pwd;

try 

CosimModelName = hDriver.CosimModelName;
if isempty( CosimModelName ) || ~bdIsLoaded( CosimModelName )
error( message( 'HDLShared:hdldialog:HDLWAVerifyCosimModel' ) );
end 
CosimSimulator = hdlget_param( CosimModelName, 'GenerateCoSimModel' );

open_system( CosimModelName );


if strcmpi( CosimSimulator, 'ModelSim' )
CosimBlock = find_system( CosimModelName, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'ReferenceBlock', 'modelsimlib/HDL Cosimulation' );
elseif strcmpi( CosimSimulator, 'Incisive' )
CosimBlock = find_system( CosimModelName, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'ReferenceBlock', 'lfilinklib/HDL Cosimulation' );
elseif strcmpi( CosimSimulator, 'Vivado Simulator' )
CosimBlock = find_system( CosimModelName, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'ReferenceBlock', 'vivadosimlib/HDL Cosimulation' );
end 

if isempty( CosimBlock )
error( message( 'HDLShared:hdldialog:HDLWAVerifyCosimBlock', CosimModelName ) );
end 




CosimAssertBlks = find_system( CosimModelName, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'LookUnderMasks', 'all', 'BlockType', 'Assertion' );

if isempty( CosimAssertBlks )
error( message( 'HDLShared:hdldialog:HDLWAVerifyCosimAssert', CosimModelName ) );
end 

for ii = 1:numel( CosimAssertBlks )
set_param( CosimAssertBlks{ ii }, 'Enabled', 'on' );
set_param( CosimAssertBlks{ ii }, 'StopWhenAssertionFail', 'on' );
end 

CosimStopTime = get_param( CosimModelName, 'stopTime' );
if strcmp( CosimStopTime, 'inf' ) || strcmp( CosimStopTime, 'Inf' )
error( message( 'HDLShared:hdldialog:HDLWAVerifyCosimInfinite', CosimModelName ) );
end 

TclCmd = [ hDriver.getParameter( 'module_prefix' ), CosimModelName, '_batch_tcl' ];
PortNumber = num2str( getAvailableSocketPort );

cd( hDriver.hdlGetCodegendir );
if strcmpi( CosimSimulator, 'ModelSim' )
vsim( 'runmode', 'Batch', 'socketsimulink', PortNumber, 'tclstart', eval( TclCmd ) );
elseif strcmpi( CosimSimulator, 'Incisive' )
nclaunch( 'runmode', 'CLI', 'socketsimulink', PortNumber, 'tclstart', eval( TclCmd ) );
elseif strcmpi( CosimSimulator, 'Vivado Simulator' )


[ s, r ] = system( [ 'vivado -mode batch -source ', CosimModelName, '.tcl' ], '-echo' );
if s
error( message( 'HDLShared:hdldialog:HDLWAVerifyCosimVivadoDLLError', [ CosimModelName, '.tcl' ], r ) );
end 
end 
cd( CosimDirName );

switch ( CosimSimulator )
case { 'ModelSim', 'Incisive' }
timeout = 180;
HdlPid = pingHdlSim( timeout, PortNumber );
if HdlPid < 0
error( message( 'HDLShared:hdldialog:HDLWAVerifyCosimWorkflowTimeout', CosimSimulator, timeout ) );
end 

open_system( CosimModelName );


CommLocalPrev = get_param( CosimBlock{ 1 }, 'CommLocal' );
CommSharedMemoryPrev = get_param( CosimBlock{ 1 }, 'CommSharedMemory' );
CommPortNumberPrev = get_param( CosimBlock{ 1 }, 'CommPortNumber' );
RestoreConfig = true;


set_param( CosimBlock{ 1 }, 'CommLocal', 'on' );
set_param( CosimBlock{ 1 }, 'CommSharedMemory', 'off' );
set_param( CosimBlock{ 1 }, 'CommPortNumber', PortNumber );

sim( CosimModelName );


set_param( CosimBlock{ 1 }, 'CommLocal', CommLocalPrev );
set_param( CosimBlock{ 1 }, 'CommSharedMemory', CommSharedMemoryPrev );
set_param( CosimBlock{ 1 }, 'CommPortNumber', CommPortNumberPrev );
case 'Vivado Simulator'
HdlPid =  - 1;
RestoreConfig = false;
sim( CosimModelName );
end 

Result = true;

catch ME
cd( CosimDirName );
if HdlPid > 0
if ispc
system( [ 'Taskkill /F /PID ', HdlPid ] );
else 
system( [ 'kill -9 ', HdlPid ] );
end 
end 
if RestoreConfig

set_param( CosimBlock{ 1 }, 'CommLocal', CommLocalPrev );
set_param( CosimBlock{ 1 }, 'CommSharedMemory', CommSharedMemoryPrev );
set_param( CosimBlock{ 1 }, 'CommPortNumber', CommPortNumberPrev );
end 


rethrow( ME );

end 


end 







% Decoded using De-pcode utility v1.2 from file /tmp/tmpPxxqwb.p.
% Please follow local copyright laws when handling this file.

