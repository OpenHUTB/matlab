


function lutObjs=getWSLookupTableObjects(config)
    ws_vars=config.getWSVarInfoTable.values;
    lutObjs=containers.Map('KeyType','char','ValueType','any');
    for i=1:numel(ws_vars)
        vars=ws_vars{i}.values;
        for j=1:numel(vars)
            if strcmpi(vars{j}.DataType,'Simulink.LookupTable')...
                &&~isKey(lutObjs,vars{j}.RTWName)
                lutObjs(vars{j}.RTWName)=...
                slci.internal.getValueFromLookupTableObject(vars{j}.InitialValue,vars{j}.RTWName);
            end
        end
    end
end