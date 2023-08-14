classdef Virtex6<eda.board.FPGA




    methods
        function this=Virtex6(varargin)
            this.FPGAVendor='Xilinx';
            this.FPGAFamily='Virtex6';
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
