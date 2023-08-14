


classdef AXI4StreamSoftwareZynq<hdlturnkey.swinterface.AXI4StreamSoftware



    properties(Access=protected,Constant)
        DriverBlockLibrary='zynqlib';
        AXI4StreamWriteBlock='AXI4-Stream IIO Write';
        AXI4StreamReadBlock='AXI4-Stream IIO Read';
    end


    properties(Access=protected)
    end


    methods

        function obj=AXI4StreamSoftwareZynq(varargin)

            obj=obj@hdlturnkey.swinterface.AXI4StreamSoftware(varargin{:});
        end

    end



    methods(Access=protected)
    end


    methods(Access=protected)
    end

end