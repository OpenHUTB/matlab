
classdef DebugSessionActionDispatcher



    methods(Access=public,Static)
        function printToOutputWindow(modelHandle,str)

            accessor=SimulinkDebugger.DebugSessionAccessor;
            session=accessor.getDebugSession(modelHandle);

            outputWindowController=session.outputWindowController();
            if isempty(outputWindowController)
                outputWindowController=...
                SimulinkDebugger.HtmlOutputWindowController(modelHandle);
                session.setOuputWindowController(outputWindowController);
            end

            outputWindowController.printToWindow(str);
        end

        function appendToOutputWindow(modelHandle,str)

            accessor=SimulinkDebugger.DebugSessionAccessor;
            session=accessor.getDebugSession(modelHandle);

            outputWindowController=session.outputWindowController();
            if isempty(outputWindowController)
                outputWindowController=...
                SimulinkDebugger.HtmlOutputWindowController(modelHandle);
                session.setOuputWindowController(outputWindowController);
            end
            outputWindowController.appendToWindow(str);
        end

        function getOutputWindowController(modelHandle)

            accessor=SimulinkDebugger.DebugSessionAccessor;
            session=accessor.getDebugSession(modelHandle);

            outputWindowController=session.outputWindowController();
            if isempty(outputWindowController)
                outputWindowController=...
                SimulinkDebugger.HtmlOutputWindowController(modelHandle);
                session.setOuputWindowController(outputWindowController);
            end
        end

        function clearAllDebugSessions()
            accessor=SimulinkDebugger.DebugSessionAccessor;
            accessor.clearAllDebugSessions();
        end
    end
end
