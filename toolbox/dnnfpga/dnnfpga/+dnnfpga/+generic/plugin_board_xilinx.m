function hB=plugin_board_xilinx()





    hB=hdlcoder.Board('IsGenericIPPlatform',true);


    hB.BoardName='Generic Deep Learning Processor Xilinx';


    hB.FPGAVendor='Xilinx';
    hB.FPGAFamily='Zynq UltraScale+';
    hB.FPGADevice='xczu9eg-ffvb1156-2-e';
    hB.FPGAPackage='';
    hB.FPGASpeed='';


    hB.SupportedTool={'Xilinx Vivado'};



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

    hB.addInterface(hdlturnkey.interface.AXI4StreamVideo('IsGenericIP',true));


    hB.addInterface(hdlturnkey.interface.InterfaceExternal());


