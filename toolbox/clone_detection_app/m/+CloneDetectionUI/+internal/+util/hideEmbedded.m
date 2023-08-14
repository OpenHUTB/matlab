function hideEmbedded(obj)




    modelName=getfullname(obj.model);
    src=simulinkcoder.internal.util.getSource(modelName);
    component=src.studio.getComponent(obj.comp,obj.id);

    if~isempty(component)
        component.DestroyOnHide=1;
        src.studio.hideComponent(component);
    end
end

