classdef ( Hidden = true )Simulator




properties 
impl_ = [  ];
end 

methods 
function obj = Simulator( simIn, simulatorImpl )
R36
simIn( 1, 1 )Simulink.SimulationInput
simulatorImpl = slsim.Simulator.createImpl( simIn );
end 

obj.impl_ = simulatorImpl;
end 
function initialize( this )
this.impl_.initializeImpl;
end 
function start( this )

this.checkSimStatus( [ slsim.SimStatus.Stopped, slsim.SimStatus.Initialized ] );
if this.simulationStatus(  ) ~= slsim.SimStatus.Initialized
this.initialize(  );
end 
this.impl_.startImpl;
end 
function pause( this )
this.impl_.pauseImpl;
end 
function isFinal = step( this )
isFinal = this.impl_.stepImpl;
end 
function resume( this )
this.checkSimStatus( [ slsim.SimStatus.Paused ] );
this.impl_.resumeImpl;
end 
function stop( this )
this.impl_.stopImpl;
end 
function out = sim( this )
this.checkSimStatus( [ slsim.SimStatus.Stopped, slsim.SimStatus.Initialized ] );
out = this.impl_.simImpl;
end 
function simStatus = simulationStatus( this )
simStatus = this.impl_.statusImpl(  );
end 
function simTime = simulationTime( this )
simTime = this.impl_.simulationTimeImpl(  );
end 
end 
methods ( Hidden )
function checkSimStatus( this, allowedStatuses )
R36
this( 1, 1 )slsim.Simulator
allowedStatuses( 1, : )slsim.SimStatus
end 
simStatus = simulationStatus( this );
if ~any( allowedStatuses == simStatus )
error( message( 'Slsim:Service:ModelInUnexpectedState' ) );
end 
end 
end 
methods ( Static, Hidden )
function obj = createImpl( simIn )
R36
simIn( 1, 1 )Simulink.SimulationInput
end 
isDeployed = builtin( 'isdeployed' );
if isDeployed

obj = slsim.SimulatorDeployed( simIn );
return ;
end 
slsim.Simulator.checkModelReady( simIn.ModelName );
simMode = get_param( simIn, 'SimulationMode' );

if strcmpi( simMode, 'normal' ) || strcmpi( simMode, 'accelerator' )
obj = slsim.SimulatorNormalAccel( simIn );
elseif strcmpi( simMode, 'rapid-accelerator' )
obj = slsim.SimulatorDeployed( simIn );
else 
error( message( 'Slsim:Service:UnsupportedSimulationMode' ) );
end 
end 
function checkModelNameNotEmpty( simIn )
R36
simIn( 1, 1 )Simulink.SimulationInput
end 
if isempty( simIn.ModelName )
error( message( 'Slsim:Service:ModelNameEmpty' ) );
end 
end 
function checkModelReady( mdlName )
mustBeTextScalar( mdlName );
if ~bdIsLoaded( mdlName )
error( message( 'Slsim:Service:ModelNotLoaded', mdlName ) );
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpSYi5qY.p.
% Please follow local copyright laws when handling this file.

