function parallelExecutionManager( model, varargin )
slfeature( 'ForEachParallelExecutionInRapidAccel', 1 );
slsvTestingHook( 'UseSimplifiedParallelExecutionEngine', 1 );
load_system( model );
modelH = get_param( model, 'handle' );
w = warning( 'off', 'Simulink:Engine:UINotUpdatedDuringRapidAccelSim' );
buildDir = getBuildDir( model );
relParallelProfilingOutputFilename =  ...
'parallelExecutionProfilingOutput_parallel.txt';
relSerialProfilingOutputFilename =  ...
'parallelExecutionProfilingOutput_serial.txt';
relNodeExecutionModesFilename =  ...
'parallelExecutionNodeExecutionModes.txt';

parallelProfilingOutputFilename =  ...
fullfile( buildDir, relParallelProfilingOutputFilename );
serialProfilingOutputFilename =  ...
fullfile( buildDir, relSerialProfilingOutputFilename );
nodeExecutionModesFilename =  ...
fullfile( buildDir, relNodeExecutionModesFilename );
options.SimulationMode = 'rapid';
options.ParallelExecutionProfiling = 'on';
options.ParallelExecutionInRapidAccelerator = 'on';
options.ParallelExecutionProfilingOutputFilename =  ...
relParallelProfilingOutputFilename;

reportOptions.compare = false;
reportOptions.optimize = false;
if ( nargin > 1 )
if ( isequal( varargin{ 1 }, 'optimize' ) )
reportOptions.optimize = true;
elseif ( isequal( varargin{ 1 }, 'compare' ) )
reportOptions.compare = true;
end 
end 

previousExecutionModes = [  ];
tmpNodeExecutionModesFilename = [ nodeExecutionModesFilename, '.tmp' ];
if exist( nodeExecutionModesFilename, 'file' )
fid = fopen( nodeExecutionModesFilename );
previousExecutionModes = fscanf( fid, '%d', [ 1, inf ] );
fclose( fid );
if reportOptions.optimize
movefile( nodeExecutionModesFilename,  ...
tmpNodeExecutionModesFilename );
end 
end 

pExecTimes = [  ];
sExecTimes = [  ];
if ( reportOptions.compare || reportOptions.optimize )
sim( model, options );
pExecTimes = getExecutionTimes( parallelProfilingOutputFilename );

options.ParallelExecutionInRapidAccelerator = 'off';
options.ParallelExecutionProfilingOutputFilename =  ...
relSerialProfilingOutputFilename;

sim( model, options );
sExecTimes = getExecutionTimes( serialProfilingOutputFilename );
end 
if reportOptions.optimize && exist( tmpNodeExecutionModesFilename, 'file' )
movefile( tmpNodeExecutionModesFilename,  ...
nodeExecutionModesFilename );
end 
warning( w.state, 'Simulink:Engine:UINotUpdatedDuringRapidAccelSim' );
generateReport( modelH, pExecTimes, sExecTimes,  ...
previousExecutionModes, reportOptions );
end 

function buildDir = getBuildDir( model )

fileGenCfg = Simulink.fileGenControl( 'getConfig' );
buildDir = fullfile( fileGenCfg.CodeGenFolder, 'slprj', 'raccel', model );
end 



function executionTimes = getExecutionTimes( filename )
fid = fopen( filename );
executionTimes = fscanf( fid, '%g', [ 1, inf ] );
fclose( fid );
end 


function launchUI( modelH, execData )
daRoot = DAStudio.Root;
explorers = daRoot.find( '-isa', 'Simulink.ParallelExecutionExplorer' );
for i = 1:length( explorers )
explorers( i ).hide;
delete( explorers( i ) );
end 

children( length( execData ) ) = Simulink.ParallelExecutionNode( execData( 1 ) );
for i = 1:length( execData )
children( i ) = Simulink.ParallelExecutionNode( execData( i ) );
end 
k = Simulink.ParallelExecutionManager( modelH, children );
m = Simulink.ParallelExecutionExplorer( k );
m.showDialogView( false );
m.Title = 'Parallel Execution Manager';
am = DAStudio.ActionManager;
am.initializeClient( m )
action = am.createAction(  ...
m,  ...
'Text', 'Save Configuration',  ...
'Tag', 'pexec_mgr_save_config',  ...
'Callback',  ...
[ 'sl(''saveParallelConfigurationFile'', ''', num2str( modelH ), ''')' ] );
tbar = am.createToolBar( m );
tbar.addAction( action );
end 

function report = generateReport( model, pExecTimes, sExecTimes, previousExecutionModes, reportOptions )

nodeHandles = get_param( model, 'ParallelExecutionNodeHandles' );
nNodes = length( nodeHandles );
report = struct;
for i = nNodes: - 1:1
report( i ).nodeName = getfullname( nodeHandles( i ) );
if reportOptions.optimize || reportOptions.compare
report( i ).parallelExecutionTime = pExecTimes( i );
report( i ).serialExecutionTime = sExecTimes( i );
end 
if reportOptions.optimize
report( i ).executionMode = 1;
if ( sExecTimes( i ) <= pExecTimes( i ) )
report( i ).executionMode = 0;
end 
if ( length( previousExecutionModes ) == nNodes )
report( i ).previousExecutionMode = previousExecutionModes( i );
else 
report( i ).previousExecutionMode =  - 1;
end 

elseif ( length( previousExecutionModes ) == nNodes )
report( i ).executionMode = previousExecutionModes( i );
else 
report( i ).executionMode =  - 1;
end 
end 
launchUI( model, report );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpoDyT6X.p.
% Please follow local copyright laws when handling this file.

