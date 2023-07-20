classdef DUT<soc.intelcomp.IntelComponentBase
    properties
Name
Version
AXIInterface
    end

    methods
        function obj=DUT(name,ver)
            obj.Name=name;
            obj.Version=ver;
            obj.addClk([name,'.ip_clk'],'IPCoreClk');
            obj.addClk([name,'.axi_clk'],'IPCoreClk');
            obj.addRst([name,'.ip_rst'],'IPCoreRstn');
            obj.addRst([name,'.axi_reset'],'IPCoreRstn');
            obj.Instance=['add_instance ',name,' ',name,' ',ver,'\n'];
        end
    end
end
