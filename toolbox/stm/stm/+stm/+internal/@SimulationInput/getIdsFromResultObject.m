

function ids=getIdsFromResultObject(resultObject)
    ids=stm.internal.getResultObjectProp(resultObject.getID,'getVectorPath');
end
