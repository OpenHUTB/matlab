function utilLinkToBlock(hDialogObject,rowNum,colNum,~)




    if colNum==0
        task=hDialogObject.getDialogSource;
        modelAdvisorObj=task.MAObj;
        sscCodeGenWorkflowObjCheck=modelAdvisorObj.getCheckObj('com.mathworks.hdlssc.ssccodegenadvisor.workflowObjectCheck');
        sscCodeGenWorkflowObj=sscCodeGenWorkflowObjCheck.ResultData;
        fullBlockName=sscCodeGenWorkflowObj.listOfSwitches(rowNum+1).Name;
        Simulink.internal.highlightResourceOwnerBlock(fullBlockName);
    end
end
