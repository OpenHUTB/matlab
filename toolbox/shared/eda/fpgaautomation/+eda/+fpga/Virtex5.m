classdef Virtex5<eda.fpga.Virtex4_5




    methods
        function this=Virtex5(varargin)
            this=this@eda.fpga.Virtex4_5(varargin{:});
            this.FPGAVendor='Xilinx';
            this.FPGAFamily='Virtex5';
            this.minDCMFreq=0.5;
            this.maxDCMFreq=500;
        end
    end
end