classdef ( Hidden = true )SimulatorDeployed < slsim.SimulatorImpl


properties 
simInput_( 1, 1 )Simulink.SimulationInput
raInstance_ = [  ];
raDir_ = '';
origDir_ = '';
rtp_ = [  ];
buildData_ = [  ];
modelName_ = '';
end 
methods 
function obj = SimulatorDeployed( simIn )
obj.simInput_ = simIn;
obj.modelName_ = simIn.ModelName;
end 
function isFinal = stepImpl( this )
isFinal = this.raInstance_.step;
end 
function startImpl( ~ )
end 
function results = simImpl( this )
initializeImpl( this );
this.raInstance_.run;
results = slsim.SimulatorDeployed.getOutputData( this.buildData_ );
end 
function pauseImpl( ~ )
end 
function initializeImpl( this )
if isempty( this.raDir_ )
this.raDir_ = slsim.SimulatorDeployed.createTempDirectory(  );
end 
this.origDir_ = pwd;
cd( this.getSlprjDirectory(  ) );
[ this.rtp_, this.buildData_ ] =  ...
slsim.SimulatorDeployed.buildRapidAccelTarget(  ...
this.simInput_.ModelName );

this.raInstance_ = slsim.internal.SimInstance(  ...
this.simInput_.ModelName,  ...
[ this.getSlprjDirectory(  ), filesep, 'slprj', filesep, 'raccel_deploy',  ...
filesep, this.simInput_.ModelName ] );
this.raInstance_.initialize(  );
end 
function stopImpl( this )
this.raInstance_.stop;
cd( this.origDir_ );
end 
function resumeImpl( ~ )
end 
function SimStatus = statusImpl( this )
status = slsim.internal.getSimulationStatus( this.modelName_ );
str = string( status );
if strcmp( str, 'Inactive' )
str = 'Stopped';
end 
SimStatus = slsim.SimStatus( str );
end 
function simTime = simulationTimeImpl( this )
simTime = slsim.internal.getSimulationTime( this.modelName_ );
end 
end 
methods ( Hidden )
function directory = getSlprjDirectory( this )
directory = this.raDir_;
end 
end 
methods ( Static )
function temp_dir_name = createTempDirectory(  )
temp_dir_name = tempname(  );
mkdir( temp_dir_name )
end 
function [ rtp, buildData ] = buildRapidAccelTarget( model )
R36
model( 1, 1 )string
end 
[ rtp, buildData ] = slsim.buildRapidAcceleratorTarget( model );
end 
function results = getOutputData( buildData )
results = sl( 'rapid_accel_target_utils', 'load_mat_file',  ...
buildData, 1, false, [  ], [  ] );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp_gctTl.p.
% Please follow local copyright laws when handling this file.

