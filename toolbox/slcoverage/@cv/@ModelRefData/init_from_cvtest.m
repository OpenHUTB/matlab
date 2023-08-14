function init_from_cvtest(this,topModelName,topTestVar,refs)

    excludedList=cv.ModelRefData.getExcludedModels(topTestVar.modelRefSettings.excludedModels);

    excludeTopModel=~strcmpi(topTestVar.modelRefSettings.enable,'off')&&topTestVar.modelRefSettings.excludeTopModel;
    apply_enable_rule_from_settings(this,topModelName,refs,...
    excludeTopModel,topTestVar.modelRefSettings.enable,excludedList);


