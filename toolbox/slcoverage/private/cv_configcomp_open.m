function cv_configcomp_open(modelH)


    [slcovcc,configSet]=cv_configcomp_get(modelH);

    if~isempty(slcovcc)&&~isempty(configSet)
        configset.showParameterGroup(configSet,{DAStudio.message('RTW:configSet:configSetSlCov')});
    else
        dd=configset.util.ConfigSetDialogSourceManager.getInstance;
        dd.clean;
    end
end
