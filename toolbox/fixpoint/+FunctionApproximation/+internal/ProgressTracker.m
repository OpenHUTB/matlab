classdef ProgressTracker<handle









    properties(SetAccess=private,GetAccess=public)
        Strategies={}
        TrackerDiagnostic=MException.empty()
    end

    properties(SetAccess=private,GetAccess=private)
        IsInitialized=false;
    end

    methods
        function initialize(this)
            this.IsInitialized=true;

            for sIndex=1:numel(this.Strategies)
                this.Strategies{sIndex}.initialize();
            end
        end

        function successfulAdvance=advance(this)



            if~this.IsInitialized
                this.initialize();
            end

            successfulAdvance=true;
            for sIndex=1:numel(this.Strategies)

                strategyDiagnostic=this.Strategies{sIndex}.advance();



                if~isempty(strategyDiagnostic)


                    this.TrackerDiagnostic=MException(message('SimulinkFixedPoint:functionApproximation:breakpointSearchStop'));
                    this.TrackerDiagnostic=this.TrackerDiagnostic.addCause(strategyDiagnostic);
                    successfulAdvance=false;
                    break;
                end
            end
        end

        function addStrategy(this,strategy)

            this.Strategies=[this.Strategies,{strategy}];
        end
    end

end