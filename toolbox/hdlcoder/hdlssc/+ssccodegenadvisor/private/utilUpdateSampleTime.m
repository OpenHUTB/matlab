function[sampleTime]=utilUpdateSampleTime(sscCodeGenWorkflowObj)






    if isempty(sscCodeGenWorkflowObj.SolverConfiguration)

        sampleTime=' ';
    else
        solverBlks=sscCodeGenWorkflowObj.SolverConfiguration;
        solverBlk=solverBlks{1};
        sampleTime=get_param(solverBlk,'LocalSolverSampleTime');
    end
end


