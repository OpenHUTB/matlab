function generateHDLForZynq(refMdlName,targetMappingInfo)



    params.workflow='IP Core Generation';
    params.defaultArchitectureName='Generic Xilinx Platform';
    params.supportBoards={'Xilinx Zynq ZC702 evaluation kit',...
    'Xilinx Zynq ZC706 evaluation kit','ZedBoard'};
    params.supportedInterface='AXI4-Lite';

    hdlce.generateHDLForIPCore(refMdlName,targetMappingInfo,params);
end
