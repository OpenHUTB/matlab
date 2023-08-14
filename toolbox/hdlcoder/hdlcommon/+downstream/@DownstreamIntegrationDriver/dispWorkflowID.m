function workflowID=dispWorkflowID(obj,workflowID,hOption,optionWidth)%#ok<INUSL>




    if~strcmpi(workflowID,hOption.WorkflowID)
        workflowID=hOption.WorkflowID;
        fprintf('%s',workflowID);
        for jj=1:(optionWidth-length(workflowID))
            fprintf('.');
        end
        fprintf('\n');
    end

end