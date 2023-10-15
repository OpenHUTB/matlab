function [ harnessName, hrnsInfo, errorInfo ] = create_sltest_harness( harnessOwners, harnessSource, functionInterface, optArgs )

arguments
    harnessOwners string
    harnessSource string
    functionInterface
    optArgs.TopModel string = ""
    optArgs.SaveExternally( 1, 1 )logical = false;
end


topModel = optArgs.TopModel;
numOfComps = numel( harnessOwners );
isInBatchMode = numOfComps > 1;
assert( ~isInBatchMode || functionInterface == "" );

hCUT = get_param( harnessOwners, 'Handle' );
if isInBatchMode
    assert( topModel ~= "" );
    assert( iscell( hCUT ) );
    hCUT = cell2mat( hCUT );
end
hModel = bdroot( hCUT );

if ~isInBatchMode
    modelName = bdroot( harnessOwners );
    if functionInterface ~= ""
        harnessName = Simulink.harness.internal.getUniqueName( modelName.char, [ functionInterface, '_Harness1' ] );
    else
        harnessName = Simulink.harness.internal.getDefaultName( modelName.char, hCUT, [  ] );
    end
    harnessName = string( harnessName );
end



wState = warning;
warning( 'off', 'Simulink:Harness:UpdatedConfigSet_GenTypeDefs' );
warning( 'off', 'Simulink:Harness:InvalidCreateUnifiedSchedulerOptionForMR' );
oc2 = onCleanup( @(  )warning( wState ) );


isSLDVCompatible = true;
args = { 'Source', harnessSource,  ...
    'DriveFcnCallWithTestSequence', false,  ...
    'SchedulerBlock', 'MATLAB Function',  ...
    'RebuildOnOpen', false,  ...
    'SLDVCompatible', isSLDVCompatible };

if optArgs.SaveExternally
    args = [ args, { 'SaveExternally', true } ];
end

if isInBatchMode
    [ hrnsInfo, status ] = Simulink.harness.internal.createMultipleHarnesses( hCUT, topModel, args{ : } );
    harnessName = strings( numOfComps, 1 );
    for i = 1:numOfComps
        if status( i )
            harnessName( i ) = hrnsInfo{ i }.name;
        end
    end
else



    args = [ args, { 'Name', harnessName, 'FunctionInterfaceName', functionInterface } ];
    Simulink.harness.create( hCUT, args{ : } );
    hrnsInfo = {  };
    status = 1;
end


errorInfo = cell( numOfComps, 1 );
for i = 1:numOfComps
    if status( i )
        [ hrnsInfo{ i }, errorInfo{ i } ] = configureHarness( harnessOwners( i ), hModel( i ), harnessName( i ), isSLDVCompatible );
    end
end

if ~isInBatchMode
    hrnsInfo = hrnsInfo{ 1 };
    errorInfo = errorInfo{ 1 };
end

end


function [ hInfo, errorInfo ] = configureHarness( harnessOwner, hModel, harnessName, isSLDVCompatible )

hCUT = get_param( harnessOwner, 'Handle' );

Simulink.harness.load( hCUT, harnessName );

errorInfo = sldvshareprivate( 'checkCompatForSLTStubbedSLFunction', hCUT, harnessName );
if ~isempty( errorInfo.identifier )

    Simulink.harness.close( hCUT, harnessName );
    Simulink.harness.delete( hCUT, harnessName );
    hInfo = MException( errorInfo.identifier, errorInfo.message );
    return ;
end

hInfo = Simulink.harness.find( hCUT, 'Name', harnessName );

if isSLDVCompatible && ~strcmp( hInfo.origSrc, 'Inport' )
    harnessH = get_param( harnessName, 'Handle' );
    fOpts = Simulink.FindOptions( "SearchDepth", 1 );
    stubFcnH = Simulink.findBlocksOfType( harnessH, 'SubSystem',  ...
        'Tag', '_Harness_SLFunc_Stub_', fOpts );
    if ~isempty( stubFcnH )

        Simulink.harness.close( hCUT, harnessName );
        Simulink.harness.delete( hCUT, harnessName );


        errorInfo.identifier = 'Sldv:Compatibility:UnsupportedHarnessSourceForSLFunctionStub';
        errorInfo.message = getString( message( errorInfo.identifier, getfullname( hCUT ) ) );
        hInfo = MException( errorInfo.identifier, errorInfo.message );
        return
    end
end

isConfigSetReadOnly = isa( getActiveConfigSet( harnessName ), 'Simulink.ConfigSetRef' );
hHarness = get_param( harnessName, 'Handle' );

if ~isConfigSetReadOnly

    if ~strcmpi( get_param( hHarness, 'SolverType' ), 'Fixed-step' )
        set_param( hHarness, 'SolverType', 'Fixed-step' );

        set_param( hHarness, 'FixedStep', 'auto' );
    end

    set_param( hHarness, 'SaveFormat', 'Dataset' );

    rootMdl = hCUT;
    if ~isa( hInfo.ownerType, 'Simulink.BlockDiagram' )
        rootMdl = bdroot( hCUT );
    end
    sldvshareprivate( 'configSLDVCompatibleHarness', rootMdl, hHarness );
end


if hInfo.saveExternally
    save_system( hHarness );
end

Simulink.harness.close( hCUT, harnessName );

if hInfo.saveExternally
    set_param( hModel, 'Dirty', 'off' );
end
end


