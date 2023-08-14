classdef ExecutionStateTracker



    methods(Static)
        function notifyExecutionStarted(editorId,requestId)
            obj=matlab.internal.editor.ExecutionStateTracker.getInstance();
            obj.startExecution(editorId,requestId);
        end

        function notifyExecutionComplete(editorId,requestId)
            obj=matlab.internal.editor.ExecutionStateTracker.getInstance();
            obj.completeExecution(editorId,requestId);
        end

        function notifyOutputBatchSent(editorId)
            obj=matlab.internal.editor.ExecutionStateTracker.getInstance();
            obj.incrementOutputBatchSequenceNumber(editorId);
        end

        function batchId=getNextOutputBatchId(editorId)
            obj=matlab.internal.editor.ExecutionStateTracker.getInstance();
            batchId=obj.getNextOutputBatchSequenceNumber(editorId);
        end

        function batchId=getLastOutputBatchId(editorId,requestId)
            obj=matlab.internal.editor.ExecutionStateTracker.getInstance();
            batchId=obj.getLastOutputBatchSequenceNumber(editorId,requestId);
        end

        function notifyEditorClose(editorId)
            obj=matlab.internal.editor.ExecutionStateTracker.getInstance();
            obj.removeEditor(editorId);
        end
    end

    methods(Static)
        function obj=getInstance()
            mlock;
            persistent instance;
            if isempty(instance)

                instance=matlab.internal.language.ExecutionTracker();
            end
            obj=instance;
        end
    end

    methods(Access=private)
        function obj=ExecutionStateTracker()
        end
    end
end

