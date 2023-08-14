function tooltip=objectivePriorities_TT(cs,~)

    key='RTW:configSet:sanityCheckObjectiveButtonToolTip';
    if strcmp(cs.get_param('IsERTTarget'),'off')
        key='RTW:configSet:configSetObjectivesDescrName2';
    end
    tooltip=message(key).getString;
