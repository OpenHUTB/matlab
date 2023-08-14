function createPreInstalledXMLFiles(varargin)



    if nargin==0
        basePath=fullfile(matlabroot,'toolbox','shared','eda','board','boardfiles');
    else
        basePath=varargin{1};
    end
    l_createXMLfile(basePath,'XilinxML401.xml','XilinxML401','XilinxML401');
    l_createXMLfile(basePath,'XilinxML402.xml','XilinxML402','XilinxML402');
    l_createXMLfile(basePath,'XilinxML403.xml','XilinxML403','');
    l_createXMLfile(basePath,'XilinxML505.xml','XilinxML505','');
    l_createXMLfile(basePath,'XilinxML506.xml','XilinxML506','XilinxML506');
    l_createXMLfile(basePath,'XilinxML507.xml','XilinxML507','');
    l_createXMLfile(basePath,'XilinxML605.xml','XilinxML605','');
    l_createXMLfile(basePath,'XilinxSP605.xml','XilinxSP605','XilinxSP605');
    l_createXMLfile(basePath,'XilinxSP601.xml','XilinxSP601','');
    l_createXMLfile(basePath,'XUPAtlys.xml','XUPAtlys','XilinxXUPAtlys');
    l_createXMLfile(basePath,'XilinxSpartan3A.xml','','XilinxSpartan3A');

    l_createXMLfile(basePath,'AlteraDE2_115.xml','AlteraDE2_115','AlteraDE2_115');
    l_createXMLfile(basePath,'AlteraArriaIIGX.xml','AlteraArriaIIGX','AlteraArriaIIGX');
    l_createXMLfile(basePath,'AlteraCycloneIIIDev.xml','AlteraCycloneIIIDev','AlteraCycloneIIIDev');
    l_createXMLfile(basePath,'AlteraCycloneIVGX.xml','AlteraCycloneIVGX','AlteraCycloneIVGX');
end

function l_createXMLfile(basePath,fileName,filClass,turnkeyClass)

    fileName=fullfile(basePath,fileName);
    board=eda.internal.boardmanager.FPGABoard;
    board.BoardFile=fileName;

    if~isempty(filClass)
        filObj=eval(['eda.board.',filClass]);
        filObj.setPIN(1);

        board.BoardName=filObj.Name;
        board.FPGA.Vendor=filObj.Component(1).PartInfo.FPGAVendor;
        board.FPGA.Family=filObj.Component(1).PartInfo.FPGAFamily;
        board.FPGA.Device=filObj.Component(1).PartInfo.FPGADevice;
        board.FPGA.Package=filObj.Component(1).PartInfo.FPGAPackage;
        board.FPGA.Speed=filObj.Component(1).PartInfo.FPGASpeed;
        board.FPGA.JTAGChainPosition=filObj.Component(1).ScanChain;
        if strcmpi(filClass,'XUPAtlys')
            board.FPGA.UseDigilentPlugIn=true;
        end

        Clock=board.FPGA.addInterface(eda.internal.boardmanager.ClockInterface.Name);
        if strcmpi(filObj.Component(1).SYSCLK.Type,'single_ended')
            Clock.setParam('ClockType','Single-Ended');
            Clock.setPin('Clock',filObj.Component.PINOUT.sysclk);
        else
            Clock.setParam('ClockType','Differential');
            Clock.setPin('Clock_P',filObj.Component.PINOUT.sysclk_p);
            Clock.setPin('Clock_N',filObj.Component.PINOUT.sysclk_n);
        end
        Clock.setParam('Frequency',num2str(filObj.Component.SYSCLK.Frequency));
        Clock.validate;

        if isfield(filObj.Component.PINOUT,'sysrst')
            rst=board.FPGA.addInterface('Reset');
            rst.setPin('Reset',filObj.Component.PINOUT.sysrst)
            if strcmpi(filObj.Component.SYSRST.Polarity,'ACTIVE_LOW')
                rst.setParam('ActiveLevel','Active-Low');
            else
                rst.setParam('ActiveLevel','Active-High');
            end
        end

        names=fieldnames(filObj.Component.PINOUT);
        for m=1:numel(names)
            field=names{m};
            if iscell(filObj.Component.PINOUT.(field))
                myStruct.(field)=sprintf('%s,',filObj.Component.PINOUT.(field){:});
                myStruct.(field)(end)='';
            else
                myStruct.(field)=filObj.Component.PINOUT.(field);
            end
        end

        switch filObj.Component.Communication_Channel
        case 'GMII'
            interface=board.FPGA.addInterface('Gigabit Ethernet - GMII');
            interface.setPin('RXCLK',myStruct.ETH_RXCLK);
            interface.setPin('RXD',myStruct.ETH_RXD);
            interface.setPin('RXDV',myStruct.ETH_RXDV);
            interface.setPin('RXER',myStruct.ETH_RXER);
            interface.setPin('TXD',myStruct.ETH_TXD);
            interface.setPin('GTXCLK',myStruct.ETH_GTXCLK);
            interface.setPin('TXEN',myStruct.ETH_TXEN);
            interface.setPin('TXER',myStruct.ETH_TXER);
            interface.setPin('COL',myStruct.ETH_COL);
            interface.setPin('CS',myStruct.ETH_CRS);
            interface.setPin('MDC',myStruct.ETH_MDC);
            interface.setPin('MDIO',myStruct.ETH_MDIO);
        case 'RGMII'
            interface=board.FPGA.addInterface('Gigabit Ethernet - RGMII');
            interface.setPin('RXC',myStruct.ETH_RXCLK);
            interface.setPin('RD',myStruct.ETH_RXD);
            interface.setPin('RX_CTL',myStruct.ETH_RX_CTL);
            interface.setPin('TD',myStruct.ETH_TXD);
            interface.setPin('TXC',myStruct.ETH_GTXCLK);
            interface.setPin('TX_CTL',myStruct.ETH_TX_CTL);
            interface.setPin('MDC',myStruct.ETH_MDC);
            interface.setPin('MDIO',myStruct.ETH_MDIO);
        end
    else
        tkObj=eval(['hdlturnkey.board.',turnkeyClass,'.plugin_board']);

        board.BoardName=tkObj.BoardName;
        board.FPGA.Vendor=tkObj.FPGAVendor;
        board.FPGA.Family=tkObj.FPGAFamily;
        board.FPGA.Device=tkObj.FPGADevice;
        board.FPGA.Package=tkObj.FPGAPackage;
        board.FPGA.Speed=tkObj.FPGASpeed;
        board.FPGA.JTAGChainPosition=tkObj.hDeviceConfig.DevicePositionInChain;

        Clock=board.FPGA.addInterface(eda.internal.boardmanager.ClockInterface.Name);
        if~tkObj.hClockModule.ClockTypeDiff
            Clock.setParam('ClockType','Single-Ended');
            Clock.setPin('Clock',tkObj.hClockModule.ClockFPGAPin);
        else
            Clock.setParam('ClockType','Differential');
            Clock.setPin('Clock_p',tkObj.hClockModule.ClockFPGAPin{1});
            Clock.setPin('Clock_n',tkObj.hClockModule.ClockFPGAPin{2});
        end
        Clock.setParam('Frequency',num2str(tkObj.hClockModule.ClockInputMHz));
        Clock.validate;

    end


    if~isempty(turnkeyClass)
        tkObj=eval(['hdlturnkey.board.',turnkeyClass,'.plugin_board']);
        interface=board.FPGA.addInterface('User-defined I/O interface');
        allDesc=tkObj.getInterfaceIDList;
        EmptyInterfaceID='No Interface Specified';
        CustomInterfaceID='Specify FPGA Pin {''LSB'',...,''MSB''}';

        for m=1:numel(allDesc)
            desc=allDesc{m};
            if strcmp(desc,EmptyInterfaceID)||strcmp(desc,CustomInterfaceID)
                continue;
            end
            tkSignal=tkObj.getInterface(desc);
            name=tkSignal.PortName;
            direction=lower(char(tkSignal.InterfaceType));
            bitwidth=tkSignal.PortWidth;
            signal=interface.addSignal(name);
            signal.Description=desc;
            signal.Direction=direction;
            signal.BitWidth=bitwidth;
            signal.FPGAPin=sprintf('%s,',tkSignal.FPGAPin{:});
            if signal.FPGAPin(end)==','
                signal.FPGAPin(end)='';
            end
            signal.validate;
        end
    end

    eda.internal.boardmanager.SaveFPGAFile(board);
end


