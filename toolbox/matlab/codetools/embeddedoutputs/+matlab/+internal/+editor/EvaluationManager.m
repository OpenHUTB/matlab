classdef(Hidden)EvaluationManager<handle







    properties(Constant)
        EDITOR_LOCK_TAG='EDITOR_LOCK'
    end

    methods(Static)

        function flag=isEvaluating(editorId)
            import matlab.internal.editor.EODataStore
            import matlab.internal.editor.EvaluationManager

            flag=EODataStore.getEditorField(editorId,EvaluationManager.EDITOR_LOCK_TAG);
            if isempty(flag)
                EODataStore.setEditorField(editorId,EvaluationManager.EDITOR_LOCK_TAG,false);
                flag=false;
            end
        end
    end


end
