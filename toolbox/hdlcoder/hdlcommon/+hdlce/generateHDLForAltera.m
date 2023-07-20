function generateHDLForAltera(refMdlName,targetMappingInfo)



    params.workflow='IP Core Generation';
    params.defaultArchitectureName='Generic Altera Platform';
    params.supportBoards={'Altera Cyclone V SoC development kit - Rev.C',...
    'Altera Cyclone V SoC development kit - Rev.D',...
    'Arrow SoCKit development board'};
    params.supportedInterface='AXI4';

    hdlce.generateHDLForIPCore(refMdlName,targetMappingInfo,params);

end

