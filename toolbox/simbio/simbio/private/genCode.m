function [ fluxM, realFluxCode, complexFluxCode, repeatedCode, initialCode ] = genCode( odedata, codeGenFlag )
















fluxBaseName = SimBiology.internal.Code.Generator.FluxBaseName;
repeatBaseName = SimBiology.internal.Code.Generator.RepeatedAssignmentsBaseName;
initialBaseName = SimBiology.internal.Code.Generator.InitialAssignmentsBaseName;

assert( ~isempty( odedata ) );

[ t0, x0, p, actualInputLengths ] = getSampleInputs( odedata );

sizeS = size( odedata.Stoich );






numOutputs = sizeS( 2 ) + ( actualInputLengths( 2 ) - sizeS( 1 ) ) + 2;

if ~isempty( odedata.Code.repeatedAssignRuleStr )
    [ callRepeatedFunctions, defineRepeatedFunctions ] = genAssignmentFunctions( odedata.Code.repeatedAssignRuleStr );
    repeatedFunctionBody = createRepeated( odedata, repeatBaseName, callRepeatedFunctions, defineRepeatedFunctions );
    repeatedCode = SimBiology.internal.Code.Generator( repeatBaseName, repeatedFunctionBody, codeGenFlag,  ...
        { t0, x0, p }, actualInputLengths( 1:3 ),  ...
        { p } );
else
    repeatedCode = '';
    callRepeatedFunctions = '';
    defineRepeatedFunctions = '';
end

[ realFluxFunctionBody, complexFluxFunctionBody ] = createFlux( odedata, fluxBaseName, callRepeatedFunctions, defineRepeatedFunctions );
realFluxCode = SimBiology.internal.Code.Generator( fluxBaseName, realFluxFunctionBody, codeGenFlag,  ...
    { t0, x0, p }, actualInputLengths,  ...
    { ones( numOutputs, 1 ) } );


fluxM = createFluxFunctionHandle( realFluxCode.mFunctionName, odedata );

if odedata.SensitivityAnalysis
    complexFluxCode = SimBiology.internal.Code.Generator( fluxBaseName, complexFluxFunctionBody, codeGenFlag,  ...
        { t0, complex( x0 ), complex( p ) }, actualInputLengths,  ...
        { complex( ones( numOutputs, 1 ) ) } );
else
    complexFluxCode = [  ];
end


if ~isempty( odedata.Code.initialAssignRuleStr )
    [ t0, z, actualInputLengths ] = getSampleInputsForInitialAssignment( odedata );
    initialFunctionBody = createInitial( odedata, initialBaseName );

    sampleOutput = zeros( actualInputLengths( 2 ), 1 );
    neverAccelerateFlag =  - 1;
    initialCode = SimBiology.internal.Code.Generator( initialBaseName, initialFunctionBody, neverAccelerateFlag,  ...
        { complex( z ), t0 }, [ actualInputLengths( 1 ), actualInputLengths( 2 ) ],  ...
        { complex( sampleOutput ) } );
else
    initialCode = [  ];
end
end

function output = createRepeated( odedata, funcname, callFunctions, defineFunctions )
nY = numel( odedata.X0 );


output = repeatedAssignmentTemplate;
output = myregexprep( output, '<functionName>', funcname );
output = myregexprep( output, '<numStates>', sprintf( '%d', nY ) );
output = myregexprep( output, '<repeatedAssignmentTypeCheck>', repeatedAssignmentTypeCheck );

output = myregexprep( output, '<callAssignmentFunctions>', callFunctions );
output = myregexprep( output, '<defineAssignmentFunctions>', defineFunctions );
end


function output = createInitial( odedata, funcname )
code = odedata.Code;
nY = numel( odedata.X0 );
nP = numel( odedata.P );

output = initialAssignmentTemplate( numel( odedata.X0 ), numel( odedata.P ) );
output = myregexprep( output, '<functionName>', funcname );
output = myregexprep( output, '<numStates>', sprintf( '%d', nY ) );
output = myregexprep( output, '<numParams>', sprintf( '%d', nP ) );
[ callFunctions, defineFunctions ] = genAssignmentFunctions( code.initialAssignRuleStr );
output = myregexprep( output, '<callAssignmentFunctions>', callFunctions );
output = myregexprep( output, '<defineAssignmentFunctions>', defineFunctions );
output = addComplexStepOverloads( output );
end

function [ realOutput, complexOutput ] = createFlux( odedata, funcname, callFunctions, defineFunctions )

code = odedata.Code;

output = fluxFunTemplate;
output = myregexprep( output, '<functionName>', funcname );
output = myregexprep( output, '<numStates>', mat2str( numel( odedata.XNames ) ) );
output = myregexprep( output, '<numParams>', mat2str( numel( odedata.P ) ) );

output = myregexprep( output, '<callAssignmentFunctions>', callFunctions );
output = myregexprep( output, '<defineAssignmentFunctions>', defineFunctions );

[ callScalingFunctions, defineScalingFunctions ] = printAllVolumeScaling(  ...
    odedata.speciesIndexToVaryingCompartment,  ...
    odedata.speciesIndexToConstantCompartment, numel( odedata.XNames ) );
output = myregexprep( output, '<callScalingFunctions>', callScalingFunctions );
output = myregexprep( output, '<defineScalingFunctions>', defineScalingFunctions );

[ callFlux, defineFlux ] = genCodeStr( code.vStr, 'reactionFlux', 'simbioFluxHelperFunction' );
output = myregexprep( output, '<callFlux>', callFlux );
output = myregexprep( output, '<defineFlux>', defineFlux );

[ callRateRules, defineRateRules ] = genCodeStr( code.rRuleStr, 'rrule', 'simbioRateRuleHelperFunction' );
output = myregexprep( output, '<callRateRules>', callRateRules );
output = myregexprep( output, '<defineRateRules>', defineRateRules );



doseRateRuleStr = sprintf( '<zeros>(%d,1);', odedata.numNonReactingSpeciesWithRateDoses );
output = myregexprep( output, '<doseRateRules>', doseRateRuleStr );



[ callSpeciesRateRules, defineSpeciesRateRules ] = genCodeStr( code.speciesrRuleStr, 'speciesRateRules', 'simbioSpeciesRateRuleHelperFunction', 'rrule' );
output = myregexprep( output, '<callSpeciesRateRules>', callSpeciesRateRules );
output = myregexprep( output, '<defineSpeciesRateRules>', defineSpeciesRateRules );

[ callAlgebraicRules, defineAlgebraicRules ] = genCodeStr( code.aRuleStr, 'algebraicRules', 'simbioAlgebraicRuleHelperFunction' );
output = myregexprep( output, '<callAlgebraicRules>', callAlgebraicRules );
output = myregexprep( output, '<defineAlgebraicRules>', defineAlgebraicRules );


constStr = sprintf( '<zeros>(%d,1);', numel( code.constStr ) );
output = myregexprep( output, '<constants>', constStr );


realOutput = myregexprep( output, '<fluxTypeCheck>', validFluxTypeCheck(  ) );
complexOutput = myregexprep( output, '<fluxTypeCheck>', complexFluxTypeCheck(  ) );


realOutput = myregexprep( realOutput, '<zeros>', 'zeros' );
complexOutput = regexprep( complexOutput, '<zeros>\((.*?)\)', 'complex(zeros($1))' );


complexOutput = addComplexStepOverloads( complexOutput );
end

function [ callScalingFunctions, defineScalingFunctions ] = printAllVolumeScaling( speciesIndexToVaryingCompartment,  ...
    speciesIndexToConstantCompartment, nStates )
defineScalingFunctions = '';
if isempty( speciesIndexToVaryingCompartment ) &&  ...
        isempty( speciesIndexToConstantCompartment )
    callScalingFunctions = '';
    return
end
[ callScaleByY, defineScaleByY ] = printVolumeScaling( speciesIndexToVaryingCompartment, 'Y0_', nStates );
[ callScaleByP, defineScaleByP ] = printVolumeScaling( speciesIndexToConstantCompartment, 'P0_', nStates );
callScalingFunctions = [ sprintf( '%%%% Volume scaling\n' ), callScaleByY, callScaleByP ];
defineScalingFunctions = [ sprintf( '%%%% Volume scaling function definitions\n' ), defineScaleByY, defineScaleByP ];
end

function [ callScaling, defineScaling ] = printVolumeScaling( indexes, volVarName, nStates )
defineScaling = '';
if isempty( indexes )
    callScaling = sprintf( '%% No scaling by %s\n', volVarName );
    return
end
speciesAndParameterIndexes = indexes( :, 1 );
volumeIndexes = indexes( :, 2 );
[ uniqueVolumeIndexes, ~, mapToList ] = unique( volumeIndexes );
n = numel( uniqueVolumeIndexes );
outputCell = cell( n, 2 );
for i = 1:n
    allIndexes = sort( speciesAndParameterIndexes( mapToList == i ) );
    tfSpeciesIndexes = ( allIndexes <= nStates );
    speciesIndexes = allIndexes( tfSpeciesIndexes );
    if ~isempty( speciesIndexes )
        speciesIndexesString = vector2string( speciesIndexes );
        outputCell{ i, 1 } = sprintf( 'Y0_(%s) = Y0_(%s) ./ %s(%d);\n',  ...
            speciesIndexesString, speciesIndexesString,  ...
            volVarName, uniqueVolumeIndexes( i ) );
    end
    parameterIndexes = allIndexes( ~tfSpeciesIndexes ) - nStates;
    if ~isempty( parameterIndexes )
        parameterIndexesString = vector2string( parameterIndexes );
        outputCell{ i, 2 } = sprintf( 'P0_(%s) = P0_(%s) ./ %s(%d);\n',  ...
            parameterIndexesString, parameterIndexesString,  ...
            volVarName, uniqueVolumeIndexes( i ) );
    end
end
outputCell = outputCell( : );
outputCell( cellfun( @isempty, outputCell ) ) = [  ];
[ callScaling, defineScaling ] = genAssignmentFunctions( outputCell, [ 'simbioVolumeScalingHelperFunction_', volVarName ] );
end

function string = vector2string( vector )
assert( isvector( vector ) );
n = numel( vector );
stringCell = cell( 1, n + 2 );
stringCell{ 1 } = '[ ';
iLast = 2;
j1 = 1;
while j1 <= n
    j2 = j1;
    while ( j2 + 1 <= n ) && vector( j2 ) + 1 == vector( j2 + 1 )
        j2 = j2 + 1;
    end
    if j1 == j2
        stringCell{ iLast } = sprintf( '%d ', vector( j1 ) );
    else
        stringCell{ iLast } = sprintf( '%d:%d ', vector( j1 ), vector( j2 ) );
    end
    j1 = j2 + 1;
    iLast = iLast + 1;
end
stringCell{ iLast } = ']';
string = sprintf( '%s', stringCell{ 1:iLast } );
end



function [ t0, x0, p, actualLengths ] = getSampleInputs( odedata )
t0 = 0;
x0 = odedata.X0;
p = odedata.P;
actualLengths = cellfun( @numel, { t0, x0, p } );
if numel( x0 ) < 2
    x0( 2, 1 ) = 0;
end
if numel( p ) < 2
    p( 2, 1 ) = 0;
end
end

function [ t0, z, actualLengths ] = getSampleInputsForInitialAssignment( odedata )
t0 = 0;
z = [ odedata.X0;odedata.P ];
actualLengths = cellfun( @numel, { t0, z } );
if numel( z ) < 2
    z( 2, 1 ) = 0;
end
end

function fh = createFluxFunctionHandle( mFunctionName, odedata )


xpad = zeros( max( 0, 2 - numel( odedata.X0 ) ), 1 );
ppad = zeros( max( 0, 2 - numel( odedata.P ) ), 1 );
fh = @( t, x, p )feval( mFunctionName, t, [ x;xpad ], [ p;ppad ] );
end

function o = repeatedAssignmentTemplate(  )



o = [  ...
    'function P0_ = <functionName>(time, Y0_in, P0_) %%#codegen', newline ...
    , '%%%% Copy inputs', newline ...
    , 'Y0_ = Y0_in(1:<numStates>);', newline ...
    , '', newline ...
    , '<callAssignmentFunctions>', newline ...
    , '<repeatedAssignmentTypeCheck>', newline ...
    , 'end', newline ...
    , newline ...
    , '<defineAssignmentFunctions>', newline ...
    ];
end

function o = initialAssignmentTemplate( nY, nP )


o = [  ...
    'function Z0_ = <functionName>(Z0, time) %%#codegen', newline ...
    , '%%%% Split Z into states and parameters.', newline ...
    , 'Y0_ = Z0(1:', sprintf( '%d', nY ), ');', newline ...
    , 'P0_ = Z0(', sprintf( '%d', nY + 1 ), ':', sprintf( '%d', nY + nP ), ');', newline ...
    , '', newline ...
    , '<callAssignmentFunctions>', newline ...
    , 'Z0_ = [Y0_; P0_];', newline ...
    , 'end', newline ...
    , newline ...
    , '<defineAssignmentFunctions>', newline ...
    ];
end

function o = fluxFunTemplate(  )
o = [  ...
    'function fluxVector = <functionName>(time, Y0_in, P0_in) %%#codegen', newline ...
    , '% Need to copy inputs to keep them constant', newline ...
    , '% Inputs may have been padded to make them vectors (so Coder will pass', newline ...
    , '% them by pointer), so we need to explicitly copy the correct number of', newline ...
    , '% elements of the vector.', newline ...
    , 'Y0_ = Y0_in(1:<numStates>);', newline ...
    , 'P0_ = P0_in(1:<numParams>);', newline ...
    , '', newline ...
    , '% Repeated Assignments', newline ...
    , '<callAssignmentFunctions>' ...
    , '', newline ...
    , '<callScalingFunctions> ', newline ...
    , '', newline ...
    , '% Reaction Fluxes', newline ...
    , '<callFlux>', newline ...
    , '% Rate rules', newline ...
    , '<callRateRules>', newline ...
    , '% Dose rate rules', newline ...
    , 'doseRateRules = <doseRateRules>', newline ...
    , '% Species rate rules', newline ...
    , '<callSpeciesRateRules>', newline ...
    , '% Algebraic rules', newline ...
    , '<callAlgebraicRules>', newline ...
    , '% Constants', newline ...
    , 'constants = <constants>', newline ...
    , newline ...
    , 'fluxVectorPossiblyComplex = [ ...', newline ...
    , 'reactionFlux; rrule; doseRateRules; ...', newline ...
    , 'speciesRateRules; algebraicRules; constants; ...', newline ...
    , '0; 0]; % padding to coerce signature of generated code', newline ...
    , '<fluxTypeCheck>', newline ...
    , 'end', newline ...
    , newline ...
    , '<defineAssignmentFunctions>' ...
    , newline ...
    , '<defineScalingFunctions>' ...
    , newline ...
    , '<defineFlux>' ...
    , newline ...
    , '<defineRateRules>' ...
    , newline ...
    , '<defineSpeciesRateRules>' ...
    , newline ...
    , '<defineAlgebraicRules>' ...
    ];
end

function o = repeatedAssignmentTypeCheck


id = 'SimBiology:Simulation:ComplexRepeatedAssignment';
msg = getString( message( id ) );
o = [  ...
    'coder.extrinsic(''warning'');', newline ...
    , 'if any(imag(P0_))', newline ...
    , sprintf( '    warning(''%s'', ''%s'');', id, msg ), newline ...
    , 'end', newline ...
    , 'P0_ = real(P0_);', newline ...
    ];
end

function o = validFluxTypeCheck


id1 = 'SimBiology:Simulation:ComplexRHS';
msg1 = getString( message( id1 ) );
id2 = 'SimBiology:Simulation:NonFiniteRHS';
msg2 = getString( message( id2 ) );
o = [  ...
    'coder.extrinsic(''warning'');', newline ...
    , 'if any(imag(fluxVectorPossiblyComplex))', newline ...
    , sprintf( '    warning(''%s'', ''%s'');', id1, msg1 ), newline ...
    , 'end', newline ...
    , 'if ~all(isfinite(fluxVectorPossiblyComplex))', newline ...
    , sprintf( '    warning(''%s'', ''%s'');', id2, msg2 ), newline ...
    , 'end', newline ...
    , 'fluxVector = real(fluxVectorPossiblyComplex);', newline ...
    ];
end

function o = complexFluxTypeCheck


o = [  ...
    'if isreal(fluxVectorPossiblyComplex)', newline ...
    , '    fluxVector = complex(fluxVectorPossiblyComplex);', newline ...
    , 'else', newline ...
    , '    fluxVector = fluxVectorPossiblyComplex;', newline ...
    , 'end', newline
    ];
end

function output = myregexprep( output, expression, rawReplace )
replace = regexptranslate( 'escape', rawReplace );
output = regexprep( output, expression, replace );
end

function [ call, define ] = genCodeStr( codeStr, varName, functionName, additionalInputs )




















assert( strcmp( codeStr( 1 ), '[' ), 'Unexpected codeStr' );
assert( strcmp( codeStr( end  - 1:end  ), '];' ), 'Unexpected codeStr' );
if strcmp( codeStr, '[];' )
    call = sprintf( '%s = <zeros>(0,1);\n', varName );
    define = '';
    return
end
terms = strsplit( codeStr( 2:end  - 2 ), sprintf( '; ...\n' ) );
for i = 1:numel( terms )
    terms{ i } = sprintf( '%s(%d) = %s;\n', varName, i, terms{ i } );
end
inputs = sprintf( '%s,time,Y0_,P0_', varName );
if exist( 'additionalInputs', 'var' ) && ~isempty( additionalInputs )
    inputs = [ inputs, ',', additionalInputs ];
end
outputs = varName;
[ call, define ] = genFunctions( terms, functionName, inputs, outputs );
call = sprintf( '%s = <zeros>(%d,1);\n%s', varName, numel( terms ), call );
end

function [ callFunctions, defineFunctions ] = genAssignmentFunctions( ruleCode, name )
arguments
    ruleCode
    name = 'simbioRuleHelperFunction'
end
[ callFunctions, defineFunctions ] = genFunctions( ruleCode, name, 'time,Y0_,P0_', 'Y0_,P0_' );
end

function [ callFunctions, defineFunctions ] = genFunctions( exprCellStr, functionName, inputs, outputs )

exprCellStr = exprCellStr( : );
idxStartChunk = getChunkBoundaries( exprCellStr );
numChunks = numel( idxStartChunk ) - 1;
callFunctions = cell( numChunks, 1 );
defineFunctions = cell( numChunks, 1 );
for i = 1:numChunks
    theseRules = exprCellStr( idxStartChunk( i ):( idxStartChunk( i + 1 ) - 1 ) );
    functionSig = sprintf( '[%s] = %s%d(%s)', outputs, functionName, i, inputs );
    callFunctions{ i } = [ functionSig, ';', newline ];
    thisFunctionDef = [ { [ 'function ', functionSig, newline ] };theseRules;{ [ 'end', newline ] } ];
    defineFunctions{ i } = [ thisFunctionDef{ : } ];
end
callFunctions = [ callFunctions{ : } ];
defineFunctions = [ defineFunctions{ : } ];
end

function [ idxStartChunk ] = getChunkBoundaries( exprCellStr )

IDEALCHUNKSIZE = 10000;
cellSizes = cellfun( @numel, exprCellStr );
cumCellSizes = cumsum( cellSizes );
modCellSizes = floor( cumCellSizes ./ IDEALCHUNKSIZE );
idxStartChunk = [ 1;find( modCellSizes( 2:end  ) > modCellSizes( 1:end  - 1 ) );numel( exprCellStr ) + 1 ];
end

function output = addComplexStepOverloads( output )
overloads =  ...
    [  ...
    '%% Overloads to support sensitivity analysis with the complex step method', newline ...
    , 'function value = min(x,y)', newline ...
    , 'value = simbio.complexstep.min(x,y);', newline ...
    , 'end', newline ...
    , 'function value = max(x,y)', newline ...
    , 'value = simbio.complexstep.max(x,y);', newline ...
    , 'end', newline ...
    , 'function value = abs(x)', newline ...
    , 'value = simbio.complexstep.abs(x);', newline ...
    , 'end', newline ...
    ];
output = [ output, overloads ];
end
