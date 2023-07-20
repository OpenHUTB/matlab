classdef SecondDerivativeNumberOfPointsInitializer<FunctionApproximation.internal.gridsizeinitializer.DerivativeBasedNumberOfPointsInitializer







    properties(Constant)
        DerivativeOrder=2
        DerivativeCalculator=FunctionApproximation.internal.derivativecalculator.CentralDifferenceAccuracyOrder2
    end
end


