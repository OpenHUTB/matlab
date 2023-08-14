function removeConstellation(obj,evolutionTree)




    obj.validateConstellationMapInput(evolutionTree);

    if isKey(obj.ConstellationMap,evolutionTree)
        remove(obj.ConstellationMap,evolutionTree);
    end
end
