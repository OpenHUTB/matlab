function utilAdjustAnnotateModel(mdladvObj,hDI)




    taskObj=mdladvObj.getTaskObj('com.mathworks.HDL.AnnotateModel');


    inputParams=mdladvObj.getInputParameters(taskObj.MAC);
    critPath=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputCriticalPathSource'));
    critNum=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputCriticalPathNumber'));
    showAllPaths=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputShowAllPaths'));
    showUniquePaths=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputShowUniquePaths'));
    showDelayData=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputShowDelayData'));
    showEndsOnly=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputShowEndsOnly'));


    if hDI.SkipPlaceAndRoute&&~hDI.SkipPreRouteTimingAnalysis
        critPath.Entries={'pre-route'};
    elseif~hDI.SkipPlaceAndRoute&&hDI.SkipPreRouteTimingAnalysis
        critPath.Entries={'post-route'};
    elseif~hDI.SkipPlaceAndRoute&&~hDI.SkipPreRouteTimingAnalysis
        critPath.Entries={'pre-route','post-route'};
    end

    critPath.Value=hDI.CriticalPathSource;
    critNum.Value=hDI.CriticalPathNumber;
    showAllPaths.Value=hDI.ShowAllPaths;
    showUniquePaths.Value=hDI.ShowUniquePaths;
    showDelayData.Value=hDI.ShowDelayData;
    showEndsOnly.Value=hDI.ShowEndsOnly;



end


