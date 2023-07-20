function names=getaction_names(h)



    persistent actionNames;

    if isempty(actionNames)
        actionNames=fields(h.actions);
    end
    names=actionNames;

