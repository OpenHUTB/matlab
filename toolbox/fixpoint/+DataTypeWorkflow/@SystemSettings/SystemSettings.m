classdef SystemSettings<handle





    properties

TopModel


DirtyHandler
AccelModeHandler
FastRestartHandler
FPTRunNameHandler
InstrumentationHandler
SignalLoggingHandler
    end

    methods
        function obj=SystemSettings(topModel)

            obj.TopModel=topModel;
        end

        function turnOffFastRestart(this)


            if isempty(this.FastRestartHandler)
                this.FastRestartHandler=fixed.internal.simulationmodehandler.FastRestartHandler(this.TopModel);
            end
            this.FastRestartHandler.turnOffFastRestart();
        end

        function restoreFastRestart(this)


            this.FastRestartHandler.restoreFastRestart();
        end

        function switchToNormalMode(this)
            this.AccelModeHandler.switchToNormalMode();
        end

        function enableInstrumentation(this)
            this.InstrumentationHandler.enableInstrumentation();
        end

        function captureSettings(this)
            this.DirtyHandler=fixed.internal.simulationmodehandler.DirtyFlagHandler(this.TopModel);
            this.AccelModeHandler=fixed.internal.simulationmodehandler.AccelModeHandler(this.TopModel);
            this.FastRestartHandler=fixed.internal.simulationmodehandler.FastRestartHandler(this.TopModel);
            this.InstrumentationHandler=fixed.internal.simulationmodehandler.InstrumentationHandler(this.TopModel);
            this.FPTRunNameHandler=fixed.internal.simulationmodehandler.FPTRunNameHandler(this.TopModel);
            this.SignalLoggingHandler=fixed.internal.simulationmodehandler.SignalLoggingHandler(this.TopModel);
        end

        function restoreSettings(this)
            this.AccelModeHandler.restoreSimulationMode();
            this.InstrumentationHandler.restore();
            this.FPTRunNameHandler.restore();
            this.FastRestartHandler.restoreFastRestart();
            this.SignalLoggingHandler.restore();
            this.DirtyHandler.restore();
        end
    end
end
