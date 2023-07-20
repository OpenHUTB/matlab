function tf=isMass(unit)






    [~,qdObj]=SimBiology.internal.getPhysicalQuantityFromComposition(unit);
    tf=qdObj.Mass~=0;
end