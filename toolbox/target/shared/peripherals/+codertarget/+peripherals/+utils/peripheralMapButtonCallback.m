function dirty=peripheralMapButtonCallback(hMask,hDlg,tag,dlgType)%#ok<INUSD>




    dirty=false;

    hCS=hMask.getConfigSet;

    selectedHardwareBoard=get_param(hCS,'HardwareBoard');

    savedHardwareBoard=get_param(hCS.getModel,'HardwareBoard');



    if matches(selectedHardwareBoard,savedHardwareBoard)
        codertarget.peripherals.utils.openPeripheralConfiguration(hMask.getConfigSet());
    else
        errordlg(message('codertarget:peripherals:HardwareBoardNotApplied',...
        message('codertarget:ui:PeripheralMappingBtnLabel').getString()).getString(),...
        "Apply changes",'replace');
    end

end
