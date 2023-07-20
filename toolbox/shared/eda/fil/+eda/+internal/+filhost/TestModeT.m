

classdef TestModeT<eda.internal.mcosutils.FullStringEnumT
    properties(Constant=true,Hidden=true)
        strValues={'FPGA-in-the-Loop',...
        'Cosim using UDP Blocks',...
        'Cosim using HDL Cosimulation Block',...
        'MAC Loopback',...
        'Localhost Direct',...
        'Localhost using FIL Blocks'};
        intValues=int32([0,1,2,3,4,5]);
    end
    methods
        function this=TestModeT(varargin)
            this=this@eda.internal.mcosutils.FullStringEnumT(varargin{:});
        end
    end
end
