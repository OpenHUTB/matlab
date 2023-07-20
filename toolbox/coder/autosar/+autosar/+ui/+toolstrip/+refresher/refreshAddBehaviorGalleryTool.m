function refreshAddBehaviorGalleryTool(cbinfo,action)






    if isvalid(action)
        action.enabled=autosar.composition.studio.ActionStateGetter.getStateForAction(action.name,cbinfo);
    end


