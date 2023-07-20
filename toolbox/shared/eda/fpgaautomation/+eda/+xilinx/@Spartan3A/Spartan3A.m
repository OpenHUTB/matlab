classdef(ConstructOnLoad)Spartan3A<eda.internal.component.FPGA








    properties

    end

    methods
        function this=Spartan3A
            this.FPGAVendor='Xilinx';
            this.FPGAFamily='Spartan3A';
            this.FPGADevice='xc3sd1800a';
            this.FPGASpeed='-4';
            this.FPGAPackage='fg676';
            this.minDCMFreq=5;
            this.maxDCMFreq=250;
        end
    end
end
