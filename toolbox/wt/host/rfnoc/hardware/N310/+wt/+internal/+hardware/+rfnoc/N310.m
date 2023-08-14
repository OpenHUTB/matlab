classdef N310<wt.internal.hardware.DeviceManager&wt.internal.hardware.rfnoc.N3xx




    properties(Hidden,SetAccess=immutable)
        AvailableMasterClockRate=[122.88e6,125e6,153.6e6]
        Product="n310"
        TransmitGainRange=[0,65,0.5];
        ReceiveGainRange=[0,75,0.5];
        TransmitCenterFrequencyRange=[1e6,6e9,1];
        ReceiveCenterFrequencyRange=[1e6,6e9,1];
    end
    properties(Hidden,SetAccess=protected)
        MasterClockRate=153.6e6
    end
    properties(Hidden)
        InternalLoopback=false
    end
    methods(Hidden)
        function obj=N310(plugin)
            obj@wt.internal.hardware.DeviceManager(plugin);
            populateAntennas(obj);
        end

        function populateAntennas(obj)
            obj.AvailableAntennas=containers.Map;
            obj.AvailableAntennas("RF0:TX/RX")=wt.internal.hardware.rfnoc.Antenna("RF0:TX/RX","A:0",1,1,"0/Radio#0",0);
            obj.AvailableAntennas("RF0:RX2")=wt.internal.hardware.rfnoc.Antenna("RF0:RX2","A:0",1,0,"0/Radio#0",0);
            obj.AvailableAntennas("RF1:TX/RX")=wt.internal.hardware.rfnoc.Antenna("RF1:TX/RX","A:1",1,1,"0/Radio#0",1);
            obj.AvailableAntennas("RF1:RX2")=wt.internal.hardware.rfnoc.Antenna("RF1:RX2","A:1",1,0,"0/Radio#0",1);
            obj.AvailableAntennas("RF2:TX/RX")=wt.internal.hardware.rfnoc.Antenna("RF2:TX/RX","B:0",1,1,"0/Radio#1",0);
            obj.AvailableAntennas("RF2:RX2")=wt.internal.hardware.rfnoc.Antenna("RF2:RX2","B:0",1,0,"0/Radio#1",0);
            obj.AvailableAntennas("RF3:TX/RX")=wt.internal.hardware.rfnoc.Antenna("RF3:TX/RX","B:1",1,1,"0/Radio#1",1);
            obj.AvailableAntennas("RF3:RX2")=wt.internal.hardware.rfnoc.Antenna("RF3:RX2","B:1",1,0,"0/Radio#1",1);
            obj.AvailableTransmitAntennas=["RF0:TX/RX","RF1:TX/RX","RF2:TX/RX","RF3:TX/RX"];
            obj.AvailableReceiveAntennas=["RF0:RX2","RF1:RX2","RF2:RX2","RF3:RX2"];
        end

        function args=getDeviceArgs(obj)
            args=getDeviceArgs@wt.internal.hardware.rfnoc.N3xx(obj);


            if(obj.InternalLoopback)
                args=strcat(args,",rfic_digital_loopback=1");
            end
        end
    end
end
