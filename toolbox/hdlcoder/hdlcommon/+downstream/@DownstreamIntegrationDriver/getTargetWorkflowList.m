function workflowList=getTargetWorkflowList(obj)





    if obj.isMLHDLC
        workflowList={obj.GenericWorkflowStr,obj.TurnkeyWorkflowStr,obj.IPWorkflowStr,obj.HLSWorkflowStr};
    elseif obj.codesignflag
        workflowList={obj.IPWorkflowStr};
    else
        workflowList={obj.GenericWorkflowStr,obj.FILWorkflowStr,obj.TurnkeyWorkflowStr,obj.XPCWorkflowStr,obj.IPWorkflowStr};
    end



    hasDLInstalled=hdlturnkey.isDLHDLInstalled;
    if hasDLInstalled&&(obj.cliDisplay||strcmpi(dnnfpgafeature('DLProcessorHDLWFA'),'on'))
        workflowList{end+1}=obj.DLWorkflowStr;
    end


    workflowNameList=obj.hWorkflowList.getWorkflowNameList;
    workflowList=[workflowList,workflowNameList];


    hasCommInstalled=exist(fullfile(matlabroot,'toolbox','comm'),'dir');
    if(~obj.isMLHDLC&&hasCommInstalled&&isCommUSRPInstalled)
        workflowList{end+1}=obj.USRPWorkflowStr;
    end


    if~obj.isMLHDLC&&checkSDRProductRequirements(false)
        workflowList{end+1}=obj.SDRWorkflowStr;
    end


    if(~obj.isMLHDLC&&obj.havePIM)
        workflowList=[workflowList,obj.pim.driverGetWorkflowNameList()];
    end
end


