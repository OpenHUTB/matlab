function utilTableOfSwitchesValueChange(hDialogObject,rowNum,colNum,newValue)











    task=hDialogObject.getDialogSource;
    modelAdvisorObj=task.MAObj;
    sscCodeGenWorkflowObjCheck=modelAdvisorObj.getCheckObj('com.mathworks.hdlssc.ssccodegenadvisor.workflowObjectCheck');
    sscCodeGenWorkflowObj=sscCodeGenWorkflowObjCheck.ResultData;

    if colNum==2
        sscCodeGenWorkflowObj.listOfSwitches(rowNum+1).Approx=newValue;
    elseif colNum==3
        sscCodeGenWorkflowObj.listOfSwitches(rowNum+1).Rs=newValue;
    end
    hDialogObject.refresh;
end

