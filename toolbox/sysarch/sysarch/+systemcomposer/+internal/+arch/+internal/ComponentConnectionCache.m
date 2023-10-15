classdef ComponentConnectionCache

    properties
        bridgeData;
        compSID;
        isArchOwnedByComp;
        inputPortInfo;
        outputPortInfo;
        physicalPortInfo;
        selfConnInfo;
    end

    methods ( Static, Hidden )

        function portInfo = createPortInfo( port, getConnected )
            arguments
                port
                getConnected = true;
            end
            portInfo.Name = port.getName;
            portInfo.CompName = systemcomposer.internal.arch.internal.ComponentConnectionCache.getComponentNameForPort( port );
            portInfo.PortAction = port.getPortAction;
            portInfo.PortNum = systemcomposer.internal.arch.internal.ComponentConnectionCache.getPortNumberForPort( port );
            if ( port.isComponentPort )
                if port.getComponent.isSubsystemReferenceComponent
                    portHandle = systemcomposer.utils.getSimulinkPeer( port.getOwnedArchitecturePort );
                else
                    portHandle = systemcomposer.utils.getSimulinkPeer( port.getArchitecturePort );
                end
                portInfo.PortSID = get_param( portHandle, 'SID' );
                portInfo.PortBlockName = '';
            else
                portHandle = systemcomposer.utils.getSimulinkPeer( port );
                portInfo.PortSID = get_param( portHandle, 'SID' );

                portInfo.PortBlockName = get_param( portHandle, 'Name' );
            end
            portInfo.PortHandle = portHandle;

            if strcmp( portInfo.PortAction, 'PHYSICAL' )
                if strcmp( get_param( portInfo.PortHandle, 'Side' ), 'Right' )
                    portInfo.PortSide = 'RConn';
                else
                    portInfo.PortSide = 'LConn';
                end
            end
            portInfo.LineProperties =  ...
                systemcomposer.internal.arch.internal.ComponentConnectionCache.getLineProperties(  ...
                systemcomposer.utils.getSimulinkPeer( port ),  ...
                strcmp( portInfo.PortAction, 'PHYSICAL' ) );


            if ( getConnected )
                connectedPorts = port.getConnectedPorts;
                portInfo.ConnectedPortInfo = [  ];
                for i = 1:numel( connectedPorts )
                    if ( port.isComponentPort && connectedPorts( i ).isComponentPort )
                        if isempty( connectedPorts( i ).p_Redefines )
                            portInfo.ConnectedPortInfo = [ portInfo.ConnectedPortInfo,  ...
                                systemcomposer.internal.arch.internal.ComponentConnectionCache.createPortInfo( connectedPorts( i ), false ) ];
                        end
                    else

                        portInfo.ConnectedPortInfo = [ portInfo.ConnectedPortInfo,  ...
                            systemcomposer.internal.arch.internal.ComponentConnectionCache.createPortInfo( connectedPorts( i ), false ) ];



                        if ( numel( portInfo.ConnectedPortInfo.PortHandle ) > 1 )



                            for idx = 1:numel( portInfo.ConnectedPortInfo.PortHandle )
                                lineHdl = get_param( portInfo.ConnectedPortInfo.PortHandle( idx ), 'LineHandles' );
                                portHdl =  - 1;
                                if ( port.getPortAction == systemcomposer.internal.arch.REQUEST ||  ...
                                        port.getPortAction == systemcomposer.architecture.model.core.PortAction.CLIENT )
                                    if ishandle( lineHdl.Outport )
                                        portHdl = get_param( lineHdl.Outport, 'DstPortHandle' );
                                    end
                                else
                                    if ishandle( lineHdl.Inport )
                                        portHdl = get_param( lineHdl.Inport, 'srcPortHandle' );
                                    end
                                end
                                if ishandle( portHdl )
                                    portNum = get_param( portHdl, 'PortNumber' );
                                    blkName = get_param( get_param( portHdl, 'Parent' ), 'Name' );
                                    if ( portNum == portInfo.PortNum && strcmp( blkName, portInfo.CompName ) )

                                        portInfo.ConnectedPortInfo.BusElementIndex = idx;
                                        break ;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        function compName = getComponentNameForPort( port )
            if ( port.isComponentPort )
                compName = port.getComponent.getName;
            else
                compName = '';
            end
        end

        function portNum = getPortNumberForPort( port )
            portHandle = systemcomposer.utils.getSimulinkPeer( port );
            if ( port.isComponentPort )
                portNum = get_param( portHandle, 'PortNumber' );
            else
                portNum = str2double( get_param( portHandle, 'Port' ) );
            end
        end

        function portName = getPortNameForAddLine( port )
            if ( isempty( port.CompName ) )

                if strcmp( port.PortAction, 'PHYSICAL' )




                    portName = [ port.PortBlockName, '/RConn1' ];
                elseif ~isfield( port, 'BusElementIndex' ) || isempty( port.BusElementIndex )
                    portName = [ port.PortBlockName, '/1' ];
                else

                    idx = port.BusElementIndex;
                    portName = [ port.PortBlockName{ idx }, '/1' ];
                end
            else


                compName = strrep( port.CompName, '/', '//' );
                if strcmp( port.PortAction, 'PHYSICAL' )
                    portName = [ compName, '/', port.PortSide, num2str( port.PortNum ) ];
                else
                    portName = [ compName, '/', num2str( port.PortNum ) ];
                end
            end
        end
    end

    methods ( Static, Access = private )
        function cachedLineInfo = getLineProperties( portHandle, isPhysical )


            cachedLineInfo = [  ];



            if strcmp( get_param( portHandle, 'Type' ), 'block' )
                return ;
            end


            lineH = get_param( portHandle, 'Line' );

            if lineH ==  - 1

                return ;
            end

            lineParams = get_param( lineH, 'ObjectParameters' );
            rawParamNames = fieldnames( lineParams );
            cachedLineInfo = {  };
            for idx = 1:length( rawParamNames )
                thisPrm = rawParamNames{ idx };
                isReadWrite = any( strcmp( 'read-write', lineParams.( thisPrm ).Attributes ) );
                isListType = strcmp( lineParams.( thisPrm ).Type, 'list' );
                isPoints = strcmpi( thisPrm, 'Points' );
                if isPoints

                    if ~isPhysical
                        cachedLineInfo{ end  + 1 } = thisPrm;%#ok<AGROW>
                        cachedLineInfo{ end  + 1 } = get_param( lineH, thisPrm );%#ok<AGROW>
                    end
                elseif isReadWrite && ~isListType

                    cachedLineInfo{ end  + 1 } = thisPrm;%#ok<AGROW>
                    cachedLineInfo{ end  + 1 } = get_param( lineH, thisPrm );%#ok<AGROW>
                end
            end
        end
    end

    methods ( Access = private )
        function shouldSkip = alreadyConnected( obj, srcPort, dstPort )
            shouldSkip = false;
            for info = obj.selfConnInfo
                if strcmp( info.srcPort, srcPort ) && strcmp( info.dstPort, dstPort )
                    shouldSkip = true;
                    break ;
                end
            end
        end
    end

    methods
        function obj = ComponentConnectionCache( blkHandle )



            bdH = bdroot( blkHandle );
            obj.bridgeData = get_param( bdH, 'SimulinkArchBridgeData' );


            comp = systemcomposer.utils.getArchitecturePeer( blkHandle );
            obj.compSID = get_param( blkHandle, 'SID' );

            isBehaviorArch = ~comp.hasReferencedArchitecture &&  ...
                comp.getArchitecture.StaticMetaClass.isA(  ...
                systemcomposer.architecture.model.design.BehaviorArchitecture.StaticMetaClass );

            obj.isArchOwnedByComp = comp.hasOwnedArchitecture;



            if isBehaviorArch
                paramName = comp.getArchitecture.getProxyBlockUserFileParameterName;

                if ( ~isempty( paramName ) && exist( get_param( blkHandle, paramName ), 'file' ) ~= 4 )
                    return ;
                end
            else
                if comp.hasReferencedArchitecture

                    filename = systemcomposer.internal.getReferenceName( blkHandle );


                    if ( exist( filename, 'file' ) ~= 4 )
                        return
                    end
                end
            end


            compPorts = comp.getPorts;
            obj.inputPortInfo = [  ];
            obj.outputPortInfo = [  ];
            obj.physicalPortInfo = [  ];
            obj.selfConnInfo = [  ];
            for i = 1:numel( compPorts )
                if ( compPorts( i ).getPortAction == systemcomposer.internal.arch.REQUEST ||  ...
                        compPorts( i ).getPortAction == systemcomposer.architecture.model.core.PortAction.CLIENT )
                    portInfo = systemcomposer.internal.arch.internal.ComponentConnectionCache.createPortInfo( compPorts( i ) );
                    obj.inputPortInfo = [ obj.inputPortInfo, portInfo ];
                elseif ( compPorts( i ).getPortAction == systemcomposer.internal.arch.PROVIDE ||  ...
                        compPorts( i ).getPortAction == systemcomposer.architecture.model.core.PortAction.SERVER )
                    portInfo = systemcomposer.internal.arch.internal.ComponentConnectionCache.createPortInfo( compPorts( i ) );
                    obj.outputPortInfo = [ obj.outputPortInfo, portInfo ];
                else
                    assert( compPorts( i ).getPortAction == systemcomposer.internal.arch.PHYSICAL )
                    portInfo = systemcomposer.internal.arch.internal.ComponentConnectionCache.createPortInfo( compPorts( i ) );
                    obj.physicalPortInfo = [ obj.physicalPortInfo, portInfo ];
                end
            end
        end

        function restoreComponentSIDBridgeMapping( obj, newBlkHandle )
            mdlSID = get_param( newBlkHandle, 'SID' );
            obj.bridgeData.updateBridgeDataMap( obj.compSID, mdlSID, newBlkHandle );
        end

        function removeCachedPortsFromBridgeMap( obj )



            if ~obj.isArchOwnedByComp
                return ;
            end

            for idx = 1:numel( obj.inputPortInfo )
                portSIDs = string( obj.inputPortInfo( idx ).PortSID );
                for locIdx = 1:numel( portSIDs )
                    obj.bridgeData.removeBlockHandleSIDPairBySID( portSIDs( locIdx ) );
                    obj.bridgeData.removeElemPairForSID( portSIDs( locIdx ) );
                end
            end
            for idx = 1:numel( obj.outputPortInfo )
                portSIDs = string( obj.outputPortInfo( idx ).PortSID );
                for locIdx = 1:numel( portSIDs )
                    obj.bridgeData.removeBlockHandleSIDPairBySID( portSIDs( locIdx ) );
                    obj.bridgeData.removeElemPairForSID( portSIDs( locIdx ) );
                end
            end
            for idx = 1:numel( obj.physicalPortInfo )
                portSIDs = string( obj.physicalPortInfo( idx ).PortSID );
                for locIdx = 1:numel( portSIDs )
                    obj.bridgeData.removeBlockHandleSIDPairBySID( portSIDs( locIdx ) );
                    obj.bridgeData.removeElemPairForSID( portSIDs( locIdx ) );
                end
            end
        end

        function recreateConnectionsBetweenCachedPorts( obj, newComp )




            lines = [  ];
            for i = 1:numel( obj.inputPortInfo )


                port = newComp.getPort( obj.inputPortInfo( i ).Name );
                if ( ~isempty( port ) && ( port.getPortAction == systemcomposer.internal.arch.REQUEST ||  ...
                        port.getPortAction == systemcomposer.architecture.model.core.PortAction.CLIENT ) )


                    if ( numel( obj.inputPortInfo( i ).ConnectedPortInfo ) > 0 )
                        connectedPort = obj.inputPortInfo( i ).ConnectedPortInfo( 1 );

                        srcPort = systemcomposer.internal.arch.internal.ComponentConnectionCache.getPortNameForAddLine( connectedPort );
                        portInfo = systemcomposer.internal.arch.internal.ComponentConnectionCache.createPortInfo( port, false );
                        dstPort = systemcomposer.internal.arch.internal.ComponentConnectionCache.getPortNameForAddLine( portInfo );



                        if newComp.getParentArchitecture.hasParentComponent
                            sysName = newComp.getParentArchitecture.getParentComponent.getQualifiedName;
                        else
                            sysName = newComp.getParentArchitecture.getName;
                        end
                        lineH = add_line( sysName, srcPort, dstPort );
                        lines = [ lines;lineH ];%#ok<AGROW>
                        set_param( lineH, obj.inputPortInfo( i ).LineProperties{ : } );
                    end
                end
            end

            for i = 1:numel( obj.outputPortInfo )


                port = newComp.getPort( obj.outputPortInfo( i ).Name );
                if ( ~isempty( port ) && ( port.getPortAction == systemcomposer.internal.arch.PROVIDE ||  ...
                        port.getPortAction == systemcomposer.architecture.model.core.PortAction.SERVER ) )


                    connectedPorts = obj.outputPortInfo( i ).ConnectedPortInfo;
                    for j = 1:numel( connectedPorts )

                        portInfo = systemcomposer.internal.arch.internal.ComponentConnectionCache.createPortInfo( port, false );
                        srcPort = systemcomposer.internal.arch.internal.ComponentConnectionCache.getPortNameForAddLine( portInfo );
                        dstPort = systemcomposer.internal.arch.internal.ComponentConnectionCache.getPortNameForAddLine( connectedPorts( j ) );


                        if strcmp( obj.outputPortInfo( i ).CompName, connectedPorts( j ).CompName )
                            continue ;
                        end



                        if newComp.getParentArchitecture.hasParentComponent
                            sysName = newComp.getParentArchitecture.getParentComponent.getQualifiedName;
                        else
                            sysName = newComp.getParentArchitecture.getName;
                        end
                        lineH = add_line( sysName, srcPort, dstPort );
                        lines = [ lines;lineH ];%#ok<AGROW>
                        set_param( lineH, obj.outputPortInfo( i ).LineProperties{ : } );
                    end
                end
            end

            for i = 1:numel( obj.physicalPortInfo )


                port = newComp.getPort( obj.physicalPortInfo( i ).Name );
                if ( ~isempty( port ) && port.getPortAction == systemcomposer.architecture.model.core.PortAction.PHYSICAL )



                    connectedPorts = obj.physicalPortInfo( i ).ConnectedPortInfo;
                    for j = 1:numel( connectedPorts )


                        portInfo = systemcomposer.internal.arch.internal.ComponentConnectionCache.createPortInfo( port, false );
                        srcPort = systemcomposer.internal.arch.internal.ComponentConnectionCache.getPortNameForAddLine( portInfo );
                        dstPort = systemcomposer.internal.arch.internal.ComponentConnectionCache.getPortNameForAddLine( connectedPorts( j ) );



                        if ~isa( port, 'systemcomposer.architecture.model.design.ComponentPort' )

                            continue ;
                        end
                        comp = port.getComponent;
                        portConn = get_param( comp.getQualifiedName, 'PortConnectivity' );
                        portHandles = get_param( comp.getQualifiedName, 'PortHandles' );
                        allPorts = [ portHandles.Inport, portHandles.Enable,  ...
                            portHandles.Trigger, portHandles.Ifaction,  ...
                            portHandles.Reset, portHandles.Outport,  ...
                            portHandles.State, portHandles.LConn,  ...
                            portHandles.RConn ];
                        portHdl = systemcomposer.utils.getSimulinkPeer( port );
                        portIdx = allPorts == portHdl;
                        dstPorts = portConn( portIdx ).DstPort;
                        dstCompNames = arrayfun( @( x )get_param( x, 'Parent' ), dstPorts, 'UniformOutput', false );
                        dstPortConns = cellfun( @( x )get_param( x, 'PortConnectivity' ), dstCompNames, 'UniformOutput', false );
                        dstConnPorts = cellfun( @( x )x.DstPort, dstPortConns, 'UniformOutput', false );
                        isAnyBranchConnected = any( find( cellfun( @( x )any( x == portHdl ), dstConnPorts ) ) );



                        if obj.alreadyConnected( srcPort, dstPort ) || isAnyBranchConnected
                            continue ;
                        end



                        if newComp.getParentArchitecture.hasParentComponent
                            sysName = newComp.getParentArchitecture.getParentComponent.getQualifiedName;
                        else
                            sysName = newComp.getParentArchitecture.getName;
                        end



                        lineH = add_line( sysName, srcPort, dstPort, 'autorouting', 'smart' );


                        lines = [ lines;lineH ];%#ok<AGROW>
                        set_param( lineH, obj.physicalPortInfo( i ).LineProperties{ : } );



                        if strcmp( connectedPorts( j ).CompName, obj.physicalPortInfo( i ).CompName )
                            info.srcPort = dstPort;
                            info.dstPort = srcPort;
                            obj.selfConnInfo = [ obj.selfConnInfo, info ];
                        end
                    end
                end
            end



            if ~systemcomposer.internal.saveAndLink.SaveAndLinkDialog.isConversionActive(  )
                Simulink.BlockDiagram.routeLine( lines );
            end
        end
    end
end


