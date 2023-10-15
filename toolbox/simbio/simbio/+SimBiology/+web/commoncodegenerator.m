function [ stepCode, stepCleanup ] = commoncodegenerator( action, stepCode, step, varargin )











switch ( action )
    case 'generateSimulationCode'
        [ stepCode, stepCleanup ] = generateSimulationCode( stepCode, step, varargin{ : } );
    case 'generateStopAndOutputTimesCode'
        [ stepCode, stepCleanup ] = generateStopAndOutputTimesCode( stepCode, step, varargin{ : } );
    case 'generateStatesToLogCode'
        [ stepCode, stepCleanup ] = generateStatesToLogCode( stepCode, step, varargin{ : } );
    case 'generateSolverTypeCode'
        [ stepCode, stepCleanup ] = generateSolverTypeCode( stepCode, step );
    case 'generateLogDecimationCode'
        [ stepCode, stepCleanup ] = generateLogDecimationCode( stepCode, step );
    case 'generateParameterizedDoseCode'
        [ stepCode, stepCleanup ] = generateParameterizedDoseCode( stepCode, step );
    case 'generateTurnOffObservableCode'
        [ stepCode, stepCleanup ] = generateTurnOffObservableCode( stepCode, varargin{ : } );
    case 'generateTurnOnObservableCode'
        [ stepCode, stepCleanup ] = generateTurnOnObservableCode( stepCode, step );
end

end

function [ stepCode, stepCleanup ] = generateSimulationCode( stepCode, step, steps, model, support )


stepCleanup = {  };


steadyStateStep = getStepByType( steps, 'Steady State' );
samplesStep = getStepByType( steps, 'Generate Samples' );
sensitivityStep = getStepByType( steps, 'Sensitivity' );
modelStep = getStepByType( steps, 'Model' );
observableStep = getStepByType( steps, 'Calculate Observables' );

runSteadyState = steadyStateStep.sectionEnabled;
runSamplesStep = samplesStep.sectionEnabled;
runInParallel = samplesStep.runInParallel;
accelerate = modelStep.accelerate;
runObservableStep = observableStep.sectionEnabled;

if runSteadyState && ~runSamplesStep

    simCode = '% Simulate the model';
    simCode = appendCode( simCode, 'data = sbiosimulate(model, cs, variants, doses);' );

    ruleCode = '% Disable initial assignment rules.';
    ruleCode = appendCode( ruleCode, 'rules         = sbioselect(model, ''Type'', ''rule'', ''RuleType'', ''initialAssignment'');' );
    ruleCode = appendCode( ruleCode, 'originalState = get(rules, {''Active''});' );
    ruleCode = appendCode( ruleCode, 'cleanupRules  = onCleanup(@() restoreRules(rules, originalState));' );
    ruleCode = appendCode( ruleCode, '' );
    ruleCode = appendCode( ruleCode, 'set(rules, ''Active'', false);' );

    stepCode = strrep( stepCode, '$(VARIANTS)', '[args.output.variant;input.variants.doseStep]' );
    stepCode = strrep( stepCode, '$(DOSES)', 'input.doses.doseStep' );
    stepCode = strrep( stepCode, '$(STEADYSTATE_CONFIGURATION)', ruleCode );
    stepCode = strrep( stepCode, '$(SIMULATION_COMMAND)', simCode );
    stepCode = strrep( stepCode, '$(GENERATE_SAMPLES_CONFIGURATION)', '$(REMOVE)' );
    stepCode = generateParameterizedDoseCode( stepCode, support.doseStepParams );
elseif runSamplesStep && ~runSteadyState

    samplesCode = '% Extract samples to simulate.';
    samplesCode = appendCode( samplesCode, 'samples = args.output.samples;' );
    [ simCode, simCodeCleanup ] = getSimulationCommandForScan( model, step, sensitivityStep, accelerate, runInParallel, runObservableStep, observableStep );
    if ~isempty( simCodeCleanup )
        stepCleanup{ end  + 1 } = simCodeCleanup;
    end

    stepCode = strrep( stepCode, '$(VARIANTS)', 'input.variants.modelStep' );
    stepCode = strrep( stepCode, '$(DOSES)', 'input.doses.modelStep' );
    stepCode = strrep( stepCode, '$(GENERATE_SAMPLES_CONFIGURATION)', samplesCode );
    stepCode = strrep( stepCode, '$(SIMULATION_COMMAND)', simCode );
    stepCode = strrep( stepCode, '$(STEADYSTATE_CONFIGURATION)', '$(REMOVE)' );
    stepCode = generateParameterizedDoseCode( stepCode, support.modelStepParams );
elseif ~runSamplesStep && ~runSteadyState

    simCode = '% Simulate the model';
    simCode = appendCode( simCode, 'data = sbiosimulate(model, cs, variants, doses);' );

    stepCode = strrep( stepCode, '$(VARIANTS)', 'input.variants.modelStep' );
    stepCode = strrep( stepCode, '$(DOSES)', 'input.doses.modelStep' );
    stepCode = strrep( stepCode, '$(SIMULATION_COMMAND)', simCode );
    stepCode = strrep( stepCode, '$(STEADYSTATE_CONFIGURATION)', '$(REMOVE)' );
    stepCode = strrep( stepCode, '$(GENERATE_SAMPLES_CONFIGURATION)', '$(REMOVE)' );
    stepCode = generateParameterizedDoseCode( stepCode, support.modelStepParams );
elseif runSamplesStep && runSteadyState

    simCode = '% Simulate the model.';
    simCode = appendCode( simCode, 'steadyStateVariants = args.output.variant;' );
    simCode = appendCode( simCode, 'data                = cell(1, length(steadyStateVariants));' );
    simCode = appendCode( simCode, 'for i = 1:length(data)' );
    simCode = appendCode( simCode, '    try' );
    simCode = appendCode( simCode, '        data{i} = sbiosimulate(model, cs, [steadyStateVariants(i) variants], doses);' );
    simCode = appendCode( simCode, '    catch ex' );
    simCode = appendCode( simCode, '        if strcmp(ex.identifier, ''SimBiology:interrupt'')' );
    simCode = appendCode( simCode, '            rethrow(ex);' );
    simCode = appendCode( simCode, '        end' );
    simCode = appendCode( simCode, '    end' );
    simCode = appendCode( simCode, 'end' );
    simCode = appendCode( simCode, 'data = [data{:}]'';' );

    ruleCode = '% Disable initial assignment rules.';
    ruleCode = appendCode( ruleCode, 'rules         = sbioselect(model, ''Type'', ''rule'', ''RuleType'', ''initialAssignment'');' );
    ruleCode = appendCode( ruleCode, 'originalState = get(rules, {''Active''});' );
    ruleCode = appendCode( ruleCode, 'cleanupRules  = onCleanup(@() restoreRules(rules, originalState));' );
    ruleCode = appendCode( ruleCode, '' );
    ruleCode = appendCode( ruleCode, 'set(rules, ''Active'', false);' );

    stepCode = strrep( stepCode, '$(VARIANTS)', 'input.variants.doseStep' );
    stepCode = strrep( stepCode, '$(DOSES)', 'input.doses.doseStep' );
    stepCode = strrep( stepCode, '$(STEADYSTATE_CONFIGURATION)', ruleCode );
    stepCode = strrep( stepCode, '$(SIMULATION_COMMAND)', simCode );
    stepCode = strrep( stepCode, '$(GENERATE_SAMPLES_CONFIGURATION)', '$(REMOVE)' );
    stepCode = generateParameterizedDoseCode( stepCode, support.doseStepParams );
end

if ( runSamplesStep )
    paramCode = samplesStep.paramCode;
    if isempty( paramCode )
        stepCode = strrep( stepCode, '$(GENERATE_SAMPLES_PARAMETER_CODE)', '$(REMOVE)' );
    else
        paramCode = appendCode( '% Construct doses.', paramCode );
        stepCode = strrep( stepCode, '$(GENERATE_SAMPLES_PARAMETER_CODE)', paramCode );
        stepCleanup{ end  + 1 } = readTemplate( 'restoreDose.txt' );
    end
else
    stepCode = strrep( stepCode, '$(GENERATE_SAMPLES_PARAMETER_CODE)', '$(REMOVE)' );
end


[ stepCode, stepCleanup{ end  + 1 } ] = generateTurnOffObservableCode( stepCode, model );

if runObservableStep && ~isempty( observableStep.statistics )
    [ stepCode, cleanup ] = generateTurnOnObservableCode( stepCode, observableStep );
    if ~isempty( cleanup )
        stepCleanup{ end  + 1 } = cleanup;
    end
else
    stepCode = strrep( stepCode, '$(TURN_ON_OBSERVABLE_CODE)', '$(REMOVE)' );
end


[ stepCode, cleanup ] = generateStopAndOutputTimesCode( stepCode, step, getconfigset( model, 'default' ), runSamplesStep );
if ~isempty( cleanup )
    stepCleanup{ end  + 1 } = cleanup;
end

if runSteadyState
    stepCleanup{ end  + 1 } = readTemplate( 'restoreRules.txt' );
end

if isempty( stepCleanup )
    stepCleanup = '';
end

end

function [ code, stepCleanup ] = getSimulationCommandForScan( model, step, sensitivityStep, accelerate, runInParallel, runObservableStep, observableStep )

stepCleanup = [  ];
cs = getconfigset( model, 'default' );
csCode = '';
if ~strcmp( cs.Name, 'default' )
    csCode = '% Set the active configuration set.';
    csCode = appendCode( csCode, 'originalConfigset = getconfigset(model, ''active'');' );
    csCode = appendCode( csCode, 'setactiveconfigset(model, cs);' );
    csCode = appendCode( csCode, '' );
    csCode = appendCode( csCode, '% Restore the original configset after the task has completed running.' );
    csCode = appendCode( csCode, 'cleanupConfigset = onCleanup(@() restoreActiveConfigset(model, originalConfigset));' );
    csCode = appendCode( csCode, '' );

    stepCleanup = readTemplate( 'restoreActiveConfigset.txt' );
end

if ~isempty( csCode )
    code = appendCode( csCode, '% Get list of observables.' );
else
    code = '% Get list of observables.';
end

hasObservables = runObservableStep && ~isempty( observableStep.statistics );
if hasObservables
    tableData = getValidStatisticsTableData( observableStep );
    hasObservables = ~isempty( tableData );
end

code = appendCode( code, 'states          = cs.RuntimeOptions.StatesToLog;' );
if hasObservables
    code = appendCode( code, 'observables     = sbioselect(model.Observables, ''Active'', true);' );
    code = appendCode( code, 'observableNames = cell(1, length(states)+length(observables));' );
else
    code = appendCode( code, 'observableNames = cell(1, length(states));' );
end

code = appendCode( code, 'for i = 1:length(states)' );
code = appendCode( code, '    observableNames{i} = states(i).PartiallyQualifiedName;' );
code = appendCode( code, 'end' );

if hasObservables
    code = appendCode( code, 'for i = 1:length(observables)' );
    code = appendCode( code, '    observableNames{i+length(states)} = observables(i).Name;' );
    code = appendCode( code, 'end' );
end
code = appendCode( code, '' );

code = appendCode( code, '% Convert doses.' );
code = appendCode( code, 'if ~isempty(doses)' );
code = appendCode( code, '    dosesTable = getTable(doses);' );
code = appendCode( code, 'else' );
code = appendCode( code, '    dosesTable = [];' );
code = appendCode( code, 'end' );
code = appendCode( code, '' );

if ~isempty( sensitivityStep ) && sensitivityStep.sensitivityDefined
    sensitivities = sensitivityStep.sensitivity;
    inputs = {  };
    outputs = {  };

    for i = 1:length( sensitivities )
        if iscell( sensitivities )
            next = sensitivities{ i };
        else
            next = sensitivities( i );
        end

        if ( next.sessionID ~=  - 1 )
            if ( next.input )
                inputs{ end  + 1 } = next.name;
            end
            if ( next.output )
                outputs{ end  + 1 } = next.name;
            end
        end
    end

    inputs = createCommaSeparatedQuotedList( unique( inputs, 'stable' ) );
    outputs = createCommaSeparatedQuotedList( unique( outputs, 'stable' ) );

    code = appendCode( code, '% Define output and input factors.' );
    code = appendCode( code, [ 'outputs = {', outputs, '};' ] );
    code = appendCode( code, [ 'inputs  = {', inputs, '};' ] );
    code = appendCode( code, '' );
end


code = appendCode( code, '% Simulate the model.' );
cmd = 'f    = createSimFunction(model, samples, observableNames, doses, variants';

if ~isempty( sensitivityStep ) && sensitivityStep.sensitivityDefined
    cmd = [ cmd, ', ''SensitivityOutputs'', outputs, ''SensitivityInputs'', inputs, ''SensitivityNormalization'', ''', sensitivityStep.normalization, '''' ];
end

if ~accelerate
    cmd = [ cmd, ', ''AutoAccelerate'', false' ];
end

if ( runInParallel )
    cmd = [ cmd, ', ''UseParallel'', true' ];
end

cmd = [ cmd, ');' ];

code = appendCode( code, cmd );


cs = getconfigset( model, 'default' );
useSolverTimes = step.useSolverTimes;


useOutputTimes = ~usesStochasticSolver( cs ) &&  ...
    step.useOutputTimes && ~isempty( step.outputTimes );

if ( useOutputTimes && useSolverTimes )

    code = appendCode( code, 'data = f(samples, cs.StopTime, dosesTable, cs.SolverOptions.OutputTimes);' );
elseif useSolverTimes

    code = appendCode( code, 'data = f(samples, cs.StopTime, dosesTable);' );
else

    code = appendCode( code, 'data = f(samples, [], dosesTable, cs.SolverOptions.OutputTimes);' );
end

end

function [ stepCode, stepCleanup ] = generateParameterizedDoseCode( stepCode, stepParams )

stepCleanup = {  };
code = '$(REMOVE)';
if ~isempty( stepParams )
    code = '% Create parameter for each dose that is being explored.';
    code = appendCode( code, '% Set parameter units to support dimensional analysis and unit conversion.' );
    for i = 1:length( stepParams )
        valueName = [ 'value', num2str( i ) ];
        unitName = [ 'unit', num2str( i ) ];
        paramVarName = [ 'param', num2str( i ) ];
        cleanupName = [ 'cleanup', num2str( i ) ];
        doseName = [ 'doses(', num2str( stepParams( i ).dose ), ')' ];
        propName = stepParams( i ).property;
        code = appendCode( code, [ valueName, '   = ', doseName, '.', propName, ';' ] );

        if propName == "RepeatCount"

            code = appendCode( code, [ paramVarName, '   = addparameter(model, ''', stepParams( i ).paramName, ''', ''ValueUnits'', ''dimensionless'');' ] );
        else


            unitProperty = getDoseUnitProperty( propName );
            code = appendCode( code, [ unitName, '    = ', doseName, '.', unitProperty, ';' ] );
            code = appendCode( code, [ paramVarName, '   = addparameter(model, ''', stepParams( i ).paramName, ''', ''ValueUnits'', ', unitName, ');' ] );
        end

        code = appendCode( code, [ cleanupName, ' = onCleanup(@() restoreDose(', paramVarName, ', ', doseName, ', ''', propName, ''', ', valueName, '));' ] );
        code = appendCode( code, '' );
    end

    if length( stepParams ) == 1
        code = appendCode( code, '% Configure dose to use new parameter.' );
    else
        code = appendCode( code, '% Configure doses to use new parameters.' );
    end

    for i = 1:length( stepParams )
        code = appendCode( code, [ 'doses(', num2str( stepParams( i ).dose ), ').', stepParams( i ).property, ' = ''', stepParams( i ).paramName, ''';' ] );
    end
end

stepCode = strrep( stepCode, '$(PARAMETERIZED_DOSE)', code );

end

function out = getDoseUnitProperty( property )

switch ( property )
    case 'Amount'
        out = 'AmountUnits';
    case 'Rate'
        out = 'RateUnits';
    case { 'StartTime', 'Interval' }
        out = 'TimeUnits';
    otherwise
        out = '';
end

end

function [ stepCode, stepCleanup ] = generateStopAndOutputTimesCode( stepCode, step, configset, isScan )
arguments
    stepCode char
    step struct
    configset SimBiology.Configset
    isScan logical = false;
end

stopTimeCode = '';
timeUnitsCode = '';
outputTimesCode = '';
logSolverAndOutputTimesCode = '';
stepCleanup = '';



if step.useSolverTimes && ~step.useConfigset
    stopTimeCode = generateStopTimeCode( step.stopTime );
end



if ~step.useConfigset
    timeUnitsCode = generateTimeUnitsCode( step.stopTimeUnits );
end




if matches( step.type, 'Simulation' ) && ~usesStochasticSolver( configset )


    if step.useOutputTimes && ~step.useConfigset


        outputTimesCode = generateOutputTimesCode( step.outputTimesDisplayValue );
    elseif ~isScan && ~step.useOutputTimes && ~isempty( configset.SolverOptions.OutputTimes )



        outputTimesCode = generateOutputTimesCode( '[]' );
    end



    if ~isScan && step.useOutputTimes && ~isempty( step.outputTimes )
        logSolverAndOutputTimesCode = generateLogSolverAndOutputTimesCode( step.useSolverTimes );
    end
end

if isempty( stopTimeCode ) && isempty( outputTimesCode ) && isempty( logSolverAndOutputTimesCode )

    stepCode = replace( stepCode, '$(STOPTIME_CONFIGURATION)', '$(REMOVE)' );
else
    newCode = '';
    if ~isempty( stopTimeCode )
        newCode = appendCode( newCode, stopTimeCode );
    end
    if ~isempty( timeUnitsCode )
        newCode = appendCode( newCode, timeUnitsCode );
    end
    if ~isempty( outputTimesCode )
        newCode = appendCode( newCode, outputTimesCode );
    end
    if ~isempty( logSolverAndOutputTimesCode )
        newCode = appendCode( newCode, logSolverAndOutputTimesCode );
    end


    stepCode = strrep( stepCode, '$(STOPTIME_CONFIGURATION)', newCode );
end
end

function newCode = generateStopTimeCode( stopTime )
newCode = '';
newCode = appendCode( newCode, '% Define StopTime cleanup code.' );
newCode = appendCode( newCode, 'originalStopTime = get(cs, ''StopTime'');' );
newCode = appendCode( newCode, 'cleanupStopTime  = onCleanup(@() set(cs, ''StopTime'', originalStopTime));' );
newCode = appendCode( newCode, '% Configure StopTime.', prependNewline = true );
newCode = appendCode( newCode, [ 'set(cs, ''StopTime'', ', num2str( stopTime, 16 ), ');' ] );
end

function newCode = generateTimeUnitsCode( stopTimeUnits )
newCode = '';
newCode = appendCode( newCode, '% Define TimeUnits cleanup code.', prependNewline = ~isempty( newCode ) );
newCode = appendCode( newCode, 'originalTimeUnits = get(cs, ''TimeUnits'');' );
newCode = appendCode( newCode, 'cleanupTimeUnits  = onCleanup(@() set(cs, ''TimeUnits'', originalTimeUnits));' );
newCode = appendCode( newCode, '% Configure TimeUnits.', prependNewline = true );
newCode = appendCode( newCode, [ 'set(cs, ''TimeUnits'', ''', stopTimeUnits, ''');' ] );
end

function newCode = generateOutputTimesCode( outputTimeDisplayText )
newCode = '';

newCode = appendCode( newCode, '% Define OutputTimes cleanup code.' );
newCode = appendCode( newCode, 'originalOutputTimes = get(cs.SolverOptions, ''OutputTimes'');' );
newCode = appendCode( newCode, 'cleanupOutputTimes  = onCleanup(@() set(cs.SolverOptions, ''OutputTimes'', originalOutputTimes));' );


newCode = appendCode( newCode, '' );
newCode = appendCode( newCode, '% Configure OutputTimes.' );
newCode = appendCode( newCode, [ 'set(cs.SolverOptions, ''OutputTimes'', ', outputTimeDisplayText, ');' ] );
end

function newCode = generateLogSolverAndOutputTimesCode( flag )
newCode = '';
newCode = appendCode( newCode, '% Specify whether to log solver times with specified output times. The' );
newCode = appendCode( newCode, '% LogSolverAndOutputTimes property should not be used directly by users' );
newCode = appendCode( newCode, '% and will likely change in a future release of SimBiology.' );


newCode = appendCode( newCode, '% Define LogSolverAndOutputTimes cleanup code.', prependNewline = true );
newCode = appendCode( newCode, 'originalLogSolverAndOutputTimes = get(cs.SolverOptions, ''LogSolverAndOutputTimes'');' );
newCode = appendCode( newCode, 'cleanupLogSolverAndOutputTimes  = onCleanup(@() set(cs.SolverOptions, ''LogSolverAndOutputTimes'', originalLogSolverAndOutputTimes));' );


flag = SimBiology.web.codegenerationutil( 'logical2str', flag );
newCode = appendCode( newCode, '' );
newCode = appendCode( newCode, '% Configure LogSolverAndOutputTimes.' );
newCode = appendCode( newCode, [ 'set(cs.SolverOptions, ''LogSolverAndOutputTimes'', ', flag, ');' ] );
end

function [ stepCode, stepCleanup ] = generateStatesToLogCode( stepCode, step, steps )

groupSimulationStep = getStepByType( steps, 'Group Simulation' );
if ~isempty( groupSimulationStep ) && groupSimulationStep.enabled


    stepCode = strrep( stepCode, '$(STATESTOLOG_CONFIGURATION)', '$(REMOVE)' );
    stepCleanup = '';
elseif ~isfield( step, 'statesToLogUseConfigset' ) || step.statesToLogUseConfigset

    stepCode = strrep( stepCode, '$(STATESTOLOG_CONFIGURATION)', '$(REMOVE)' );
    stepCleanup = '';
else

    states = {  };
    statesToLog = step.statesToLog;
    if iscell( statesToLog )
        statesToLog = [ statesToLog{ : } ];
    end

    for i = 1:length( statesToLog )
        next = statesToLog( i );
        if logical( next.use ) && ( next.sessionID ~=  - 1 )
            states{ end  + 1 } = next.name;%#ok<*AGROW>
        end
    end


    newCode = '% Define StatesToLog cleanup code.';
    newCode = appendCode( newCode, 'originalStatesToLog = get(cs.RuntimeOptions, ''StatesToLog'');' );
    newCode = appendCode( newCode, 'cleanupStatesToLog  = onCleanup(@() restoreStatesToLog(cs, originalStatesToLog));' );


    newCode = appendCode( newCode, '' );
    newCode = appendCode( newCode, '% Configure StatesToLog.' );
    newCode = appendCode( newCode, [ 'set(cs.RuntimeOptions, ''StatesToLog'', {', createCommaSeparatedQuotedList( states ), '});' ] );


    stepCode = strrep( stepCode, '$(STATESTOLOG_CONFIGURATION)', newCode );


    stepCleanup = readTemplate( 'restoreStatesToLog.txt' );
end

end

function [ stepCode, stepCleanup ] = generateSolverTypeCode( stepCode, step )


newCode = '% Define SolverType cleanup code.';
newCode = appendCode( newCode, 'originalSolverType = get(cs, ''SolverType'');' );
newCode = appendCode( newCode, 'cleanupSolverType  = onCleanup(@() restoreSolverType(cs, originalSolverType));' );


newCode = appendCode( newCode, '' );
newCode = appendCode( newCode, '% Configure SolverType.' );
newCode = appendCode( newCode, [ 'set(cs, ''SolverType'', ''', step.solverType, ''');' ] );

stepCode = strrep( stepCode, '$(SOLVER_CODE)', newCode );


stepCleanup = readTemplate( 'restoreSolver.txt' );

end

function [ stepCode, stepCleanup ] = generateLogDecimationCode( stepCode, step )

if step.logDecimationUseConfigset

    stepCode = strrep( stepCode, '$(LOGDECIMATION_CODE)', '$(REMOVE)' );
    stepCleanup = '';
else

    newCode = '% Define LogDecimation cleanup code.';
    newCode = appendCode( newCode, 'originalLogDecimation = get(cs.SolverOptions, ''LogDecimation'');' );
    newCode = appendCode( newCode, 'cleanupLogDecimation  = onCleanup(@() restoreLogDecimation(cs, originalLogDecimation));' );


    newCode = appendCode( newCode, '' );
    newCode = appendCode( newCode, '% Configure LogDecimation.' );
    newCode = appendCode( newCode, [ 'set(cs.SolverOptions, ''LogDecimation'', ', num2str( step.logDecimation ), ');' ] );

    stepCode = strrep( stepCode, '$(LOGDECIMATION_CODE)', newCode );


    stepCleanup = readTemplate( 'restoreLogDecimation.txt' );
end

end

function [ stepCode, stepCleanup ] = generateTurnOffObservableCode( stepCode, model )


if isempty( model.Observables )
    stepCode = strrep( stepCode, '$(TURN_OFF_OBSERVABLE_CODE)', '$(REMOVE)' );
    stepCleanup = [  ];
else
    obsCode = '% Turn off observables.';
    obsCode = appendCode( obsCode, 'observables        = model.Observables;' );
    obsCode = appendCode( obsCode, 'activateState      = get(observables, {''Active''});' );
    obsCode = appendCode( obsCode, 'cleanupObservables = onCleanup(@() restoreObservables(observables, activateState));' );
    obsCode = appendCode( obsCode, 'set(observables, ''Active'', false);' );
    stepCode = strrep( stepCode, '$(TURN_OFF_OBSERVABLE_CODE)', obsCode );

    stepCleanup = readTemplate( 'restoreObservables.txt' );
end

end

function [ stepCode, stepCleanup ] = generateTurnOnObservableCode( stepCode, step )

stepCleanup = [  ];
names = {  };
tableData = getValidStatisticsTableData( step );


if ~isempty( tableData )
    names = { tableData.name };
end


if ~isempty( names )
    names = SimBiology.web.codegenerationutil( 'createCommaSeparatedQuotedList', names );
    obsCode = '% Turn on observables.';
    obsCode = appendCode( obsCode, [ 'obsNames    = {', names, '};' ] );
    obsCode = appendCode( obsCode, 'observables = sbioselect(model.Observables, ''Name'', obsNames);' );
    obsCode = appendCode( obsCode, 'set(observables, ''Active'', true);' );
    stepCode = strrep( stepCode, '$(TURN_ON_OBSERVABLE_CODE)', obsCode );
else
    stepCode = strrep( stepCode, '$(TURN_ON_OBSERVABLE_CODE)', '$(REMOVE)' );
end

end

function tableData = getValidStatisticsTableData( step )

tableData = step.statistics;
if iscell( tableData )
    tableData = [ tableData{ : } ];
end


if ~isempty( tableData )
    tableData = tableData( [ tableData.use ] );
    tableData = tableData( cellfun( 'isempty', { tableData.matlabError } ) );
end

end

function flag = usesStochasticSolver( configset )
flag = ismember( configset.solverType, { 'ssa', 'impltau', 'expltau' } );
end

function content = readTemplate( name )

content = SimBiology.web.codegenerationutil( 'readTemplate', name );

end

function step = getStepByType( steps, type )

step = SimBiology.web.codegenerationutil( 'getStepByType', steps, type );

end

function out = createCommaSeparatedQuotedList( list )

out = SimBiology.web.codegenerationutil( 'createCommaSeparatedQuotedList', list );

end

function code = appendCode( code, newCode, varargin )

code = SimBiology.web.codegenerationutil( 'appendCode', code, newCode, varargin{ : } );
end

