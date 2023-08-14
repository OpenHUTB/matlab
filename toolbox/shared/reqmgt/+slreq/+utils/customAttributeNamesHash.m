
function out=customAttributeNamesHash(action,propNameOrHash)
    persistent hash2propNameMap;
    persistent propName2HashMap;

    switch action
    case 'hash'
        if isempty(hash2propNameMap)
            hash2propNameMap=containers.Map('KeyType','char','ValueType','char');
        end
        if isempty(propName2HashMap)
            propName2HashMap=containers.Map('KeyType','char','ValueType','char');
        end

        if isKey(propName2HashMap,propNameOrHash)
            out=propName2HashMap(propNameOrHash);
        else







            rawHash=char(mlreportgen.utils.hash(propNameOrHash));
            hashValue=['c_',rawHash];

            propName2HashMap(propNameOrHash)=hashValue;
            hash2propNameMap(hashValue)=propNameOrHash;
            out=hashValue;
        end

    case 'lookup'

        if~isempty(hash2propNameMap)&&isKey(hash2propNameMap,propNameOrHash)
            out=hash2propNameMap(propNameOrHash);
        else
            out=propNameOrHash;
        end
    case 'reset'
        clear hash2propNameMap;
        clear propName2HashMap;
    end

end