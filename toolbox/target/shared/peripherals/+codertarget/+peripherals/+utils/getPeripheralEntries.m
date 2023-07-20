function peripheralEntries=getPeripheralEntries(modelName)




    if ischar(modelName)
        hCS=getActiveConfigSet(modelName);
    else
        hCS=modelName;
    end
    defFile=codertarget.peripherals.utils.getDefFileNameForBoard(hCS);
    pInfo=codertarget.peripherals.PeripheralInfo(defFile);
    peripheralEntries=getListOfPeripherals(pInfo);
end

