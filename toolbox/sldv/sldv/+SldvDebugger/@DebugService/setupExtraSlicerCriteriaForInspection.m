






function sliceCriteria=setupExtraSlicerCriteriaForInspection(obj)



    mapKey=obj.getCriteriaMapKey(0);
    criteriaIndex=obj.getCriteriaIndex(mapKey);
    if~isempty(criteriaIndex)
        sliceCriteria=obj.criteriaMap(mapKey);
    else

        sliceCriteria=obj.addSliceCriteriaForDebugWorkflows('criterionColor','Red');
    end


    obj.criteriaMap(mapKey)=sliceCriteria;


    startingPoints=sliceCriteria.getUserStarts;
    exclusionPoints=sliceCriteria.getUserExclusions;
    for i=1:length(startingPoints)
        sliceCriteria.removeStart(startingPoints(i).Handle);
    end
    for i=1:length(exclusionPoints)
        sliceCriteria.removeExclusion(exclusionPoints(i).Handle);
    end
    sliceCriteria.refresh;
end
