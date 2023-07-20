classdef ArriaV<eda.fpga.Arria2



    methods
        function r=getIOBufIPName(~)
            r='arriav_io_ibuf';
        end
        function this=ArriaV(varargin)
            this.FPGAVendor='Altera';

            this.minDCMFreq=0.5;
            this.maxDCMFreq=666.667;
            if~isempty(varargin)
                arg=this.componentArg(varargin);
                this.FPGADevice=arg.Device;
                if isfield(arg,'FPGAFamily')
                    this.FPGAFamily=arg.FPGAFamily;
                end
            end
        end
    end
end
