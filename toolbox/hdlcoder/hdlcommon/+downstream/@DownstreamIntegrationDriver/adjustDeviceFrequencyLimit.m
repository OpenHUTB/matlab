function limit=adjustDeviceFrequencyLimit(obj)
    dcPorts={};
    hRD=obj.hIP.getReferenceDesignPlugin;
    limit=hRD.hClockModule.ClockMaxMHz;

    if~isempty(hRD)
        fdcInterface=hRD.getFDCParameterValue;
        aximanagerInterface=hRD.getAXIParameterValue;
        dcPorts=obj.hTurnkey.hTable.hTableMap.getConnectedPortList('FPGA Data Capture');

        if(strcmp(fdcInterface,'Ethernet')&&strcmp(aximanagerInterface,'Ethernet'))
            if(~isempty(dcPorts)&&obj.hIP.getAXI4SlaveEnable)
                hRD.hClockModule.ClockMaxMHz=100;
                limit=100;
            end
        end
    end
end
