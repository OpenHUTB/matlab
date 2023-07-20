classdef Virtex7<eda.fpga.Virtex6



    methods
        function this=Virtex7(varargin)
            this.FPGAFamily='Virtex7';
            this.FPGAVendor='Xilinx';
            this.minDCMFreq=0.5;
            this.maxDCMFreq=666.667;
            if~isempty(varargin)
                arg=this.componentArg(varargin);
                this.FPGADevice=arg.Device;
                this.FPGASpeed=arg.Speed;
                this.FPGAPackage=arg.Package;
            end
        end
    end
end
