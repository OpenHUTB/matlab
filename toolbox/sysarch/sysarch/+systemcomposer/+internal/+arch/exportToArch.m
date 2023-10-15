function exportToArch( myOrigModel, myArch, dstPath, doAutoArrange, showProgress, parentDlg )




arguments
    myOrigModel char
    myArch char
    dstPath char = pwd
    doAutoArrange logical = true
    showProgress logical = false
    parentDlg = [  ]
end

if showProgress
    progDlg = systemcomposer.internal.ProgressBar(  ...
        DAStudio.message( 'SystemArchitecture:studio:ExportingToArchitecture' ),  ...
        parentDlg, false );
    showProgressFcn = @doShowProgress;
else
    progDlg = [  ];
    showProgressFcn = @doNotShowProgress;
end


showProgressFcn( progDlg, DAStudio.message( 'SystemArchitecture:ExportToArch:ProgressPreparing' ), 0 );


if contains( myOrigModel, '/' )

    tokensOrig = split( myOrigModel, '/' );
    topModelOrig = tokensOrig{ 1 };
    myOrigModel = topModelOrig;
end



myTempModel = [ myOrigModel, '_tempExportWorkflow' ];


load_system( myOrigModel );
fileName = get_param( myOrigModel, 'FileName' );
[ ~, ~, fileExt ] = fileparts( fileName );
if isempty( fileExt )
    error( message( 'SystemArchitecture:ExportToArch:SrcModelFileNotFound', myOrigModel ) );
end


if bdIsDirty( myOrigModel )
    error( message( 'SystemArchitecture:ExportToArch:SrcModelHasUnsavedChanges', myOrigModel ) );
end


currDir = pwd;
prevPath = addpath( currDir );
pathCleanup = onCleanup( @(  )path( prevPath ) );
cd( tempdir );
cdCleanup = onCleanup( @(  )cd( currDir ) );
delete( [ myTempModel, '.*' ] );
copyfile( fileName, [ myTempModel, fileExt ] );
tmpModelCleaner = onCleanup( @(  )cleanupTempModel( myTempModel, fileExt ) );
load_system( myTempModel );

delete( cdCleanup );


if exist( dstPath, 'dir' ) ~= 7
    error( message( 'SystemArchitecture:ExportToArch:InvalidDestination', dstPath ) );
end
[ ~, fa ] = fileattrib( dstPath );
if ~fa.UserWrite
    error( message( 'SystemArchitecture:ExportToArch:DestinationNotWriteable', dstPath ) );
end


if isfile( [ dstPath, '/', myArch, '.slx' ] )
    ME = MSLException( 'SystemArchitecture:ExportToArch:ArchModelAlreadyExists', dstPath, myArch );
    throwAsCaller( ME );
end

cd( dstPath );
cdCleanup = onCleanup( @(  )cd( currDir ) );

try
    model = systemcomposer.internal.arch.new( myArch );
    rootArch = model.getTopLevelCompositionArchitecture;
    actArch = systemcomposer.arch.Architecture( rootArch );


    set_param( myArch, 'DataDictionary', get_param( bdroot( myTempModel ), 'DataDictionary' ) );


    copyConfigSetFromSource( myOrigModel, model );


    showProgressFcn( progDlg, DAStudio.message( 'SystemArchitecture:ExportToArch:ProgressCompiling' ) );




    origSimMode = get_param( myOrigModel, 'SimulationMode' );
    if ~strcmpi( origSimMode, 'normal' )
        set_param( myOrigModel, 'SimulationMode', 'normal' );
        simModeCleanup = onCleanup( @(  )set_param( myOrigModel, 'SimulationMode', origSimMode ) );
    end








    evalin( 'base', [ bdroot( myOrigModel ), '([],[],[], ''compile'')' ] );
    evalin( 'base', [ bdroot( myOrigModel ), '([],[],[], ''term'')' ] );

    if ( isempty( get_param( myOrigModel, 'Parent' ) ) && strcmp( get_param( myOrigModel, 'IsExportFunctionModel' ), 'on' ) )


        txn = systemcomposer.internal.arch.internal.AsyncPluginTransaction( bdroot( myArch ) );
        comp = addComponent( actArch, myOrigModel );
        txn.commit(  );
        comp.makeReference( myOrigModel, 'IsArchitecture', 'false' );
        save_system( myArch, [ myArch, '.slx' ] );
        return ;
    end


    showProgressFcn( progDlg, DAStudio.message( 'SystemArchitecture:ExportToArch:ProgressComponents' ) );


    myBlocks = find_system( myTempModel, 'SearchDepth', 1 );
    myBlocks = myBlocks( 2:end  );
    addedBlocksModel = {  };
    addedBlocksArch = {  };
    skippedBlocks = {  };


    [ addedBlocksModel, addedBlocksArch, skippedBlocks ] = addBlocksToArchitecture ...
        ( myBlocks, myArch, myTempModel, addedBlocksModel, addedBlocksArch, skippedBlocks, progDlg, showProgressFcn );


    for cnt = 1:length( addedBlocksArch )
        addedBlocksArch{ cnt } = strrep( addedBlocksArch{ cnt }, [ myArch, '/' ], '' );
    end


    showProgressFcn( progDlg, DAStudio.message( 'SystemArchitecture:ExportToArch:ProgressConnectors' ), 0 );




    evalin( 'base', [ bdroot( myOrigModel ), '([],[],[], ''compile'')' ] );
    mdlCompileCleaner = onCleanup( @(  )evalin( 'base', [ bdroot( myOrigModel ), '([],[],[], ''term'')' ] ) );


    for cnt = 1:length( addedBlocksModel )
        showProgressFcn( progDlg, '', cnt / length( addedBlocksModel ) * 100 );
        currPortConn = get_param( addedBlocksModel{ cnt }, 'PortConnectivity' );
        addLineToSrc( addedBlocksModel{ cnt }, currPortConn,  ...
            addedBlocksArch{ cnt }, addedBlocksModel, addedBlocksArch, myArch, myTempModel )
    end
    systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( myArch ) );


    showProgressFcn( progDlg, DAStudio.message( 'SystemArchitecture:ExportToArch:ProgressInterfaces' ), 0 );






    zcMdl = get_param( myArch, 'SystemComposerModel' );
    for cntR = 1:length( addedBlocksArch )
        showProgressFcn( progDlg, '', cntR / length( addedBlocksArch ) * 100 );
        newBlock = [ myArch, '/', addedBlocksArch{ cntR } ];
        newBlockModel = addedBlocksModel{ cntR };
        if ( strcmp( get_param( newBlock, 'BlockType' ), 'SubSystem' ) ||  ...
                strcmp( get_param( newBlock, 'BlockType' ), 'ModelReference' ) )
            newBlockParent = newBlock;
        else
            newBlockParent = get_param( newBlock, 'Parent' );
        end
        component = zcMdl.lookup( 'Path', newBlockParent ).getImpl;
        addSignalInterfaces( myArch, newBlock, newBlockModel, component, myOrigModel );
    end
    delete( mdlCompileCleaner );


    showProgressFcn( progDlg, DAStudio.message( 'SystemArchitecture:ExportToArch:ProgressParameters' ), 0 );





    oldStatus = systemcomposer.internal.arch.internal.parameterSyncWarningStatus( true );
    c = onCleanup( @(  )systemcomposer.internal.arch.internal.parameterSyncWarningStatus( oldStatus ) );

    actArch = systemcomposer.internal.getWrapperForImpl( rootArch );

    systemcomposer.internal.parameters.arch.sync.copyParametersBetweenModels( myTempModel, actArch );
    showProgressFcn( progDlg, '', 40 );


    for i = 1:length( addedBlocksArch )
        showProgressFcn( progDlg, '', 40 + i / length( addedBlocksArch ) * 30 );
        blkInMdl = addedBlocksModel{ i };
        blkInArch = strrep( addedBlocksArch{ i }, [ myArch, '/' ], '' );
        try
            comp = actArch.Model.lookup( 'Path', [ myArch, '/', blkInArch ] );
        catch e
            comp = [  ];
        end
        if ~isempty( comp )
            compImpl = comp.getImpl;
            systemcomposer.internal.parameters.arch.sync.copyInstParametersBetweenModels( blkInMdl, blkInArch, compImpl, actArch );
        end
    end



    showProgressFcn( progDlg, DAStudio.message( 'SystemArchitecture:ExportToArch:ProgressSaving' ), 0 );
    save_system( myArch, [ myArch, '.slx' ] );
    open_system( myArch );



    showProgressFcn( progDlg, DAStudio.message( 'SystemArchitecture:ExportToArch:ProgressSaving' ) );
    sl2zcBlockHdlMap = buildSL2ZCHandleMap( myTempModel, myArch,  ...
        addedBlocksModel, addedBlocksArch );
    copySLLinks2ZCAndSave( sl2zcBlockHdlMap, myTempModel, myArch )



    if doAutoArrange
        showProgressFcn( progDlg, DAStudio.message( 'SystemArchitecture:ExportToArch:ProgressAutoArrange' ) );
        beautifyAllLevels( myArch );
        showProgressFcn( progDlg, DAStudio.message( 'SystemArchitecture:ExportToArch:ProgressSaving' ) );
        save_system( myArch, [ myArch, '.slx' ] );
        open_system( myArch );
    end


    showProgressFcn( progDlg, DAStudio.message( 'SystemArchitecture:ExportToArch:ProgressFinishing' ) );


    editor = GLUE2.Util.findAllEditors( myArch );
    scene = editor.getScene;
    nodes = scene.nodes;
    systembox = nodes( arrayfun( @( x )isa( x, 'MG2.RoundedRectNode' ), nodes ) );
    position = [ systembox( 1 ).Rect( 1 ) + 50, systembox( 1 ).Rect( 2 ) + systembox( 1 ).Rect( 4 ),  ...
        systembox( 1 ).Rect( 3 ), systembox( 1 ).Rect( 4 ) ];
    annotation = DAStudio.message(  ...
        'SystemArchitecture:studio:ExportToArchAnnotation',  ...
        myOrigModel,  ...
        datestr( now ) );
    Simulink.Annotation( [ myArch, '/anntExp' ], 'Text', annotation,  ...
        'Position', position );
    save_system( myArch, [ myArch, '.slx' ] );

catch ME
    if strcmp( get_param( myOrigModel, 'SimulationStatus' ), 'paused' )


        evalin( 'base', [ bdroot( myOrigModel ), '([],[],[], ''term'')' ] );
    end
    close_system( myArch, 0 );
    throw( ME );
end
end


function result = isBlockAllowedInComposition( currBlock, varargin )


curArch = [  ];

narginchk( 1, 2 );
if nargin == 2
    curArch = varargin{ 1 };
end

result = false;
allowedBlockTypes = { 'Inport', 'Outport', 'PMIOPort', 'ModelReference', 'SubSystem', 'Delay', 'UnitDelay', 'RateTransition' };
currBlockType = get_param( currBlock, 'BlockType' );
if ( any( strcmp( allowedBlockTypes, currBlockType ) ) )
    if isAllowedStateflowBasedBlock( currBlock )
        result = true;
    end

    if strcmp( currBlockType, 'PMIOPort' ) && ~isempty( curArch )

        hdl = get_param( curArch, 'Handle' );
        if ~isempty( get_param( hdl, 'Parent' ) )
            result = true;
        end
    elseif ( ~( strcmp( currBlockType, 'Inport' ) &&  ...
            strcmp( get_param( currBlock, 'OutputFunctionCall' ), 'on' ) ) ) &&  ...
            ~( slprivate( 'is_stateflow_based_block', currBlock ) ) &&  ...
            ~( strcmp( currBlockType, 'Reference' ) ) &&  ...
            ~( strcmp( currBlockType, 'SubSystem' ) &&  ...
            ~isempty( get_param( currBlock, 'ReferencedSubsystem' ) ) )
        result = true;
    end
end
end

function result = isAllowedStateflowBasedBlock( block )

result = false;
if slprivate( 'is_stateflow_based_block', block ) && strcmp( 'Chart', get_param( block, 'SFBlockType' ) )
    chartID = sfprivate( 'block2chart', get_param( block, 'Handle' ) );
    stateflowRoot = sfroot;
    chartObj = stateflowRoot.find( '-isa', 'Stateflow.Chart', 'Id', chartID );
    ioEvents = chartObj.find( '-isa', 'Stateflow.Event', { 'Scope', 'Input', '-OR', 'Scope', 'Output' } );
    if isempty( ioEvents )

        result = true;
    end
end
end

function result = isComponentPurelyComposition( currBlock )

result = true;
myBlocks = find_system( currBlock, 'SearchDepth', 1, 'LookUnderMasks',  ...
    'on', 'FollowLinks', 'on' );
for cntB = 1:length( myBlocks )
    if ( ~isBlockAllowedInComposition( myBlocks{ cntB } ) )
        result = false;
        break ;
    end
end
end

function b = isFunctionalMaskedSubsystem( currBlock )


b = strcmpi( get_param( currBlock, 'Mask' ), 'on' ) &&  ...
    ( ~isempty( get_param( currBlock, 'MaskInitialization' ) ) ||  ...
    ~isempty( get_param( currBlock, 'MaskVariables' ) ) ||  ...
    ~isempty( get_param( currBlock, 'MaskCallbacks' ) ) ||  ...
    strcmpi( get_param( currBlock, 'MaskSelfModifiable' ), 'on' ) );
end

function [ addedBlocksModel, addedBlocksArch, skippedBlocks ] = addBlocksToArchitecture ...
    ( myBlocks, myArch, myModel, addedBlocksModel, addedBlocksArch, skippedBlocks, progDlg, showProgressFcn )

if nargin < 7
    progDlg = [  ];
    showProgressFcn = @doNotShowProgress;
end

adapterDlyBlks = [  ];
adapterRTBlks = [  ];
origRTBBlks = [  ];
for cnt = 1:length( myBlocks )
    showProgressFcn( progDlg, '', cnt / length( myBlocks ) * 100 );
    currBlock = myBlocks{ cnt };
    currBlockName = fixSlashInName( get_param( currBlock, 'Name' ) );
    if ( isBlockAllowedInComposition( currBlock, myArch ) )
        parent = get_param( currBlock, 'Parent' );
        isBlockInsideVariant = ( ~isempty( get_param( parent, 'Parent' ) ) &&  ...
            strcmp( get_param( parent, 'BlockType' ), 'SubSystem' ) &&  ...
            strcmp( get_param( parent, 'Variant' ), 'on' ) );

        if ( strcmp( get_param( currBlock, 'BlockType' ), 'Inport' ) &&  ...
                strcmp( get_param( currBlock, 'IsBusElementPort' ), 'off' ) ) &&  ...
                ( ~isBlockInsideVariant || isFunctionalMaskedSubsystem( parent ) )




            newBlock = add_block( 'simulink/Signal Routing/Bus Element In',  ...
                [ myArch, '/', strrep( get_param( currBlock, 'Name' ), '/', '_' ), '_element' ], 'MakeNameUnique', 'on', 'CreateNewPort', 'on' );
            set_param( newBlock, 'PortName', get_param( currBlock, 'Name' ) );
            set_param( newBlock, 'Element', '' );

        elseif ( strcmp( get_param( currBlock, 'BlockType' ), 'Outport' ) &&  ...
                strcmp( get_param( currBlock, 'IsBusElementPort' ), 'off' ) ) &&  ...
                ( ~isBlockInsideVariant || isFunctionalMaskedSubsystem( parent ) )




            newBlock = add_block( 'simulink/Signal Routing/Bus Element Out',  ...
                [ myArch, '/', strrep( get_param( currBlock, 'Name' ), '/', '_' ), '_element' ], 'MakeNameUnique', 'on' );
            set_param( newBlock, 'PortName', get_param( currBlock, 'Name' ) );
            set_param( newBlock, 'Element', '' )
        elseif ( strcmp( get_param( currBlock, 'BlockType' ), 'Delay' ) ) ||  ...
                strcmp( get_param( currBlock, 'BlockType' ), 'UnitDelay' )
            newBlock = add_block( 'built-in/SubSystem', [ myArch, '/', currBlockName ] );
            adapterDlyBlks = [ adapterDlyBlks;newBlock ];
        elseif ( strcmp( get_param( currBlock, 'BlockType' ), 'RateTransition' ) )
            newBlock = add_block( 'built-in/SubSystem', [ myArch, '/', currBlockName ] );
            adapterRTBlks = [ adapterRTBlks;newBlock ];
            origRTBBlks = [ origRTBBlks;get_param( currBlock, 'Handle' ) ];
        elseif strcmp( get_param( currBlock, 'BlockType' ), 'PMIOPort' )
            newBlock = add_block( 'built-in/PMIOPort', [ myArch, '/', currBlockName ], 'MakeNameUnique', 'on', 'Side', get_param( currBlock, 'Side' ) );
        elseif ( strcmp( get_param( currBlock, 'BlockType' ), 'SubSystem' ) ) && ~slprivate( 'is_stateflow_based_block', currBlock )




            if isFunctionalMaskedSubsystem( currBlock )





                forceNoModelRef = true;
                if ( forceNoModelRef )


                    newBlock = add_block( 'built-in/SubSystem', [ myArch, '/', currBlockName ] );
                    myBlocksSubIn = find_system( currBlock, 'SearchDepth', 1, 'LookUnderMasks',  ...
                        'on', 'FollowLinks', 'on', 'BlockType', 'Inport' );
                    myBlocksSubOut = find_system( currBlock, 'SearchDepth', 1, 'LookUnderMasks',  ...
                        'on', 'FollowLinks', 'on', 'BlockType', 'Outport' );
                    myBlocksSubPMIO = find_system( currBlock, 'SearchDepth', 1, 'LookUnderMasks',  ...
                        'on', 'FollowLinks', 'on', 'BlockType', 'PMIOPort' );
                    myBlocksSub = { myBlocksSubIn{ : }, myBlocksSubOut{ : }, myBlocksSubPMIO{ : } };
                    if ~isempty( myBlocksSub )
                        currArch = get_param( myBlocksSub{ 1 }, 'Parent' );
                        currArch = replaceModelNameWithArchName( currArch, myModel, myArch );
                        if ( length( myBlocksSub ) > 0 )
                            [ addedBlocksModel, addedBlocksArch, skippedBlocks ] = addBlocksToArchitecture ...
                                ( myBlocksSub, currArch, myModel, addedBlocksModel, addedBlocksArch, skippedBlocks );
                        end
                    end
                else
                    actArch = systemcomposer.utils.getArchitecturePeer( get_param( myArch, 'Handle' ) );
                    if isa( actArch, 'systemcomposer.architecture.model.design.Component' )
                        actArch = actArch.getArchitecture;
                    end
                    actArch = systemcomposer.arch.Architecture( actArch );
                    prefix = [ strrep( myArch, '/', '_' ), '_' ];

                    mdlName = [ prefix, currBlockName ];
                    mdlName( isspace( mdlName ) ) = [  ];


                    new_system( mdlName, 'Model', currBlock );
                    c1 = addComponent( actArch, currBlockName );
                    c1 = makeReference( c1, mdlName );
                    newBlock = [ myArch, '/', get_param( currBlock, 'Name' ) ];
                    set_param( mdlName, 'Solver', get_param( bdroot( myModel ), 'Solver' ) );
                    set_param( newBlock, 'ModelName', mdlName );
                    set_param( mdlName, 'DataDictionary', get_param( bdroot( myModel ), 'DataDictionary' ) );
                    save_system( mdlName, [ mdlName, '.slx' ] );
                end
            else
                if ( strcmp( get_param( currBlock, 'Variant' ), 'on' ) )

                    newBlock = add_block( 'built-in/SubSystem', [ myArch, '/', currBlockName ] );










                    currBDH = bdroot( newBlock );
                    oldAllowedBlockH = get_param( currBDH, 'AllowedBlockHandlesForConvertToVariant' );
                    newAllowedBlockH = [ oldAllowedBlockH, newBlock ];

                    set_param( currBDH, 'AllowedBlockHandlesForConvertToVariant', newAllowedBlockH );
                    c = onCleanup( @(  )set_param( currBDH, 'AllowedBlockHandlesForConvertToVariant', oldAllowedBlockH ) );

                    newBlock = Simulink.VariantManager.convertToVariant( newBlock );
                    delete( c );


                    Simulink.SubSystem.deleteContents( newBlock );
                else
                    newBlock = add_block( 'built-in/SubSystem', [ myArch, '/', currBlockName ] );
                end
                myBlocksSub = find_system( currBlock, 'SearchDepth', 1, 'MatchFilter', @Simulink.match.allVariants, 'FollowLinks', 'on' );
                if ~isempty( myBlocksSub )
                    currArch = myBlocksSub{ 1 };
                    currArch = replaceModelNameWithArchName( currArch, myModel, myArch );
                    myBlocksSub = myBlocksSub( 2:end  );

                    if ( length( myBlocksSub ) > 0 )
                        [ addedBlocksModel, addedBlocksArch, skippedBlocks ] = addBlocksToArchitecture ...
                            ( myBlocksSub, currArch, myModel, addedBlocksModel, addedBlocksArch, skippedBlocks );
                    end
                end
            end

            copyVariantSettingsFromSrcToDst( currBlock, newBlock );
        elseif ( strcmp( get_param( currBlock, 'BlockType' ), 'ModelReference' ) )
            if strcmp( get_param( currBlock, 'ProtectedModel' ), 'on' )
                mdlName = get_param( currBlock, 'ModelFile' );
            else
                mdlName = get_param( currBlock, 'ModelName' );
            end
            model = systemcomposer.internal.arch.load( bdroot( myArch ) );
            rootArch = model.getTopLevelCompositionArchitecture;
            actArch = systemcomposer.arch.Architecture( rootArch );
            if ( strcmp( actArch.Name, myArch ) )
                prefix = '';
            else
                prefix = [ strrep( myArch, [ actArch.Name, '/' ], '' ), '/' ];
            end

            comp = addComponent( actArch, [ prefix, currBlockName ] );
            try
                comp( end  ).makeReference( mdlName, 'IsArchitecture', 'false' );
            catch ME


                comp( end  ).makeReference( mdlName, 'IsArchitecture', 'false' );
            end

            newBlock = get_param( [ myArch, '/', currBlockName ], 'Handle' );
        else
            newBlock = add_block( currBlock, [ myArch, '/', currBlockName ] );
        end
        setPositionOfNewBlock( currBlock, newBlock );
        addedBlocksModel{ end  + 1 } = myBlocks{ cnt };%#ok<*AGROW>
        newBlockName = strrep( get_param( newBlock, 'Name' ), '/', '//' );
        addedBlocksArch{ end  + 1 } = [ myArch, '/', newBlockName ];%#ok<*AGROW>
        systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( myArch ) );

        modeEnum = systemcomposer.internal.adapter.ModeEnums;

        for nn = 1:numel( adapterDlyBlks )
            adapterComp = systemcomposer.utils.getArchitecturePeer( adapterDlyBlks( nn ) );
            if ~adapterComp.isAdapterComponent
                createAdapterBlock( adapterComp );
                systemcomposer.internal.adapter.setAdapterMode( adapterDlyBlks( nn ), modeEnum.UnitDelay );
            end
        end


        for nn = 1:numel( adapterRTBlks )
            adapterComp = systemcomposer.utils.getArchitecturePeer( adapterRTBlks( nn ) );
            if ~adapterComp.isAdapterComponent
                createAdapterBlock( adapterComp );


                opts = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
                opts( 'Integrity' ) = strcmpi( get_param( origRTBBlks( nn ), 'Integrity' ), 'on' );
                opts( 'Deterministic' ) = strcmpi( get_param( origRTBBlks( nn ), 'Deterministic' ), 'on' );
                opts( 'InitialConditions' ) = get_param( origRTBBlks( nn ), 'InitialCondition' );

                systemcomposer.internal.adapter.setAdapterMode( adapterRTBlks( nn ), modeEnum.RateTransition, opts );
            end
        end
    elseif ( isBusRelatedBlock( currBlock ) )


        currBlockHdl = get_param( currBlock, 'Handle' );


        if ( strcmp( get_param( currBlock, 'BlockType' ), 'BusSelector' ) )
            isOutputAsBus = strcmpi( get_param( currBlock, 'OutputAsBus' ), 'on' );
            if isOutputAsBus
                portHandles = get_param( currBlock, 'PortHandles' );
                outputs = numel( portHandles.Outport );
                outputSignals = get_param( currBlock, 'OutputSignals' );
            else
                outputs = split( get_param( currBlock, 'OutputSignals' ), ',' );
            end
            currPos = get_param( currBlock, 'Position' );
            currParent = get_param( currBlock, 'Parent' );
            archParent = replaceModelNameWithArchName( currParent, myModel, myArch );

            for cntO = 1:length( outputs )


                newBlock = add_block( currBlock, [ get_param( currBlock, 'Parent' ), '/',  ...
                    currBlockName ],  ...
                    'MakeNameUnique', 'on' );
                if ( mod( cntO, 2 ) )

                    newPosChange =  - 10;
                else

                    newPosChange = 10;
                end
                newBlockHdl = get_param( newBlock, 'Handle' );
                set_param( newBlock, 'Position',  ...
                    [ currPos( 1 ), currPos( 2 ) + newPosChange, currPos( 3 ),  ...
                    currPos( 4 ) + newPosChange ] );
                if isOutputAsBus
                    set_param( newBlock, 'OutputSignals', outputSignals );
                else
                    set_param( newBlock, 'OutputSignals', outputs{ cntO } );
                end




                currPC = get_param( currBlock, 'PortConnectivity' );
                srcBlkPC = get_param( currPC( 1 ).SrcBlock, 'PortConnectivity' );
                dstBlkPC = get_param( currPC( 1 + cntO ).DstBlock, 'PortConnectivity' );
                srcBlkI = 0;
                flag = 0;
                for cntPCI = 1:length( srcBlkPC )
                    if ~isempty( srcBlkPC( cntPCI ).DstBlock )
                        srcBlkI = srcBlkI + 1;
                        for cntDst = 1:length( srcBlkPC( cntPCI ).DstBlock )
                            if ( srcBlkPC( cntPCI ).DstBlock( cntDst ) == currBlockHdl )
                                flag = 1;
                                break ;
                            end
                        end
                    end
                    if ( flag == 1 )
                        break ;
                    end
                end

                dstBlkIndx = {  };
                if ( iscell( dstBlkPC ) )



                    for dstConnIdx = 1:numel( dstBlkPC )
                        dstBlkPCItem = dstBlkPC{ dstConnIdx };



                        dstBlkIndx = [ dstBlkIndx, { getConnectedDestinationPortIndex( srcBlkPC, dstBlkPCItem, currBlockHdl, cntO ) } ];
                    end




                    hasMultiplePorts = cellfun( @( x )numel( x ) > 1, dstBlkIndx );
                    multiplePortIdx = find( hasMultiplePorts == 1 );
                    if isempty( multiplePortIdx )
                        dstBlkIndx = [ dstBlkIndx{ : } ];
                    else
                        for m = 1:numel( multiplePortIdx ) - 1



                            if isequal( currPC( 1 + cntO ).DstBlock( multiplePortIdx( m ) ), currPC( 1 + cntO ).DstBlock( multiplePortIdx( m + 1 ) ) )
                                dstBlkIndx{ multiplePortIdx( m ) } = dstBlkIndx{ multiplePortIdx( m ) }( 1 );
                                dstBlkIndx{ multiplePortIdx( m + 1 ) } = dstBlkIndx{ multiplePortIdx( m + 1 ) }( m + 1 );
                            end
                        end
                        dstBlkIndx = [ dstBlkIndx{ : } ];
                    end

                else
                    dstBlkPCItem = dstBlkPC;
                    dstBlkIndx = getConnectedDestinationPortIndex( srcBlkPC, dstBlkPCItem, currBlockHdl, cntO );
                end

                Simulink.BlockDiagram.createSubsystem( newBlockHdl );
                ssBlock = get_param( newBlockHdl, 'Parent' );
                fixBlockNamesInsideSubsystem( ssBlock );
                try
                    Simulink.internal.CompositePorts.convertToBEP( newBlockHdl );
                catch MEBEP
                    disp( MEBEP );

                end
                fixBlocksInsideSubsystem( ssBlock, currBlockHdl );

                add_line( get_param( currBlock, 'Parent' ),  ...
                    [ fixSlashInName( get_param( currPC( 1 ).SrcBlock, 'Name' ) ), '/', num2str( srcBlkI ) ],  ...
                    [ fixSlashInName( get_param( ssBlock, 'Name' ) ), '/1' ] );



                for idxCnt = 1:numel( dstBlkIndx )

                    delete_line( get_param( currBlock, 'Parent' ),  ...
                        [ fixSlashInName( get_param( currBlock, 'Name' ) ), '/', num2str( cntO ) ],  ...
                        [ fixSlashInName( get_param( currPC( cntO + 1 ).DstBlock( idxCnt ), 'Name' ) ), '/', num2str( dstBlkIndx( idxCnt ) ) ] );

                    add_line( get_param( currBlock, 'Parent' ),  ...
                        [ fixSlashInName( get_param( ssBlock, 'Name' ) ), '/1' ],  ...
                        [ fixSlashInName( get_param( currPC( cntO + 1 ).DstBlock( idxCnt ), 'Name' ) ), '/', num2str( dstBlkIndx( idxCnt ) ) ] );
                end


                newBlockArch = convertSLSubsystemToAdapter( ssBlock, bdroot( archParent ), [ archParent, '/', 'Adapter' ] );



                inBlks = find_system( newBlockArch, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'Inport' );
                set_param( inBlks( 1 ), 'PortName', 'In1' );
                outBlks = find_system( newBlockArch, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'Outport' );
                if ( strcmp( get_param( outBlks( 1 ), 'IsBusElementPort' ), 'on' ) )
                    set_param( outBlks( 1 ), 'PortName', 'Out' );
                end
                currPosition = get_param( newBlockArch, 'Position' );
                newAdapterPos = [ currPosition( 1 ), currPosition( 2 ) + ( ( cntO ) * 45 ) - 20,  ...
                    currPosition( 3 ) - 20, currPosition( 2 ) + ( ( cntO ) * 45 + 5 ) ];
                set_param( newBlockArch, 'Position', newAdapterPos );
                set_param( newBlockArch, 'Selected', 'off' );
                addedBlocksModel{ end  + 1 } = ssBlock;%#ok<*AGROW>
                addedBlocksArch{ end  + 1 } = [ archParent, '/',  ...
                    get_param( newBlockArch, 'Name' ) ];%#ok<*AGROW>
                systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( myArch ) );
            end
            delete_block( currBlock );
        else
            Simulink.BlockDiagram.createSubsystem( currBlockHdl );
            ssBlock = get_param( currBlockHdl, 'Parent' );
            fixBlockNamesInsideSubsystem( ssBlock );
            try
                Simulink.internal.CompositePorts.convertToBEP( currBlockHdl );
            catch MEBEP
                disp( MEBEP );

            end



            outBlks = find_system( ssBlock, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'Outport' );
            set_param( outBlks{ 1 }, 'PortName', 'Out' );

            inBlks = find_system( ssBlock, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'Inport' );
            for cntN = 1:length( inBlks )
                set_param( inBlks{ cntN }, 'Name', [ 'Inport', num2str( cntN ) ] );
            end

            inBlks = find_system( ssBlock, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'Inport' );
            for cntN = 1:length( inBlks )
                if ( strcmp( get_param( inBlks( cntN ), 'IsBusElementPort' ), 'on' ) )
                    set_param( inBlks{ cntN }, 'PortName', [ 'In', num2str( cntN ) ] );
                end
            end


            newBlock = convertSLSubsystemToAdapter( ssBlock, bdroot( myArch ), [ myArch, '/Adapter' ] );

            currPosition = get_param( ssBlock, 'Position' );
            set_param( newBlock, 'Position',  ...
                [ currPosition( 1 ), currPosition( 1 ) - 150, currPosition( 1 ) + 20, currPosition( 1 ) - 130 ] );
            set_param( newBlock, 'Position',  ...
                [ currPosition( 1 ), currPosition( 1 ) - 150, currPosition( 1 ) + 20, currPosition( 1 ) - 130 ] );
            set_param( newBlock, 'Selected', 'off' );

            addedBlocksModel{ end  + 1 } = ssBlock;%#ok<*AGROW>
            addedBlocksArch{ end  + 1 } = [ myArch, '/', get_param( newBlock, 'Name' ) ];%#ok<*AGROW>
            systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( myArch ) );
        end
    else
        skippedBlocks{ end  + 1 } = currBlock;
    end
end
end

function setPositionOfNewBlock( currBlock, newBlock )


newPosition = get_param( currBlock, 'Position' );
if ( strcmp( get_param( currBlock, 'BlockType' ), 'Inport' ) ||  ...
        strcmp( get_param( currBlock, 'BlockType' ), 'Outport' ) )
    newPosition( 3 ) = newPosition( 1 ) + 10;
    newPosition( 4 ) = newPosition( 2 ) + 10;
end
set_param( newBlock, 'Position', newPosition );
end

function result = isBusRelatedBlock( currBlock )

result = false;
allowedBlockTypes = { 'BusSelector', 'BusCreator' };
currBlockType = get_param( currBlock, 'BlockType' );
for cntL = 1:length( allowedBlockTypes )
    if ( strcmp( allowedBlockTypes{ cntL }, currBlockType ) )
        result = true;
        break ;
    end
end
end

function fixBlockNamesInsideSubsystem( ssBlock )



subBlocks = find_system( ssBlock, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices );
subBlocks = subBlocks( 2:end  );
for cnt = 1:length( subBlocks )

    oldName = get_param( subBlocks{ cnt }, 'Name' );
    newName = erase( oldName, '<' );
    newName = erase( newName, '>' );
    if ( ~strcmp( oldName, newName ) )
        set_param( subBlocks{ cnt }, 'Name', newName );
    end
end
end

function fixBlocksInsideSubsystem( ssBlock, currBlockHdl )



subBlocks = find_system( ssBlock, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices );
subBlocks = subBlocks( 2:end  );
inblkNames = {  };
outblkNames = {  };
isOutputAsBus = strcmpi( get_param( currBlockHdl, 'OutputAsBus' ), 'on' );
outputSignalNames = split( get_param( currBlockHdl, 'OutputSignals' ), ',' );

for cnt = 1:length( subBlocks )
    if strcmp( get_param( subBlocks{ cnt }, 'BlockType' ), 'Inport' )
        inblkNames{ end  + 1 } = get_param( subBlocks{ cnt }, 'PortName' );
    end

    if strcmp( get_param( subBlocks{ cnt }, 'BlockType' ), 'Outport' )
        outblkNames{ end  + 1 } = get_param( subBlocks{ cnt }, 'PortName' );
    end
end

if isOutputAsBus
    outblkNames = outputSignalNames;
    outblkNames = cellfun( @( x )regexprep( x, '.*\.', '' ), outblkNames, 'UniformOutput', false );
end

replIn = replace_block( ssBlock, 'Inport',  ...
    'simulink/Sources/In Bus Element', 'noprompt' );
replOut = replace_block( ssBlock, 'Outport',  ...
    'simulink/Sinks/Out Bus Element', 'noprompt' );
for cnt = 1:length( replIn )
    blkHdl = get_param( replIn{ cnt }, 'Handle' );
    set_param( blkHdl, 'Element', outblkNames{ cnt } );
    set_param( blkHdl, 'Name', [ inblkNames{ cnt }, '_', outblkNames{ cnt } ] );
    set_param( blkHdl, 'PortName', inblkNames{ cnt } );
end
for cnt = 1:length( replOut )
    blkHdl = get_param( replOut{ cnt }, 'Handle' );
    if isOutputAsBus
        set_param( blkHdl, 'Element', outblkNames{ cnt } );
    else
        set_param( blkHdl, 'Element', '' );
    end
    set_param( blkHdl, 'Name', [ outblkNames{ cnt }, '_element' ] );
    set_param( blkHdl, 'PortName', outblkNames{ cnt } );
end
end


function addInterfaceToPort( currBlock, currBlockModel, component, myModel, myArch, model, blkString )



currBlockType = get_param( currBlock, 'BlockType' );
if strcmp( currBlockType, 'SubSystem' ) &&  ...
        strcmp( get_param( currBlock, 'SimulinkSubDomain' ), 'ArchitectureAdapter' )
    return ;
end
blockName = get_param( currBlock, 'Name' );
isModelCompiled = false;
if ( strcmp( currBlockType, 'ModelReference' ) )
    blockName = get_param( currBlock, 'ModelName' );
    load_system( blockName );
    try
        if ( strcmp( get_param( blockName, 'SimulationStatus' ), 'stopped' ) )
            feval( blockName, [  ], [  ], [  ], 'compile' );
            isModelCompiled = true;
        end
    catch ME
        if ( isModelCompiled )
            feval( blockName, [  ], [  ], [  ], 'term' );
        end
        throw( ME );
    end
else
    blockName = currBlockModel;
end

blockName = strrep( blockName, '_tempExportWorkflow', '' );
if ( any( strcmp( { 'SubSystem' }, currBlockType ) ) )
    blks = find_system( blockName, 'SearchDepth', 1, 'BlockType', blkString );
elseif ( any( strcmp( { 'Inport' }, currBlockType ) ) )
    blks = { blockName };
elseif ( any( strcmp( { 'Outport' }, currBlockType ) ) )
    blks = { blockName };
else
    blks = {  };
end
for cntI = 1:length( blks )
    if ( getSimulinkBlockHandle( blks( cntI ) ) ==  - 1 )

        continue ;
    end
    compPortData = get_param( blks( cntI ), 'CompiledPortDataTypes' );
    compPortDims = get_param( blks( cntI ), 'CompiledPortDimensions' );
    compPortCplx = get_param( blks( cntI ), 'CompiledPortComplexSignals' );
    compPortUnits = get_param( blks( cntI ), 'CompiledPortUnits' );
    pH = get_param( blks( cntI ), 'PortHandles' );

    if ( strcmp( get_param( blks{ cntI }, 'IsBusElementPort' ), 'on' ) )
        portName = get_param( blks( cntI ), 'PortName' );
    else
        portName = get_param( blks( cntI ), 'Name' );
    end
    portName = portName{ 1 };
    isBusType = false;
    isBEP = strcmpi( get_param( blks{ 1 }, 'isComposite' ), 'on' );
    if ( ~isempty( component ) )
        compPort = component.getPort( portName );
    else
        rootArch = model.getTopLevelCompositionArchitecture;
        compPort = rootArch.getPort( portName );
    end

    dtype = [  ];
    dims = [  ];
    cplx = [  ];
    units = [  ];

    if isBEP


        bepTree = systemcomposer.BusObjectManager.fetchTreeNodeObjectForBusElementPort( get_param( blks{ cntI }, 'Handle' ) );
        bepTreeRootNode = Simulink.internal.CompositePorts.TreeNode.findNode( bepTree, '' );
        if ~isempty( bepTreeRootNode.busTypeRootAttrs )
            isBusType = true;
            dtype = strrep( Simulink.internal.CompositePorts.TreeNode.getDataType( bepTreeRootNode ), 'Bus: ', '' );
            dims = Simulink.internal.CompositePorts.TreeNode.getDims( bepTreeRootNode );
            cplx = Simulink.internal.CompositePorts.TreeNode.getComplexity( bepTreeRootNode );
            units = Simulink.internal.CompositePorts.TreeNode.getUnit( bepTreeRootNode );
        end
    end
    if ~isBusType && ( ~isempty( compPortData{ 1 } ) && isempty( compPortData{ 1 }.Outport ) )
        sigHier = get_param( pH{ 1 }.Inport, 'SignalHierarchy' );
        if ~isempty( sigHier.BusObject )
            dtype = sigHier.BusObject;
            isBusType = true;
        else
            dtype = compPortData{ 1 }.Inport{ 1 };
        end
        dims = compPortDims{ 1 }.Inport( 2:end  );
        cplx = compPortCplx{ 1 }.Inport;
        units = compPortUnits{ 1 }.Inport{ 1 };


    elseif ~isBusType && ( ~isempty( compPortData{ 1 } ) )
        sigHier = get_param( pH{ 1 }.Outport, 'SignalHierarchy' );
        if ~isempty( sigHier.BusObject )
            dtype = sigHier.BusObject;
            isBusType = true;
        else
            dtype = compPortData{ 1 }.Outport{ 1 };
        end

        dims = compPortDims{ 1 }.Outport( 2:end  );
        cplx = compPortCplx{ 1 }.Outport;
        units = compPortUnits{ 1 }.Outport{ 1 };


    end
    if ( ~isempty( compPort ) && ~( isBEP && ~isBusType ) )
        if ~compPort.isArchitecturePort
            compPort = compPort.getArchitecturePort;
        end

        compPort = systemcomposer.arch.ArchitecturePort( compPort );
        if ~isBusType
            try

                compPortInterface = compPort.createInterface( "ValueType" );
                if ~isempty( enumeration( dtype ) )
                    compPortInterface.setType( [ 'Enum: ', dtype ] );
                elseif ( ~isempty( dtype ) )
                    compPortInterface.setType( dtype );
                end

                if isnumeric( dims )
                    if numel( dims ) > 1
                        dims = sprintf( '%s%s%s', '[', num2str( dims ), ']' );

                        dims = strrep( dims, '  ', ' ' );
                    else
                        dims = num2str( dims );
                    end
                end
                if ( ~isempty( dims ) )
                    compPortInterface.setDimensions( dims );
                end






                if ~isempty( units )
                    compPortInterface.setUnits( units );
                end
                if ( cplx )
                    compPortInterface.setComplexity( 'complex' );
                end
            catch ME




            end
        else
            try

                modelWrapper = systemcomposer.arch.Model( myArch );
                interfaceDictionary = modelWrapper.InterfaceDictionary;
                pi = getOrMakeInterface( interfaceDictionary, dtype );
                compPort.setInterface( pi );
            catch ME



            end
        end
    end
end
if isModelCompiled
    feval( blockName, [  ], [  ], [  ], 'term' );
end
end




function addSignalInterfaces( myArch, currBlock, currBlockModel, component, myModel )

model = systemcomposer.internal.arch.load( myArch );

blockType = get_param( currBlock, 'BlockType' );

if ( strcmpi( blockType, 'Inport' ) )

    addInterfaceToPort( currBlock, currBlockModel, component, myModel, myArch, model, 'Outport' );
elseif ( strcmpi( blockType, 'Outport' ) )

    addInterfaceToPort( currBlock, currBlockModel, component, myModel, myArch, model, 'Inport' );
end

end

function outString = replaceModelNameWithArchName( string, myModel, myArch )
outString = regexprep( string, [ '^', myModel ], bdroot( myArch ) );
end

function addLineToSrc( currBlock, currPortConns, currBlockInArch, addedBlocksModel, addedBlocksArch, myArch, myModel )

visitedBlks = { get_param( currBlock, 'Name' ) };
portDTypes = get_param( currBlock, 'CompiledPortDataTypes' );
for cntP = 1:length( currPortConns )
    if contains( currPortConns( cntP ).Type, { 'LConn', 'RConn' } ) && isempty( currPortConns( cntP ).SrcBlock )
        currPortConns( cntP ).SrcBlock = get_param( currBlock, 'Handle' );
        portHandles = get_param( currBlock, 'PortHandles' );
        sideAndNum = strsplit( currPortConns( cntP ).Type, 'Conn' );
        if numel( sideAndNum ) == 1
            sideAndNum{ 2 } = '1';
        end
        if strcmpi( sideAndNum{ 1 }, 'L' )
            currPortConns( cntP ).SrcPort = portHandles.LConn( str2double( sideAndNum{ 2 } ) );
        elseif strcmpi( sideAndNum{ 1 }, 'R' )
            currPortConns( cntP ).SrcPort = portHandles.RConn( str2double( sideAndNum{ 2 } ) );
        end
    end

    currPortNumber = cntP;

    addIndividualLineToSrc( currPortConns( currPortNumber ), cntP, portDTypes, visitedBlks );
end
    function addIndividualLineToSrc( currPortConn, cntP, portDTypes, visitedBlks )
        if ( logical( currPortConn.SrcBlock ) & currPortConn.SrcBlock ~=  - 1 &  ...
                ~strcmp( currPortConn.Type, 'trigger' ) & ~contains( currPortConn.Type, { 'LConn', 'RConn' } ) )
            srcParent = get_param( currPortConn.SrcBlock, 'Parent' );
            archParent = replaceModelNameWithArchName( srcParent, myModel, myArch );
            srcBlkInMdl = get_param( currPortConn.SrcBlock, 'Name' );
            if ( ~strcmp( srcParent, myModel ) )


                srcParent = strrep( srcParent, [ myModel, '/' ], '' );
                srcBlkInMdl = [ srcParent, '/', srcBlkInMdl ];
            end


            if ( any( strcmp( visitedBlks, srcBlkInMdl ) ) )
                return ;
            end


            whichIdx = strcmp( addedBlocksModel, [ myModel, '/', srcBlkInMdl ] );
            visitedBlks{ end  + 1 } = srcBlkInMdl;
            for cntIdx = 1:length( whichIdx )
                blkOfInterest = addedBlocksModel( cntIdx );
                if ( whichIdx( cntIdx ) && strcmp( [ myModel, '/', srcBlkInMdl ], blkOfInterest{ 1 } ) )
                    if ( strcmp( get_param( blkOfInterest{ 1 }, 'BlockType' ), 'BusSelector' ) )




                        whichIdx = cntIdx + currPortConn.SrcPort;
                        currPortConn.SrcPort = 0;
                        break ;
                    else
                        whichIdx = cntIdx;
                        break ;
                    end
                end
            end
            srcBlkInArch = addedBlocksArch( whichIdx );
            if ~isempty( srcBlkInArch )

                srcBlkName = srcBlkInArch{ 1 };
                if ( ~isempty( portDTypes ) && ( cntP > length( portDTypes.Inport ) || strcmp( portDTypes.Inport{ cntP }, 'fcn_call' ) ) )

                elseif any( strcmp( addedBlocksArch, srcBlkName ) )
                    currBlockInArch = strrep( currBlockInArch, [ srcParent, '/' ], '' );
                    srcBlkName = strrep( srcBlkName, [ srcParent, '/' ], '' );
                    dstPortName = [ currBlockInArch, '/', num2str( cntP ) ];
                    try
                        add_line( archParent,  ...
                            [ srcBlkName, '/', num2str( currPortConn.SrcPort + 1 ) ],  ...
                            dstPortName );
                    catch MEPort

                    end
                end
            else

                skipPortConns = get_param( currPortConn.SrcBlock, 'PortConnectivity' );



                for idx = 1:length( skipPortConns )
                    if ~( strcmp( skipPortConns( idx ).Type, '1' ) )
                        return ;
                    end
                end
                for idx = 1:length( skipPortConns )
                    addIndividualLineToSrc( skipPortConns( idx ),  ...
                        cntP, portDTypes, visitedBlks );
                end
            end
        elseif contains( currPortConn.Type, { 'LConn', 'RConn' } )
            if ~isempty( currPortConn.SrcBlock ) && ~isempty( currPortConn.DstBlock )
                zcMdl = get_param( myArch, 'SystemComposerModel' );
                srcParent = get_param( currPortConn.SrcBlock, 'Parent' );
                dstParent = get_param( currPortConn.DstBlock, 'Parent' );
                archSrcParent = replaceModelNameWithArchName( srcParent, myModel, myArch );
                archDstParent = replaceModelNameWithArchName( dstParent, myModel, myArch );
                if ( ~strcmp( srcParent, myModel ) )


                    srcParent = strrep( srcParent, [ myModel, '/' ], '' );
                else
                    srcParent = '';
                end

                if ( ~strcmp( dstParent, myModel ) )


                    dstParent = strrep( dstParent, [ myModel, '/' ], '' );
                else
                    dstParent = '';
                end

                if ~isempty( srcParent )
                    archSrcPort = getSourceConnectionPortInComposition( [ myArch, '/', srcParent ], currPortConn, zcMdl );
                else
                    archSrcPort = getSourceConnectionPortInComposition( myArch, currPortConn, zcMdl );
                end
                if ~isempty( dstParent )
                    if ~iscell( dstParent )
                        dstParent = { dstParent };
                    end
                    archDstPort = [  ];
                    for k = 1:numel( dstParent )
                        archDstPort = [ archDstPort, getDestinationConnectionPortInComposition( [ myArch, '/', dstParent{ k } ], currPortConn, zcMdl ) ];
                    end
                else
                    archDstPort = getDestinationConnectionPortInComposition( myArch, currPortConn, zcMdl );
                end
                for k = 1:numel( archDstPort )
                    try
                        if ~isempty( archSrcPort ) && ~isempty( archDstPort( k ) )
                            if isequal( archSrcParent, archDstParent )
                                if ~archSrcPort.getImpl.isConnectedTo( archDstPort( k ).getImpl )
                                    archSrcPort.connect( archDstPort( k ) );
                                end
                            else
                                if ~archSrcPort.getImpl.isConnectedTo( archDstPort( k ).getImpl )
                                    archSrcPort.connect( archDstPort( k ) );
                                end
                            end
                        end
                    catch e %#ok<NASGU>


                    end
                end
            end


        end
    end
end

function map = buildSL2ZCHandleMap( slModel, zcModel, addedBlocksModel, addedBlocksArch )


map = containers.Map( 'KeyType', 'double', 'ValueType', 'double' );

for n = 1:numel( addedBlocksArch )
    zcBh = get_param( [ zcModel, '/', addedBlocksArch{ n } ], 'Handle' );
    slBh = get_param( addedBlocksModel{ n }, 'Handle' );
    map( slBh ) = zcBh;
end
end

function copySLLinks2ZCAndSave( map, slModel, zcModel )


slBHs = map.keys;
zcBHs = map.values;

processed = false;

for n = 1:length( slBHs )
    slBH = slBHs{ n };
    zcBH = zcBHs{ n };

    linkInfo = rmi.getReqs( slBH );
    if ~isempty( linkInfo )
        processed = true;
        for i = 1:numel( linkInfo )
            slreq.createLink( zcBH, linkInfo( i ) );
        end
    end
end

if processed

    slModelFileName = get_param( slModel, 'FileName' );
    slDataLinkSet = slreq.utils.getLinkSet( slModelFileName );
    if ~isempty( slDataLinkSet ) && slreq.utils.isEmbeddedLinkSet( slDataLinkSet )


        rmidata.embed( zcModel )
    end

    zcModelFileName = get_param( zcModel, 'FileName' );
    zcDataLinkSet = slreq.utils.getLinkSet( zcModelFileName );

    if ~isempty( zcDataLinkSet )
        zcDataLinkSet.save;

    end
end
end

function copyVariantSettingsFromSrcToDst( src, dst )

propertiesToCopy = { 'VariantObject', 'VariantControlMode', 'AllowZeroVariantControls', 'PropagateVariantConditions' };
for i = 1:1:numel( propertiesToCopy )
    set_param( dst, propertiesToCopy{ i }, get_param( src, propertiesToCopy{ i } ) );
end
end

function createAdapterBlock( comp )

adapterWrapper = systemcomposer.internal.getWrapperForImpl( comp, 'systemcomposer.arch.Component' );
ports = adapterWrapper.Architecture.addPort( { 'In', 'Out' }, { 'in', 'out' } );
ports( 1 ).connect( ports( 2 ) );
systemcomposer.utils.makeAdapter( adapterWrapper );
end

function fixedName = fixSlashInName( blkName )


fixedName = strrep( blkName, '/', '//' );
end

function dstBlkIdx = getConnectedDestinationPortIndex( srcBlkPC, dstBlkPC, currBlockHdl, srcOutputIndex )



dstBlkIdx = [  ];

for cntPCO = 1:length( srcBlkPC )
    for cntPCOO = 1:length( dstBlkPC )
        if ~isempty( srcBlkPC( cntPCO ).DstBlock )
            for cntDst = 1:length( dstBlkPC( cntPCOO ).SrcBlock )





                dstMatchIdx = ( srcBlkPC( cntPCO ).DstBlock == currBlockHdl );
                srcMatch = any( dstMatchIdx );



                dstMatch = ( dstBlkPC( cntPCOO ).SrcBlock( cntDst ) == currBlockHdl &&  ...
                    dstBlkPC( cntPCOO ).SrcPort == srcOutputIndex - 1 );

                if srcMatch && dstMatch
                    dstBlkIdx = [ dstBlkIdx, str2double( dstBlkPC( cntPCOO ).Type ) ];
                end
            end
        end
    end
end
end

function copyConfigSetFromSource( origSLModelName, newArchModelObj )



archModelName = newArchModelObj.getName(  );
csSL = getActiveConfigSet( origSLModelName );
csArch = attachConfigSetCopy( archModelName, csSL, true );
csToRemove = getActiveConfigSet( archModelName );
setActiveConfigSet( archModelName, csArch.Name );
detachConfigSet( archModelName, csToRemove.Name );
csArch.Name = csSL.Name;

end

function beautifyAllLevels( sys )

if ~strcmp( get_param( sys, 'SimulinkSubDomain' ), 'ArchitectureAdapter' ) && ~strcmp( get_param( sys, 'SimulinkSubDomain' ), 'Simulink' )


    open_system( sys );
    doBeautify(  );
end

ss = find_system( sys, 'SearchDepth', 1, 'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'SubSystem' );
for idx = 1:length( ss )
    if ~isequal( get_param( ss{ idx }, 'handle' ), get_param( sys, 'handle' ) )
        beautifyAllLevels( ss{ idx } );
    end
end

    function doBeautify(  )

        lineHandles = find_system( sys, 'MatchFilter', @Simulink.match.allVariants, 'FindAll', 'On', 'SearchDepth', 1, 'Type', 'Line' );
        Simulink.BlockDiagram.routeLine( lineHandles );


        editor = GLUE2.Util.findAllEditors( sys );
        if ~isempty( editor )
            SLM3I.Util.fitSystemBox( editor );
        end
        set_param( sys, 'ZoomFactor', 'FitToView' );
    end
end

function cleanupTempModel( mdl, fileExt )
close_system( mdl, 0 );
currDir = pwd;
cdCleanup = onCleanup( @(  )cd( currDir ) );
cd( tempdir );
delete( [ mdl, fileExt ] );
end

function newBlockHdl = convertSLSubsystemToAdapter( srcBlk, targetbd, targetBlk )
ssToAdapterConv = systemcomposer.internal.SLSubsystemToAdapterConverter( srcBlk, targetbd, targetBlk );
newBlockHdl = ssToAdapterConv.newBlockHdl;
delete( ssToAdapterConv );
end

function doShowProgress( dlg, status, value )
arguments
    dlg handle
    status char = ''
    value int32 =  - 1
end

if ~isempty( status )
    dlg.setStatus( status );
end
if value >= 0
    dlg.setValue( value );
end
dlg.show(  );
end

function doNotShowProgress( ~, ~, ~ )
end

function pi = getOrMakeInterface( dict, dtype )
pi = getInterface( dict, dtype );

if isempty( pi )
    bo = evalin( 'base', dtype );
    pi = addInterface( dict, dtype, 'SimulinkBus', bo );


    for elem = bo.Elements'
        if contains( elem.DataType, 'Bus: ' )
            boName = strrep( elem.DataType, 'Bus: ', '' );
            getOrMakeInterface( dict, boName );
        end
    end
end
end

function archSrcPort = getSourceConnectionPortInComposition( srcBlkPath, currPortConn, zcMdl )
archSrcPort = systemcomposer.arch.ComponentPort.empty;
archSrcComponent = zcMdl.lookup( 'Path', srcBlkPath );
if strcmpi( get_param( currPortConn.SrcBlock, 'BlockType' ), 'PMIOPort' )
    if ~isempty( archSrcComponent )
        archSrcPort = findobj( archSrcComponent.Ports, 'Name', get_param( currPortConn.SrcBlock, 'Name' ) );
        if isa( archSrcPort, 'systemcomposer.arch.ComponentPort' )
            archSrcPort = archSrcPort.ArchitecturePort;
        end
    end
else
    try
        archSrcComponent = zcMdl.lookup( 'Path', [ srcBlkPath, '/', get_param( currPortConn.SrcBlock, 'Name' ) ] );
        if ~isempty( archSrcComponent )
            portHandles = get_param( archSrcComponent.SimulinkHandle, 'PortHandles' );
            otherPortHandles = get_param( currPortConn.SrcBlock, 'PortHandles' );
            isLConn = any( arrayfun( @( x )isequal( x, currPortConn.SrcPort ), otherPortHandles.LConn ) );
            if isLConn
                prtHandle = portHandles.LConn( get_param( currPortConn.SrcPort, 'PortNumber' ) );
            else
                prtHandle = portHandles.RConn( get_param( currPortConn.SrcPort, 'PortNumber' ) );
            end
            archSrcPort = findobj( archSrcComponent.Ports, 'SimulinkHandle', prtHandle );
        end
    catch

    end
end
end

function archDstPort = getDestinationConnectionPortInComposition( dstBlkPath, currPortConn, zcMdl )
archDstPort = systemcomposer.arch.ComponentPort.empty;
archDstComponent = zcMdl.lookup( 'Path', dstBlkPath );
for i = 1:numel( currPortConn.DstBlock )
    if strcmpi( get_param( currPortConn.DstBlock( i ), 'BlockType' ), 'PMIOPort' )
        if ~isempty( archDstComponent )
            archDstPort = findobj( archDstComponent.Ports, 'Name', get_param( currPortConn.DstBlock( i ), 'Name' ) );
            if isa( archDstPort, 'systemcomposer.arch.ComponentPort' )
                archDstPort = archDstPort.ArchitecturePort;
                break ;
            end
        end
    else
        try
            archDstComponent = zcMdl.lookup( 'Path', [ dstBlkPath, '/', get_param( currPortConn.DstBlock( i ), 'Name' ) ] );
            if ~isempty( archDstComponent )
                portHandles = get_param( archDstComponent.SimulinkHandle, 'PortHandles' );
                otherPortHandles = get_param( currPortConn.DstBlock( i ), 'PortHandles' );
                isLConn = any( arrayfun( @( x )isequal( x, currPortConn.DstPort( i ) ), otherPortHandles.LConn ) );
                if isLConn
                    prtHandle = portHandles.LConn( get_param( currPortConn.DstPort( i ), 'PortNumber' ) );
                else
                    prtHandle = portHandles.RConn( get_param( currPortConn.DstPort( i ), 'PortNumber' ) );
                end
                archDstPort = findobj( archDstComponent.Ports, 'SimulinkHandle', prtHandle );
                if ~isempty( archDstPort )
                    break ;
                end
            end
        catch

        end
    end
end
end


% Decoded using De-pcode utility v1.2 from file /tmp/tmpcCNXID.p.
% Please follow local copyright laws when handling this file.

