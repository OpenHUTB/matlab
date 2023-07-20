

classdef ExclusionEditor<ModelAdvisor.ExclusionEditorBase

    methods(Access=public)
        function this=ExclusionEditor(aModelName)
            this@ModelAdvisor.ExclusionEditorBase(aModelName);
            this.setPropDefaults();
        end

        function dirtyEditor(aObj)
            if~isempty(aObj.fDialogHandle)
                aObj.fDialogHandle.restoreFromSchema;
                aObj.fDialogHandle.enableApplyButton(true);
                aObj.fDialogHandle.setTitle([DAStudio.message('ModelAdvisor:engine:ModelAdvisorExclusionEditor'),' *']);
            end

            aObj.setUnsavedChanges(true);
        end

        dlg=getDialogSchema(aObj);
        data=getExclusionsdialogSchema(aObj);
        data=getExclusionState(aObj);
        [addChecksIDs,addCheckNames,removeChecks]=updatePropsForChecks(this,prop,ssid);
        setPropDefaults(aObj);
        propMap=getProperties(this,ssid,sel);
    end

    methods(Static=true)




        function instance=getInstance(mdlName)
            instance=ModelAdvisor.ExclusionEditorBase.findExistingDlg(mdlName);
            if isempty(instance)||~strcmp(class(instance),'ModelAdvisor.ExclusionEditor')
                instance=ModelAdvisor.ExclusionEditor(mdlName);
            end
        end


    end
end

