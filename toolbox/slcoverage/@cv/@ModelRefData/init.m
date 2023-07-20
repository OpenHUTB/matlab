function init(this,modelH)
    try
        topModelName=get_param(modelH,'Name');
        refs=cv.ModelRefData.getMdlReferences(topModelName,true);
        refs=unique(refs);
        excludedList=cv.ModelRefData.getExcludedModels(get_param(modelH,'CovModelRefExcluded'));
        excludeTopModel=strcmpi(get_param(modelH,'RecordCoverage'),'off');
        apply_enable_rule_from_settings(this,topModelName,refs,...
        excludeTopModel,get_param(modelH,'CovModelRefEnable'),excludedList);

    catch Mex
        display(Mex.message);
    end

