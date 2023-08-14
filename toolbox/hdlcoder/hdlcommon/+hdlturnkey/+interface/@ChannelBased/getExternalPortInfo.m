function[extPortName,portWidth,hSubPort,portDimension,totalWidth,isComplex]=getExternalPortInfo(hChannel,extPortCell,hElab)


















    extPortName=extPortCell{1};
    hDataType=extPortCell{2};
    associatedSubPortID=extPortCell{3};

    isFlexibleWidth=hDataType.isFlexibleWidth;
    if isFlexibleWidth
        hSubPort=hChannel.getPort(associatedSubPortID);
        if hSubPort.isAssigned
            hTableMap=hElab.hTurnkey.hTable.hTableMap;
            portName=hSubPort.getAssignedPortName;
            hInterface=hTableMap.getInterface(portName);
            hChannel.SamplePackingDimension=hInterface.SamplePackingDimension;




            if hSubPort.getAssignedPort.isComplex
                hChannel.SamplePackingDimension='All';
                hInterface.SamplePackingDimension='All';
                hChannel.PackingMode='Power of 2 Aligned';
                hInterface.PackingMode='Power of 2 Aligned';
            end
        else
            hChannel.PackingMode='';
            if~(hChannel.isFrameModePort(hElab.hTurnkey.hTable))
                hChannel.SamplePackingDimension='';
            else




                hChannel.SamplePackingDimension='None';
            end
        end
        [portWidth,portDimension,totalWidth,isComplex]=hChannel.getPortWidth(hSubPort,hChannel.PackingMode);
    else
        hSubPort=[];
        portWidth=hDataType.getMaxWordLength;
        portDimension=1;
        totalWidth=portWidth*portDimension;
        isComplex=false;
    end

end
