function result=upgradeAdvisorActionCB(taskObj)






    entries={};


    maObj=taskObj.MAobj;
    system=bdroot(maObj.System);


    legacyConfigParams=getLegacyConfigParams(system);


    try
        stf=get_param(system,'SystemTargetFile');
        switch stf
        case 'slrealtime.tlc'

        case{'slrt.tlc','slrtert.tlc','xpctarget.tlc','xpctargetert.tlc'}
            set_param(system,'SystemTargetFile','slrealtime.tlc');
            stfEntry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:stfUpgraded'));
            stfEntry.setColor('Pass');
            entries{end+1}=stfEntry;
        otherwise
            stfEntry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:stfNotUpgraded'));
            stfEntry.setColor('Warn');
            entries{end+1}=stfEntry;
        end
    catch ME
        errorEntry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:upgradeError','System Target File',ME.message));
        errorEntry.setColor('Fail');
        entries{end+1}=errorEntry;
    end


    try
        blkUpgrades=upgradeBlocks(system);
        entries=[entries,blkUpgrades];
    catch ME
        errorEntry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:upgradeError','blocks',ME.message));
        errorEntry.setColor('Fail');
        entries{end+1}=errorEntry;
    end


    try
        if~isempty(slrealtime.internal.logging.UpgradeUtils.getBufferedSignals(system))
            slrealtime.internal.logging.UpgradeUtils.convertBufferedSignals(system);
            sigTxt=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:bufferedSigUpgraded'));
            sigTxt.setColor('Pass');
            entries{end+1}=sigTxt;
        end
    catch ME
        errorEntry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:upgradeError','signals',ME.message));
        errorEntry.setColor('Fail');
        entries{end+1}=errorEntry;
    end


    try
        entries=[entries,doConfigParams(system,'upgrade',legacyConfigParams)];
    catch ME
        errorEntry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:upgradeError','configuration parameters',ME.message));
        errorEntry.setColor('Fail');
        entries{end+1}=errorEntry;
    end



    passEntries={};
    warnEntries={};
    failEntries={};
    for i=1:length(entries)
        switch entries{i}.Color
        case 'Pass'
            passEntries{end+1}=entries{i};%#ok<AGROW>
        case 'Warn'
            warnEntries{end+1}=entries{i};%#ok<AGROW>
        case 'Fail'
            failEntries{end+1}=entries{i};%#ok<AGROW>
        end
    end


    result=ModelAdvisor.Paragraph;
    status=ModelAdvisor.Text;
    status.RetainReturn=true;
    status.setBold(true);
    if~isempty(failEntries)
        status.setColor('Fail');
        status.setContent([DAStudio.message('Simulink:tools:MAFail'),newline]);
    elseif~isempty(warnEntries)
        status.setColor('Warn');
        status.setContent([DAStudio.message('Simulink:tools:MAWarning'),newline]);
    else
        status.setColor('Pass');
        status.setContent(DAStudio.message('Simulink:tools:MAPass'));
    end
    result.addItem(status);


    if~isempty(failEntries)
        fText=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:resultStatusFail'));
        fText.setColor('Fail');
        result.addItem(fText);

        fList=ModelAdvisor.List;
        fList.Items=failEntries;
        result.addItem(fList);
    end


    if~isempty(warnEntries)
        wText=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:resultStatusWarn'));
        wText.setColor('Warn');
        result.addItem(wText);

        wList=ModelAdvisor.List;
        wList.Items=warnEntries;
        result.addItem(wList);
    end


    if isempty(passEntries)
        if isempty(failEntries)

            pText=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:resultStatusNoChanges'));
            pText.setColor('Pass');
            result.addItem(pText);
        end
    else
        pText=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:resultStatusChanges'));
        pText.setColor('Pass');
        result.addItem(pText);

        pList=ModelAdvisor.List;
        pList.Items=passEntries;
        result.addItem(pList);
    end


end
