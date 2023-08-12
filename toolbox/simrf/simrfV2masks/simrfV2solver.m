function simrfV2solver( block, action )







top_sys = bdroot( block );
if strcmpi( get_param( top_sys, 'Lock' ), 'on' )
return 
end 





switch ( action )
case 'simrfInit'
auxData = createsolverauxdata( block );


MaskWSValues = simrfV2getblockmaskwsvalues( block );
IPfreqPrev = auxData.IPfreq;
OPfreqPrev = auxData.OPfreq;

if regexpi( get_param( top_sys, 'SimulationStatus' ),  ...
'^(updating|initializing)$' )





builtin( 'license', 'checkout', 'RF_Toolbox' );
if MaskWSValues.AutoFreq || MaskWSValues.EnableInterpFilter
[ IPfreq, OPfreq, IPBlks ] =  ...
simrfV2_find_solverIPOPfreqs( block );
if ( length( IPBlks ) == 1 )
val = 'on';
else 
val = 'off';
end 
set_param( block, 'HiddenFIRfilterControllerParam', val );
end 

if MaskWSValues.AutoFreq


if ( ( isempty( auxData.tones ) ) ||  ...
( ~isequal( auxData.IPfreq, IPfreq ) ||  ...
~isequal( auxData.OPfreq, OPfreq ) ) )
[ tones, harms ] = simrfV2_fundamental_tones( IPfreq, OPfreq );
auxData.tones = tones;
auxData.harmonics = harms;
auxData.IPfreq = IPfreq;
auxData.OPfreq = OPfreq;
else 
tones = auxData.tones;
harms = auxData.harmonics;
end 
else 

tones = simrfV2checkparam( MaskWSValues.Tones, 'Tones', 'gtez' );
validateattributes( tones, { 'numeric' },  ...
{ 'nonempty', 'row', 'finite', 'real', 'nonnegative' },  ...
block, 'specified frequencies' )
if length( tones ) ~= length( unique( tones ) )
error( message( 'simrf:simrfV2errors:FreqsNotUnique',  ...
'Tones' ) )
end 

if length( tones ) > 1
ldcTones = ( tones ~= 0 );
tones = tones( ldcTones );
else 
ldcTones = true;
end 
tones = simrfV2convert2baseunit( tones,  ...
MaskWSValues.Tones_unit );

harms = simrfV2checkparam( MaskWSValues.Harmonics,  ...
'Harmonics', 'gtz', length( MaskWSValues.Tones ) );
harms = harms( ldcTones );
auxData.tones = tones;
auxData.harmonics = harms;


auxData.IPfreq = [  ];
auxData.OPfreq = [  ];
end 


auxData.FilterDelay = 0;
set_param( block, 'UserData', auxData )





if isempty( tones )
tones_str = '[]';
harms_str = '[]';
else 
tones_str = simrfV2vector2str( tones );
harms_str = simrfV2vector2str( harms );
end 


SolverConf = [ block, '/Solver Configuration' ];
EnvironPar = [ block, '/Environment Parameters' ];

set_param( SolverConf, 'Tones', tones_str )
set_param( SolverConf, 'Harmonics', harms_str )
set_param( SolverConf, 'FrequencyDomain', 'on' )
set_param( SolverConf, 'PhysicalDomain', 'network_engine_domain' )
set_param( SolverConf, 'LeftPortType', 'input' )
set_param( SolverConf, 'RightPortType', 'generic' )
set_param( SolverConf, 'SubClassName', 'solver' )
set_param( SolverConf, 'DoDC', 'off' )
set_param( SolverConf, 'ResidualTolerance', '1e-9' )
set_param( SolverConf, 'UseLocalSolver', 'off' )
set_param( SolverConf, 'UseCCode', MaskWSValues.UseCCode )

if ( ( MaskWSValues.SmallSignalApprox ) &&  ...
( ~MaskWSValues.AllSimFreqs ) )

simFreqs = simrfV2checkparam( MaskWSValues.SimFreqs,  ...
'Small signal frequencies', 'gtez' );
validateattributes( simFreqs, { 'numeric' },  ...
{ 'nonempty', 'row', 'finite', 'real', 'nonnegative' },  ...
block, 'specified frequencies' )
if length( simFreqs ) ~= length( unique( simFreqs ) )
error( message( 'simrf:simrfV2errors:FreqsNotUnique',  ...
'Small signal frequencies' ) )
end 
simFreqs = simrfV2convert2baseunit( simFreqs,  ...
MaskWSValues.SimFreqs_unit );
allFreqs = simrfV2_sysfreqs( tones, harms );
[ isSimFreqMember, allFreqInd ] =  ...
freqIsMember( simFreqs, allFreqs, 1e-8 );
if all( ~isSimFreqMember )
error( message( [ 'simrf:simrfV2errors:' ...
, 'SSFreqsNoneInAllFreqs' ] ) )
elseif ~all( isSimFreqMember )
warning( message( [ 'simrf:simrfV2errors:' ...
, 'SSFreqsNotInAllFreqs' ] ) )
end 



simFreqs = allFreqs( allFreqInd( isSimFreqMember ) );
simFreqs_str = simrfV2vector2str( simFreqs );
if ~strcmpi( get_param( block, 'SimFreqsInternal' ),  ...
simFreqs_str )
set_param( block, 'SimFreqsInternal', simFreqs_str );
end 
end 

switch MaskWSValues.SolverType
case 'Trapezoidal Rule'
set_param( SolverConf, 'LocalSolverChoice',  ...
'NE_TRAPEZOIDAL_ADVANCER' )
case 'Backward Euler'
set_param( SolverConf, 'LocalSolverChoice',  ...
'NE_BACKWARD_EULER_ADVANCER' )
case { 'NDF2', 'Auto' }
set_param( SolverConf, 'LocalSolverChoice',  ...
'NE_NDF2_ADVANCER' )
end 


stepsize = simrfV2checkparam( MaskWSValues.StepSize,  ...
'Step size', 'gtez', 1 );
stepsize = simrfV2convert2baseunit( stepsize,  ...
MaskWSValues.StepSize_unit );

validateattributes( MaskWSValues.SamplesPerFrame,  ...
{ 'numeric' },  ...
{ 'nonempty', 'scalar', 'real', 'integer', 'positive',  ...
'<=', 1024 },  ...
mfilename, 'Samples per frame' );
stepsize_str = num2str( stepsize * MaskWSValues.SamplesPerFrame, 16 );
set_param( SolverConf, 'LocalSolverSampleTime', stepsize_str )





if MaskWSValues.NormalizeCarrierPower
set_param( SolverConf, 'DoFixedCost', 'on' )
else 
set_param( SolverConf, 'DoFixedCost', 'off' )
end 
set_param( SolverConf, 'MaxNonlinIter', '3' )
set_param( SolverConf, 'MaxModeIter', '2' )
set_param( SolverConf, 'LinearAlgebra', 'Sparse' )
set_param( SolverConf, 'Profile', 'off' )
set_param( SolverConf, 'UseLocalSampling', 'off' )
set_param( SolverConf, 'DelaysMemoryBudget', '1024' )

if ( MaskWSValues.AddNoise )
set_param( SolverConf, 'SimulateNoise', 'on' )
else 
set_param( SolverConf, 'SimulateNoise', 'off' )
end 


temperature_str = num2str( MaskWSValues.Temperature, 16 );
set_param( EnvironPar, 'Temperature', temperature_str )
set_param( EnvironPar, 'Temperature_unit',  ...
MaskWSValues.Temperature_unit )
set_param( EnvironPar, 'GMIN', '1e-12', 'GMIN_unit', '1/Ohm' )
set_param( EnvironPar,  ...
'GlobalNoiseOn', num2str( MaskWSValues.AddNoise ) )
stepsize_str = num2str( MaskWSValues.StepSize, 16 );
set_param( EnvironPar, 'StepSize', stepsize_str );
set_param( EnvironPar, 'StepSize_unit',  ...
MaskWSValues.StepSize_unit );
end 

if ( ( MaskWSValues.AddNoise ) && ( ~MaskWSValues.defaultRNG ) )
validateattributes( MaskWSValues.Seed,  ...
{ 'numeric' }, { 'nonempty', 'scalar', 'finite', 'real',  ...
'integer', '>=', 0, '<', uint64( 2 ^ 32 ) }, mfilename, 'Seed' );
end 
if ( ( MaskWSValues.SmallSignalApprox ) && ( ~MaskWSValues.AllSimFreqs ) )

validateattributes( MaskWSValues.SimFreqs, { 'numeric' },  ...
{ 'nonempty', 'row', 'finite', 'real', 'nonnegative' },  ...
block, 'specified frequencies' )
end 

validateattributes( MaskWSValues.RelTol,  ...
{ 'numeric' }, { 'nonempty', 'scalar', 'finite', 'real',  ...
'positive', '<', 1.0, '>=', 1e-6 }, mfilename, 'RelTol' );
validateattributes( MaskWSValues.AbsTol,  ...
{ 'numeric' }, { 'nonempty', 'scalar', 'finite', 'real',  ...
'positive' }, mfilename, 'RelTol' );
validateattributes( MaskWSValues.MaxIter,  ...
{ 'numeric' }, { 'nonempty', 'scalar', 'finite', 'real',  ...
'positive', 'integer', '<=', 50 }, mfilename, 'MaxIter' );
if ~isempty( auxData.FigHandlePop ) && ishghandle( auxData.FigHandlePop )
dlg = simrfV2_find_dialog( block );
if isempty( dlg )
blkParent = get_param( block, 'Parent' );
if strcmp( get_param( blkParent, 'type' ), 'block' ) &&  ...
strcmp( get_param( blkParent, 'classname' ), 'tbsparam' )
dlg = simrfV2_find_dialog( blkParent );
end 
end 
if ~isempty( dlg )
if ( any( size( IPfreqPrev ) ~= size( auxData.IPfreq ) ) ||  ...
any( ~freqIsEq( IPfreqPrev, auxData.IPfreq, 1e-8 ) ) ||  ...
any( size( OPfreqPrev ) ~= size( auxData.OPfreq ) ) ||  ...
any( ~freqIsEq( OPfreqPrev, auxData.OPfreq, 1e-8 ) ) )
simrfV2_select_solver_freqs( dlg.getSource, true );







else 
simrfV2_select_solver_freqs( dlg.getSource );




end 
end 
end 

case 'simrfDelete'

case 'simrfCopy'

case 'simrfDefault'

end 

end 

function auxData = createsolverauxdata( block )
auxData = get_param( block, 'UserData' );

if isempty( auxData ) || ~isfield( auxData, 'Vers' )


auxData.Vers = 2.0;
auxData.tones = [  ];
auxData.harmonics = [  ];
auxData.IPfreq = [  ];
auxData.OPfreq = [  ];
auxData.FigHandle = [  ];
auxData.FigHandlePop = [  ];
set_param( block, 'UserData', auxData )
end 
end 


function res = freqIsEq( A, B, relTol, absTol )
if nargin == 3
res = abs( A - B ) < relTol * max( abs( A ), abs( B ) ) + relTol;
else 
res = abs( A - B ) < relTol * max( abs( A ), abs( B ) ) + absTol;
end 
end 

function [ isMem, memInd ] = freqIsMember( A, B, varargin )
memInd = arrayfun( @( Ael )find( freqIsEq( Ael, [ B( : );Ael ],  ...
varargin{ : } ), 1 ), A );
memInd( memInd > length( B ) ) = 0;
isMem = logical( memInd );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpWT7VVo.p.
% Please follow local copyright laws when handling this file.

