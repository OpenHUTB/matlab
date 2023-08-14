classdef RefactorOptions<handle
    properties
        id=DAStudio.message('sl_pir_cpp:creator:refactorOptionsTitle')
        title=DAStudio.message('sl_pir_cpp:creator:refactorOptionsTitle')
        cloneUIObj;
        fDialogHandle=[];
        unsavedChanges=false;
        eventListener=[];
        model;
    end

    methods
        function obj=RefactorOptions(cloneUIObj)
            obj.cloneUIObj=cloneUIObj;
            obj.model=cloneUIObj.model;
            CloneDetectionUI.internal.util.setEventHandler(obj);
        end
        function dirtyEditor(aObj)
            if~isempty(aObj.fDialogHandle)
                aObj.fDialogHandle.enableApplyButton(true);
                aObj.fDialogHandle.setTitle([aObj.title,' *']);
                aObj.setUnsavedChanges(true);
            end
        end

        function out=getUnsavedChanges(aObj)
            out=aObj.unsavedChanges;
        end

        function setUnsavedChanges(aObj,flag)
            aObj.unsavedChanges=flag;
        end
        dlgStruct=getDialogSchema(obj);

    end
end

