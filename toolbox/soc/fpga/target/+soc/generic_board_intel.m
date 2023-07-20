function hB=generic_board_intel()





    hB=hdlcoder.Board('IsGenericIPPlatform',true);

    hB.BoardName='Generic Intel Platform for SoC Blockset';


    hB.FPGAVendor='Altera';
    hB.FPGAFamily='Cyclone V';
    hB.FPGADevice='5CSXFC6D6F31C6';
    hB.FPGAPackage='';
    hB.FPGASpeed='';


    hB.SupportedTool={'Altera QUARTUS II'};



    hB.hClockModule=hdlturnkey.ClockModuleIP('IsGenericIP',true);
    hB.hClockModule.InternalReset=true;






    hB.addInterface(hdlturnkey.interface.AXI4('IDWidth',14,'IsGenericIP',true));


    maxStreams=16;
    for nn=0:maxStreams-1
        hB.addInterface(hdlturnkey.interface.AXI4Stream(...
        'MasterChannelNumber',1,...
        'SlaveChannelNumber',1,...
        'IsGenericIP',true,...
        'InterfaceID',['AXI4-Stream ',num2str(nn)]));
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


