classdef Engine < handle

properties ( Constant = true, Hidden = true )
engine = sim3d.engine.Engine(  )
end 


properties ( Constant = true, Access = private )
NumberOfWarmUpSteps( 1, 1 )uint32 = 1
DefHttp = 7070;
DefStreamer = 8888;
end 


properties ( Access = private, Hidden = true )
engineInterface;
engineFactory;
end 

methods ( Access = private )
function self = Engine(  )
self.engineFactory = sim3d.engine.EngineFactory(  );
self.engineInterface = self.engineFactory.createEngine(  );
self.engineInterface.start(  );
end 
end 
methods 
function delete( self )
if ~isempty( self.engineInterface )
self.engineInterface.stop(  );
end 
end 
end 
methods ( Static = true, Hidden = true )
function startSimulation( command )
if ~sim3d.engine.Engine.isPlatformEnabled(  )
error( message( 'shared_sim3dblks:sim3dblkConfig:blkPrmError_UnsupportedPlatform' ) );
end 
sim3d.engine.Engine.engine.engineInterface.startSimulation( command );
end 
function setSampleTime( sampleTime )
SetSimulation3DInterfaceSampleTime( sampleTime );
end 
function sampleTime = getSampleTime(  )
sampleTime = GetSimulation3DInterfaceSampleTime(  );
end 
end 

methods ( Static = true, Access = public, Hidden = true )
function ready = isReady( readyTimeout_sec )

ready = sim3d.engine.Engine.engine.engineInterface.isReady( readyTimeout_sec );
end 
function stop(  )

sim3d.engine.Engine.engine.engineInterface.stop(  );
end 
function start(  )

sim3d.engine.Engine.engine.engineInterface.start(  );
end 
function restart(  )

sim3d.engine.Engine.engine.engineInterface.restart(  );
end 
function stateOut = getSetState( stateIn, operation )
persistent engineState
if isempty( engineState )
engineState = sim3d.engine.EngineCommands.STOP;
end 
switch operation
case 'get'
stateOut = engineState;
case 'set'
engineState = stateIn;
stateOut = [  ];
end 
end 
function state = getState(  )
state = sim3d.engine.Engine.getSetState( [  ], 'get' );
end 
function setState( state )
sim3d.engine.Engine.getSetState( state, 'set' );
end 
end 
methods ( Static = true, Access = public, Hidden = true )
function value = isPlatformEnabled(  )
platform = computer( 'arch' );
if ispref( 'Simulation3D', platform )
value = getpref( 'Simulation3D', platform );
else 

switch ( platform )
case 'win64'
value = true;
case 'glnxa64'
value = false;
case 'maci64'
value = false;
end 
end 
end 
function enabledPlatform(  )
platform = computer( 'arch' );
setpref( 'Simulation3D', platform, true );
end 
function disablePlatform(  )
platform = computer( 'arch' );
setpref( 'Simulation3D', platform, false );
end 
function debug = getDebugLevel(  )
if ispref( 'Simulation3D', 'debug' )
debug = uint32( getpref( 'Simulation3D', 'debug' ) );
else 
debug = uint32( 0 );
end 
end 
function setDebugLevel( debug )
R36
debug( 1, 1 )uint32
end 
setpref( 'Simulation3D', 'debug', debug );
end 
function warmUpSteps = getWarmUpSteps(  )
if ispref( 'Simulation3D', 'warmUpSteps' )
warmUpSteps = uint32( getpref( 'Simulation3D', 'warmUpSteps' ) );
else 
warmUpSteps = sim3d.engine.Engine.NumberOfWarmUpSteps;
end 
end 
function setWarmUpSteps( warmUpSteps )
R36
warmUpSteps( 1, 1 )uint32
end 
setpref( 'Simulation3D', 'warmUpSteps', warmUpSteps );
end 
function httpPort = getHttpPort(  )
if ispref( 'Simulation3D', 'httpPort' )
httpPort = getpref( 'Simulation3D', 'httpPort' );
else 
httpPort = sim3d.engine.Engine.DefHttp;
end 
end 
function setHttpPort( httpPort )
R36
httpPort
end 
setpref( 'Simulation3D', 'httpPort', httpPort );
end 
function streamerPort = getStreamerPort(  )
if ispref( 'Simulation3D', 'streamerPort' )
streamerPort = getpref( 'Simulation3D', 'streamerPort' );
else 
streamerPort = sim3d.engine.Engine.DefStreamer;
end 
end 
function setStreamerPort( streamerPort )
R36
streamerPort
end 
setpref( 'Simulation3D', 'streamerPort', streamerPort );
end 

end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpKAa7KC.p.
% Please follow local copyright laws when handling this file.

