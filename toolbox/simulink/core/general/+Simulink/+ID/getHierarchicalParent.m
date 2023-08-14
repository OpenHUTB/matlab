function parentSID=getHierarchicalParent(sid)




    narginchk(1,1);

    if~Simulink.ID.isValid(sid)
        DAStudio.error('Simulink:utility:objectDestroyed');
    end
    h=Simulink.ID.getHandle(sid);


    if isempty(h)
        parentSID='';
        return;
    end
    if isnumeric(h)
        h=get_param(h,'Object');
    end

    parent=h.getParent;
    if~isa(parent,'Simulink.Root')
        parentSID=Simulink.ID.getSID(parent);
    else
        parentSID='';
    end


