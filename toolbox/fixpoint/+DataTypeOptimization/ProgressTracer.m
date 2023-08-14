classdef ProgressTracer<handle







    properties(SetAccess=private)
        strategies={}
tracerDiagnostic
    end

    properties(SetAccess=private,GetAccess=private)
        isInitialized=false;
    end

    methods
        function initialize(this)
            this.tracerDiagnostic=MSLDiagnostic.empty();
            this.isInitialized=true;

            for sIndex=1:numel(this.strategies)
                this.strategies{sIndex}.initialize();
            end
        end

        function reset(this)
            for sIndex=1:numel(this.strategies)
                this.strategies{sIndex}.reset();
            end
        end

        function successfulAdvance=advance(this)



            if~this.isInitialized
                this.initialize();
            end

            successfulAdvance=true;
            for sIndex=1:numel(this.strategies)

                strategyDiagnostic=this.strategies{sIndex}.advance();



                if~isempty(strategyDiagnostic)


                    this.tracerDiagnostic=MSLDiagnostic(message('SimulinkFixedPoint:dataTypeOptimization:nsstop'));
                    this.tracerDiagnostic=this.tracerDiagnostic.addCause(strategyDiagnostic);
                    successfulAdvance=false;
                    break;
                end
            end
        end

        function addStrategy(this,strategy)

            this.strategies=[this.strategies,{strategy}];
        end
    end

end