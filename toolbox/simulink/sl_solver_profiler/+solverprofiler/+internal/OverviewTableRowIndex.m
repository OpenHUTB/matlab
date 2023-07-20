classdef OverviewTableRowIndex<double

    enumeration
        ZeroCrossing(23)
        JacobianUpdate(24)
        TotalReset(25)
        InternalReset(31)
        TotalException(32)
        ExceptionByDAENewtonIteration(37)


        TotalSteps(16)
        ResetCausedByZC(26)
        ResetCausedByDiscreteSignal(27)
        ResetCausedByZOHSignal(28)
        ResetCausedByBlock(29)
        InitialReset(30)
        ExceptionByErrorControl(33)
        ExceptionByNewtonIteration(34)
        ExceptionByInfiniteState(35)
        ExceptionByInfiniteDerivative(36)
    end
end
