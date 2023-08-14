classdef DlgSelectItem<handle















    properties

id
allProjNames
projName
useModule
allModuleNames
allModuleIds
moduleName
moduleId



sourceInfo







make2way

allowMultiselect



reqs
    end

    methods

        function obj=DlgSelectItem(sourceInfo,make2way,allowMultiselect)
            obj.id=oslc.selection;
            obj.allProjNames=oslc.Project.getProjectNames();
            obj.projName=oslc.Project.currentProject();
            obj.useModule=false;
            obj.allModuleNames={};
            obj.allModuleIds={};
            obj.moduleName='';
            obj.moduleId='';
            obj.sourceInfo=sourceInfo;
            obj.make2way=make2way;
            obj.allowMultiselect=allowMultiselect;
            obj.reqs=[];
        end

        function dlgStruct=getDialogSchema(this)

            projectLabel.Type='text';
            projectLabel.Name=getString(message('Slvnv:oslc:ProjectArea'));
            projectLabel.RowSpan=[1,1];
            projectLabel.ColSpan=[1,1];

            projectCombo.Type='combobox';
            projectCombo.Name='';
            projectCombo.Tag='DngProjectCombo';
            projectCombo.Entries=[{['<',getString(message('Slvnv:oslc:ProjectNotSpecified')),'>']};this.allProjNames];
            projectCombo.Values=(0:numel(this.allProjNames))';
            if isempty(this.projName)
                projectCombo.Value=0;
            else
                projectCombo.Value=find(strcmp(this.allProjNames,this.projName));
            end
            projectCombo.RowSpan=[1,1];
            projectCombo.ColSpan=[2,2];
            projectCombo.ObjectMethod='DngProjectCombo_callback';
            projectCombo.MethodArgs={'%dialog'};
            projectCombo.ArgDataTypes={'handle'};


            moduleCheckbox.Type='checkbox';
            moduleCheckbox.Name=getString(message('Slvnv:oslc:LinkInModuleContext'));
            moduleCheckbox.Tag='DngModuleCheckbox';
            moduleCheckbox.Value=this.useModule;
            moduleCheckbox.RowSpan=[2,2];
            moduleCheckbox.ColSpan=[2,2];
            moduleCheckbox.Enabled=~isempty(this.projName);
            moduleCheckbox.ObjectMethod='DngModuleCheckbox_callback';
            moduleCheckbox.MethodArgs={'%dialog'};
            moduleCheckbox.ArgDataTypes={'handle'};

            moduleLabel.Type='text';
            moduleLabel.Name=getString(message('Slvnv:oslc:ModuleContext'));
            moduleLabel.RowSpan=[3,3];
            moduleLabel.ColSpan=[1,1];
            moduleLabel.Enabled=this.useModule;

            moduleCombo.Type='combobox';
            moduleCombo.Name='';
            moduleCombo.Tag='DngModuleCombo';
            moduleCombo.Entries=[{getString(message('Slvnv:slreq_import:DngSelectModuleComboDefault'))};this.allModuleNames];
            moduleCombo.Values=(0:numel(this.allModuleNames))';
            if isempty(this.moduleName)
                moduleCombo.Value=0;
            else
                moduleCombo.Value=find(strcmp(this.allModuleNames,this.moduleName));
            end
            moduleCombo.RowSpan=[3,3];
            moduleCombo.ColSpan=[2,2];
            moduleCombo.Enabled=this.useModule;
            moduleCombo.ObjectMethod='DngModuleCombo_callback';
            moduleCombo.MethodArgs={'%dialog'};
            moduleCombo.ArgDataTypes={'handle'};

            reqLabel.Type='text';
            reqLabel.Name=getString(message('Slvnv:oslc:SpecifyId'));
            reqLabel.RowSpan=[4,4];
            reqLabel.ColSpan=[1,1];

            reqEdit.Type='edit';
            reqEdit.Value=regexprep(sprintf('%d,',this.id),',$','');
            reqEdit.Tag='DngIdEdit';
            reqEdit.RowSpan=[4,4];
            reqEdit.ColSpan=[2,2];
            reqEdit.Enabled=~isempty(this.projName)&&(~this.useModule||~isempty(this.moduleName));
            reqEdit.ObjectMethod='DngIdEdit_callback';
            reqEdit.MethodArgs={'%dialog'};
            reqEdit.ArgDataTypes={'handle'};

            backlinkCheckbox.Type='checkbox';
            backlinkCheckbox.Name=getString(message('Slvnv:oslc:InsertBacklink'));
            backlinkCheckbox.Tag='DngBacklinkCheckbox';
            backlinkCheckbox.Value=rmipref('BiDirectionalLinking');
            backlinkCheckbox.RowSpan=[5,5];
            backlinkCheckbox.ColSpan=[2,2];
            backlinkCheckbox.Enabled=~isempty(this.id);
            backlinkCheckbox.ObjectMethod='DngBacklinkCheckbox_callback';
            backlinkCheckbox.MethodArgs={'%dialog'};
            backlinkCheckbox.ArgDataTypes={'handle'};

            panel.Type='group';
            panel.Name=getString(message('Slvnv:oslc:SpecifyDngItem'));
            panel.LayoutGrid=[5,2];
            panel.Items={...
            projectLabel,projectCombo,...
            moduleCheckbox,...
            moduleLabel,moduleCombo,...
            reqLabel,reqEdit,...
            backlinkCheckbox};

            dlgStruct.DialogTitle=getString(message('Slvnv:oslc:DngLinkTarget'));
            dlgStruct.Items={panel};
            dlgStruct.StandaloneButtonSet={'OK','Cancel'};

            dlgStruct.PreApplyCallback='preApplyCallback';
            dlgStruct.PreApplyArgs={this,'%dialog'};
            dlgStruct.PostApplyCallback='postApplyCallback';
            dlgStruct.PostApplyArgs={this,'%dialog'};
            dlgStruct.CloseCallback='onClose';
            dlgStruct.CloseArgs={this,'%dialog'};
            dlgStruct.Sticky=true;

        end

    end




    methods(Access=public,Hidden=true)

        DngProjectCombo_callback(this,dlg)

        DngModuleCheckbox_callback(this,dlg)

        DngModuleCombo_callback(this,dlg)

        DngBacklinkCheckbox_callback(this,dlg)

        [isValid,msg]=preApplyCallback(this,dlg)

        DngIdEdit_callback(this,dlg)

        function onClose(this,dlg)%#ok<INUSD>
            ReqMgr.activeDlgUtil('clear');
        end

    end

    methods(Static,Access=private)
        [status,msg]=updateFieldsInParentDialog(parentDlgH,reqstruct);
    end

end

