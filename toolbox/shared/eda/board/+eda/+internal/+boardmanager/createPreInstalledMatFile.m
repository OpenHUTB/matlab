function createPreInstalledMatFile(varargin)

    if nargin==0
        basePath=fullfile(matlabroot,'toolbox','shared','eda','board','resources');
    else
        basePath=varargin{1};
    end

    fileName=fullfile(basePath,'InstalledFPGABoards');
    if exist(fileName,'file')
        delete(fileName);
    end

    internalpath=fullfile(matlabroot,'toolbox','shared','eda','board','internal');
    addpath(internalpath);

    fpgaBoardObjects(1)=l_getBoardObj('XilinxML401','XilinxML401');
    fpgaBoardObjects(end+1)=l_getBoardObj('XilinxML402','XilinxML402');
    fpgaBoardObjects(end+1)=l_getBoardObj('XilinxML403','');
    fpgaBoardObjects(end+1)=l_getBoardObj('XilinxML505','');
    fpgaBoardObjects(end+1)=l_getBoardObj('XilinxML506','XilinxML506');
    fpgaBoardObjects(end+1)=l_getBoardObj('XilinxML507','');
    fpgaBoardObjects(end+1)=l_getBoardObj('XilinxML605','XilinxML605',false);
    fpgaBoardObjects(end+1)=l_getBoardObj('XilinxSP605','XilinxSP605');
    fpgaBoardObjects(end+1)=l_getBoardObj('XilinxSP601','');
    fpgaBoardObjects(end+1)=l_getBoardObj('XUPAtlys','XilinxXUPAtlys');
    fpgaBoardObjects(end+1)=l_getBoardObj('XilinxXUPV5','');
    fpgaBoardObjects(end+1)=l_getBoardObj('','XilinxSpartan3A');

    fpgaBoardObjects(end+1)=l_getBoardObj('AlteraDE2_115','AlteraDE2_115');
    fpgaBoardObjects(end+1)=l_getBoardObj('AlteraArriaIIGX','AlteraArriaIIGX');
    fpgaBoardObjects(end+1)=l_getBoardObj('AlteraCycloneIIIDev','AlteraCycloneIIIDev');
    fpgaBoardObjects(end+1)=l_getBoardObj('AlteraCycloneIVGX','AlteraCycloneIVGX');
    fpgaBoardObjects(end+1)=eda.internal.boardmanager.ReadFPGAFile(fullfile(internalpath,'AlteraNios2.xml'));%#ok<NASGU>

    save(fileName,'fpgaBoardObjects');

    rmpath(internalpath);

end

function board=l_getBoardObj(filClass,turnkeyClass,varargin)
    UseTurnkeyBoardClass=true;
    if nargin>2
        UseTurnkeyBoardClass=varargin{1};
    end

    board=eda.internal.boardmanager.FPGABoard;
    board.BoardFile='';

    if~isempty(filClass)
        board.FILBoardClass=['eda.board.',filClass];
        filObj=eval(board.FILBoardClass);
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
            interface=board.FPGA.addInterface(eda.internal.boardmanager.GMII.Name);
        case 'MII'
            interface=board.FPGA.addInterface(eda.internal.boardmanager.MII.Name);
        case 'RGMII'
            interface=board.FPGA.addInterface(eda.internal.boardmanager.RGMII.Name);
        end

        if isfield(filObj.Component,'PhyAddr')
            interface.setGenerateMDIOModule(true);
            interface.setPhyAddr(num2str(filObj.Component.PhyAddr));
        end

        signalNames=interface.getSignalNames;
        for m=1:numel(signalNames)
            tmp=signalNames{m};
            signal=interface.getSignal(tmp);
            sgName=signal.SignalName;
            interface.setPin(sgName,myStruct.(sgName));
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
            Clock.setPin('Clock_P',tkObj.hClockModule.ClockFPGAPin{1});
            Clock.setPin('Clock_N',tkObj.hClockModule.ClockFPGAPin{2});
        end
        Clock.setParam('Frequency',num2str(tkObj.hClockModule.ClockInputMHz));
        Clock.validate;

    end


    if~isempty(turnkeyClass)
        TurnkeyClass=['hdlturnkey.board.',turnkeyClass,'.plugin_board'];
        if UseTurnkeyBoardClass
            board.TurnkeyBoardClass=TurnkeyClass;
        else
            board.TurnkeyBoardClass='';
        end
        tkObj=eval(TurnkeyClass);
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
    board.validate;
end



