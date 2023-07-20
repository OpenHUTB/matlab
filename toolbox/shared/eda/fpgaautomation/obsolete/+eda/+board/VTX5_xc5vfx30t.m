classdef VTX5_xc5vfx30t<eda.board.FPGA





    methods
        function h=VTX5_xc5vfx30t(varargin)
            h.FPGAVendor='Xilinx';
            h.FPGAFamily='Virtex5';
            h.FPGADevice='xc5vfx30t';
            h.FPGASpeed=varargin{2};
            h.FPGAPackage=varargin{4};
            freq=varargin(6);
            h.SynthesisFrequencies=freq{:};
        end



    end
end
