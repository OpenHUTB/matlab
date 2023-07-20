classdef VirtexU<eda.fpga.Virtex6



    methods
        function this=VirtexU(varargin)
            this.FPGAFamily='VirtexU';
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
