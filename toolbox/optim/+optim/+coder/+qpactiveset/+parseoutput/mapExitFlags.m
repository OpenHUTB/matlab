function solution=mapExitFlags(solution)














%#codegen

    coder.allowpcode('plain');

    validateattributes(solution,{'struct'},{'scalar'});

    UNBOUNDED=coder.const(optim.coder.SolutionState('ObjectiveLimitReached'));
    INCONSISTENT_EQ=coder.const(optim.coder.SolutionState('InconsistentEq'));
    ILLPOSED=coder.const(optim.coder.SolutionState('IllPosed'));



    switch solution.state
    case UNBOUNDED
        solution.state(:)=-3;
    case INCONSISTENT_EQ
        solution.state(:)=-2;
    case ILLPOSED
        solution.state(:)=-2;
    end

end

