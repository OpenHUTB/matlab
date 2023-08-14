function populateUserPorts(obj,hN,hChannel,hElab)













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



        if hChannel.isSampleControlBusAssigned
            if~hSubPort.isAssigned
                continue;
            end
        else



            if~hElab.hTurnkey.hD.isMLHDLC&&~hElab.hTurnkey.hD.isMDS&&...
                hChannel.isFrameToSample
                if~hChannel.isStandardPortGroup(hSubPort)&&...
                    ~hSubPort.isAssigned
                    continue;
                end
            else
                if~hChannel.isRequiredUserPortGroup(hSubPort)&&...
                    ~hSubPort.isAssigned
                    continue;
                end
            end
        end

        hSubPortType=hSubPort.hDataType;
        subPortName=hSubPort.PortName;

        if hSubPortType.isBusType
            hChannel.UserAssignedOutportPorts{end+1}=subPortID;
            memberIDList=hSubPortType.getMemberIDList;
            for jj=1:length(memberIDList)
                memberID=memberIDList{jj};
                memberType=hSubPortType.getMemberType(memberID);
                if isempty(subPortName)
                    portName=memberID;
                else
                    portName=sprintf('%s_%s',subPortName,memberID);
                end
                portWidth=memberType.WordLength;
                portDimension=1;
                portPirType=pir_ufixpt_t(portWidth,0);

                index=index+1;

                hChannel.UserOutportNames{end+1}=sprintf('user_%s',portName);
                hChannel.UserOutportWidths{end+1}=portWidth;
                hChannel.UserOutportList.(portName).Width=portWidth;
                hChannel.UserOutportDimensions{end+1}=portDimension;
                hChannel.UserOutportList.(portName).Dimension=portDimension;
                hChannel.UserOutportList.(portName).Index=index;
                hChannel.UserTopOutportSignals{end+1}=hN.addSignal(portPirType,sprintf('top_user_%s',portName));
            end

        else
            portName=subPortName;
            [portWidth,portDimension,totalWidth,isComplex]=hChannel.getPortWidth(hSubPort,hChannel.PackingMode);





            if isComplex
                if~hElab.hTurnkey.hD.isMLHDLC&&~hElab.hTurnkey.hD.isMDS&&...
                    hChannel.isFrameToSample
                    portDimension=2;
                else
                    portDimension=2*portDimension;
                end
            end




            if portDimension>1&&strcmp(obj.SamplePackingDimension,'All')
                portPirType=pir_ufixpt_t(portWidth,0);
                hChannel.UserOutportWidths{end+1}=portWidth;
                hChannel.UserOutportList.(portName).Width=portWidth;
                hChannel.UserOutportDimensions{end+1}=portDimension;
                hChannel.UserOutportList.(portName).Dimension=portDimension;


                portPirType=pirelab.getPirVectorType(portPirType,portDimension);

            else
                portPirType=pir_ufixpt_t(totalWidth,0);
                hChannel.UserOutportWidths{end+1}=totalWidth;
                hChannel.UserOutportList.(portName).Width=totalWidth;
                hChannel.UserOutportDimensions{end+1}=1;
                hChannel.UserOutportList.(portName).Dimension=1;
            end

            index=index+1;
            hChannel.UserAssignedOutportPorts{end+1}=subPortID;
            hChannel.UserOutportNames{end+1}=sprintf('user_%s',portName);
            hChannel.UserOutportList.(portName).Index=index;
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



        if hChannel.isSampleControlBusAssigned
            if~hSubPort.isAssigned
                continue;
            end
        else



            if~hElab.hTurnkey.hD.isMLHDLC&&~hElab.hTurnkey.hD.isMDS&&...
                hChannel.isFrameToSample
                if~hChannel.isStandardPortGroup(hSubPort)&&...
                    ~hSubPort.isAssigned
                    continue;
                end
            else
                if~hChannel.isRequiredUserPortGroup(hSubPort)&&...
                    ~hSubPort.isAssigned
                    continue;
                end
            end
        end

        hSubPortType=hSubPort.hDataType;
        subPortName=hSubPort.PortName;

        if hSubPortType.isBusType
            hChannel.UserAssignedInportPorts{end+1}=subPortID;
            memberIDList=hSubPortType.getMemberIDList;
            for jj=1:length(memberIDList)
                memberID=memberIDList{jj};
                memberType=hSubPortType.getMemberType(memberID);
                if isempty(subPortName)
                    portName=memberID;
                else
                    portName=sprintf('%s_%s',subPortName,memberID);
                end
                portWidth=memberType.WordLength;
                portDimension=1;
                portPirType=pir_ufixpt_t(portWidth,0);

                index=index+1;
                hChannel.UserInportNames{end+1}=sprintf('user_%s',portName);
                hChannel.UserInportWidths{end+1}=portWidth;
                hChannel.UserInportList.(portName).Width=portWidth;
                hChannel.UserInportDimensions{end+1}=portDimension;
                hChannel.UserInportList.(portName).Dimension=portDimension;
                hChannel.UserInportList.(portName).Index=index;
                hChannel.UserTopInportSignals{end+1}=hN.addSignal(portPirType,sprintf('top_user_%s',portName));

            end

        else
            portName=subPortName;
            [portWidth,portDimension,totWidth,isComplex]=hChannel.getPortWidth(hSubPort,hChannel.PackingMode);





            if isComplex
                if~hElab.hTurnkey.hD.isMLHDLC&&~hElab.hTurnkey.hD.isMDS&&...
                    hChannel.isFrameToSample
                    portDimension=2;
                else
                    portDimension=2*portDimension;
                end
            end



            if portDimension>1&&strcmp(obj.SamplePackingDimension,'All')
                portPirType=pir_ufixpt_t(portWidth,0);
                hChannel.UserInportWidths{end+1}=portWidth;
                hChannel.UserInportList.(portName).Width=portWidth;
                hChannel.UserInportDimensions{end+1}=portDimension;
                hChannel.UserInportList.(portName).Dimension=portDimension;

                portPirType=pirelab.getPirVectorType(portPirType,portDimension);

            else
                portPirType=pir_ufixpt_t(totWidth,0);
                hChannel.UserInportWidths{end+1}=totWidth;
                hChannel.UserInportList.(portName).Width=totWidth;
                hChannel.UserInportDimensions{end+1}=1;
                hChannel.UserInportList.(portName).Dimension=1;
            end

            index=index+1;
            hChannel.UserAssignedInportPorts{end+1}=subPortID;
            hChannel.UserInportNames{end+1}=sprintf('user_%s',portName);
            hChannel.UserInportList.(portName).Index=index;
            hChannel.UserTopInportSignals{end+1}=hN.addSignal(portPirType,sprintf('top_user_%s',portName));
        end

    end

end

