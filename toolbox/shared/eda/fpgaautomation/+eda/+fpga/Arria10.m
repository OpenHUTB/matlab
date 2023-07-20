classdef Arria10<eda.fpga.ArriaV

    methods
        function r=getIOBufIPName(~)
            r='twentynm_io_ibuf';
        end
        function this=Arria10(varargin)
            this=this@eda.fpga.ArriaV(varargin{:});
            this.FPGAFamily='Arria 10';
        end
    end
end