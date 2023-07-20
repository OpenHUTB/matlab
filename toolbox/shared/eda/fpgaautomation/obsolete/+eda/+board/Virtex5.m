classdef Virtex5<eda.board.FPGA




    methods
        function this=Virtex5(varargin)
            this.FPGAVendor='Xilinx';
            this.FPGAFamily='Virtex5';
            if~isempty(varargin)
                arg=this.findPVPair(varargin);
                this.FPGADevice=arg.Device;
                this.FPGASpeed=arg.Speed;
                this.FPGAPackage=arg.Package;
                this.SynthesisFrequencies=arg.Frequency;
            end
        end
    end
end
