function hP=convertToTurnkeyObject(boardObj)




    if~isempty(boardObj.TurnkeyBoardClass)
        hP=eval(boardObj.TurnkeyBoardClass);
        return;
    end

    hP=hdlturnkey.PluginBoard;


    hP.BoardName=boardObj.BoardName;


    hP.FPGAVendor=boardObj.FPGA.Vendor;
    hP.FPGAFamily=boardObj.FPGA.Family;
    hP.FPGADevice=boardObj.FPGA.Device;
    hP.FPGAPackage=boardObj.FPGA.Package;
    hP.FPGASpeed=boardObj.FPGA.Speed;


    devicePositionInChain=boardObj.FPGA.JTAGChainPosition;
    switch hP.FPGAVendor
    case 'Altera'
        hP.RequiredTool={'Altera QUARTUS II'};
        hP.ConstrainFileNamePostfix='top.sdc';
        hP.PinAssignFileNamePostfix='top.qsf';
        hP.hDeviceConfig=hdlturnkey.DeviceConfigQuartus(devicePositionInChain);
    otherwise
        hP.RequiredTool={'Xilinx ISE'};
        hP.ConstrainFileNamePostfix='top.ucf';
        hP.hDeviceConfig=hdlturnkey.DeviceConfigiMPACT(devicePositionInChain,boardObj.FPGA.UseDigilentPlugIn);
    end



    hP.TopLevelNamePostfix='top';


    clock=boardObj.FPGA.getClock;

    switch hP.FPGAVendor
    case 'Altera'
        pllname='hdlturnkey.AlteraPLL';
    otherwise
        pllname='hdlturnkey.ClockModuleXilinx';
    end

    if clock.isDiffClock
        pllarg={'ClockPortName',{'CLKIN_P','CLKIN_N'}};
        pllarg=[pllarg,'ClockFPGAPin',{clock.getClkPin}];
        pllarg=[pllarg,'ClockType','DIFF'];
        clksignal=clock.getSignal('Clock_P');
    else
        pllarg={'ClockPortName','CLKIN'};
        pllarg=[pllarg,'ClockFPGAPin',clock.getClkPin];
        clksignal=clock.getSignal('Clock');
    end
    pllarg=[pllarg,'ClockInputMHz',clock.getFrequency];

    if boardObj.FPGA.hasReset
        reset=boardObj.FPGA.getReset;
        pllarg=[pllarg,'ResetPortName','RESETIN'];
        pllarg=[pllarg,'ResetActiveLow',reset.isActiveLow];
        pllarg=[pllarg,'ResetFPGAPin',reset.getResetPin];
    end

    hP.hClockModule=feval(pllname,pllarg{:});
    l_setIOStandard(hP.hClockModule,'ClockIOConstrain',clksignal,hP.FPGAVendor);

    if boardObj.FPGA.hasReset
        rstsignal=reset.getSignal('Reset');
        l_setIOStandard(hP.hClockModule,'ResetIOConstrain',rstsignal,hP.FPGAVendor);
    end

    if boardObj.FPGA.hasUserIO
        userio=boardObj.FPGA.getUserIO;
        signalNames=userio.getSignalNames;
        for m=1:numel(signalNames)
            signal=userio.getSignal(signalNames{m});
            interface=hdlturnkey.interface.InterfaceIO(...
            'InterfaceID',sprintf('%s (%s)',signal.SignalName,signal.Description),...
            'InterfaceType',signal.Direction,...
            'PortName',signal.SignalName,...
            'PortWidth',signal.BitWidth,...
            'FPGAPin',signal.getPinsInTurnkeyFormat);
            l_setIOStandard(interface,'IOPadConstraint',signal,hP.FPGAVendor);
            hP.addInterface(interface);
        end
    end

end

function l_setIOStandard(interface,prop,signal,FPGAVendor)
    if~isempty(signal.IOStandard)
        if strcmpi(FPGAVendor,'Xilinx')
            interface.(prop)={['IOStandard = ',signal.IOStandard]};
        else
            interface.(prop)={['IO_STANDARD "',signal.IOStandard,'"']};
        end
    end
end



