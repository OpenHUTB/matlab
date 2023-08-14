classdef Spartan3ADSP<eda.fpga.Spartan6





    methods
        function this=Spartan3ADSP(varargin)
            this.FPGAVendor='Xilinx';
            this.FPGAFamily='Spartan-3A DSP';
            this.minDCMFreq=5;
            this.maxDCMFreq=250;
            if~isempty(varargin)
                arg=this.componentArg(varargin);
                this.FPGADevice=arg.Device;
                this.FPGASpeed=arg.Speed;
                this.FPGAPackage=arg.Package;
            end
        end
    end
end
