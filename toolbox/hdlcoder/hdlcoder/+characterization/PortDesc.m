classdef PortDesc






    properties
port
range
widthTemplate
    end

    properties(Hidden=true,Constant)
        REMAINING_PORTS=-3;
    end

    methods
        function self=PortDesc()
            self.port=characterization.PortDesc.REMAINING_PORTS;
            self.range={1,1,1};
            self.widthTemplate='fixdt(0, %d, 0)';
        end

    end

end
