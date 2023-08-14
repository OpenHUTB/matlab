classdef X310<wt.internal.hardware.DeviceManager&wt.internal.hardware.rfnoc.X3xx




    properties(Hidden,SetAccess=immutable)
        AvailableMasterClockRate=[184.32e6,200e6]
        AvailableHardwareMemory=1024*1024*1024
        Product="X310"

        TransmitGainRange=[0,31.5,0.5];
        ReceiveGainRange=[0,31.5,0.5];
        TransmitCenterFrequencyRange=[10e6,6e9,1];
        ReceiveCenterFrequencyRange=[10e6,6e9,1];
    end
    properties(Hidden,SetAccess=protected)
        MasterClockRate=200e6
    end
    methods(Hidden)
        function obj=X310(plugin)
            obj@wt.internal.hardware.DeviceManager(plugin);
            populateAntennas(obj);
        end
        function populateAntennas(obj)
            obj.AvailableAntennas=containers.Map;
            obj.AvailableAntennas("RFA:TX/RX")=wt.internal.hardware.rfnoc.Antenna("RFA:TX/RX","A:0",1,1,"0/Radio#0",0);
            obj.AvailableAntennas("RFA:RX2")=wt.internal.hardware.rfnoc.Antenna("RFA:RX2","A:0",1,0,"0/Radio#0",0);
            obj.AvailableAntennas("RFB:TX/RX")=wt.internal.hardware.rfnoc.Antenna("RFB:TX/RX","B:0",1,1,"0/Radio#1",0);
            obj.AvailableAntennas("RFB:RX2")=wt.internal.hardware.rfnoc.Antenna("RFB:RX2","B:0",1,0,"0/Radio#1",0);
            obj.AvailableTransmitAntennas=["RFA:TX/RX","RFB:TX/RX"];
            obj.AvailableReceiveAntennas=["RFA:RX2","RFB:RX2"];
        end
    end
end
