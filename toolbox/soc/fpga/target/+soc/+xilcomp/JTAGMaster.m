classdef JTAGMaster<soc.xilcomp.XilinxComponentBase
    properties
    end

    methods
        function obj=JTAGMaster
            obj.addClk('jtag_axi/aclk','SystemClk');
            obj.addRst('jtag_axi/aresetn','SystemRstn');
            obj.addAXI4Master('jtag_axi/axi4m','all','sys');
            obj.Instance='set jtag_axi [create_bd_cell -vlnv mathworks.com:ip:hdlverifier_axi_manager:*.* jtag_axi]\n';
        end
    end

end