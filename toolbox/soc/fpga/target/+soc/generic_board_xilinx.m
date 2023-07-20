function hB=generic_board_xilinx()





    hB=hdlcoder.Board('IsGenericIPPlatform',true);

    hB.BoardName='Generic Xilinx Platform for SoC Blockset';


    hB.FPGAVendor='Xilinx';
    hB.FPGAFamily='Zynq';
    hB.FPGADevice='xc7z020';
    hB.FPGAPackage='clg484';
    hB.FPGASpeed='-1';


    hB.SupportedTool={'Xilinx Vivado'};



    hB.hClockModule=hdlturnkey.ClockModuleIP('IsGenericIP',true);
    hB.hClockModule.InternalReset=true;



    hB.addInterface(hdlturnkey.interface.AXI4Lite('IsGenericIP',true));

    hB.addInterface(hdlturnkey.interface.AXI4('IsGenericIP',true));


    maxStreams=16;
    for nn=0:maxStreams-1
        hB.addInterface(hdlturnkey.interface.AXI4Stream(...
        'MasterChannelNumber',1,...
        'SlaveChannelNumber',1,...
        'IsGenericIP',true,...
        'InterfaceID',['AXI4-Stream ',num2str(nn)]));
    end


    maxVideoStreams=16;
    for nn=0:maxVideoStreams-1
        hB.addInterface(hdlturnkey.interface.AXI4StreamVideo(...
        'MasterChannelNumber',1,...
        'SlaveChannelNumber',1,...
        'IsGenericIP',true,...
        'InterfaceID',['AXI4-Stream Video ',num2str(nn)]));
    end


    maxMasters=16;
    for nn=0:maxMasters-1
        if exist(fullfile('./dutIntfInfo.mat'),'file')
            load(fullfile('./dutIntfInfo.mat'),'dutIntfInfo');
            rdIntf=['AXI4 Master ',num2str(nn),' Read'];
            wrIntf=['AXI4 Master ',num2str(nn),' Write'];

            if isKey(dutIntfInfo,rdIntf)&&isKey(dutIntfInfo,wrIntf)

                hB.addInterface(hdlturnkey.interface.AXI4Master(...
                'InterfaceID',['AXI4 Master ',num2str(nn)],...
                'DefaultReadBaseAddr',dutIntfInfo(rdIntf),...
                'DefaultWriteBaseAddr',dutIntfInfo(wrIntf),...
                'IsGenericIP',true));

            elseif isKey(dutIntfInfo,rdIntf)

                hB.addInterface(hdlturnkey.interface.AXI4Master(...
                'InterfaceID',['AXI4 Master ',num2str(nn)],...
                'DefaultReadBaseAddr',dutIntfInfo(rdIntf),...
                'DefaultWriteBaseAddr',dutIntfInfo(rdIntf),...
                'IsGenericIP',true));


            elseif isKey(dutIntfInfo,wrIntf)

                hB.addInterface(hdlturnkey.interface.AXI4Master(...
                'InterfaceID',['AXI4 Master ',num2str(nn)],...
                'DefaultWriteBaseAddr',dutIntfInfo(wrIntf),...
                'DefaultReadBaseAddr',dutIntfInfo(wrIntf),...
                'IsGenericIP',true));

            end
        end
    end





    hB.addInterface(hdlturnkey.interface.InterfaceExternal());


