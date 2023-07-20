
function settings=getLampSettingsForDialog(~,config)





    if isfield(config,'components')&&~isempty(config.components)
        components=config.components;
        for index=1:length(components)
            component=components(index);
            if isfield(component,'name')&&strcmp(component.name,'LampStateComponent')&&...
                isfield(component,'settings')&&...
                isfield(component.settings,'valueType')
                settings.stateValueType=component.settings.valueType;
                break;
            end
        end
    end



    assert(~isempty(settings.stateValueType),'Could not determine lamp settings');
end
