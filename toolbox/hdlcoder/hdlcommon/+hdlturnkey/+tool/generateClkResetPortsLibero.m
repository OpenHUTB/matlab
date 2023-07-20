function generateClkResetPortsLibero(fid,topModuleFile,isAXI4LiteInterface)




    if isAXI4LiteInterface


        portlist_clk={
        {'AXI4_Lite_ACLK','clk','Input','1'},...
        };

        portlist_reset={
        {'AXI4_Lite_ARESETN','reset_n','Input','1'},...
        };
    else

        portlist_clk={
        {'AXI4_ACLK','clk','Input','1'},...
        };

        portlist_reset={
        {'AXI4_ARESETN','reset_n','Input','1'},...
        };

    end
    hdlturnkey.tool.generateLiberoTclInterfaceDefinition(fid,'axi_clk',hdlturnkey.IOType.IN,'clock',portlist_clk,topModuleFile);
    hdlturnkey.tool.generateLiberoTclInterfaceDefinition(fid,'axi_reset',hdlturnkey.IOType.IN,'reset',portlist_reset,topModuleFile);

end
