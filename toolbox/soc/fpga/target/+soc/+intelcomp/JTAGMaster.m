classdef JTAGMaster<soc.intelcomp.IntelComponentBase
    properties
    end

    methods
        function obj=JTAGMaster
            obj.addClk('AXI_Manager.aclk','SystemClk');
            obj.addRst('AXI_Manager.aresetn','SystemRstn');
            obj.addAXI4Master('AXI_Manager.axm_m0','all','sys');
            obj.Instance=[...
            'add_instance AXI_Manager AXI_Manager\n',...
            'set_instance_parameter_value AXI_Manager {ID_WIDTH} {1}\n',...
            'set_instance_parameter_value AXI_Manager {AXI_DATA_WIDTH} {32}\n',...
'set_instance_parameter_value AXI_Manager {AXI_ADDR_WIDTH} {32}\n'...
            ];
        end
    end

end