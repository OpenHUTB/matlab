classdef CYC3_ep3c25f324c8<eda.board.FPGA





    methods
        function h=CYC3_ep3c25f324c8(varargin)
            h.FPGAVendor='Altera';
            h.FPGAFamily='Cyclone III';
            h.FPGADevice='EP3C25F324C8';
            h.FPGASpeed='';
            h.FPGAPackage='';
            freq=varargin(6);
            h.SynthesisFrequencies=freq{:};
        end
    end
end
