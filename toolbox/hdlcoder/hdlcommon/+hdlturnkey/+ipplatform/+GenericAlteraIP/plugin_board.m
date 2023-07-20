function hB=plugin_board()





    hB=hdlcoder.Board('IsGenericIPPlatform',true);


    hB.BoardName='Generic Altera Platform';


    hB.FPGAVendor='Altera';
    hB.FPGAFamily='Arria 10';
    hB.FPGADevice='10AS066N3F40E2SG';
    hB.FPGAPackage='';
    hB.FPGASpeed='';


    hB.SupportedTool={'Altera QUARTUS II','Intel Quartus Pro'};



    hB.hClockModule=hdlturnkey.ClockModuleIP('IsGenericIP',true);





    hB.addInterface(hdlturnkey.interface.AXI4('IsGenericIP',true));

    hB.addInterface(hdlturnkey.interface.AXI4Stream('IsGenericIP',true));

    hB.addInterface(hdlturnkey.interface.InterfaceExternal());

    hB.addInterface(hdlturnkey.interface.AXI4Master('IsGenericIP',true));


    if exist('hdlturnkey.interface.JTAGDataCapture','class')
        hB.addInterface(hdlturnkey.interface.JTAGDataCapture());
    end


