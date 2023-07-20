classdef Virtex4<eda.fpga.Virtex4_5





    methods
        function this=Virtex4(varargin)
            this=this@eda.fpga.Virtex4_5(varargin{:});
            this.FPGAVendor='Xilinx';
            this.FPGAFamily='Virtex4';
            this.minDCMFreq=5;
            this.maxDCMFreq=400;
        end
    end
end