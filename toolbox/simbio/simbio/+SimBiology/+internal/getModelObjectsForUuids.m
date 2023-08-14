









function objects=getModelObjectsForUuids(model,uuids)

    allObjects=SimBiology.internal.getAllQuantityObjects(model);
    allUuids=get(allObjects,{'UUID'});

    allIndices=num2cell(1:numel(allUuids));
    map=containers.Map(allUuids,allIndices);
    matchingIndicies=cell2mat(values(map,uuids));
    objects=allObjects(matchingIndicies);
end