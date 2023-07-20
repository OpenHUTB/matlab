function tf=hasConstellation(obj,evolutionTree)




    obj.validateConstellationMapInput(evolutionTree);
    tf=iskey(obj.ConstellationMap,evolutionTree);
end
