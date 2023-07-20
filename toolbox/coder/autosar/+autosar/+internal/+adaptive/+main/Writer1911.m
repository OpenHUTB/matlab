classdef Writer1911<autosar.internal.adaptive.main.Writer1903









    methods(Access=public)

        function writeReportExecutionState(this,state)
            if strcmp(state,'kRunning')
                this.CodeWriterObj.wBlockStart(['if(!exec_client.ReportExecutionState(ara::exec::'...
                ,'ExecutionState::kRunning))']);
            else
                this.CodeWriterObj.wBlockStart(['if(!exec_client.ReportExecutionState(ara::exec::'...
                ,'ExecutionState::kTerminating))']);
            end
        end
    end
end
