classdef ExitflagImpl<double





    enumeration
        Undefined(NaN)
        BoundsEqual(10)
        NoDecreaseAlongSearchDirection(5)
        LocalMinimumFound(4)
        SearchDirectionTooSmall(4)
        FunctionChangeBelowTolerance(3)
        OptimalWithPoorFeasibility(3)
        StepSizeBelowTolerance(2)
        IntegerFeasible(2)
        OptimalSolution(1)
        SolverLimitExceeded(0)
        OutputFcnStop(-1)
        NoFeasiblePointFound(-2)
        Unbounded(-3)
        TrustRegionRadiusTooSmall(-3)
        IllConditioned(-4)
        FoundNaN(-4)
        FoundNaNInfOrComplex(-4)
        PrimalDualInfeasible(-5)
        SingularPoint(-5)
        Nonconvex(-6)
        CannotDetectSignChange(-6)
        DirectionTooSmall(-7)
        NoDescentDirectionFound(-8)
        FeasibilityLost(-9)
        FailureInSuppliedFcn(-10)
    end

end