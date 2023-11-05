function boardObj=convertToFilObject(customBoardObj)

    switch customBoardObj.FPGA.Family
    case eda.internal.fpgadevice.getXilinxVivadoFPGAFamilies
        classname='Kintex7';
    case{'Cyclone IV E','Cyclone IV GX'}
        classname='Cyclone4';
    case{'Cyclone V'}
        classname='Cyclone5';
    case{'Cyclone III','Cyclone II'}
        classname='Cyclone3';
    case{'Arria II','Arria II GX'}
        classname='Arria2';
    case{'Arria V'}
        classname='ArriaV';
    case{'Stratix IV','Stratix III'}
        classname='Stratix4';
    case{'Stratix V'}
        classname='Stratix5';
    otherwise
        classname=strrep(customBoardObj.FPGA.Family,' ','');
    end
    classname=['eda.fpga.',classname];

    cmd=sprintf('%s(''FPGAFamily'',''%s'',''Device'',''%s'',''Speed'',''%s'',''Package'',''%s'')',...
    classname,customBoardObj.FPGA.Family,customBoardObj.FPGA.Device,customBoardObj.FPGA.Speed,customBoardObj.FPGA.Package);

    Component.PartInfo=eval(cmd);
    Component.ScanChain=customBoardObj.FPGA.JTAGChainPosition;
    boardObj=eda.board.CustomBoard(customBoardObj.BoardName,Component);

    if customBoardObj.FPGA.hasClock
        Clock=customBoardObj.FPGA.getInterface(eda.internal.boardmanager.ClockInterface.Name);
        Component.SYSCLK.Frequency=Clock.getFrequency;
        switch Clock.getParam('ClockType')
        case 'Differential'
            Component.SYSCLK.Type='DIFF';
        otherwise
            Component.SYSCLK.Type='SINGLE_ENDED';
        end

        interface=Clock;
        if strcmpi(interface.getParam('ClockType'),'Differential')
            tmp1=interface.getSignal('Clock_P');
            tmp2=interface.getSignal('Clock_N');
            boardObj.addPinMap('sysclk_p',tmp1.FPGAPin,tmp1.IOStandard);
            boardObj.addPinMap('sysclk_n',tmp2.FPGAPin,tmp2.IOStandard);
        else
            tmp=interface.getSignal('Clock');
            boardObj.addPinMap('sysclk',tmp.FPGAPin,tmp.IOStandard);
        end
    end

    if customBoardObj.FPGA.hasReset
        interface=customBoardObj.FPGA.getInterface(eda.internal.boardmanager.ResetInterface.Name);
        tmp=interface.getSignal('Reset');
        boardObj.addPinMap('sysrst',tmp.FPGAPin,tmp.IOStandard);
        if strcmpi(interface.getParam('ActiveLevel'),'Active-Low')
            Component.SYSRST.Polarity='Active_Low';
        else
            Component.SYSRST.Polarity='Active_High';
        end
    end

    Component.UseDigilentPlugin=customBoardObj.FPGA.UseDigilentPlugIn;

    list=customBoardObj.FPGA.getInterfaceList;
    for m=1:numel(list)
        interface=customBoardObj.FPGA.getInterface(list{m});
        if isa(interface,'eda.internal.boardmanager.ClockInterface')...
            ||isa(interface,'eda.internal.boardmanager.ResetInterface')

            continue;
        end
        if isa(interface,'eda.internal.boardmanager.FILCommInterface')
            Component.Communication_Channel=interface.Communication_Channel;
        end
        if isa(interface,'eda.internal.boardmanager.PCIe')
            Component.MAC_Component_Name=interface.MAC_Component_Name;
        end
        if isa(interface,'eda.internal.boardmanager.EthInterface')
            if interface.isMDIOModuleEnabled
                Component.PhyAddr=str2double(interface.getPhyAddr);
            end
        end

        signalNames=interface.getSignalNames;
        for k=1:numel(signalNames)
            tmp=signalNames{k};
            signal=interface.getSignal(tmp);
            boardObj.addPinMap(tmp,signal.getPinsInFilFormat,signal.IOStandard);
        end
        if~isempty(customBoardObj.WorkflowOptions)
            boardObj.WorkflowOptions=customBoardObj.WorkflowOptions;
        end
        if~isempty(customBoardObj.ConnectionOptions)
            boardObj.ConnectionOptions=customBoardObj.ConnectionOptions;
        end
        if~isempty(customBoardObj.ProgramFPGAOptions)
            boardObj.ProgramFPGAOptions=customBoardObj.ProgramFPGAOptions;
        end

        if strcmp(customBoardObj.BoardName,'Altera Cyclone IV GX FPGA development kit')

            Component.PartInfo.RGMII_TX_PhaseShift=500;
        end

        boardObj.setComponent(Component);


    end

end




