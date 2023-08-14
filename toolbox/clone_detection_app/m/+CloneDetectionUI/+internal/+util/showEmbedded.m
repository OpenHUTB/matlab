function showEmbedded(obj,dockposition,dockoption)




    modelName=getfullname(obj.model);
    src=simulinkcoder.internal.util.getSource(modelName);
    component=src.studio.getComponent(obj.comp,obj.id);

    if isempty(component)
        DAStudio.openEmbeddedDDGForSource(src.studio,obj,obj.id,...
        obj.title,dockposition,dockoption);
    else
        src.studio.showComponent(component);
        src.studio.setActiveComponent(component);
    end
end