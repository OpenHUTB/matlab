classdef FPTRunNameHandler<fixed.internal.simulationmodehandler.SimulationModeHandler




    methods

        function restore(this)

            for modelObj=this.ModelMode
                modelObj.restoreRunName();
            end
        end

    end

    methods(Access=protected)

        function setModelMode(this)
            this.ModelMode(end+1)=fixed.internal.simulationmodehandler.ModelReference(this.TopModel);
        end

    end
end