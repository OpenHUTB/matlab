function onTaskDurationSourceChange(hMask,hDlg,parameterName,newParameterValueIdx)%#ok<INUSL>




    validValues={'Dialog','Input port','Recorded task execution statistics'};
    newParameterValue=validValues{newParameterValueIdx+1};
    hMask.onTaskParameterChange(hDlg,parameterName,newParameterValue);
end
