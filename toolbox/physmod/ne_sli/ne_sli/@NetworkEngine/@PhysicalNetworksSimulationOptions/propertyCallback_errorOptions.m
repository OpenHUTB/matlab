function propertyCallback_errorOptions(this,eventData)






    owner=eventData.AffectedObject;
    event=eventData.Type;

    switch event
    case 'PropertyPostSet'
        dirtyModel=pmsl_private('pmsl_markmodeldirty');
        dirtyModel(owner.getBlockDiagram);
    otherwise
        pm_assert(0,'unsupported callback in propertyCallback_errorOptions');
    end





