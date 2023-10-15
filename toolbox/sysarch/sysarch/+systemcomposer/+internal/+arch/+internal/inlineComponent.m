function [ modelBlockHdls ] = inlineComponent( blocks, inlineAll, varargin )





try
    if nargin > 2
        f = varargin{ 1 };
    end

    modelBlockHdls = zeros( 1, numel( blocks ) );
    for i = 1:numel( blocks )
        block = blocks( i );
        if isnumeric( block )

            blockHandle = block;
            if nargin > 2
                waitbar( i / ( numel( blocks ) + 1 ), f, message( 'SystemArchitecture:studio:Inlining' ).string );
            end


            [ ComponentBlockType, ~, ~, ~ ] = systemcomposer.internal.validator.getComponentBlockType( blockHandle );

            switch class( ComponentBlockType )
                case 'systemcomposer.internal.validator.ProtectedModelBehavior'
                    modelBlockHdls( i ) = processProtectedComp( blockHandle );
                case 'systemcomposer.internal.validator.Stateflow'
                    modelBlockHdls( i ) = processStateflowBehaviorComp( blockHandle );
                case 'systemcomposer.internal.validator.SubsystemInlinedBehavior'
                    modelBlockHdls( i ) = process( blockHandle, inlineAll, false );
                case 'systemcomposer.internal.validator.SubsystemReferenceBehavior'
                    modelBlockHdls( i ) = process( blockHandle, inlineAll, false );
                otherwise
                    modelBlockHdls( i ) = process( blockHandle, inlineAll );
            end
            slreq.utils.onHierarchyChange( 'postchange', get_param( bdroot( modelBlockHdls( i ) ), 'Handle' ) );
        else
            error( 'Invalid Input' );
        end
    end

catch ME
    rethrow( ME );
end

end

function newBlockHandle = process( blockHandle, inlineAll, copyFromBlockDiagram )
arguments
    blockHandle;
    inlineAll;
    copyFromBlockDiagram = true;
end

bdH = bdroot( blockHandle );

systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdH );


cache = systemcomposer.internal.arch.internal.ComponentConnectionCache( blockHandle );

bOrigFullName = getfullname( blockHandle );
bOrigName = get_param( blockHandle, 'Name' );

bPosition = get_param( blockHandle, 'Position' );

bPortSchema = get_param( blockHandle, 'PortSchema' );


previousName = get_param( blockHandle, 'Name' );
set_param( blockHandle, 'Name', [ 'Reserved_TmpNameForRename_', previousName ] );

mdlH =  - 1;
if copyFromBlockDiagram

    mdlH = load_system( systemcomposer.internal.getReferenceName( blockHandle ) );

    if ( strcmpi( get_param( mdlH, 'SimulinkSubdomain' ), 'Simulink' ) )
        inlineAll = false;
    end
    handleToCopyFrom = mdlH;
else

    inlineAll = false;
    handleToCopyFrom = blockHandle;
end


systemcomposer.internal.arch.internal.ZCUtils.DeleteConnectedLines( blockHandle );



systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdH );

newBlockHandle = add_block( 'built-in/Subsystem', bOrigFullName );
bFullName = getfullname( newBlockHandle );
systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdH );



if copyFromBlockDiagram
    systemcomposer.internal.arch.internal.importProfilesAndCopyStereotypes( mdlH, newBlockHandle );
else


    zcModel = get_param( bdH, 'SystemComposerModel' );
    srcComp = zcModel.lookup( 'SimulinkHandle', blockHandle );
    dstComp = zcModel.lookup( 'SimulinkHandle', newBlockHandle );

    srcArch.modelName = get_param( bdH, 'Name' );
    if systemcomposer.internal.isSubsystemReferenceComponent( blockHandle )
        srcArch.UUID = srcComp.OwnedArchitecture.UUID;
    else
        srcArch.UUID = srcComp.Architecture.UUID;
    end
    dstArch.modelName = get_param( bdH, 'Name' );
    dstArch.UUID = dstComp.Architecture.UUID;

    systemcomposer.internal.arch.internal.importProfilesAndCopyStereotypes( srcArch, dstArch );
end

if inlineAll

    txn = systemcomposer.internal.SubdomainBlockValidationSuspendTransaction( bdroot( newBlockHandle ) );
    ddTxn = systemcomposer.internal.DragDropTransaction(  );
    Simulink.BlockDiagram.copyContentsToSubsystem( mdlH, newBlockHandle );
    isSWArch = Simulink.internal.isArchitectureModel( handleToCopyFrom, 'SoftwareArchitecture' ) ||  ...
        ( Simulink.internal.isArchitectureModel( handleToCopyFrom, 'AUTOSARArchitecture' ) &&  ...
        ( slfeature( 'SoftwareModelingAutosar' ) > 0 || slfeature( 'FunctionsModelingAutosar' ) ) );

    if isSWArch
        rootArch = systemcomposer.utils.getArchitecturePeer( bdH );
        inlinedComp = systemcomposer.utils.getArchitecturePeer( blockHandle );
        partTrait = rootArch.getTrait( systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass );
        rootFcns = partTrait.getFunctionsOfType( systemcomposer.architecture.model.swarch.FunctionType.OSFunction );










        fcnToCalledParentHandle = [  ];
        for i = 1:numel( rootFcns )
            rootFcn = rootFcns( i );








            if rootFcn.calledFunctionParent ~= inlinedComp
                continue ;
            end



            fcnBeingRemoved = rootFcn.calledFunction;
            compFcnName = fcnBeingRemoved.calledFunctionName;

            oldComp = fcnBeingRemoved.calledFunctionParent;
            newCompH = Simulink.SystemArchitecture.internal.ApplicationManager.getDroppedBlockHandle(  ...
                systemcomposer.utils.getSimulinkPeer( oldComp ) );

            fcnPeriod = '-1';
            fcnCallInport = swarch.utils.getFcnCallInport( fcnBeingRemoved );
            if ~isempty( fcnCallInport ) && strcmp( fcnBeingRemoved.period, get_param( fcnCallInport, 'SampleTime' ) )


                fcnPeriod = fcnBeingRemoved.period;
            end

            fcnToCalledParentHandle = [ fcnToCalledParentHandle ...
                , struct( 'Function', rootFcn,  ...
                'CalledFunction', compFcnName,  ...
                'ParentHandle', newCompH,  ...
                'Period', fcnPeriod ) ];%#ok<AGROW>
        end
    end

    ddTxn.commit(  );

    if isSWArch






        delete_block( find_system( newBlockHandle, 'SearchDepth', 1,  ...
            'BlockType', 'Inport', 'OutputFunctionCall', 'on' ) );


        mf0Txn = mf.zero.getModel( rootArch ).beginTransaction(  );
        for i = 1:numel( fcnToCalledParentHandle )
            fcnInfo = fcnToCalledParentHandle( i );
            rootFcn = fcnInfo.Function;

            rootFcn.calledFunctionParent = systemcomposer.utils.getArchitecturePeer( fcnInfo.ParentHandle );
            rootFcn.calledFunctionName = fcnInfo.CalledFunction;
            if ~strcmp( fcnInfo.Period, '-1' )
                swarch.utils.setFunctionAndRootInportBlockPeriod( rootFcn, fcnInfo.Period );
            end
        end
        mf0Txn.commit(  );
    end

    txn.commit(  );
else


    oldInports = find_system( handleToCopyFrom, 'SearchDepth', 1, 'BlockType', 'Inport' );
    oldOutports = find_system( handleToCopyFrom, 'SearchDepth', 1, 'BlockType', 'Outport' );
    for idx = 1:numel( oldInports )

        isFcnCallPort = strcmp( get_param( oldInports( idx ), 'OutputFunctionCall' ), 'on' );
        if isFcnCallPort
            continue ;
        end


        isComposite = strcmp( get_param( oldInports( idx ), 'isComposite' ), 'on' );
        portName = get_param( oldInports( idx ), 'name' );
        fullPortName = [ bFullName, '/', portName ];
        if isComposite

            ddTxn = systemcomposer.internal.DragDropTransaction(  );
            add_block( oldInports( idx ), fullPortName );
            ddTxn.commit(  );
        else


            bepH = add_block( 'simulink/Ports & Subsystems/In Bus Element',  ...
                [ bFullName, '/Bus Element In1' ],  ...
                'MakeNameUnique', 'on',  ...
                'CreateNewPort', 'on',  ...
                'PortName', portName,  ...
                'Element', '' );
            systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( bepH ) );
            syncPortProperties( bepH, oldInports( idx ) );
        end
    end

    for idx = 1:numel( oldOutports )
        isComposite = strcmp( get_param( oldOutports( idx ), 'isComposite' ), 'on' );
        portName = get_param( oldOutports( idx ), 'name' );
        fullPortName = [ bFullName, '/', portName ];
        if isComposite

            ddTxn = systemcomposer.internal.DragDropTransaction(  );
            add_block( oldOutports( idx ), fullPortName );
            ddTxn.commit(  );
        else


            bepH = add_block( 'simulink/Ports & Subsystems/Out Bus Element',  ...
                [ bFullName, '/Bus Element Out1' ],  ...
                'MakeNameUnique', 'on',  ...
                'CreateNewPort', 'on',  ...
                'PortName', portName,  ...
                'Element', '' );
            systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( bepH ) );
            syncPortProperties( bepH, oldOutports( idx ) );
        end
    end


    if ~copyFromBlockDiagram
        oldPhysicalPorts = find_system( handleToCopyFrom, 'SearchDepth', 1, 'BlockType', 'PMIOPort' );
        for idx = 1:numel( oldPhysicalPorts )
            portName = get_param( oldPhysicalPorts( idx ), 'name' );
            fullPortName = [ bFullName, '/', portName ];

            ddTxn = systemcomposer.internal.DragDropTransaction(  );
            add_block( oldPhysicalPorts( idx ), fullPortName );
            ddTxn.commit(  );
        end
    end
end



systemcomposer.internal.arch.internal.importParameters( blockHandle, newBlockHandle, inlineAll );


systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdH );


locUpdatePortRequirementLinks( blockHandle, newBlockHandle );
locUpdateBlockRequirementLinks( blockHandle, newBlockHandle );


delete_block( blockHandle );

systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdH );


comp = systemcomposer.utils.getArchitecturePeer( newBlockHandle );
cache.recreateConnectionsBetweenCachedPorts( comp );


set_param( newBlockHandle, 'PortSchema', bPortSchema );


set_param( newBlockHandle, 'position', bPosition );


set_param( newBlockHandle, 'Name', bOrigName );

systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdH );
end

function newBlkHdl = processProtectedComp( blockHandle )
bdH = bdroot( blockHandle );


modelName = get_param( blockHandle, 'ModelFile' );
mdlInfo = Simulink.MDLInfo( modelName );


cache = systemcomposer.internal.arch.internal.ComponentConnectionCache( blockHandle );

bPosition = get_param( blockHandle, 'Position' );

bPortSchema = get_param( blockHandle, 'PortSchema' );

bFullName = getfullname( blockHandle );


systemcomposer.internal.arch.internal.ZCUtils.DeleteConnectedLines( blockHandle );


previousName = get_param( blockHandle, 'Name' );
set_param( blockHandle, 'Name', [ 'Reserved_TmpNameForRename_', previousName ] );



systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdH );


newBlkHdl = add_block( 'built-in/Subsystem', bFullName );
systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdH );







mdlInports = mdlInfo.Interface.Inports;
mdlOutports = mdlInfo.Interface.Outports;

for idx = 1:numel( mdlInports )

    isFcnCallPort = mdlInports( idx ).OutputFunctionCall;
    if isFcnCallPort
        continue ;
    end



    portName = mdlInports( idx ).Name;
    bepH = add_block( 'simulink/Ports & Subsystems/In Bus Element',  ...
        [ bFullName, '/Bus Element In1' ],  ...
        'MakeNameUnique', 'on',  ...
        'CreateNewPort', 'on',  ...
        'PortName', portName,  ...
        'Element', '' );
    systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( bepH ) );
end

for idx = 1:numel( mdlOutports )


    portName = mdlOutports( idx ).Name;
    bepH = add_block( 'simulink/Ports & Subsystems/Out Bus Element',  ...
        [ bFullName, '/Bus Element Out1' ],  ...
        'MakeNameUnique', 'on',  ...
        'CreateNewPort', 'on',  ...
        'PortName', portName,  ...
        'Element', '' );
    systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( bepH ) );
end

systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdH );


locUpdatePortRequirementLinks( blockHandle, newBlkHdl );
locUpdateBlockRequirementLinks( blockHandle, newBlkHdl );


delete_block( blockHandle );

systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdH );


comp = systemcomposer.utils.getArchitecturePeer( newBlkHdl );
cache.recreateConnectionsBetweenCachedPorts( comp );


set_param( newBlkHdl, 'PortSchema', bPortSchema );


set_param( newBlkHdl, 'position', bPosition );

systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdH );
end

function syncPortProperties( bepH, srcH )


set_param( bepH, 'OutMin', get_param( srcH, 'OutMin' ) );
set_param( bepH, 'OutMax', get_param( srcH, 'OutMax' ) );
set_param( bepH, 'SignalType', get_param( srcH, 'SignalType' ) );
set_param( bepH, 'Unit', get_param( srcH, 'Unit' ) );
set_param( bepH, 'PortDimensions', get_param( srcH, 'PortDimensions' ) );
set_param( bepH, 'OutDataTypeStr', get_param( srcH, 'OutDataTypeStr' ) );


dstPeer = systemcomposer.utils.getArchitecturePeer( bepH );
srcPeer = systemcomposer.utils.getArchitecturePeer( srcH );
for s = srcPeer.getPrototype
    dstPeer.applyPrototype( s.fullyQualifiedName );
end
for u = srcPeer.getPropertySets
    usageToSync = dstPeer.getPropertySet( u.getName );
    for us = usageToSync.properties.toArray
        propQualName = [ u.getName, '.', us.getName ];
        if ~srcPeer.isPropValDefault( propQualName )
            srcVal = srcPeer.getPropVal( propQualName );
            if isempty( srcVal.units )
                srcVal.units = '*';
            end
            dstPeer.setPropVal( propQualName, srcVal.expression, srcVal.units );
        end
    end
end
end

function newblockHandle = processStateflowBehaviorComp( blockHandle )
chartImplToComponentConverter = systemcomposer.internal.arch.internal.ChartImplToComponentConverter( blockHandle );
newblockHandle = chartImplToComponentConverter.convertChartImplToComponent(  );
end

function locUpdatePortRequirementLinks( oldBlockHandle, newBlockHandle )
srcComp = systemcomposer.utils.getArchitecturePeer( oldBlockHandle );
tgtComp = systemcomposer.utils.getArchitecturePeer( newBlockHandle );

srcPorts = srcComp.getPorts;
for i = 1:numel( srcPorts )
    lnk = slreq.outLinks( srcPorts( i ) );
    if ~isempty( lnk )
        tgtPrt = tgtComp.getPort( srcPorts( i ).getName );
        lnk.setSource( systemcomposer.utils.getSimulinkPeer( tgtPrt ) );
    end
    lnk = slreq.inLinks( srcPorts( i ) );
    if ~isempty( lnk )
        tgtPrt = tgtComp.getPort( srcPorts( i ).getName );
        lnk.setDestination( systemcomposer.utils.getSimulinkPeer( tgtPrt ) );
    end
end

end

function locUpdateBlockRequirementLinks( oldBlockHandle, newBlockHandle )

srcLinks = slreq.outLinks( oldBlockHandle );
dstLinks = slreq.inLinks( oldBlockHandle );

for i = 1:numel( srcLinks )
    srcLinks( i ).setSource( newBlockHandle );
end

for i = 1:numel( dstLinks )
    dstLinks( i ).setDestination( newBlockHandle );
end
end


