function forgetComponent(configname,compname)




    model=dig.config.Model.getOrCreate(configname);
    component=model.getComponent(compname);
    if~isempty(component)
        compPath=component.Path;
        model.Preferences.forgetPath(compPath);
    else
        throw(MException(message('dig:config:resources:NoSuchComponent',compname)));
    end
    model.savePreferences();
end