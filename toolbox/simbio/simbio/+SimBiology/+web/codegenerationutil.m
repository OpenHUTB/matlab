function out = codegenerationutil( action, varargin )












switch ( action )
    case 'getArgs'
        out = getArgs( varargin{ : } );
    case 'getModifierFromArgList'
        out = getModifierFromArgList( varargin{ : } );
    case 'getObjectCommand'
        out = getObjectCommand( varargin{ 1 } );
    case 'createCommaSeparatedList'
        out = createCommaSeparatedList( varargin{ 1 } );
    case 'createCommaSeparatedQuotedList'
        out = createCommaSeparatedQuotedList( varargin{ 1 } );
    case 'logical2str'
        out = logical2str( varargin{ 1 } );
    case 'appendCode'
        out = appendCode( varargin{ : } );
    case 'appendCodeInLoop'
        out = appendCodeInLoop( varargin{ 1 }, varargin{ 2 } );
    case 'readTemplate'
        out = readTemplate( varargin{ 1 } );
    case 'cleanupContent'
        out = cleanupContent( varargin{ 1 } );
    case 'createRunProgramMFile'
        out = createRunProgramMFile( varargin{ 1 } );
    case 'getStepByType'
        out = getStepByType( varargin{ : } );
    case 'getStepIndexByType'
        out = getStepIndexByType( varargin{ : } );
    case 'getValueProperty'
        out = getValueProperty( varargin{ : } );
    case 'getValuePropertyForState'
        out = getValuePropertyForState( varargin{ : } );
    case 'getConstantPropertyForState'
        out = getConstantPropertyForState( varargin{ : } );
    case 'generateCovarianceMatrix'
        out = generateCovarianceMatrix( varargin{ : } );
    case 'findUniqueName'
        out = findUniqueName( varargin{ : } );
    case 'findUniqueNameUsingDelimiter'
        out = findUniqueNameUsingDelimiter( varargin{ : } );
    case 'loadVariable'
        out = loadVariable( varargin{ : } );
    case 'loadTableData'
        out = loadTableData( varargin{ : } );
    case 'constructDosesFromData'
        out = constructDosesFromData( varargin{ : } );
end

end

function out = getArgs( inputs, steps )


modelStep = getStepByType( steps, 'Model' );
if ~isempty( modelStep )
    modelExplorer = modelStep.explorer;
    support.model = isfield( modelStep, 'model' );
    support.variants = supports( modelStep.internal.args, 'supportVariant' );
    support.doses = supports( modelStep.internal.args, 'supportDose' );
else
    modelExplorer = [  ];
    support.model = false;
    support.variants = false;
    support.doses = false;
end


doseStep = getStepByType( steps, 'Dose' );
if ~isempty( doseStep ) && doseStep.enabled
    doseExplorer = doseStep.explorer;
else
    doseExplorer = [  ];
end


dataStep = getStepByArgType( steps, 'data' );
support.data = ~isempty( dataStep );


dataCustomStep = getStepByType( steps, 'DataCustom' );
support.customData = ~isempty( dataCustomStep );


support.signature = '';


if support.model
    modelSessionID = modelStep.model;
else
    modelSessionID = {  };
end


model = SimBiology.web.modelhandler( 'getModelFromSessionID', modelSessionID );


if support.variants
    variants = modelStep.variants;
else
    variants = {  };
end


variantSessionIDs = [  ];
if ~isempty( variants )
    if iscell( variants )
        variants = [ variants{ : } ];
    end

    use = logical( [ variants.use ] );
    ids = [ variants.sessionID ];
    variantSessionIDs = ids( use );
end


modelStepSlider = [  ];
modelStepParams = [  ];
support.hasModelStepSliders = false;

if ~isempty( modelExplorer ) && ~isempty( modelExplorer.sliders )


    sessionIDsToExclude = {  };
    fitStep = getStepByType( steps, 'Fit' );

    if ~isempty( fitStep ) && fitStep.enabled
        namesToExclude = { fitStep.estimatedParameterInfo.name };
        sessionIDsToExclude = {  };

        for i = 1:numel( namesToExclude )
            fitObj = SimBiology.internal.getObjectFromPQN( model, namesToExclude{ i } );
            if ~isempty( fitObj )
                sessionIDsToExclude{ end  + 1 } = fitObj.SessionID;
            end
        end
    end

    sessionIDsToExclude = unique( [ sessionIDsToExclude{ : } ] );
    [ modelStepSlider, modelStepParams ] = constructVariant( model, modelExplorer.sliders, sessionIDsToExclude );
    support.hasModelStepSliders = true;
end


doseStepSlider = [  ];
doseStepParams = [  ];
if ~isempty( doseExplorer ) && ~isempty( doseExplorer.sliders )
    [ doseStepSlider, doseStepParams ] = constructVariant( model, doseExplorer.sliders, [  ] );
end


doseInfo = [  ];
support.modelStepParams = [  ];
support.doseStepParams = [  ];
if support.doses

    doseInfo1.fieldname = 'modelStep';
    doseInfo1.rawdoses = modelStep.doses;
    doseInfo1.sessionIDs = [  ];
    doseInfo1.toConstruct = {  };
    doseInfo1.doses = [  ];
    doseInfo = constructDoses( model, doseInfo1 );



    for i = 1:length( modelStepParams )
        modelStepParams( i ).dose = find( doseInfo.doses == modelStepParams( i ).dose );
    end


    if ~isempty( doseStep )
        doseInfo2.fieldname = 'doseStep';
        doseInfo2.rawdoses = doseStep.doses;
        doseInfo2.sessionIDs = [  ];
        doseInfo2.toConstruct = {  };
        doseInfo2.doses = [  ];
        doseInfo( 2 ) = constructDoses( model, doseInfo2 );
    end



    for i = 1:length( doseStepParams )
        doseStepParams( i ).dose = find( doseInfo( 2 ).doses == doseStepParams( i ).dose );
    end

    support.modelStepParams = modelStepParams;
    support.doseStepParams = doseStepParams;
end



argList = {  };

if support.model
    argList{ end  + 1 } = model;
    argList{ end  + 1 } = getconfigset( model, 'default' );
    support.signature = 'model, cs, ';
end

rawdata = [  ];
if support.data



    calcObservablesStep = getStepByType( steps, 'Calculate Observables' );
    if isfield( inputs, 'stepToRun' ) && strcmp( inputs.stepToRun, 'NCA' ) && ~isempty( calcObservablesStep ) && calcObservablesStep.sectionEnabled
        data = load( inputs.matfileName );
        data = data.data.results;
        rawdata = data;
    else
        [ data, rawdata ] = loadTableDataAndConfigure( dataStep );
    end
    argList{ end  + 1 } = data;
    support.signature = [ support.signature, 'data, ' ];
end

if support.customData
    dataInfo = dataCustomStep.customProgramDataInfo;
    if iscell( dataInfo )
        dataInfo = [ dataInfo{ : } ];
    end


    if ~isempty( dataInfo )
        dataInfo = dataInfo( [ dataInfo.use ] );


        dataStruct = struct;
        rawdata = struct;

        for i = 1:length( dataInfo )
            [ dataStruct.( dataInfo( i ).name ), rawdata.( dataInfo( i ).name ) ] = loadTableDataAndConfigure( dataInfo( i ) );
        end

        argList{ end  + 1 } = dataStruct;
    else
        argList{ end  + 1 } = [  ];
    end
    support.signature = [ support.signature, 'data, ' ];
end



if support.variants
    variants = getVariants( model, [  ], variantSessionIDs );
    variants = horzcat( variants, modelStepSlider );
    variantStruct = [  ];

    variantStruct.modelStep = variants;
    if ~isempty( doseStep )
        variantStruct.doseStep = doseStepSlider;
    end

    argList{ end  + 1 } = variantStruct;
    support.variantObjs = argList{ end  };
    support.signature = [ support.signature, 'variantsStruct, ' ];
end



if ( support.doses )
    doseStruct = [  ];
    for i = 1:length( doseInfo )
        doseStruct.( doseInfo( i ).fieldname ) = doseInfo( i ).doses;
    end

    argList{ end  + 1 } = doseStruct;
    support.doseObjs = argList{ end  };
    support.signature = [ support.signature, 'dosesStruct, ' ];
end



outputArguments = {  };
if strcmp( inputs.action, 'runSection' ) || strcmp( inputs.action, 'runSectionAndAdvance' )
    for i = 1:length( steps )
        if strcmp( steps{ i }.type, inputs.stepToRun )
            break ;
        end



        next = steps{ i }.internal.outputArguments;
        if ~isempty( next ) && steps{ i }.sectionEnabled
            outputArguments = [ outputArguments, next' ];
        end
    end
end

if ~isempty( outputArguments )
    dataRow = inputs.dataRow;
    output = load( dataRow.matfileName );
    output = output.( dataRow.matfileVariableName );

    support.output = true;
    support.outputArgs = outputArguments;
    support.signature = [ support.signature, 'output, ' ];
    argList{ end  + 1 } = output;
else
    support.output = false;
    support.outputArgs = [  ];
end


support.signature = support.signature( 1:end  - 2 );

out.argList = argList;
out.support = support;
out.rawdata = rawdata;

end

function [ v, paramDoses ] = constructVariant( model, sliders, sessionIDsToExclude )

v = sbiovariant( 'sliders' );
paramDoses = [  ];
names = get( model.Parameters, { 'Name' } );

for i = 1:length( sliders )
    next = sliders( i );

    if ( next.use )
        if strcmp( next.type, 'repeatdose' )
            d = sbioselect( model, 'SessionID', next.sessionID );
            value = get( d, next.property );

            if isnumeric( value )


                doseInfo.dose = d;
                doseInfo.property = next.property;
                doseInfo.paramName = findUniqueName( names, 'dose_Parameter' );
                names{ end  + 1 } = doseInfo.paramName;

                v.addcontent( { 'parameter', doseInfo.paramName, 'Value', next.value } );

                if isempty( paramDoses )
                    paramDoses = doseInfo;
                else
                    paramDoses( end  + 1 ) = doseInfo;
                end
            else


                param = resolveparameter( d, model, value );
                if ~isempty( param )
                    v.addcontent( { param.type, param.PartiallyQualifiedNameReally, 'Value', next.value } );
                end
            end
        else
            if isempty( find( next.sessionID == sessionIDsToExclude, 1 ) )
                v.addcontent( { next.type, next.pqn, getValueProperty( next.type ), next.value } );
            end
        end
    end
end

if isempty( v.Content )
    v = [  ];
end

end

function doseInfo = constructDoses( model, doseInfo )

for i = 1:length( doseInfo.rawdoses )
    if iscell( doseInfo.rawdoses )
        next = doseInfo.rawdoses{ i };
    else
        next = doseInfo.rawdoses( i );
    end

    if ( next.use )

        if strcmp( next.type, 'dose' )
            if ( next.sessionID ~=  - 1 )

                doseInfo.sessionIDs( end  + 1 ) = next.sessionID;
            end
        else

            doseInfo.toConstruct{ end  + 1 } = next;
        end
    end
end


constructedDoses = constructDosesFromData( doseInfo.toConstruct );



doseInfo.doses = buildDoseArray( model, constructedDoses, doseInfo.sessionIDs );

end

function doses = constructDosesFromData( dosesToConstruct )

doses = [  ];
for i = 1:length( dosesToConstruct )
    next = dosesToConstruct{ i };


    data = loadVariable( next.matfileName, next.matfileVariableName );
    derivedData = loadVariable( next.matfileName, next.matfileDerivedVariableName );

    if ~isempty( derivedData )
        data = [ data, derivedData ];
    end

    if ~isa( next, 'SimData' ) && isfield( next, 'exclusions' )
        data( next.exclusions, : ) = [  ];
    end


    columnName = next.name( length( next.dataName ) + 2:end  );

    rate = '';
    group = '';
    children = next.children;
    templateDose = sbiodose( 'test', 'schedule' );
    templateDose.TargetName = next.targetName;

    for j = 1:length( children )
        value = children( j ).value;
        type = children( j ).type;
        switch lower( children( j ).property )
            case 'group'
                group = value;
            case 'amount units'
                templateDose.AmountUnits = value;
            case 'lag parameter name'
                templateDose.LagParameterName = value;
            case 'rate'
                if strcmp( type, 'rawdata' )
                    rate = value( length( next.dataName ) + 2:end  );
                elseif strcmp( type, 'parameter' )
                    templateDose.DurationParameterName = value;
                end
            case 'rate units'
                templateDose.RateUnits = value;
            case 'time units'
                templateDose.TimeUnits = value;
        end
    end


    gd = groupedData( data );


    gd.Properties.GroupVariableName = next.groupColumn;
    gd.Properties.IndependentVariableName = next.independentColumn;

    dose = createDoses( gd, columnName, rate, templateDose, group );
    if isempty( doses )
        doses = dose;
    else
        doses( end  + 1 ) = dose;
    end
end

end

function out = buildDoseArray( model, out, sessionIDs )

allDoses = getdose( model );
for i = 1:length( sessionIDs )
    next = sbioselect( allDoses, 'SessionID', sessionIDs( i ) );

    if isempty( out )
        out = next;
    else
        out( end  + 1 ) = next;
    end
end

end

function out = getVariants( model, out, sessionIDs )

allVariants = getvariant( model );
for i = 1:length( sessionIDs )
    next = sbioselect( allVariants, 'SessionID', sessionIDs( i ) );

    if ~isempty( next )
        if isempty( out )
            out = next;
        else
            out( end  + 1 ) = next;
        end
    end
end

end

function out = getObjectCommand( state )

out = '';
obj = get( state, 'Parent' );
type = get( obj, 'Type' );

if strcmp( type, 'kineticlaw' )
    robj = get( obj, 'Parent' );
    obj = get( robj, 'Parent' );
    type = get( obj, 'Type' );


    mobj = get( robj, 'Parent' );
    robjs = get( mobj, 'Reactions' );
    index = find( robj == robjs );

    out = [ 'Reaction(', num2str( index ), ')' ];

    pobj = sbioselect( robj, 'Type', 'parameter' );
    index = find( pobj == state );

    out = [ out, '.KineticLaw(1).Parameters(', num2str( index ), ')' ];
else
    stateType = get( state, 'Type' );
    if strcmp( stateType, 'species' )
        allSpecies = get( obj, 'Species' );
        index = find( state == allSpecies );
        out = [ 'Species(', num2str( index ), ')' ];
    elseif strcmp( stateType, 'parameter' )
        allParameters = get( obj, 'Parameters' );
        index = find( state == allParameters );
        out = [ 'Parameters(', num2str( index ), ')' ];
    elseif strcmp( stateType, 'compartment' )
        allCompartments = get( obj, 'Compartments' );
        index = find( state == allCompartments );
        out = [ 'Compartments(', num2str( index ), ')' ];
    end
end

while strcmp( type, 'compartment' )
    nextObj = get( obj, 'Parent' );
    allComps = get( nextObj, 'Compartments' );
    index = find( allComps == obj );

    out = [ 'Compartments(', num2str( index ), ').', out ];%#ok<*AGROW>
    obj = nextObj;
    type = get( obj, 'Type' );
end

if strcmp( out( 1 ), '.' )
    out = out( 2:end  );
end

end

function out = getModifierFromArgList( argList, type )

out = [  ];
for i = 1:numel( argList )
    if isstruct( argList{ i } )
        names = fieldnames( argList{ i } );
        for j = 1:length( names )
            next = argList{ i }.( names{ j } );
            if isa( next, type )
                out = argList{ i };
                break ;
            end
        end
    end
end

end

function out = supports( args, field )

out = false;
if ~isempty( args )
    if isfield( args, field )
        out = args.( field );
    end
end

end

function out = createCommaSeparatedList( list )

out = '';
for i = 1:length( list )
    out = [ out, list{ i }, ', ' ];
end

if ~isempty( out )
    out = out( 1:end  - 2 );
end

end

function out = createCommaSeparatedQuotedList( list )

out = '';
for i = 1:length( list )
    out = [ out, '''', list{ i }, ''', ' ];
end

if ~isempty( out )
    out = out( 1:end  - 2 );
end

end

function out = logical2str( value )

if value
    out = 'true';
else
    out = 'false';
end

end

function code = appendCode( code, newCode, NameValueArgs )
arguments
    code char
    newCode char



    NameValueArgs.prependNewline = false;
end

if NameValueArgs.prependNewline
    newCode = [ newline, newCode ];
end

code = [ code, newline, newCode ];
end

function code = appendCodeInLoop( code, newCode )

if isempty( code )
    code = newCode;
else
    code = [ code, newline, newCode ];
end

end

function content = readTemplate( name )


fileDir = fullfile( matlabroot, 'toolbox', 'simbio', 'simbio', '+SimBiology', '+web', '+templates' );
fileName = fullfile( fileDir, name );


content = fileread( fileName );
contentD = double( content );
contentD( contentD == 13 ) = [  ];
content = char( contentD );

end

function content = cleanupContent( content )



index = flip( strfind( content, '$(REMOVE)' ) );
for i = 1:length( index )
    value = content( index( i ):index( i ) + length( '$(REMOVE)' ) + 1 );
    if strcmp( deblank( value ), '$(REMOVE)' )

        content( index( i ):index( i ) + length( '$(REMOVE)' ) + 1 ) = [  ];
    else
        content( index( i ):index( i ) + length( '$(REMOVE)' ) - 1 ) = [  ];
    end
end

end

function filename = createRunProgramMFile( code )







tempdirName = sbiogate( 'sbiotempdir' );
[ ~, filename ] = fileparts( tempname );


filename = fullfile( tempdirName, [ filename, '.m' ] );
fid = fopen( filename, 'w' );


fprintf( fid, '%s', code );
fclose( fid );

end

function step = getStepByType( steps, type )

step = [  ];
for i = 1:length( steps )
    next = steps{ i };
    if any( strcmp( next.type, type ) )
        step = next;
        return ;
    end
end

end

function index = getStepIndexByType( steps, type )

index =  - 1;
for i = 1:length( steps )
    next = steps{ i };
    if any( strcmp( next.type, type ) )
        index = i;
        return ;
    end
end

end

function step = getStepByArgType( steps, type )

step = [  ];
for i = 1:length( steps )
    next = steps{ i }.internal;
    if isfield( next, 'argType' ) && strcmp( next.argType, type )
        step = steps{ i };
        return ;
    end
end

end

function out = getValuePropertyForState( state )

out = getValueProperty( state.type );

end

function prop = getValueProperty( type )

switch ( type )
    case 'species'
        prop = 'InitialAmount';
    case 'parameter'
        prop = 'Value';
    case 'compartment'
        prop = 'Capacity';
    otherwise
        prop = '';
end

end

function out = getConstantPropertyForState( state )

out = getConstantProperty( state.type );

end

function prop = getConstantProperty( type )

switch ( type )
    case 'species'
        prop = 'ConstantAmount';
    case 'parameter'
        prop = 'ConstantValue';
    case 'compartment'
        prop = 'ConstantCapacity';
end

end

function covMatrix = generateCovarianceMatrix( names, covInfo )

covMatrix = zeros( length( names ) );

for i = 1:length( names )
    next = covInfo( i );
    for j = 1:length( names )
        covMatrix( i, j ) = next.( [ 'param', num2str( j - 1 ) ] );
    end
end

end

function name = findUniqueName( allNames, nameIn )

name = findUniqueNameUsingDelimiter( allNames, nameIn, '_', false );

end

function name = findUniqueNameUsingDelimiter( allNames, nameIn, delimiter, indexRequired )



if ~indexRequired && ( isempty( allNames ) || ~any( strcmp( allNames, nameIn ) ) )
    name = nameIn;
    return ;
end

index = 1;
newName = [ nameIn, delimiter, num2str( index ) ];
while any( strcmp( allNames, newName ) )
    index = index + 1;
    newName = [ nameIn, delimiter, num2str( index ) ];
end
name = newName;

end

function data = loadVariable( matfile, matfileVarName )

if ~isempty( matfileVarName ) && SimBiology.internal.variableExistsInMatFile( matfile, matfileVarName )
    data = load( matfile, matfileVarName );
    data = data.( matfileVarName );
else
    data = [  ];
end

end

function data = loadTableData( matfile, matfileVarName, matfileDerivedVarName )

data = loadVariable( matfile, matfileVarName );
derivedData = loadVariable( matfile, matfileDerivedVarName );

if ~isempty( derivedData )
    data = [ data, derivedData ];
end

end

function [ data, rawdata ] = loadTableDataAndConfigure( info )

data = loadVariable( info.dataMATFile, info.dataMATFileVariableName );
derivedData = loadVariable( info.dataMATFile, info.matfileDerivedVariableName );
rawdata = data;

varName = '';
if isfield( info, 'dataName' )
    idx = find( info.dataName == '.' );
    if ~isempty( idx )
        varName = info.dataName;
        varName = varName( idx( end  ) + 1:end  );
    end
end

if ~isempty( varName )
    data = data.( varName );
    if ~isempty( derivedData )
        derivedData = derivedData.( varName );
    end
end


if ~isa( data, 'SimData' )
    if ~isempty( derivedData )
        data = [ data, derivedData ];
    end

    if ~isempty( info.dataUnits )
        data.Properties.VariableUnits = info.dataUnits;
    end


    rawdata = data;
    data( info.exclusions, : ) = [  ];
else
    if ~isempty( derivedData )
        dataTemp.data = data;
        dataTemp.derived = derivedData;
        data = dataTemp;
        rawdata = data;
    end
end
end
