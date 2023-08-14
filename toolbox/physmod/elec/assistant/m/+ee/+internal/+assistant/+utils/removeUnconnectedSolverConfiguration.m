function removeUnconnectedSolverConfiguration(unconnectedSolvers)


    for idx=1:numel(unconnectedSolvers)
        thisSolver=unconnectedSolvers{idx};
        thisSubsystem=get_param(thisSolver,'Parent');
        delete_block(thisSubsystem);
    end

end