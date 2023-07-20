function components=slLoadedToolstripComponents()







    components=[];
    model=dig.config.Model.get('sl_toolstrip_plugins');
    if model.Loaded
        for ii=1:length(model.Components)
            component=model.Components(ii);
            components(ii).name=component.Name;%#ok<AGROW> 
            components(ii).path=component.Path;%#ok<AGROW> 
            components(ii).persisted=slIsToolstripComponentPersisted(component.Name);%#ok<AGROW> 
        end
    end
end