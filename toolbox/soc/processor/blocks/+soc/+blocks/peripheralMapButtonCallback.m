function dirty=peripheralMapButtonCallback(hMask,hDlg,tag,dlgType)%#ok<INUSD>




    dirty=false;

    codertarget.peripherals.utils.openPeripheralConfiguration(hMask.getConfigSet());

end
