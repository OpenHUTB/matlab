function hB=plugin_board()





    hB=hdlcoder.Board('IsGenericIPPlatform',true);


    hB.BoardName='Generic Microchip Platform';


    hB.FPGAVendor='Microchip';
    hB.FPGAFamily='SmartFusion2';
    hB.FPGADevice='M2S150TS';
    hB.FPGAPackage='1152 FC';
    hB.FPGASpeed='-1';


    hB.SupportedTool={'Microchip Libero SoC'};



    hB.hClockModule=hdlturnkey.ClockModuleIP('IsGenericIP',true);





    hB.addInterface(hdlturnkey.interface.AXI4('IsGenericIP',true));

    hB.addInterface(hdlturnkey.interface.InterfaceExternal());

    hB.addInterface(hdlturnkey.interface.AXI4Master('IsGenericIP',true));

    hB.addInterface(hdlturnkey.interface.AXI4Lite('IsGenericIP',true));



