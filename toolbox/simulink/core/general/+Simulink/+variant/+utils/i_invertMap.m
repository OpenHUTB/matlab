
function newMap=i_invertMap(origMap)



    newMap=containers.Map();
    origKeys=origMap.keys;
    for i=1:numel(origKeys)
        values=origMap(origKeys{i});
        for j=1:numel(values)
            Simulink.variant.utils.i_addKeyValueWithDupsToMap(newMap,values{j},origKeys{i});
        end
    end
end
