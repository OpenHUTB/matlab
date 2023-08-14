function newState=createSFState(obj,parent)


    newState=createSFState@sd.execution.CompositeNode(obj,parent);

    obj.cleanUp.createSFState(obj.getParentState.cachedSFState);
end
