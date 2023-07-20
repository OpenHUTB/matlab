classdef KintexU<eda.fpga.Virtex6



    methods
        function this=KintexU(varargin)
            this.FPGAFamily='KintexU';
            this.FPGAVendor='Xilinx';
            this.minDCMFreq=0.5;
            this.maxDCMFreq=666.667;
            if~isempty(varargin)
                arg=this.componentArg(varargin);
                if isfield(arg,'FPGAFamily')
                    this.FPGAFamily=arg.FPGAFamily;
                end
                this.FPGADevice=arg.Device;
                this.FPGASpeed=arg.Speed;
                this.FPGAPackage=arg.Package;
            end
        end
    end
end
