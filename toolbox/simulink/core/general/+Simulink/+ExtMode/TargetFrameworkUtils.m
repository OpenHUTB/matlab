classdef(Hidden=true)TargetFrameworkUtils<handle




    methods(Static)
        function extModeConnectivity=getActiveExternalModeConnectivity(model,...
            board)




            extModeConnectivity=[];

            cs=getActiveConfigSet(model);
            index=get_param(cs,'ExtModeTransport');
            extModeTrans=Simulink.ExtMode.Transports.getExtModeTransport(cs,index);

            protocolStacks=board.CommunicationProtocolStacks;
            for protocol=protocolStacks
                if isa(protocol,'target.internal.ExternalMode')
                    externalModeConectivities=protocol.Connectivities;
                    for connectivity=externalModeConectivities

                        if strcmp(extModeTrans,connectivity.getTransport)
                            assert(isa(connectivity,'target.internal.XCPExternalModeConnectivity'),...
                            'Expected XCPExternalModeConnectivity');
                            extModeConnectivity=connectivity;
                            return;
                        end
                    end
                end
            end
        end

        function communicationInterface=getBoardCommunicationInterfaceForXCPTransport(board,...
            xcpTransport)


            communicationInterfaceChannel=xcpTransport.getCommunicationInterfaceChannel;
            boardChannels={board.CommunicationInterfaces.Channel};
            communicationInterface=board.CommunicationInterfaces(strcmp(boardChannels,communicationInterfaceChannel));
            if~isscalar(communicationInterface)
                error(message('Simulink:Extmode:InvalidTFCommunicationInterface',...
                xcpTransport.getTransport,...
                board.Name,...
                communicationInterfaceChannel,...
                board.Name));
            end
        end
    end
end
