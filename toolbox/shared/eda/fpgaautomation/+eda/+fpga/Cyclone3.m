classdef Cyclone3<eda.fpga.Altera





    methods
        function this=Cyclone3(varargin)
            this.FPGAVendor='Altera';
            this.FPGAFamily='Cyclone III';
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
