classdef ByteOrder<handle




%#codegen

    properties(Access=private)

        MachineByteOrder='little-endian';
    end

    methods(Hidden)
        function obj=ByteOrder()
            coder.allowpcode('plain');
            coder.extrinsic('computer');


            if isempty(coder.target)
                [~,~,b]=computer;
            else
                [~,~,b]=coder.const(@computer);
            end
            if strcmpi(b,'l')
                obj.MachineByteOrder='little-endian';
            else
                obj.MachineByteOrder='big-endian';
            end
        end
    end

    methods(Access=protected)
        function val=NeedByteSwap(obj,byteOrder)
            val=~strcmpi(byteOrder,obj.MachineByteOrder);
        end
    end
end

