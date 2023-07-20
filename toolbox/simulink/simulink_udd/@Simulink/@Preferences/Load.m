function Load(obj)










    s=matlab.settings.internal.settings;
    if~s.hasGroup('Simulink')

        return;
    end

    SimulinkSettings=s.Simulink;


    versioned_parameters={'ErrorIfLoadNewModel'};
    versioned_fields={'NewSave','NewOpenSave'};

    names=fields(SimulinkSettings);

    is_upgrade=true;

    release_name_key='LastSavedRelease';
    v=simulink_version;
    if SimulinkSettings.hasSetting(release_name_key)
        prefs_release=SimulinkSettings.(release_name_key).ActiveValue;
        if strcmp(prefs_release,v.release)
            is_upgrade=false;
        end
    else
        SimulinkSettings.addSetting(release_name_key);
    end


    paramnames=obj.getAllRootParameterNames;

    for i=1:numel(names)
        if~ismember(names{i},paramnames)




            continue;
        end
        if SimulinkSettings.hasSetting(names{i})
            if is_upgrade
                match=strcmp(names{i},versioned_parameters);
                if any(match)


                    SimulinkSettings.removeSetting(names{i});
                    continue;
                end
            end

            val=SimulinkSettings.(names{i}).ActiveValue;
            try
                set_param(0,names{i},val);
            catch E
                warning(E.identifier,'%s',E.message);
            end
        elseif SimulinkSettings.hasGroup(names{i})


            val=struct;
            node=SimulinkSettings.(names{i});
            fs=fields(node);
            for k=1:numel(fs)
                if is_upgrade
                    match=strcmp(fs{k},versioned_fields);
                    if any(match)


                        node.removeSetting(fs{k});
                        continue;
                    end
                end
                val.(fs{k})=node.(fs{k}).ActiveValue;
            end
            try
                set_param(0,names{i},val);
            catch E
                warning(E.identifier,'%s',E.message);
            end
        end
    end

    if is_upgrade
        SimulinkSettings.(release_name_key).PersonalValue=v.release;
    end

