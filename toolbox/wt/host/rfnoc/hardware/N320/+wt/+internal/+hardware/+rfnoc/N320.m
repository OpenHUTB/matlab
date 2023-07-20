classdef N320<wt.internal.hardware.DeviceManager&wt.internal.hardware.rfnoc.N3xx




    properties(Hidden,SetAccess=immutable)
        AvailableMasterClockRate=[200e6,245.76e6,250e6]
        Product="n320"
        TransmitGainRange=[0,60,1];
        ReceiveGainRange=[0,60,1];
        TransmitCenterFrequencyRange=[1e6,6e9,1];
        ReceiveCenterFrequencyRange=[1e6,6e9,1];
    end
    properties(Hidden,SetAccess=protected)
        MasterClockRate=250e6
    end
    methods(Hidden)
        function obj=N320(plugin)
            obj@wt.internal.hardware.DeviceManager(plugin);
            populateAntennas(obj);
        end
        function populateAntennas(obj)
            obj.AvailableAntennas=containers.Map;
            obj.AvailableAntennas("RF0:TX/RX")=wt.internal.hardware.rfnoc.Antenna("RF0:TX/RX","A:0",1,1,"0/Radio#0",0);
            obj.AvailableAntennas("RF0:RX2")=wt.internal.hardware.rfnoc.Antenna("RF0:RX2","A:0",1,0,"0/Radio#0",0);
            obj.AvailableAntennas("RF1:TX/RX")=wt.internal.hardware.rfnoc.Antenna("RF1:TX/RX","B:0",1,1,"0/Radio#1",0);
            obj.AvailableAntennas("RF1:RX2")=wt.internal.hardware.rfnoc.Antenna("RF1:RX2","B:0",1,0,"0/Radio#1",0);
            obj.AvailableTransmitAntennas=["RF0:TX/RX","RF1:TX/RX"];
            obj.AvailableReceiveAntennas=["RF0:RX2","RF1:RX2"];
        end
    end
end
