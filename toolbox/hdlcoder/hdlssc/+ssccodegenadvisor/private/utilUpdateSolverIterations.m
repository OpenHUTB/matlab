function[numberOfSolverIterations,editable]=utilUpdateSolverIterations(sscCodeGenWorkflowObj)




    modeArray=ones(1,numel(sscCodeGenWorkflowObj.StateSpaceParameters));

    if isprop(sscCodeGenWorkflowObj,'StateSpaceParameters')&&...
        isfield(sscCodeGenWorkflowObj.StateSpaceParameters,'NumberOfSwitchingModes')
        for i=1:numel(sscCodeGenWorkflowObj.StateSpaceParameters)
            modeArray(i)=sscCodeGenWorkflowObj.StateSpaceParameters(i).NumberOfSwitchingModes;
        end
    end

    if isprop(sscCodeGenWorkflowObj,'StateSpaceParameters')&&...
        isfield(sscCodeGenWorkflowObj.StateSpaceParameters,'NumberOfSwitchingModes')&&...
        all(modeArray==1)





        numberOfSolverIterations=1;
        editable=false;

    elseif sscCodeGenWorkflowObj.UseFixedCost


        numberOfSolverIterations=sscCodeGenWorkflowObj.NumFixedCostIters;
        editable=false;
    else

        numberOfSolverIterations=sscCodeGenWorkflowObj.NumberOfSolverIterations;
        editable=true;
    end
end


