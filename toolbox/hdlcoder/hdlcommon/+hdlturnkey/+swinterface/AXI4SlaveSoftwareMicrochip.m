


classdef AXI4SlaveSoftwareMicrochip<hdlturnkey.swinterface.AXI4SlaveSoftware



    properties(Access=protected)
        DriverBlockLibrary='axiinterfacelib';
        AXI4SlaveWriteBlock='AXI4-Interface Write';
        AXI4SlaveReadBlock='AXI4-Interface Read';
    end


    properties(Access=protected)
    end


    methods

        function obj=AXI4SlaveSoftwareMicrochip(varargin)

            obj=obj@hdlturnkey.swinterface.AXI4SlaveSoftware(varargin{:});
        end

    end



    methods(Static,Access=protected)
        function addHandshakeBlock(newBlockPath,ipCoreDeviceFile,copReadyOffset,copStrobeOffset)
            zynq.util.addHandShakeBlock(newBlockPath,ipCoreDeviceFile,copReadyOffset,copStrobeOffset);
        end
    end


    methods(Access=protected)
    end

end