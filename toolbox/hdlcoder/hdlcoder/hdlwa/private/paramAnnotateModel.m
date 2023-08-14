function paramAnnotateModel(taskobj)



    mdladvObj=taskobj.MAObj;


    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;


    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    critPath=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputCriticalPathSource'));
    critNum=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputCriticalPathNumber'));
    showAllPaths=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputShowAllPaths'));
    showUniquePaths=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputShowUniquePaths'));
    showDelayData=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputShowDelayData'));
    showEndsOnly=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputShowEndsOnly'));


    if(showAllPaths.Value~=hDI.ShowAllPaths)
        hDI.ShowAllPaths=showAllPaths.Value;
    elseif(showUniquePaths.Value~=hDI.ShowUniquePaths)
        hDI.ShowUniquePaths=showUniquePaths.Value;
    elseif(showDelayData.Value~=hDI.ShowDelayData)
        hDI.ShowDelayData=showDelayData.Value;
    elseif(showEndsOnly.Value~=hDI.ShowEndsOnly)
        hDI.ShowEndsOnly=showEndsOnly.Value;
    elseif(~strcmp(critPath.Value,hDI.CriticalPathSource))
        hDI.CriticalPathSource=critPath.Value;
    elseif(~strcmp(critNum.Value,hDI.CriticalPathNumber))
        hDI.CriticalPathNumber=critNum.Value;
    end


    utilAdjustAnnotateModel(mdladvObj,hDI);


end