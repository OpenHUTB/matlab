
function i_addKeyValueToMap(map,key,value)



    if map.isKey(key)
        map(key)=unique([map(key),value]);%#ok<NASGU>
    else
        map(key)=value;%#ok<NASGU>
    end
end
