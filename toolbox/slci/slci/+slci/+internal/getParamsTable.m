function[out]=getParamsTable(config,blkH)

    out=containers.Map;
    key=slci.internal.constructKeyForParamsTable(blkH);

    paramsTable=config.getParamsTable();

    if~isempty(paramsTable)&&isKey(paramsTable,key)
        out=paramsTable(key);
    end

end