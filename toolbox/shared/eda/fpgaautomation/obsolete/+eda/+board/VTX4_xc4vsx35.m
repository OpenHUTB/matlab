classdef VTX4_xc4vsx35<eda.board.FPGA





    methods
        function h=VTX4_xc4vsx35(varargin)
            h.FPGAVendor='Xilinx';
            h.FPGAFamily='Virtex4';
            h.FPGADevice='xc4vsx35';
            h.FPGASpeed=varargin{2};
            h.FPGAPackage=varargin{4};
            freq=varargin(6);
            h.SynthesisFrequencies=freq{:};
        end
    end
end
