

classdef Util<handle
    properties(Constant,Access=public)
        SEARCH_REPLACE_CHANNEL='/searchreplace';
    end

    methods(Access=public)
    end

    methods(Static,Access=public)
        function comp=getFinderComponent()
            comp=[];
            studio=[];
            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if~isempty(allStudios)
                studio=allStudios(1);
            end
            if isempty(studio)
                warning('No active studio');
                return;
            end
            comp=studio.getComponent('GLUE2:Finder Component','Find');
        end

        function clearUndoRedoForStudio(studio)
            ediotrDomain=studio.getActiveDomain();
            clearUndoRedoForEditorDomain(ediotrDomain);
        end

        function clearUndoRedoForEditor(editor)
            editorDomain=editor.getStudio.getActiveDomain();
            clearUndoRedoForEditorDomain(editorDomain);
        end

        function asyncFuncMgr=startAsyncFuncManager(asyncFuncMgr,fcn,errFcn)
            import dastudio_util.cooperative.AsyncFunctionRepeaterTask.Status;
            processResultStatus=asyncFuncMgr.Status;
            if processResultStatus==Status.Created
                asyncFuncMgr.start(fcn,'OnError',errFcn);
            elseif processResultStatus==Status.Paused
                asyncFuncMgr.resume();
            elseif processResultStatus==Status.Stopped||processResultStatus==Status.Errored
                asyncFuncMgr.delete();
                asyncFuncMgr=dastudio_util.cooperative.AsyncFunctionRepeaterTask;
                processResultStatus=asyncFuncMgr.Status;
                if processResultStatus==Status.Created
                    asyncFuncMgr.start(fcn,'OnError',errFcn);
                end
            end
        end

        function pauseAsyncFunctionManager(asyncFuncMgr)
            import dastudio_util.cooperative.AsyncFunctionRepeaterTask.Status;
            processResultStatus=asyncFuncMgr.Status;
            if processResultStatus~=Status.Running
                return;
            end
            asyncFuncMgr.pause();
        end
    end
end

function clearUndoRedoForEditorDomain(editorDomain)
    if isempty(editorDomain)
        return;
    end
    editorDomain.clearUndoRedoStack(false);
end
