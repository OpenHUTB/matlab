



function newMap=i_invertMap(oldMap)
    newMap=containers.Map();
    if~isempty(oldMap)
        newMap=containers.Map(oldMap.values,oldMap.keys);
    end
end

