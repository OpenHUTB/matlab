function rememberComponent(configname,compname)




    model=dig.config.Model.getOrCreate(configname);
    component=model.getComponent(compname);
    if~isempty(component)
        model.Preferences.rememberPath(component.Path);
    else
        throw(MException(message('dig:config:resources:NoSuchComponent',compname)));
    end
    model.savePreferences();
end