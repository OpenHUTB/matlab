function requiredToolList=getRequiredTool(obj,boardName)




    currentWorkflow=obj.get('Workflow');
    if isFILWorkflow(obj)
        bMgr=eda.internal.boardmanager.BoardManager.getInstance;
        bObj=bMgr.getBoardObj(boardName);
        toolName=bObj.getFILFPGAToolName;
        if strcmpi(toolName,'Altera Quartus II')
            toolName='Altera QUARTUS II';
        end
        requiredToolList={toolName};
    elseif isUSRPWorkflow(obj)
        requiredToolList={'Xilinx ISE'};

    elseif isSDRWorkflow(obj)
        try
            requiredToolList=l_getRequiredToolListSDR(boardName);
        catch
            requiredToolList={'Xilinx ISE'};
        end

    elseif isIPWorkflow(obj)

        [~,hP]=obj.hIP.isInIPPlatformList(boardName);
        requiredToolList=hP.RequiredTool;

    elseif obj.hWorkflowList.isInWorkflowList(currentWorkflow)

        hWorkflow=obj.hWorkflowList.getWorkflow(currentWorkflow);
        requiredToolList=hWorkflow.getRequiredTool(obj,boardName);

    elseif(obj.isPluginWorkflow)
        requiredToolList=obj.pim.driverGetRequiredToolName(boardName);
    else

        [~,hP]=obj.hAvailableBoardList.isInBoardList(boardName);
        requiredToolList=hP.RequiredTool;
    end
end
