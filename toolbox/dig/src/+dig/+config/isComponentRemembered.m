function result=isComponentRemembered(configname,compname)




    model=dig.config.Model.getOrCreate(configname);
    component=model.getComponent(compname);
    if~isempty(component)
        result=model.Preferences.isRemembered(component.Path);
    else
        throw(MException(message('dig:config:resources:NoSuchComponent',compname)));
    end
end