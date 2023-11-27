
function tunableVars = getTunableVariables( modelName )

arguments
    modelName( 1, 1 )string
end

product = "Simulink_Compiler";
[ status, msg ] = builtin( 'license', 'checkout', product );
if ~status
    product = extractBetween( msg, 'Cannot find a license for ', '.' );
    if ~isempty( product )
        error( message( 'simulinkcompiler:build:LicenseCheckoutError', product{ 1 } ) );
    end
    error( msg );
end

[ varsInRTP, nonTunableTerminalVarNames ] = getVariableInfoFromRTP( modelName );
varsInMaskFile = getVariablesFromMaskFile( modelName );
vars = [ varsInRTP, varsInMaskFile ];


if ~isempty( vars )
    charNames = cellfun( @( x )char( x ), { vars.name }, 'UniformOutput', false );
    [ ~, uniqueIndices, ~ ] = unique( charNames );
    vars = vars( uniqueIndices );
end

tunableVars = getTerminalVariablesAndValues( vars );

if ~isempty( nonTunableTerminalVarNames )
    [ ~, tunableVarsIdx ] = setdiff( [ tunableVars.QualifiedName ], nonTunableTerminalVarNames );
    tunableVars = tunableVars( tunableVarsIdx );
end
end






function variables = getVariablesFromMaskFile( modelName )
arguments
    modelName( 1, 1 )string
end


maskTreeAndModel = simulink.rapidaccelerator.internal.getMaskTreeAndModel( modelName );
maskTree = maskTreeAndModel.maskTree;


mf0Variables = [  ...
    maskTree.referencedGlobalWorkspaceVariables.toArray,  ...
    maskTree.referencedModelWorkspaceVariables.toArray ...
    ];


variables = arrayfun( @( x )struct( 'name', string( x.name ), 'value', x.value ), mf0Variables );
end


function terminalVariableNames = getTerminalVariablesFromNonTunableVarInfo( nonTunableVarInfo )
terminalVariableNames = string.empty;
for i = 1:numel( nonTunableVarInfo )
    varName = nonTunableVarInfo( i ).name;
    regexStr = varName + "((\.)?\w*)*";
    fullyQualifiedNamesInExpression = regexp( nonTunableVarInfo( i ).nonTunableUses, regexStr, "match" );

    for idx = 1:numel( fullyQualifiedNamesInExpression )
        terminalVariableNames = [ terminalVariableNames, fullyQualifiedNamesInExpression{ idx } ];%#ok
    end
end

terminalVariableNames = unique( terminalVariableNames, 'stable' );
end



function terminalVariables = getTerminalVariablesAndValues( variables )
terminalVariables = [  ];
for i = 1:length( variables )
    variable = variables( i );
    if ~isstruct( variable )
        newVariable.QualifiedName = variable.name;
        newVariable.Value = variable.value;
        terminalVariables = [ terminalVariables, newVariable ];%#ok
    else
        terminalVariables = [ terminalVariables, getTerminalVariablesAndValuesFromStruct( variable ) ];%#ok
    end
end
end



function terminalVariables = getTerminalVariablesAndValuesFromStruct( variable )

assert( isstruct( variable ) );
terminalVariables = getTerminalVariablesAndValuesFromStructHelper( variable.name, variable.value, [  ] );
end



function terminalVariables = getTerminalVariablesAndValuesFromStructHelper( name, value, terminalVariables )

if ~isstruct( value )
    newTerminal.QualifiedName = name;
    newTerminal.Value = value;
    terminalVariables = [ terminalVariables, newTerminal ];
else
    fieldNames = fieldnames( value );
    for j = 1:length( fieldNames )
        fieldName = fieldNames{ j };
        fieldPath = name + "." + string( fieldName );
        fieldValue = value.( fieldName );
        terminalVariables = getTerminalVariablesAndValuesFromStructHelper( fieldPath, fieldValue, terminalVariables );
    end
end
end



function [ variables, nonTunableTerminalVarNames ] = getVariableInfoFromRTP( modelName )
arguments
    modelName( 1, 1 )string
end
rtp = getRTP( modelName );
variablesWithMapEntries = getVariablesInRTPWithMapEntries( rtp );
structVariables = getStructVariablesInRTP( rtp );
collapsedBaseWorkspaceVariables = rtp.collapsedBaseWorkspaceVariables;



variables = [ variablesWithMapEntries, structVariables, collapsedBaseWorkspaceVariables ];

nonTunableTerminalVarNames = getTerminalVariablesFromNonTunableVarInfo( rtp.nonTunableVariables );
end



function structVariables = getStructVariablesInRTP( rtp )
structVariables = [  ];
modelStructParameterIndices = find( cellfun( @( x )~isempty( x ) && x.ModelParam, { rtp.parameters.structParamInfo } ) );
for i = 1:length( modelStructParameterIndices )
    paramIdx = modelStructParameterIndices( i );
    tempVariable.name = string( rtp.parameters( paramIdx ).structParamInfo.Identifier );
    tempVariable.value = rtp.parameters( paramIdx ).values;
    structVariables = [ structVariables, tempVariable ];%#ok
end
end



function variables = getVariablesInRTPWithMapEntries( rtp )
variables = [  ];

for i = 1:length( rtp.parameters )
    map = rtp.parameters( i ).map;
    for j = 1:length( map )
        mapEntry = map( j );
        tempVariable.name = string( mapEntry.Identifier );
        tempVariable.value = getVariableValueFromRTP( rtp, i, mapEntry.ValueIndices, mapEntry.Dimensions );
        variables = [ variables, tempVariable ];%#ok
    end
end
end



function value = getVariableValueFromRTP( rtp, parameterEntryIndex, valueIndices, dimensions )
value = reshape( rtp.parameters( parameterEntryIndex ).values( valueIndices( 1 ):valueIndices( 2 ) ), dimensions );
end



function rtp = getRTP( modelName )
if Simulink.isRaccelDeployed
    modelInterface = Simulink.RapidAccelerator.getStandaloneModelInterface( modelName );
    modelInterface.initializeForDeployment(  );
    buildDir = modelInterface.getBuildDir(  );
    buildRTPFile = fullfile( buildDir, filesep, 'build_rtp.mat' );
    rtp = load( buildRTPFile );
else
    rtp = Simulink.BlockDiagram.buildRapidAcceleratorTarget( modelName );
end
end

