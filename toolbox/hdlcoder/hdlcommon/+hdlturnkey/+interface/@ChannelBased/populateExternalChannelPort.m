function populateExternalChannelPort(hN,hChannel,MasterInputPortList,MasterOutputPortList,SlaveInputPortList,SlaveOutputPortList,hElab)




    hChannel.ExtInportNames={};
    hChannel.ExtOutportNames={};
    hChannel.ExtInportWidths={};
    hChannel.ExtOutportWidths={};
    hChannel.ExtInportTotalWidth={};
    hChannel.ExtOutportTotalWidth={};
    hChannel.ExtInportDimensions={};
    hChannel.ExtOutportDimensions={};
    hChannel.ExtInportList={};
    hChannel.ExtOutportList={};
    hChannel.PackingMode='';

    if hChannel.ChannelDirType==hdlturnkey.IOType.OUT

        for ii=1:length(MasterInputPortList)
            portCell=MasterInputPortList{ii};
            [extPortName,portWidth,~,portDimension,totalWidth,isComplex]=hdlturnkey.interface.ChannelBased.getExternalPortInfo(hChannel,portCell,hElab);
            hdlturnkey.interface.ChannelBased.populateExternalInputPort(hChannel,extPortName,portWidth,portDimension,totalWidth,isComplex,ii,hElab);
        end

        for ii=1:length(MasterOutputPortList)
            portCell=MasterOutputPortList{ii};
            [extPortName,portWidth,~,portDimension,totalWidth,isComplex]=hdlturnkey.interface.ChannelBased.getExternalPortInfo(hChannel,portCell,hElab);
            hdlturnkey.interface.ChannelBased.populateExternalOutputPort(hChannel,extPortName,portWidth,portDimension,totalWidth,isComplex,ii,hElab);
        end

    else

        for ii=1:length(SlaveInputPortList)
            portCell=SlaveInputPortList{ii};
            [extPortName,portWidth,~,portDimension,totalWidth,isComplex]=hdlturnkey.interface.ChannelBased.getExternalPortInfo(hChannel,portCell,hElab);
            hdlturnkey.interface.ChannelBased.populateExternalInputPort(hChannel,extPortName,portWidth,portDimension,totalWidth,isComplex,ii,hElab);
        end

        for ii=1:length(SlaveOutputPortList)
            portCell=SlaveOutputPortList{ii};
            [extPortName,portWidth,~,portDimension,totalWidth,isComplex]=hdlturnkey.interface.ChannelBased.getExternalPortInfo(hChannel,portCell,hElab);
            hdlturnkey.interface.ChannelBased.populateExternalOutputPort(hChannel,extPortName,portWidth,portDimension,totalWidth,isComplex,ii,hElab);
        end

    end


    if~strcmp(hChannel.SamplePackingDimension,'All')
        hdlturnkey.interface.ChannelBased.elabExternalPortForFrameMode(hN,hChannel);
    else
        hdlturnkey.interface.ChannelBased.elabExternalPortForSampleMode(hN,hChannel);
    end

end
