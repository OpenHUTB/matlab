function out=getFullSFObjectName(aSID)
    obj=Simulink.ID.getHandle(aSID);
    out='';%#ok




    if(isa(obj.getParent,'Stateflow.Chart'))
        out=obj.Name;
    else
        parentSID=Simulink.ID.getSID(obj.getParent);
        out=[slci.internal.getFullSFObjectName(parentSID)...
        ,'.'...
        ,obj.Name];
    end
end
