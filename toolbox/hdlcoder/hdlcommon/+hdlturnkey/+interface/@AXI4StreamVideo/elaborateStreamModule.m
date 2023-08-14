function elaborateStreamModule(obj,hN,hElab,hChannel,multiRateCountEnable,multiRateCountValue)





    obj.populateExternalPorts(hN,hChannel,hElab);


    obj.populateUserPorts(hN,hChannel);


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
    'OutportNames',[hChannel.ExtOutportNames,hChannel.UserOutportNames,hChannel.AutoOutportNames],...
    'OutportWidths',[hChannel.ExtOutportWidths,hChannel.UserOutportWidths,hChannel.AutoOutportWidths]);

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
        end
        connectInterfacePort(obj,hN,hElab,hSubPort.getAssignedPortName,top_user_signal,hdlturnkey.IOType.OUT,hChannel);
    end


end
