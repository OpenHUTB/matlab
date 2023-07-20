function hB=plugin_board_intel()





    hB=hdlcoder.Board('IsGenericIPPlatform',true);


    hB.BoardName='Generic Deep Learning Processor Intel';


    hB.FPGAVendor='Altera';
    hB.FPGAFamily='Arria 10';
    hB.FPGADevice='10AS066N3F40E2SG';
    hB.FPGAPackage='';
    hB.FPGASpeed='';


    hB.SupportedTool={'Altera QUARTUS II'};



    hB.hClockModule=hdlturnkey.ClockModuleIP('IsGenericIP',true);



    hB.addInterface(hdlturnkey.interface.AXI4('IsGenericIP',true));


    hB.addInterface(hdlturnkey.interface.AXI4Master(...
    'InterfaceID','AXI4 Master Activation Data',...
    'ReadSupport',true,...
    'WriteSupport',true,...
    'MaxDataWidth',512,...
    'AddrWidth',32,...
    'IsGenericIP',true));

    hB.addInterface(hdlturnkey.interface.AXI4Master(...
    'InterfaceID','AXI4 Master Weight Data',...
    'ReadSupport',true,...
    'WriteSupport',true,...
    'MaxDataWidth',512,...
    'AddrWidth',32,...
    'IsGenericIP',true));

    hB.addInterface(hdlturnkey.interface.AXI4Master(...
    'InterfaceID','AXI4 Master Debug',...
    'ReadSupport',true,...
    'WriteSupport',true,...
    'MaxDataWidth',512,...
    'AddrWidth',32,...
    'IsGenericIP',true));


    hB.addInterface(hdlturnkey.interface.AXI4Stream('IsGenericIP',true));


    hB.addInterface(hdlturnkey.interface.InterfaceExternal());


