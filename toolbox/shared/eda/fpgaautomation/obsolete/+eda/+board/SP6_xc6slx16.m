classdef SP6_xc6slx16<eda.board.FPGA





    methods
        function h=SP6_xc6slx16(varargin)
            h.FPGAVendor='Xilinx';
            h.FPGAFamily='Spartan6';
            h.FPGADevice='xc6slx16';
            h.FPGASpeed=varargin{2};
            h.FPGAPackage=varargin{4};
            freq=varargin(6);
            h.SynthesisFrequencies=freq{:};
        end
    end
end
