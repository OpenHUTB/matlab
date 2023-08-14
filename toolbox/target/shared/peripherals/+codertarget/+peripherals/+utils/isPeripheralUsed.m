function PeripheralUsed=isPeripheralUsed(ModelName,PeripheralType)




    peripheralEntries=codertarget.peripherals.utils.getPeripheralEntries(ModelName);
    if any(contains(peripheralEntries,PeripheralType))
        [~,pInfoData]=codertarget.peripherals.utils.getPeripheralInfoFromRefModels(ModelName);
        PeripheralUsed=~isempty(pInfoData)&&isstruct(pInfoData)&&isfield(pInfoData,PeripheralType);
    else
        PeripheralUsed=false;
    end
end

