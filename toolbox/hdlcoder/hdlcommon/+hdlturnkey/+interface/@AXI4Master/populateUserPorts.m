function populateUserPorts(~,hN,hChannel)













    hChannel.UserInportNames={};
    hChannel.UserOutportNames={};
    hChannel.UserInportWidths={};
    hChannel.UserOutportWidths={};
    hChannel.UserInportDimensions={};
    hChannel.UserOutportDimensions={};
    hChannel.UserInportList={};
    hChannel.UserOutportList={};
    hChannel.UserAssignedInportPorts={};
    hChannel.UserAssignedOutportPorts={};
    hChannel.UserTopInportSignals={};
    hChannel.UserTopOutportSignals={};


    index=0;
    inputPortList=hChannel.getInputPortIDList;
    for ii=1:length(inputPortList)
        subPortID=inputPortList{ii};
        hSubPort=hChannel.getPort(subPortID);


        if hChannel.isEmptyPort(hSubPort)
            continue;
        end


        if~hSubPort.isAssigned
            continue;
        end

        hSubPortType=hSubPort.hDataType;
        subPortName=hSubPort.PortName;

        if hSubPortType.isBusType
            hChannel.UserAssignedOutportPorts{end+1}=subPortID;

            hSubPortMemberIDList=hSubPortType.getMemberIDList;
            for jj=1:length(hSubPortMemberIDList)
                hSubPortMemberID=hSubPortMemberIDList{jj};


                memberIsRequired=hSubPortType.getMemberIsRequired(hSubPortMemberID);
                if~memberIsRequired
                    memberIsAssigned=hChannel.getBusMemberIsAssigned(hSubPortMemberID);
                    if~memberIsAssigned
                        continue;
                    end
                end

                if isempty(subPortName)
                    portName=hSubPortMemberID;
                else
                    portName=sprintf('%s_%s',subPortName,hSubPortMemberID);
                end

                [portWidth,portDimension]=hChannel.getBusMemberWidth(hSubPort,hSubPortMemberID);
                portPirType=pir_ufixpt_t(portWidth,0);
                if portDimension>1
                    portPirType=pirelab.getPirVectorType(portPirType,portDimension);
                end

                index=index+1;

                hChannel.UserOutportNames{end+1}=sprintf('user_%s',portName);
                hChannel.UserOutportWidths{end+1}=portWidth;
                hChannel.UserOutportDimensions{end+1}=portDimension;
                hChannel.UserOutportList.(portName).Width=portWidth;
                hChannel.UserInportList.(portName).Dimension=portDimension;
                hChannel.UserOutportList.(portName).Index=index;
                hChannel.UserTopOutportSignals{end+1}=hN.addSignal(portPirType,sprintf('top_user_%s',portName));
            end

        else
            portName=hSubPort.ExternalPortName;
            portType=hSubPort.PortType;
            [portWidth,portDimension]=hChannel.getPortWidth(hSubPort);
            portPirType=pir_ufixpt_t(portWidth,0);
            if portDimension>1
                portPirType=pirelab.getPirVectorType(portPirType,portDimension);
            end

            index=index+1;

            hChannel.UserAssignedOutportPorts{end+1}=subPortID;
            hChannel.UserOutportNames{end+1}=sprintf('user_%s',portName);
            hChannel.UserOutportWidths{end+1}=portWidth;
            hChannel.UserOutportDimensions{end+1}=portDimension;
            hChannel.UserOutportList.(portType).Width=portWidth;
            hChannel.UserInportList.(portName).Dimension=portDimension;
            hChannel.UserOutportList.(portType).Index=index;
            hChannel.UserTopOutportSignals{end+1}=hN.addSignal(portPirType,sprintf('top_user_%s',portName));
        end

    end


    index=0;
    outputPortList=hChannel.getOutputPortIDList;
    for ii=1:length(outputPortList)
        subPortID=outputPortList{ii};
        hSubPort=hChannel.getPort(subPortID);


        if hChannel.isEmptyPort(hSubPort)
            continue;
        end


        if~hSubPort.isAssigned
            continue;
        end

        hSubPortType=hSubPort.hDataType;
        subPortName=hSubPort.PortName;

        if hSubPortType.isBusType
            hChannel.UserAssignedInportPorts{end+1}=subPortID;

            hSubPortMemberIDList=hSubPortType.getMemberIDList;
            for jj=1:length(hSubPortMemberIDList)
                hSubPortMemberID=hSubPortMemberIDList{jj};


                memberIsRequired=hSubPortType.getMemberIsRequired(hSubPortMemberID);
                if~memberIsRequired
                    memberIsAssigned=hChannel.getBusMemberIsAssigned(hSubPortMemberID);
                    if~memberIsAssigned
                        continue;
                    end
                end

                if isempty(subPortName)
                    portName=hSubPortMemberID;
                else
                    portName=sprintf('%s_%s',subPortName,hSubPortMemberID);
                end

                [portWidth,portDimension]=hChannel.getBusMemberWidth(hSubPort,hSubPortMemberID);
                portPirType=pir_ufixpt_t(portWidth,0);
                if portDimension>1
                    portPirType=pirelab.getPirVectorType(portPirType,portDimension);
                end

                index=index+1;

                hChannel.UserInportNames{end+1}=sprintf('user_%s',portName);
                hChannel.UserInportWidths{end+1}=portWidth;
                hChannel.UserInportDimensions{end+1}=portDimension;
                hChannel.UserInportList.(portName).Width=portWidth;
                hChannel.UserInportList.(portName).Dimension=portDimension;
                hChannel.UserInportList.(portName).Index=index;
                hChannel.UserTopInportSignals{end+1}=hN.addSignal(portPirType,sprintf('top_user_%s',portName));

            end

        else
            portName=hSubPort.ExternalPortName;
            portType=hSubPort.PortType;
            [portWidth,portDimension]=hChannel.getPortWidth(hSubPort);
            portPirType=pir_ufixpt_t(portWidth,0);
            if portDimension>1
                portPirType=pirelab.getPirVectorType(portPirType,portDimension);
            end

            index=index+1;

            hChannel.UserAssignedInportPorts{end+1}=subPortID;
            hChannel.UserInportNames{end+1}=sprintf('user_%s',portName);
            hChannel.UserInportWidths{end+1}=portWidth;
            hChannel.UserInportDimensions{end+1}=portDimension;
            hChannel.UserInportList.(portType).Width=portWidth;
            hChannel.UserInportList.(portName).Dimension=portDimension;
            hChannel.UserInportList.(portType).Index=index;
            hChannel.UserTopInportSignals{end+1}=hN.addSignal(portPirType,sprintf('top_user_%s',portName));
        end

    end

end

