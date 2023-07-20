function modelOrderReductionCheckAll(mdladvObj,flag)




    sscCodeGenWorkflowObjCheck=mdladvObj.getCheckObj('com.mathworks.hdlssc.ssccodegenadvisor.workflowObjectCheck');
    sscCodeGenWorkflowObj=sscCodeGenWorkflowObjCheck.ResultData;


    for i=1:numel(sscCodeGenWorkflowObj.listOfSwitches)
        sscCodeGenWorkflowObj.listOfSwitches(i).Approx=flag;
    end


end


