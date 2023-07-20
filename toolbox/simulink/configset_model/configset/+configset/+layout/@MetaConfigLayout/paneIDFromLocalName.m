function id=paneIDFromLocalName(obj,name)








    if isempty(obj.LocalNameMap)
        obj.LocalNameMap=containers.Map('KeyType','char','ValueType','char');
        loc_initLocalNameMap(obj);
    end
    if obj.LocalNameMap.isKey(name)
        id=obj.LocalNameMap(name);
    else
        id='';
    end

end



function loc_initLocalNameMap(obj)
    paneIds=obj.EnglishNameMap.values;
    for i=1:length(paneIds)
        obj.LocalNameMap(obj.getPaneDisplay(paneIds{i}))=paneIds{i};
    end
end

