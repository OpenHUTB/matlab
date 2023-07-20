function configParamUpgTable=checkConfigParams(model)





    configParamUpgTable=ModelAdvisor.FormatTemplate('TableTemplate');
    configParamUpgTable.setSubTitle(DAStudio.message('slrealtime:advisor:configParamSubTitle'));
    configParamUpgTable.setColTitles({DAStudio.message('slrealtime:advisor:parameterName'),DAStudio.message('slrealtime:advisor:action')});

    legacyConfigParams=getLegacyConfigParams(model);
    entries=doConfigParams(model,'check',legacyConfigParams);

    for chgIdx=1:length(entries)
        configParamUpgTable.addRow(entries{chgIdx});
    end

    if isempty(entries)
        configParamUpgTable.setSubResultStatus('Pass');
        configParamUpgTable.setSubResultStatusText(DAStudio.message('slrealtime:advisor:noConfigParamsToUpgrade'));
    else
        configParamUpgTable.setSubResultStatus('Warn');
        configParamUpgTable.setSubResultStatusText(DAStudio.message('slrealtime:advisor:configParamsToUpgrade'));
    end

end

