function i_addKeyValueWithDupsToMap(map,key,value)








    if map.isKey(key)

        map(key)=[map(key),value];%#ok<NASGU>
    else
        map(key)={value};%#ok<NASGU>
    end
end
