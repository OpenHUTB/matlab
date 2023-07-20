classdef Cyclone4<eda.fpga.Altera





    methods
        function this=Cyclone4(varargin)
            this.FPGAVendor='Altera';
            this.minDCMFreq=0.5;
            this.maxDCMFreq=666.667;
            if~isempty(varargin)
                arg=this.componentArg(varargin);
                this.FPGADevice=arg.Device;
                this.FPGASpeed='';
                this.FPGAPackage='';
                if isfield(arg,'FPGAFamily')
                    this.FPGAFamily=arg.FPGAFamily;
                end
            end
        end

    end
end
