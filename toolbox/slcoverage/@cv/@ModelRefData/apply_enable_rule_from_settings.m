



function rules=apply_enable_rule_from_settings(this,topModelName,refs,excludeTopModel,modelRefEnable,excludedList)

    rules=cv.ModelRefData.get_enable_rule_from_settings(topModelName,refs,excludeTopModel,modelRefEnable,excludedList);
    this.adjustCoverageEnable(rules);
