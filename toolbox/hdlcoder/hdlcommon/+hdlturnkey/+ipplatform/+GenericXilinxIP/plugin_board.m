function hB=plugin_board()





    hB=hdlcoder.Board('IsGenericIPPlatform',true);


    hB.BoardName='Generic Xilinx Platform';


    hB.FPGAVendor='Xilinx';
    hB.FPGAFamily='Zynq';
    hB.FPGADevice='xc7z020';
    hB.FPGAPackage='clg484';
    hB.FPGASpeed='-1';


    hB.SupportedTool={'Xilinx Vivado','Xilinx ISE'};



    hB.hClockModule=hdlturnkey.ClockModuleIP('IsGenericIP',true);





    hB.addInterface(hdlturnkey.interface.AXI4Lite('IsGenericIP',true));

    hB.addInterface(hdlturnkey.interface.AXI4('IsGenericIP',true));

    hB.addInterface(hdlturnkey.interface.AXI4Stream('IsGenericIP',true));

    hB.addInterface(hdlturnkey.interface.AXI4StreamVideo('IsGenericIP',true));

    hB.addInterface(hdlturnkey.interface.AXI4Master('IsGenericIP',true));

    hB.addInterface(hdlturnkey.interface.AXIVDMAIn());

    hB.addInterface(hdlturnkey.interface.AXIVDMAOut());

    hB.addInterface(hdlturnkey.interface.InterfaceExternal());


    if exist('hdlturnkey.interface.JTAGDataCapture','class')
        hB.addInterface(hdlturnkey.interface.JTAGDataCapture());
    end
