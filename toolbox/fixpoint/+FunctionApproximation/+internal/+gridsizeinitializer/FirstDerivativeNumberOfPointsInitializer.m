classdef FirstDerivativeNumberOfPointsInitializer<FunctionApproximation.internal.gridsizeinitializer.DerivativeBasedNumberOfPointsInitializer







    properties(Constant)
        DerivativeOrder=1
        DerivativeCalculator=FunctionApproximation.internal.derivativecalculator.CentralDifferenceAccuracyOrder2
    end
end


