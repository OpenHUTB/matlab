classdef Cyclone5<eda.fpga.Altera





    methods
        function this=Cyclone5(varargin)
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


        function ibufgds(~,hC,diff_n,diff_p,out)
            ibufgds=hC.component(...
            'UniqueName','cyclonev_io_ibuf',...
            'InstName','ibufa',...
            'Component',eda.internal.component.BlackBox({...
            'I','INPUT','boolean',...
            'IBAR','INPUT','boolean',...
            'O','OUTPUT','boolean'}),...
            'I',diff_p,...
            'IBAR',diff_n,...
            'O',out);
            ibufgds.Partition.Device.PartInfo.FPGAVendor='Altera';
            ibufgds.addprop('generic');
            ibufgds.generic=generics(...
            'bus_hold','string','"FALSE"',...
            'differential_mode','string','"TRUE"');
            ibufgds.addprop('NoHDLFiles');
            ibufgds.addprop('wrapperFileNotNeeded');
        end
    end
end
