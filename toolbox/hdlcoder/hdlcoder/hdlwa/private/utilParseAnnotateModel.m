function isReset=utilParseAnnotateModel(mdladvObj,hDI)




    taskObj=mdladvObj.getTaskObj('com.mathworks.HDL.AnnotateModel');

    isReset=false;


    inputParams=mdladvObj.getInputParameters(taskObj.MAC);
    CriticalPathSource=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputCriticalPathSource'));
    CriticalPathNumber=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputCriticalPathNumber'));
    ShowAllPaths=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputShowAllPaths'));
    ShowUniquePaths=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputShowUniquePaths'));
    ShowDelayData=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputShowDelayData'));
    ShowEndsOnly=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputShowEndsOnly'));

    try
        if~isequal(CriticalPathSource.Value,hDI.CriticalPathSource)
            hDI.CriticalPathSource=CriticalPathSource.Value;
        end
        if~isequal(CriticalPathNumber.Value,hDI.CriticalPathNumber)
            hDI.CriticalPathNumber=CriticalPathNumber.Value;
        end
        if~isequal(ShowAllPaths.Value,hDI.ShowAllPaths)
            hDI.ShowAllPaths=ShowAllPaths.Value;
        end
        if~isequal(ShowUniquePaths.Value,hDI.ShowUniquePaths)
            hDI.ShowUniquePaths=ShowUniquePaths.Value;
        end
        if~isequal(ShowDelayData.Value,hDI.ShowDelayData)
            hDI.ShowDelayData=ShowDelayData.Value;
        end
        if~isequal(ShowEndsOnly.Value,hDI.ShowEndsOnly)
            hDI.ShowEndsOnly=ShowEndsOnly.Value;
        end

    catch ME

        taskObj.reset;
        isReset=true;

        errorMsg=sprintf(['Error occurred in Task 4.3 when loading Restore Point.\n',...
        'The error message is:\n%s\n'],...
        ME.message);
        hf=errordlg(errorMsg,'Error','modal');

        set(hf,'tag','load Annotate model error dialog');
        setappdata(hf,'MException',ME);
    end


end


