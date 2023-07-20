function showEmbeddedDlg(obj,dockposition,dockoption)

    component=obj.cbInfoObj.studio.getComponent(obj.comp,obj.id);
    if isempty(component)
        DAStudio.openEmbeddedDDGForSource(obj.cbInfoObj.studio,obj,obj.id,...
        obj.title,dockposition,dockoption);
    else
        if component.isVisible
            obj.studio.showComponent(component);
            obj.studio.setActiveComponent(component);
        end
    end
end