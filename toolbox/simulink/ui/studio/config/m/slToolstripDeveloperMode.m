function oldEnabled=slToolstripDeveloperMode(value)

    start_simulink;

    configName='sl_toolstrip_plugins';

    oldMode=dig.config.devMode(configName);
    oldEnabled=oldMode==dig.model.ViewMode.Inspector;

    if(nargin==1)
        isEnabled=false;

        if(islogical(value))
            isEnabled=value;
        elseif(ischar(value)||isstring(value))
            isEnabled=strcmp(value,'on');
        elseif(isa(value,'double'))
            isEnabled=value>0;
        end

        if(isEnabled)
            mode=dig.model.ViewMode.Inspector;
            keyValue='Ctrl';

            if ismac
                keyValue='Command';
            end

            disp(DAStudio.message('simulink_ui:studio:resources:toolstripDeveloperMode',keyValue));
        else
            mode=dig.model.ViewMode.Normal;
        end

        dig.config.devMode(configName,mode);
    end
end
