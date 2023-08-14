classdef FastRestartHandler<fixed.internal.simulationmodehandler.SimulationModeHandler




    methods

        function turnOffFastRestart(this)


            this.ModelMode.switchFastRestartMode('off');
        end

        function restoreFastRestart(this)


            this.ModelMode.restoreFastRestart();

        end

        function fastRestartOn=isFastRestartOn(this)

            fastRestartOn=ismember('on',{this.ModelMode.CurrentFastRestartSetting});
        end

    end

    methods(Access=protected)

        function setModelMode(this)
            this.ModelMode(end+1)=fixed.internal.simulationmodehandler.ModelReference(this.TopModel);
        end

    end
end
