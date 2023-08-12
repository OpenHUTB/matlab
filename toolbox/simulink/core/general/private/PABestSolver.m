function sortedTableByBestSolver = PABestSolver( model )






















validateattributes( model, { 'char' }, { 'nonempty' } );
load_system( model );



[ refModels, ~ ] = find_mdlrefs( model, 'MatchFilter', @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices );
closeRefModel = onCleanup( @(  )close_system( refModels, 0 ) );

checkModelConstraints( model );

simParms = parseVSSimParams( model );
simParms.baseline = generateReferenceSolution( model );

stats = solverSweep( simParms );

generatedTable = statsTable( simParms, stats );

sortedTableByBestSolver = sortTableByCriterion( generatedTable );







fprintf( '\n\n%s\n\n', sortedTableByBestSolver.Properties.CustomProperties.Title );
fprintf( 'Best solver is %s : Solvers are ranked (top to bottom) by accuracy. If mescd > 2 then solvers are ranked by steps.\n\n',  ...
char( sortedTableByBestSolver{ 1, 1 } ) );
disp( sortedTableByBestSolver );

























end 

function checkModelConstraints( model )








[ sys, ~, ~, ~ ] = feval( model, [  ], [  ], [  ], 'sizes' );
if sys( 1 ) == 0
error( 'Model has not continuous states' );
end 



end 

function allParameterValues = parseVSSimParams( model )

allParameterValues = struct;

allParameterValues.model = model;
allParameterValues.solverType = get_param( model, 'SolverType' );
if strcmp( allParameterValues.solverType, 'Variable-step' )
allParameterValues.solvers = qeslGetSolvers( 'ErrorControl' );
else 
allParameterValues.solvers = qeslGetSolvers( 'FixedStep', 'SolvesDE' );
end 
allParameterValues.cpuTimeLimit = 30;
allParameterValues.numRuns = 1;
allParameterValues.errorMode = 'WholeTrajectory';
allParameterValues.screenLogging = false;
end 

function simOutRef = generateReferenceSolution( model )


[ sys, ~, ~, ~ ] = feval( model, [  ], [  ], [  ], 'sizes' );
simOutRef.refSolCoords = 1:1:sys( 1 );


if strcmp( get_param( model, 'RelTol' ), 'auto' )
baseRtol = '1e-7';
else 
baseRtol = num2str( 1e-3 * str2double( get_param( model, 'RelTol' ) ) );
end 
if strcmp( get_param( model, 'AbsTol' ), 'auto' )
baseAtol = '1e-10';
else 
baseAtol = num2str( 1e-3 * str2double( get_param( model, 'AbsTol' ) ) );
end 
simout = sim( model, 'Solver', 'VariableStepAuto', 'AbsTol', baseAtol, 'Reltol', baseRtol, 'SaveFormat', 'Array',  ...
'ReturnWorkspaceOutputs', 'on', 'SaveTime', 'on', 'SaveState', 'on' );
simOutRef.refSol = [ simout.tout, simout.xout( :, simOutRef.refSolCoords ) ];
end 

function simStats = solverSweep( simParms )

simStats = struct;

for s = 1:length( simParms.solvers )
solver = simParms.solvers{ s };
runStats = computeStats( solver, simParms );


if ~isempty( runStats )
if isfield( simStats, ( solver ) )
simIdx = numel( SimStats.( solver ).stats ) + 1;
else 
simIdx = 1;
end 
simStats.( solver ).stats( simIdx ) = runStats;
end 
end 
end 

function stats = computeStats( solver, simParms )


set_param( simParms.model, 'Solver', solver );
setSolverProfilerParms( simParms.model );


simOut = sim( simParms.model, 'TimeOut', simParms.cpuTimeLimit );

if ~strcmp( simOut.SimulationMetadata.ExecutionInfo.StopEvent, 'ReachedStopTime' )
stats = [  ];
return ;
end 


set_param( simParms.model, 'ReturnWorkspaceOutputs', 'on', 'SaveTime', 'On',  ...
'SaveState', 'on', 'SaveFormat', 'Array' );

CPU = zeros( simParms.numRuns, 1 );
for l = 1:simParms.numRuns
simOut = sim( simParms.model );
CPU( l ) = simOut.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;
end 
stats = updateStats( solver, simParms, simOut, CPU );
end 

function stats = updateStats( solver, simParms, simOut, CPU )

spidata = simOut.spidata;


stats.solver = solver;
stats = computeScenarioStats( simParms, stats );
stats = computeStatsError( simParms, simOut, stats );
stats.steps = length( simOut.tout );
stats.accept = length( spidata.odeInfo.successfulStepInfo );
if isfield( spidata.odeInfo.computationCount, 'forcingFunction' )
stats.nFF = double( spidata.odeInfo.computationCount.forcingFunction );
else 
stats.nFF = double( spidata.odeInfo.computationCount.derivative );
end 
stats.nJac = double( spidata.odeInfo.computationCount.jacobian );
stats.nLU = double( spidata.odeInfo.computationCount.matrixFactor );
stats.nLin = double( spidata.odeInfo.computationCount.linearSolve );
stats.CPU = median( CPU );
end 

function stats = computeScenarioStats( simParms, stats )

model = simParms.model;

switch simParms.solverType
case 'Variable-step'
stats.rtol = get_param( model, 'RelTol' );
stats.atol = get_param( model, 'AbsTol' );
initialStep = get_param( model, 'InitialStep' );
if ~strcmp( initialStep, 'auto' )
stats.h0 = initialStep;
else 
stats.h0 = get_param( model, 'CompiledStepSize' );
end 
case 'Fixed-step'
fixedStep = get_param( model, 'FixedStep' );
if ~strcmp( fixedStep, 'auto' )
stats.h0 = fixedStep;
else 
stats.h0 = get_param( model, 'CompiledStepSize' );
end 
end 
end 

function stats = computeStatsError( simParms, simOut, stats )


baseData = simParms.baseline.refSol;
interpStates = zeros( size( simOut.xout( :, simParms.baseline.refSolCoords ) ) );

for i = 1:size( interpStates, 2 )
interpStates( :, i ) = interp1( baseData( :, 1 ), baseData( :, i + 1 ), simOut.tout );
end 

absErr = abs( simOut.xout( :, simParms.baseline.refSolCoords ) - interpStates );

switch simParms.solverType
case 'Variable-step'

if ~strcmp( stats.rtol, 'auto' ) && ~strcmp( stats.atol, 'auto' )

stats.mescdTrajectory =  ...
 - log10( max( max( absErr ./ ( str2double( stats.atol ) / str2double( stats.rtol ) + abs( interpStates ) ) ) ) );
else 

absInterpStates = max( abs( interpStates ), 1e-12 .* ones( size( interpStates ) ) );
stats.scdTrajectory =  - log10( max( max( absErr ./ absInterpStates ) ) );
end 
case 'Fixed-step'

absInterpStates = max( abs( interpStates ), 1e-12 .* ones( size( interpStates ) ) );
stats.scdTrajectory =  - log10( max( max( absErr ./ absInterpStates ) ) );
end 

stats.intAbsErr = sum( abs( ( ( simOut.tout( 2:end  ) - simOut.tout( 1:end  - 1 ) ) / 2 ) .*  ...
( absErr( 2:end , : ) + absErr( 1:end  - 1, : ) ) ), 'all' );
end 

function finalTable = statsTable( simParms, stats )



if isempty( stats )
error( 'There are no solver statistics for model %s \n', simParms.model );
end 
nSolvers = length( fieldnames( stats ) );

allSolvers = fieldnames( stats );
finalTable = table(  );

for s = 1:nSolvers
solver = allSolvers{ s };
solverNumSims = numel( stats.( solver ).stats );
solverTable = struct2table( stats.( solver ).stats( 1:solverNumSims ), 'AsArray', true );
finalTable = [ finalTable;solverTable ];%#ok
end 




finalTable = addprop( finalTable, 'Title', 'table' );
finalTable.Properties.CustomProperties.Title = [ 'Model = ', simParms.model ...
, ', RelTol = ', char( finalTable{ 1, 2 } ) ...
, ', AbsTol = ', char( finalTable{ 1, 3 } ) ...
, ', InitStepSize = ', char( finalTable{ 1, 4 } ) ...
, ', CPUTimeLimit = ', num2str( simParms.cpuTimeLimit ) ...
, ', Runs = ', num2str( simParms.numRuns ) ];
end 

function sortedTable = sortTableByCriterion( nonSortedTable )


runs = str2double( extractBetween( nonSortedTable.Properties.CustomProperties.Title, "NumRuns = ", ")" ) );

Match = cellfun( @( x )ismember( x, { 'mescdTrajectory', 'mescdEndPoint', 'scdTrajectory', 'scdEndPoint' } ),  ...
nonSortedTable.Properties.VariableNames, 'UniformOutput', 0 );
sortCol = find( cell2mat( Match ) );

accTable = sortrows( nonSortedTable, sortCol, 'descend' );
errorCol = table2array( accTable( :, sortCol ) );


if errorCol( 1 ) >= 2

bestTable = accTable( ( errorCol >= 2 ), : );
worstTable = accTable( ( errorCol < 2 ), : );

if runs >= 3
sortedBestTable = sortrows( bestTable, 'CPU' );
else 
sortedBestTable = sortrows( bestTable, { 'steps', 'nJac', 'nFF' } );
end 

sortedTableOld = [ sortedBestTable;worstTable ];
else 
sortedTableOld = accTable;
end 
sortedTable = tablePostProcessing( sortedTableOld );
sortedTable.Properties.CustomProperties.Title = sortedTableOld.Properties.CustomProperties.Title;
end 

function reducedTable = tablePostProcessing( fullTable )


reducedTable = fullTable( :, [ 1, 5, 7, 10, 9, 13 ] );
end 

function setSolverProfilerParms( model )

set_param( model, 'SaveSolverProfileInfo', 'on' );
set_param( model, 'SolverProfileInfoName', 'spidata' );
set_param( model, 'SolverProfileInfoLevel', struct( 'base', 4, 'jacobian', 1 ) );
set_param( model, 'SolverProfileInfoMaxSize', '100000000' );
set_param( model, 'SolverJacobianMethodControl', 'SparsePerturbation' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpa_QUIn.p.
% Please follow local copyright laws when handling this file.

