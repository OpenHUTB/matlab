



classdef CDExclusionEditor<ModelAdvisor.ExclusionEditorBase
    properties
        excludeModelReferences;
        excludeLibraryLinks;
excludeInactiveRegions
    end
    methods

        function this=CDExclusionEditor(aModelName)
            this@ModelAdvisor.ExclusionEditorBase(aModelName);
            this.setPropDefaults();

            if isKey(this.exclusionState,'LibraryLinks_Library')
                this.excludeLibraryLinks=true;
            else
                this.excludeLibraryLinks=false;
            end

            if isKey(this.exclusionState,'ModelReference_BlockType')
                this.excludeModelReferences=true;
            else
                this.excludeModelReferences=false;
            end

            if isKey(this.exclusionState,'InactiveRegions_BlockType')
                this.excludeInactiveRegions=true;
            else
                this.excludeInactiveRegions=false;
            end

        end
        function dirtyEditor(aObj)
            if~isempty(aObj.fDialogHandle)
                aObj.fDialogHandle.restoreFromSchema;
                aObj.fDialogHandle.enableApplyButton(true);
                aObj.fDialogHandle.setTitle([DAStudio.message('sl_pir_cpp:creator:cloneDetectionExclusionEditor'),'*']);
                aObj.setUnsavedChanges(true);
            end
        end

        function excludeModelReferencescb(this)
            this.excludeModelReferences=~this.excludeModelReferences;
            prop=getProp(this,'CD1',DAStudio.message('sl_pir_cpp:creator:excludeModelRefs'),...
            'ModelReference','BlockType',false,{'.*'});
            if this.excludeModelReferences
                this.addExclusionPropToState(prop);
            else
                removePropFromMap(this,this.exclusionState,prop);
            end
            dirtyEditor(this);
        end

        function excludeLibraryLinkscb(this)
            this.excludeLibraryLinks=~this.excludeLibraryLinks;
            prop=getProp(this,'CD2',DAStudio.message('sl_pir_cpp:creator:excludeLibLinks'),...
            'LibraryLinks','Library',false,{'.*'});

            if this.excludeLibraryLinks
                this.addExclusionPropToState(prop);
            else
                removePropFromMap(this,this.exclusionState,prop);
            end
            dirtyEditor(this);
        end

        function excludeInactiveRegionscb(this)
            this.excludeInactiveRegions=~this.excludeInactiveRegions;
            prop=getProp(this,'CD3',DAStudio.message('sl_pir_cpp:creator:excludeInactiveRegions'),...
            'InactiveRegions','BlockType',false,{'.*'});

            if this.excludeInactiveRegions
                this.addExclusionPropToState(prop);
            else
                removePropFromMap(this,this.exclusionState,prop);
            end
            dirtyEditor(this);
        end

        function prop=getProp(~,id,propDesc,name,Type,includeChildren,checkids)
            prop.propDesc=propDesc;
            prop.Type=Type;
            prop.id=id;
            prop.rationale=propDesc;
            prop.includeChildren=includeChildren;
            prop.checkIDs=checkids;
            prop.sid='off';
            prop.checkType='CloneDetection';
            prop.value=name;
            prop.name=name;
        end

        dlg=getDialogSchema(aObj)
        data=getExclusionsdialogSchema(aObj)
        data=getExclusionState(aObj)
        [addChecksIDs,addCheckNames,removeChecks]=updatePropsForChecks(this,prop,ssid);
        setPropDefaults(aObj)
        propMap=getProperties(this,ssid,sel)

    end

    methods(Static=true)




        function instance=getInstance(mdlName)
            instance=ModelAdvisor.ExclusionEditorBase.findExistingDlg(mdlName);
            if isempty(instance)||~strcmp(class(instance),'CDExclusionEditor')
                instance=CDExclusionEditor(mdlName);
            end
        end

    end
end

