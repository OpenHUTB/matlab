classdef Writer1810<autosar.internal.adaptive.main.WriterBase









    methods(Access=public)

        function writeReportExecutionState(this,state)
            if strcmp(state,'kRunning')
                this.CodeWriterObj.wBlockStart(['if(exec_client.ReportExecutionState(ara::exec::'...
                ,'ExecutionState::kRunning) != ara::exec::ExecutionReturnType::kSuccess)']);
            else
                this.CodeWriterObj.wBlockStart(['if(exec_client.ReportExecutionState(ara::exec::'...
                ,'ExecutionState::kTerminating) != ara::exec::ExecutionReturnType::kSuccess)']);
            end
        end

        function includeLogHeaders(this)
            this.CodeWriterObj.wLine('#include <ara/log/logger.h>');
            this.CodeWriterObj.wLine('#include <ara/log/logging.h>');
            this.CodeWriterObj.wLine('#include <ara/log/logstream.h>');
        end
    end
end


