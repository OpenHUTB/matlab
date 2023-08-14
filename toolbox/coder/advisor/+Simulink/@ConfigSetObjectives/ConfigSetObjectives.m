classdef ConfigSetObjectives<handle




    properties
opCopy
ThisDlg
base
    end

    properties(Access=private)
objsLeft
objsName
        dirty logical=false;
        numOfObjs int32=0;
        justSwitched logical=true;
priorities
unSelected
prioritiesOld
unSelectedOld
        listbox2selected=-1
ParentSrc
    end

    methods
        function obj=ConfigSetObjectives()

            obj.init;
        end
    end

    methods
        dialogCallback(obj,hDlg,tag)
        out=getDialogSchema(obj,schemaName)
        out=getObjectiveDialogSchema(obj)
        view(obj,cs);
    end

    methods(Access=private)
        init(obj,varargin)
    end
end


