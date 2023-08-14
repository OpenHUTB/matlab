classdef MaxSuccessAttemptStrategy<FunctionApproximation.internal.progresstracking.TrackingStrategy







    properties
TimesSuccessRegistered
MaxAttemptsAfterSuccess
SolverObj
    end

    methods
        function this=MaxSuccessAttemptStrategy(SolverObj,maxSuccessfullAttempts)

            this.SolverObj=SolverObj;

            this.MaxAttemptsAfterSuccess=maxSuccessfullAttempts;
        end

        function initialize(this)

            this.TimesSuccessRegistered=0;
        end

        function diagnostic=check(this)

            diagnostic=MException.empty();
            if this.TimesSuccessRegistered==this.MaxAttemptsAfterSuccess
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:maxSuccessAttemptsReached'));
            end
        end

        function diagnostic=advance(this)

            this.TimesSuccessRegistered=this.TimesSuccessRegistered+~isempty(getFeasibleDBUnits(this.SolverObj));
            diagnostic=this.check();
        end

    end
end