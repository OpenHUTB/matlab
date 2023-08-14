function elaborateStreamModule(obj,hN,hElab,hChannel,multiRateCountEnable,multiRateCountValue)





    obj.populateExternalPorts(hN,hChannel,hElab);


    obj.populateUserPorts(hN,hChannel,hElab);


    obj.populateAutoPorts(hN,hElab,hChannel);


    networkName=sprintf('%s_%s',hElab.TopNetName,...
    lower(hChannel.ChannelPortLabel));

    hStreamNet=pirelab.createNewNetwork(...
    'PirInstance',hElab.BoardPirInstance,...
    'Network',hN,...
    'Name',networkName...
    );


    hStreamNetSignals=pirelab.addIOPortToNetwork(...
    'Network',hStreamNet,...
    'InportNames',[hChannel.ExtInportNames,hChannel.UserInportNames,hChannel.AutoInportNames],...
    'InportWidths',[hChannel.ExtInportWidths,hChannel.UserInportWidths,hChannel.AutoInportWidths],...
    'InportDimensions',[hChannel.ExtInportDimensions,hChannel.UserInportDimensions,hChannel.AutoInportDimensions],...
    'OutportNames',[hChannel.ExtOutportNames,hChannel.UserOutportNames,hChannel.AutoOutportNames],...
    'OutportWidths',[hChannel.ExtOutportWidths,hChannel.UserOutportWidths,hChannel.AutoOutportWidths],...
    'OutportDimensions',[hChannel.ExtOutportDimensions,hChannel.UserOutportDimensions,hChannel.AutoOutportDimensions]);

    hStreamNetInportSignals=hStreamNetSignals.hInportSignals;
    hStreamNetOutportSignals=hStreamNetSignals.hOutportSignals;


    if hChannel.ChannelDirType==hdlturnkey.IOType.IN
        obj.elaborateStreamSlave(hElab,hChannel,hStreamNet,...
        hStreamNetInportSignals,hStreamNetOutportSignals,multiRateCountEnable,multiRateCountValue);
    else
        obj.elaborateStreamMaster(hElab,hChannel,hStreamNet,...
        hStreamNetInportSignals,hStreamNetOutportSignals,multiRateCountEnable,multiRateCountValue);
    end


    hTopStreamNetInSignals=[hChannel.ExtTopInportSignals,hChannel.UserTopInportSignals{:},hChannel.AutoTopInportSignals{:}];
    hTopStreamNetOutSignals=[hChannel.ExtTopOutportSignals,hChannel.UserTopOutportSignals{:},hChannel.AutoTopOutportSignals{:}];
    pirelab.instantiateNetwork(hN,hStreamNet,hTopStreamNetInSignals,...
    hTopStreamNetOutSignals,sprintf('%s_inst',networkName));


    if obj.isFrameMode||(~hElab.hTurnkey.hD.isMLHDLC&&~hElab.hTurnkey.hD.isMDS...
        &&obj.isFrameToSample)


        hDataPort=hChannel.getDataPort;
        hValidPort=hChannel.getValidPort;

        if(~hElab.hTurnkey.hD.isMLHDLC&&~hElab.hTurnkey.hD.isMDS...
            &&hChannel.isFrameToSample)


            hReadyPort=hChannel.getReadyPort;
        end

        if hChannel.ChannelDirType==hdlturnkey.IOType.IN

            extPortName=hDataPort.PortName;
            top_data_signal=hChannel.UserTopOutportSignals(hChannel.UserOutportList.(extPortName).Index);

            extPortName=hValidPort.PortName;
            top_valid_signal=hChannel.UserTopOutportSignals(hChannel.UserOutportList.(extPortName).Index);
            if(~hElab.hTurnkey.hD.isMLHDLC&&~hElab.hTurnkey.hD.isMDS...
                &&hChannel.isFrameToSample)


                extPortName=hReadyPort.PortName;
                top_ready_signal=hChannel.UserTopInportSignals(hChannel.UserInportList.(extPortName).Index);

                if hDataPort.getAssignedPort.isComplex

                    top_data_signal=pirelab.demuxSignal(hN,top_data_signal{1});
                end
            end

        else

            extPortName=hDataPort.PortName;
            top_data_signal=hChannel.UserTopInportSignals(hChannel.UserInportList.(extPortName).Index);

            extPortName=hValidPort.PortName;
            top_valid_signal=hChannel.UserTopInportSignals(hChannel.UserInportList.(extPortName).Index);

            if(~hElab.hTurnkey.hD.isMLHDLC&&~hElab.hTurnkey.hD.isMDS...
                &&hChannel.isFrameToSample)


                extPortName=hReadyPort.PortName;
                top_ready_signal=hChannel.UserTopOutportSignals(hChannel.UserOutportList.(extPortName).Index);

                if hDataPort.getAssignedPort.isComplex

                    outMux=pirelab.getMuxOnOutput(hN,top_data_signal{1});
                    top_data_signal=outMux.PirInputSignals;
                end
            end

        end

        if(~hElab.hTurnkey.hD.isMLHDLC&&~hElab.hTurnkey.hD.isMDS...
            &&hChannel.isFrameToSample)


            if hDataPort.getAssignedPort.isComplex
                hTopUserSignals={top_data_signal(1),top_data_signal(2),top_valid_signal,top_ready_signal};
            else
                hTopUserSignals={top_data_signal,top_valid_signal,top_ready_signal};
            end
        else
            hTopUserSignals={top_data_signal,top_valid_signal};
        end

        connectFrameInterfacePort(obj,hN,hElab,hChannel.getDataPort.getAssignedPortName,hTopUserSignals,...
        hChannel.ChannelDirType,hChannel);

    else


        for ii=1:length(hChannel.UserAssignedInportPorts)
            subPortID=hChannel.UserAssignedInportPorts{ii};
            hSubPort=hChannel.getPort(subPortID);
            subPortName=hSubPort.PortName;
            if hSubPort.hDataType.isBusType
                hBusType=hSubPort.hDataType;
                memberIDList=hBusType.getMemberIDList;
                top_user_signal={};
                for jj=1:length(memberIDList)
                    memberID=memberIDList{jj};
                    if isempty(subPortName)
                        portName=memberID;
                    else
                        portName=sprintf('%s_%s',subPortName,memberID);
                    end
                    top_user_signal{end+1}=hChannel.UserTopInportSignals(hChannel.UserInportList.(portName).Index);%#ok<AGROW>
                end
            else

                top_user_signal=hChannel.UserTopInportSignals(hChannel.UserInportList.(subPortName).Index);
                hUserSignal=top_user_signal{1};
                if hUserSignal.Type.getDimensions>1

                    outMux=pirelab.getMuxOnOutput(hN,hUserSignal);
                    top_user_signal=outMux.PirInputSignals;
                end
            end

            connectInterfacePort(obj,hN,hElab,hSubPort.getAssignedPortName,top_user_signal,hdlturnkey.IOType.IN,hChannel);
        end

        for ii=1:length(hChannel.UserAssignedOutportPorts)
            subPortID=hChannel.UserAssignedOutportPorts{ii};
            hSubPort=hChannel.getPort(subPortID);

            subPortName=hSubPort.PortName;
            if hSubPort.hDataType.isBusType
                hBusType=hSubPort.hDataType;
                memberIDList=hBusType.getMemberIDList;
                top_user_signal={};
                for jj=1:length(memberIDList)
                    memberID=memberIDList{jj};
                    if isempty(subPortName)
                        portName=memberID;
                    else
                        portName=sprintf('%s_%s',subPortName,memberID);
                    end
                    top_user_signal{end+1}=hChannel.UserTopOutportSignals(hChannel.UserOutportList.(portName).Index);%#ok<AGROW>
                end
            else
                top_user_signal=hChannel.UserTopOutportSignals(hChannel.UserOutportList.(subPortName).Index);
                hUserSignal=top_user_signal{1};
                if hUserSignal.Type.getDimensions>1

                    top_user_signal=pirelab.demuxSignal(hN,hUserSignal);
                end
            end

            connectInterfacePort(obj,hN,hElab,hSubPort.getAssignedPortName,top_user_signal,hdlturnkey.IOType.OUT,hChannel);
        end
    end

end
