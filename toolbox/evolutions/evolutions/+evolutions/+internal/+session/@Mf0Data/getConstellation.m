function constellation=getConstellation(obj,evolutionTree)




    obj.validateConstellationMapInput(evolutionTree);
    if isKey(obj.ConstellationMap,evolutionTree.Id)
        constellation=obj.ConstellationMap(evolutionTree.Id);
    else
        constellation=[];
    end
end
