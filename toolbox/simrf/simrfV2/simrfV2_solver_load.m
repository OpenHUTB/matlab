function simrfV2_solver_load(hBlk)

















    if strcmpi(get_param(hBlk,'SolverDelFlag'),'1')
        solverBlk=['nesl_utility_internal/Solver',sprintf('\n'),'Configuration'];
        blockToDelete=simrfV2_findConnected(hBlk,solverBlk);
        if~isempty(blockToDelete)
            stepSize=char(get_param(blockToDelete,'LocalSolverSampleTime'));
            set_param(hBlk,'StepSize',stepSize,'SolverDelFlag','0');
            ph=get_param(blockToDelete,'PortHandles');
            simrfV2deletelines(get(ph{1}.RConn,'Line'));
            delete_block(blockToDelete)
        end
    end

end