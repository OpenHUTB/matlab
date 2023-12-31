classdef MAX10<eda.fpga.Cyclone5




    methods
        function this=MAX10(varargin)
            this=this@eda.fpga.Cyclone5(varargin{:});
        end


        function ibufgds(~,hC,diff_n,diff_p,out)
            ibufgds=hC.component(...
            'UniqueName','fiftyfivenm_io_ibuf',...
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
