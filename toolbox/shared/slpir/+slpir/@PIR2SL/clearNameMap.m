function clearNameMap(~)
    nMap=slpir.PIR2SL.getNameMapSingletonInstance;
    if nMap.isempty
        return;
    end
    keys=nMap.keys;
    nMap.remove(keys);
end
