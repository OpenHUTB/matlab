function settings=getSwitchSettingsFromDialog(config)
    settings=struct;
    if isfield(config,'settings')
        if isfield(config.settings,'useEnumDataType')
            if isequal(config.settings.useEnumDataType,1)
                settings.useEnumeratedType=true;
            else
                settings.useEnumeratedType=false;
            end
        else
            settings.useEnumeratedType=false;
        end
        if isfield(config.settings,'enumDataType')
            settings.enumeratedType=config.settings.enumDataType;
        else
            settings.enumeratedType='';
        end
    end
    if isfield(config,'components')&&~isempty(config.components)
        components=config.components;
        for index=1:length(components)
            if strcmp(components(index).name,'CustomSwitchStateComponent')||...
                strcmp(components(index).name,'RotarySwitchComponent')
                if isfield(components(index).settings,'states')
                    settings.states=components(index).settings.states;
                end
            end
        end
    end
end

