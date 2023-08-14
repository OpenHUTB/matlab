function elaborateAXIMasterModule(obj,hN,hElab,hChannel)





    obj.populateUserPorts(hN,hChannel);


    networkName=sprintf('%s_%s',hElab.TopNetName,...
    lower(hChannel.ChannelPortLabel));

    hMasterNet=pirelab.createNewNetwork(...
    'PirInstance',hElab.BoardPirInstance,...
    'Network',hN,...
    'Name',networkName...
    );

    hChannel.hMasterNet=hMasterNet;


    hMasterNetSignals=pirelab.addIOPortToNetwork(...
    'Network',hMasterNet,...
    'InportNames',[hChannel.ExtInportNames,hChannel.UserInportNames],...
    'InportWidths',[hChannel.ExtInportWidths,hChannel.UserInportWidths],...
    'InportDimensions',[hChannel.ExtInportDimensions,hChannel.UserInportDimensions],...
    'OutportNames',[hChannel.ExtOutportNames,hChannel.UserOutportNames],...
    'OutportWidths',[hChannel.ExtOutportWidths,hChannel.UserOutportWidths],...
    'OutportDimensions',[hChannel.ExtOutportDimensions,hChannel.UserOutportDimensions]);

    hChannel.ChannelNetInportSignals=hMasterNetSignals.hInportSignals;
    hChannel.ChannelNetOutportSignals=hMasterNetSignals.hOutportSignals;


    if hChannel.ChannelDirType==hdlturnkey.IOType.IN
        obj.elaborateReadMaster(hElab,hChannel,hMasterNet);
    else
        obj.elaborateWriteMaster(hElab,hChannel,hMasterNet);
    end


    hTopMasterNetInSignals=[hChannel.ExtTopInportSignals,hChannel.UserTopInportSignals{:}];
    hTopMasterNetOutSignals=[hChannel.ExtTopOutportSignals,hChannel.UserTopOutportSignals{:}];
    pirelab.instantiateNetwork(hN,hMasterNet,hTopMasterNetInSignals,...
    hTopMasterNetOutSignals,sprintf('%s_inst',networkName));



    for ii=1:length(hChannel.UserAssignedInportPorts)
        subPortID=hChannel.UserAssignedInportPorts{ii};
        hSubPort=hChannel.getPort(subPortID);
        if~hSubPort.isAssigned
            continue;
        end

        subPortName=hSubPort.PortName;
        if hSubPort.hDataType.isBusType
            hBusType=hSubPort.hDataType;
            memberIDList=hBusType.getMemberIDList;
            top_user_signal={};
            for jj=1:length(memberIDList)
                memberID=memberIDList{jj};


                memberIsRequired=hBusType.getMemberIsRequired(memberID);
                if~memberIsRequired
                    memberIsAssigned=hChannel.getBusMemberIsAssigned(memberID);
                    if~memberIsAssigned
                        continue;
                    end
                end

                if isempty(subPortName)
                    portName=memberID;
                else
                    portName=sprintf('%s_%s',subPortName,memberID);
                end
                top_user_signal{end+1}=hChannel.UserTopInportSignals(hChannel.UserInportList.(portName).Index);%#ok<AGROW>
            end
        else
            top_user_signal=hChannel.getUserInportTopSignal(hSubPort.PortType);
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
        if~hSubPort.isAssigned
            continue;
        end

        subPortName=hSubPort.PortName;
        if hSubPort.hDataType.isBusType
            hBusType=hSubPort.hDataType;
            memberIDList=hBusType.getMemberIDList;
            top_user_signal={};
            for jj=1:length(memberIDList)
                memberID=memberIDList{jj};


                memberIsRequired=hBusType.getMemberIsRequired(memberID);
                if~memberIsRequired
                    memberIsAssigned=hChannel.getBusMemberIsAssigned(memberID);
                    if~memberIsAssigned
                        continue;
                    end
                end

                if isempty(subPortName)
                    portName=memberID;
                else
                    portName=sprintf('%s_%s',subPortName,memberID);
                end
                top_user_signal{end+1}=hChannel.UserTopOutportSignals(hChannel.UserOutportList.(portName).Index);%#ok<AGROW>
            end
        else
            top_user_signal=hChannel.getUserOutportTopSignal(hSubPort.PortType);
            hUserSignal=top_user_signal{1};
            if hUserSignal.Type.getDimensions>1

                top_user_signal=pirelab.demuxSignal(hN,hUserSignal);
            end
        end

        connectInterfacePort(obj,hN,hElab,hSubPort.getAssignedPortName,top_user_signal,hdlturnkey.IOType.OUT,hChannel);
    end
end
