function preferredLoadMode=getPreferredLoadMode






    s=settings;
    pm_assert(s.hasGroup('simscape'));
    ssc=s.simscape;
    pm_assert(ssc.hasSetting('DefaultEditingMode'));
    preferredLoadMode=ssc.DefaultEditingMode.ActiveValue;





    persistent allowedEnums;
    persistent choiceToEnum;

    if isempty(allowedEnums)

        allValues=pmsl_rtmpreferences(true);
        allowedEnums={};
        choiceToEnum=containers.Map;
        for i=1:2:(numel(allValues)-1)
            enum=allValues{i+0};
            choice=allValues{i+1};
            allowedEnums{end+1}=enum;%#ok
            choiceToEnum(choice)=enum;
        end

    end

    if~any(strcmp(preferredLoadMode,allowedEnums))


        if choiceToEnum.isKey(preferredLoadMode)
            preferredLoadMode=choiceToEnum(preferredLoadMode);
        else

            preferredLoadMode=char(ssc.DefaultEditingMode.FactoryValue);
        end
    end





