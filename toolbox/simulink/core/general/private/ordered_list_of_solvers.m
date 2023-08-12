function [ varStepSolvers, fixedStepSolvers, varargout ] = ordered_list_of_solvers( configSet )



additionalSolverVal = configset.feature( 'EnableSlexecAdditionalSolvers' );
additionalSolverString = num2str( additionalSolverVal );
enable3PSolvers = str2double( additionalSolverString( end  ) );
enableDAESSC = str2double( additionalSolverString( end  - 1 ) );
enableODEN = str2double( additionalSolverString( end  - 2 ) );
enableODE1BE = str2double( additionalSolverString( end  - 3 ) );

varStepSolvers = { 'VariableStepAuto',  ...
'VariableStepDiscrete',  ...
'ode45',  ...
'ode23',  ...
'ode113',  ...
'ode15s',  ...
'ode23s',  ...
'ode23t',  ...
'ode23tb'
 };
if enableODEN
varStepSolvers{ end  + 1 } = 'odeN';
end 


if enableDAESSC
varStepSolvers{ end  + 1 } = 'daessc';
end 


if enable3PSolvers
varStepSolvers( end  + 1:end  + 3 ) = {  ...
'CVODES',  ...
'IDAS',  ...
'DASKR' };
end 

varStepSolversDescription = {  };

if nargout >= 3

varStepSolversDescription = {  ...
getString( message( 'SimulinkExecution:SolverDescription:AUTO' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:Discrete' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE45' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE23' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE113' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE15S' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE23S' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE23T' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE23TB' ) ),  ...
 };

if enableODEN
varStepSolversDescription( end  + 1 ) = { getString( message( 'SimulinkExecution:SolverDescription:ODEN' ) ) };
end 


if enableDAESSC
varStepSolversDescription( end  + 1 ) = { getString( message( 'SimulinkExecution:SolverDescription:DAESSC' ) ) };
end 


if enable3PSolvers
varStepSolversDescription( end  + 1:end  + 3 ) = {  ...
getString( message( 'SimulinkExecution:SolverDescription:CVODES' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:IDAS' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:DASKR' ) ) };
end 


end 
fixedStepSolvers = { 'FixedStepAuto', 'FixedStepDiscrete',  ...
'ode8',  ...
'ode5',  ...
'ode4',  ...
'ode3',  ...
'ode2',  ...
'ode1',  ...
'ode14x' ...
 };

if enableODE1BE
fixedStepSolvers{ end  + 1 } = 'ode1be';
end 

fixedStepSolversDescription = {  };

if nargout >= 4

fixedStepSolversDescription = {  ...
getString( message( 'SimulinkExecution:SolverDescription:AUTO' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:Discrete' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE8' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE5' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE4' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE3' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE2' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE1' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE14X' ) ),  ...
 };

if enableODE1BE
fixedStepSolversDescription( end  + 1 ) = { getString( message( 'SimulinkExecution:SolverDescription:ODE1BE' ) ) };
end 
end 

[ varStepSolvers, varStepSolversDescription ] =  ...
feasibleVarStepSolversToSwitchTo( configSet, nargout, varStepSolvers, varStepSolversDescription );

[ fixedStepSolvers, fixedStepSolversDescription ] =  ...
feasibleFixedStepSolversToSwitchTo( configSet, nargout, fixedStepSolvers, fixedStepSolversDescription );

if nargout >= 3
varargout{ 1 } = varStepSolversDescription;
end 

if nargout >= 4
varargout{ 2 } = fixedStepSolversDescription;
end 

end 


function [ varStepSolvers, varStepSolversDescription ] =  ...
feasibleVarStepSolversToSwitchTo( configSet, numOut, varStepSolvers, varStepSolversDescription )



if ( ~isempty( configSet ) && ~isempty( configSet.getModel(  ) ) )
model = configSet.getModel(  );





isFastRestartOn = ( get_param( model, 'FastRestart' ) == "on" );
simStatus = get_param( model, 'SimulationStatus' );
simStatusRunningOrCompiled = ( simStatus == "running" ) || ( simStatus == "compiled" );

if ( isFastRestartOn && simStatusRunningOrCompiled )

isSolverDiscrete = ( get_param( model, 'CompiledSolverName' ) == "VariableStepDiscrete" );
if ( isSolverDiscrete )

varStepSolvers = { 'VariableStepDiscrete' };
if numOut >= 3

varStepSolversDescription = { getString( message( 'SimulinkExecution:SolverDescription:Discrete' ) ) };
end 
else 

varStepSolvers = varStepSolvers( varStepSolvers ~= "VariableStepDiscrete" );
if numOut >= 3

varStepSolversDescription = varStepSolversDescription( varStepSolversDescription ~=  ...
getString( message( 'SimulinkExecution:SolverDescription:Discrete' ) ) );
end 

end 

hasMassMatrix = ( get_param( model, 'isLinearlyImplicit' ) == "on" );

if ( hasMassMatrix )
nonDAESolvers = { 'ode45', 'ode113', 'ode23', 'ode23s', 'ode23tb' };
varStepSolvers = setdiff( varStepSolvers, nonDAESolvers, 'stable' );

if numOut >= 3

nonDAESolversDescription = {  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE45' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE113' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE23S' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE23TB' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE23' ) ) };

varStepSolversDescription = setdiff( varStepSolversDescription, nonDAESolversDescription, 'stable' );
end 
end 








solverFlags = get_param( bdroot, 'SolverStatusFlags' );

SL_CS_STATUS_FORCE_IMPSOLVER = 0x10000;
forceImpSolver = ( bitand( solverFlags, SL_CS_STATUS_FORCE_IMPSOLVER ) > 0 );
if ( forceImpSolver )




explicitSolvers = { 'ode45', 'ode113', 'ode23' };
varStepSolvers = setdiff( varStepSolvers, explicitSolvers, 'stable' );



if numOut >= 3

explicitSolversDescription = {  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE45' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE113' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE23' ) ) };

varStepSolversDescription = setdiff( varStepSolversDescription, explicitSolversDescription, 'stable' );
end 
end 


SL_CS_STATUS_FORCE_EXPSOLVER = 0x20000;
forceExpSolver = ( bitand( solverFlags, SL_CS_STATUS_FORCE_EXPSOLVER ) > 0 );
if ( forceExpSolver )




implicitSolvers = { 'ode15s', 'ode23t', 'ode23tb', 'VariableStepAuto', 'daessc', 'ode23s' };

varStepSolvers = setdiff( varStepSolvers, implicitSolvers, 'stable' );



if numOut >= 3

implicitSolversDescription = {  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE15S' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE23T' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE23TB' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:AUTO' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:DAESSC' ) ),  ...
getString( message( 'SimulinkExecution:SolverDescription:ODE23S' ) ) };

varStepSolversDescription = setdiff( varStepSolversDescription, implicitSolversDescription, 'stable' );
end 
end 

end 
end 

end 


function [ fixedStepSolvers, fixedStepSolversDescription ] =  ...
feasibleFixedStepSolversToSwitchTo( configSet, numOut, fixedStepSolvers, fixedStepSolversDescription )






if ( ~isempty( configSet ) && ~isempty( configSet.getModel(  ) ) )
model = configSet.getModel(  );
if ( ( get_param( model, 'FastRestart' ) == "on" ) &&  ...
( get_param( model, 'SimulationStatus' ) == "compiled" ) &&  ...
( get_param( model, 'SolverType' ) == "Fixed-step" ) )

currSolver = get_param( model, 'Solver' );
idx = find( strcmp( fixedStepSolvers, currSolver ) );
fixedStepSolvers = { fixedStepSolvers{ idx } };

if numOut >= 4

fixedStepSolversDescription = { fixedStepSolversDescription{ idx } };
end 
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpCo6tmj.p.
% Please follow local copyright laws when handling this file.

