function conjugatePort( archPort )

arguments
    archPort{ mustBeA( archPort, 'systemcomposer.arch.ArchitecturePort' ) }
end
aPortImpl = archPort.getImpl;
cPortImpl = aPortImpl.getParentComponentPort;
isRootPort = isempty( cPortImpl );
if ~isRootPort
    compPort = systemcomposer.internal.getWrapperForImpl( cPortImpl );
    cPortHdl = compPort.SimulinkHandle;
end
newPortAction = [  ];
portHdls = archPort.SimulinkHandle;
[ newPortAction, newPortBlockName ] = systemcomposer.internal.getConjugatePortAction( archPort );
assert( ~isempty( newPortAction ) );



modelName = bdroot( portHdls( 1 ) );
bdH = get_param( modelName, 'Handle' );
archPluginTxn = systemcomposer.internal.arch.internal.ArchitecturePluginTransaction( modelName );


portUUID = archPort.UUID;
bridgeData = get_param( modelName, 'SimulinkArchBridgeData' );
bridgeData.removeElemPairForUUID( portUUID );
for portHdl = portHdls
    bridgeData.removeBlockHandleSIDPairByHandle( portHdl );
end


import systemcomposer.internal.arch.internal.ZCUtils
for idx = 1:length( portHdls )
    blkFullNames{ idx } = getfullname( portHdls( idx ) );
    blockParams{ idx } = systemcomposer.internal.arch.internal.ZCUtils.getBlockParams( portHdls( idx ) );
end

if ~isRootPort
    portLocation = Simulink.PortPlacement.getPortLocation( cPortHdl, "WORLD" );
end

hasInterface = ~isempty( archPort.Interface );
for idx = 1:length( portHdls )
    portInfo = systemcomposer.AnonymousInterfaceManager.GetSLPortInfo( portHdls( idx ) );
    portIntfInfos( idx ) = portInfo;
end
slreq.utils.onHierarchyChange( 'prechange', bdH );




idx = 1;
newBlockH = add_block( [ 'simulink/Ports & Subsystems/', newPortBlockName ],  ...
    blkFullNames{ idx }, 'MakeNameUnique', 'on',  ...
    'CreateNewPort', 'on' );
sidspace = get_param( bdroot( newBlockH ), 'SIDSpace' );
sidspace.swapSID( portHdls( idx ), newBlockH );
delete_block( portHdls( idx ) );
newBlockHs( idx ) = newBlockH;


for idx = 2:length( blkFullNames )
    newBlockH = add_block( newBlockHs( 1 ),  ...
        blkFullNames{ idx }, 'MakeNameUnique', 'on',  ...
        'CreateNewPort', 'off' );
    sidspace = get_param( bdroot( newBlockH ), 'SIDSpace' );
    sidspace.swapSID( portHdls( idx ), newBlockH );
    delete_block( portHdls( idx ) );
    newBlockHs( idx ) = newBlockH;
end


slreq.utils.onHierarchyChange( 'postchange', bdH );

for idx = 1:length( newBlockHs )
    systemcomposer.internal.arch.internal.ZCUtils.restoreBlockParams(  ...
        newBlockHs( idx ), blockParams{ idx } )
end


aPortImpl.setPortAction( newPortAction );
if ~isRootPort
    cPortImpl.setPortAction( newPortAction );
end


shouldSerializePortElemPair = ~systemcomposer.internal.isSubsystemReferenceComponent(  ...
    archPort.Parent.SimulinkHandle );
for newBlockH = newBlockHs
    newBlockSID = get_param( newBlockH, 'SID' );
    bridgeData.addBlockHandleSIDPair( newBlockH, newBlockSID );
    bridgeData.addSimulinkArchitectureElemPair( newBlockSID, aPortImpl.UUID, shouldSerializePortElemPair );
end



if ~isRootPort
    Simulink.PortPlacement.setPortLocation( compPort.SimulinkHandle, portLocation, "WORLD" );
end


delete( archPluginTxn );



if hasInterface
    interface = archPort.Interface;
    if isa( interface.Owner, 'systemcomposer.interface.Dictionary' )


        systemcomposer.BusObjectManager.SetPortInterface( aPortImpl, interface.Name, class( interface ) );
    else
        switch class( interface )
            case 'systemcomposer.interface.DataInterface'
                for idx = 1:length( portIntfInfos )
                    systemcomposer.AnonymousInterfaceManager.SetBusPortInfo( newBlockHs( idx ), portIntfInfos( idx ) );
                end
            case 'systemcomposer.ValueType'

                assert( length( portIntfInfos ) == 1 && length( newBlockHs ) == 1, "Incorrect number of port interface information for value type!" );
                systemcomposer.AnonymousInterfaceManager.SetBusPortInfo( newBlockHs, portIntfInfos );
            otherwise
                error( 'Unsupported interface type of "%s" for port "%s" on component "%s".', class( interface ), archPort.Name, get( archPort.Parent, 'Name' ) );
        end
    end
end
systemcomposer.internal.arch.internal.processBatchedPluginEvents( modelName );
end

