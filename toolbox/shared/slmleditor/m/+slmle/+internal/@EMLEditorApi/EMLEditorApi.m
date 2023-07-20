classdef EMLEditorApi<handle





    properties(Access=private)
        logger=false
    end

    methods(Access=private)
        function obj=EMLEditorApi()
        end
    end

    methods(Static)
        obj=editorHandle()
        obj=getInstance()
    end

    methods
        clearHighlight(obj,int)
        bool=closeAllScripts(obj)
        int=documentActiveMachine(obj,int)
        bool=documentChangeActiveInstance(obj,int1,int2)
        documentClose(obj,int)
        bool=documentDataScopeChangeReply(obj,int,str1,str2)
        bool=documentDisplayTooltipSymbol(obj,int,str)
        arr=documentGetBuildBreakpoints(obj,int)
        int=documentGetDebugArrowLineNum(obj,int)
        arr=documentGetRunBreakpoints(obj,int)
        str=documentGetShortName(obj,int)
        str=documentGetText(obj,int)
        str=documentGetTitle(obj,int)
        bool=documentGotoSymbolFirstExistence(obj,int,str)
        bool=documentHighlightError(obj,int1,int2,int3)
        bool=documentIsDirty(obj,int)
        bool=documentIsLibraryMFile(obj,int)
        bool=documentIsOpen(obj,int,sid)
        arr=documentLayout(obj,int)
        bool=documentOpen(obj,...
        int_activeMachineId,...
        int_parentMachineId,...
        int_documentId,...
        bool_isBlock,...
        bool_isTruthTable,...
        bool_isStateflowApp,...
        bool_isDESVariant,...
        str_title,...
        str_shortName,...
        str_text,...
        int_x,int_y,int_w,int_h,...
        str_fileName,...
        str_uniqueId,...
        sid)
        bool=documentOpenFromDebugger(obj,...
        int_activeMachineId,...
        int_parentMachineId,...
        int_documentId,...
        bool_isBlock,...
        bool_isTruthTable,...
        bool_isDESVariant,...
        str_title,...
        str_shortName,...
        str_text,...
        int_x,int_y,int_w,int_h,...
        str_fileName,...
        str_uniqueId,...
        sid)
        int=documentParentMachine(obj,int)
        bool=documentSetBlkHandle(obj,int,double)
        bool=documentSetBuildBreakpoints(obj,int,arr)
        bool=documentSetDebuggableChart(obj,int,arr)
        bool=documentSetDirty(obj,int,bool)
        bool=documentSetLock(obj,int,bool)
        bool=documentSetRunBreakpoints(obj,int,arr)
        bool=documentSetShortName(obj,int,str)
        bool=documentSetText(obj,int,str,bool)
        bool=documentSetTitle(obj,int,str)
        bool=documentSymbolChecked(obj,int,str)
        bool=documentToFront(obj,int,bool,sid)
        bool=documentToFrontFromDebugger(obj,int,sid)
        bool=documentUpdateFilePath(obj,id,filepath)
        bool=documentUpdateSubstring(obj,int1,int2,int3,str)
        arr=editorCachedObjectIds(~)
        editorTerminate(~)
        bool=equals(obj,other)
        cls=getClass(~)
        int=getCurrentLine(obj,int)
        str=getResourceString(~,str)
        int=hashCode(obj)
        bool=isInDebugging(obj)
        bool=isInferenceReportEnabled(obj)
        bool=isLibraryMFilesEditable(obj)
        machineClearOptions(obj,int)
        int=machineDocumentByTitle(obj,int,str)
        map=machineGetOptions(obj,int)
        bool=machineIsLibrary(obj,int)
        bool=machineIsOpen(obj,machineId)
        bool=machineOpen(obj,machineId,isLibrary)
        bool=machineSetDebuggable(obj,int,bool1,bool2)
        bool=machineSetDirty(obj,machineId,makeDirty)
        bool=machineSetUIState(obj,id,str)
        notifyMachinesOfChange(~)
        str=toString(obj)
        updateEditorUniqueKey(obj,int,str)
        update(obj,text,objectId)
    end

    methods(Static)
        setLogger(bool)
    end
end

