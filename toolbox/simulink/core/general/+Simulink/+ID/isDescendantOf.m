function b=isDescendantOf(parentSID,sid)




    narginchk(2,2);
    if~Simulink.ID.isValid(parentSID)
        DAStudio.error('Simulink:utility:objectDestroyed');
    end
    if~Simulink.ID.isValid(sid)
        DAStudio.error('Simulink:utility:objectDestroyed');
    end

    b=false;
    sid=Simulink.ID.getHierarchicalParent(sid);
    while sid~=""
        if strcmp(sid,parentSID)
            b=true;
            return
        end
        sid=Simulink.ID.getHierarchicalParent(sid);
    end
