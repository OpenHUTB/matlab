


classdef AXI4SlaveSoftwareAlteraSoC<hdlturnkey.swinterface.AXI4SlaveSoftware



    properties(Access=protected)
        DriverBlockLibrary='alterasoclib';
        AXI4SlaveWriteBlock='AXI4 Write';
        AXI4SlaveReadBlock='AXI4 Read';
    end


    properties(Access=protected)
    end


    methods

        function obj=AXI4SlaveSoftwareAlteraSoC(varargin)

            obj=obj@hdlturnkey.swinterface.AXI4SlaveSoftware(varargin{:});
        end

    end



    methods(Static,Access=protected)
        function addHandshakeBlock(newBlockPath,ipCoreDeviceFile,copReadyOffset,copStrobeOffset)
            codertarget.alterasoc.internal.addHandShakeBlock(newBlockPath,ipCoreDeviceFile,copReadyOffset,copStrobeOffset);
        end
    end


    methods(Access=protected)
    end

end