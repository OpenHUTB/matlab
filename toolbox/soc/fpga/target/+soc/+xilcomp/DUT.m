classdef DUT<soc.xilcomp.XilinxComponentBase
    properties
Name
Version
AXIInterface
    end

    methods
        function obj=DUT(name,ver)
            obj.Name=name;
            obj.Version=ver;
            obj.addClk([name,'/IPCORE_CLK'],'IPCoreClk');
            obj.addClk([name,'/AXI4_Lite_ACLK'],'IPCoreClk');
            obj.addRst([name,'/IPCORE_RESETN'],'IPCoreRstn');
            obj.addRst([name,'/AXI4_Lite_ARESETN'],'IPCoreRstn');
            obj.Instance=[...
            'set ',name,' [create_bd_cell -vlnv mathworks.com:ip:',name,':',ver,' ',name,']\n'];
        end
    end
end
