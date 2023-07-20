function addConstellation(obj,tree,constellation)




    assert(isequal(nargin,3));
    obj.validateConstellationMapInput(tree);
    obj.ConstellationMap(tree.Id)=constellation;
end
