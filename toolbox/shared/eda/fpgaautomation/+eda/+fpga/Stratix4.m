classdef Stratix4<eda.fpga.Altera





    methods

        function this=Stratix4(varargin)
            this.FPGAVendor='Altera';
            this.FPGAFamily='Stratix IV';

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
        function numclkin=getPllNumClkIn(~)
            numclkin='10';
        end

        function ibufgds(~,hC,diff_n,diff_p,out)
            ibufgds=hC.component(...
            'UniqueName','stratixiv_io_ibuf',...
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
