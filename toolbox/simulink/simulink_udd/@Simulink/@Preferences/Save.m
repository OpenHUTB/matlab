function Save(obj)













    paramnames=obj.getAllRootParameterNames;

    s=matlab.settings.internal.settings;
    if~s.hasGroup('Simulink')
        s.addGroup('Simulink');
    end
    SimulinkSettings=s.Simulink;

    for i=1:numel(paramnames)
        name=paramnames{i};
        val=get_param(0,name);
        if isstruct(val)


            if~SimulinkSettings.hasGroup(name)
                SimulinkSettings.addGroup(name);
            end
            node=SimulinkSettings.(name);
            keys=fieldnames(val);
            for k=1:numel(keys)

                if~node.hasSetting(keys{k})
                    node.addSetting(keys{k});
                end
                try
                    node.(keys{k}).PersonalValue=val.(keys{k});
                catch E
                    warning(E.identifier,'%s',E.message);
                end
            end
        else

            if~SimulinkSettings.hasSetting(name)
                SimulinkSettings.addSetting(name);
            end
            try
                SimulinkSettings.(name).PersonalValue=get_param(0,name);
            catch E
                warning(E.identifier,'%s',E.message);
            end
        end
    end




    if SimulinkSettings.hasSetting('WideVectorLines')

        SimulinkSettings.removeSetting('WideVectorLines');
    end
    if SimulinkSettings.hasSetting('WindowReuse')

        SimulinkSettings.removeSetting('WindowReuse');
    end
    if SimulinkSettings.hasSetting('UseSimulinkToolstrip')

        SimulinkSettings.removeSetting('UseSimulinkToolstrip');
    end
