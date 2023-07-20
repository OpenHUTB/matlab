classdef ManageAllocationSetProfiles<handle




    properties(Constant)
    end

    properties(Access=private)
        rootArch=[];
        isNullWarnState=[];
        mdlName=[];
        studio=[];
        DialogInstance=[];
        allocSet=[];
    end

    methods(Access=private)
        function this=ManageAllocationSetProfiles()

        end
    end

    methods(Static)
        function obj=instance(cbinfo)


            persistent instance
            if isempty(instance)||~isvalid(instance)
                instance=systemcomposer.allocation.internal.ManageAllocationSetProfiles;
            end




            w=warning('query','dastudio:studio:IsNull');
            instance.isNullWarnState=w.state;
            warning('off','dastudio:studio:IsNull');


            instance.allocSet=cbinfo.allocSet;

            obj=instance;
        end

        function launch(cbinfo)


            instance=systemcomposer.allocation.internal.ManageAllocationSetProfiles.instance(cbinfo);
            if isempty(instance.DialogInstance)||~ishandle(instance.DialogInstance)
                instance.DialogInstance=DAStudio.Dialog(instance);
            end


            instance.DialogInstance.show();
            instance.DialogInstance.refresh();
        end
    end

    methods

        function schema=getDialogSchema(this)



            profileSchema=this.getManageProfileSchema();

            panel.Type='panel';
            panel.Tag='main_panel';
            panel.Items={profileSchema};
            panel.LayoutGrid=[3,2];
            panel.RowStretch=[0,1,0];
            panel.ColStretch=[1,0];

            schema.OpenCallback=@(dlg)this.handleOpenDialog(dlg);
            schema.CloseCallback='handleClose';
            schema.CloseArgs={this,'%dialog'};
            schema.HelpMethod='handleClickHelp';
            schema.HelpArgs={};
            schema.HelpArgsDT={};
            schema.DialogTitle=DAStudio.message('SystemArchitecture:AddRemoveProfileDialog:Title');
            schema.Items={panel};
            schema.DialogTag='system_composer_profile_dialog';
            schema.Source=this;
            schema.SmartApply=true;

            schema.StandaloneButtonSet={'Ok','Help'};

            schema.MinMaxButtons=true;
            schema.ShowGrid=1;
            schema.DisableDialog=false;
            schema.AlwaysOnTop=false;
            schema.ExplicitShow=true;
        end

        function handleClickHelp(~)


            helpview(fullfile(docroot,'systemcomposer','helptargets.map'),'profilemanage');
        end

        function handleClickImportButton(this)

            systemcomposer.allocation.internal.editor.performImportDialog(this.allocSet.getName());
        end

        function handleClickRemoveButton(this,dlg)


            selectedProfileIdx=dlg.getSelectedTableRows('profilesTable');
            if isempty(selectedProfileIdx)

                return;
            end


            imd=DAStudio.imDialog.getIMWidgets(dlg);
            profilesTable=imd.find('tag','profilesTable');
            tableData=profilesTable.getAllTableItems();

            selectedRows=tableData(selectedProfileIdx+1,:);


            pb=systemcomposer.internal.ProgressBar(...
            DAStudio.message('SystemArchitecture:studio:PleaseWait'),dlg);

            profileNames=cell(size(selectedRows));
            for pi=1:numel(selectedRows)
                profileNames(pi)=selectedRows(pi,1);
            end


            prompt=message('SystemArchitecture:AllocationUI:ConfirmDeleteProfileSet',strjoin(profileNames)).string;
            confirm=questdlg(...
            prompt,...
            message('SystemArchitecture:studio:ConfirmDeleteProfileTitle').string,...
            message('SystemArchitecture:studio:ConfirmDeleteProfile_Yes').string,...
            message('SystemArchitecture:studio:Cancel').string,...
            message('SystemArchitecture:studio:Help').string,...
            message('SystemArchitecture:studio:Cancel').string);

            if strcmp(confirm,message('SystemArchitecture:studio:ConfirmDeleteProfile_Yes').string)

                for idx=1:numel(profileNames)
                    try
                        this.allocSet.removeProfile(profileNames{idx});
                    catch ME
                        diag=MSLException(get_param(this.allocSet.getName,'handle'),ME.identifier,ME.message);
                        sldiagviewer.reportError(diag);
                    end
                end
            elseif strcmp(confirm,message('SystemArchitecture:studio:Help').string)

                helpview(fullfile(docroot,'systemcomposer','helptargets.map'),'define_profiles');
            end


            pb.setStatus(DAStudio.message('SystemArchitecture:studio:Complete'));
        end

        function[isValid,msg]=handleClose(this,~)

            isValid=true;
            msg='';


            warning(this.isNullWarnState,'dastudio:studio:IsNull');
        end

        function selectionChange(~,dlg,tag)


            if isempty(dlg.getSelectedTableRows(tag))



                dlg.setFocus('importButton');
            end
        end
    end

    methods(Access=private)
        function schema=getManageProfileSchema(this)
            row=1;
            col=1;


            desc.Type='text';
            desc.Tag='txtDesc';
            desc.RowSpan=[row,row];
            desc.ColSpan=[col,col+1];
            desc.Name=DAStudio.message('SystemArchitecture:AddRemoveProfileDialog:Description');



            profiles=this.allocSet.p_ProfileNamespace.Profiles;
            profileNames=cell(size(profiles));
            for pi=1:numel(profiles)
                profileNames{pi}=profiles(pi).getName();
            end

            tableData=profileNames';

            row=row+1;
            profilesTable.Tag='profilesTable';
            profilesTable.Type='table';
            profilesTable.SelectionBehavior='row';
            profilesTable.ColumnID={'ProfileNames'};
            profilesTable.ColHeader={...
            DAStudio.message('SystemArchitecture:AddRemoveProfileDialog:Name')};
            profilesTable.ColumnStretchable=1;
            profilesTable.ColumnCharacterWidth=10;
            profilesTable.Grid=false;
            profilesTable.Data=tableData;
            profilesTable.MultiSelect=true;
            profilesTable.Source=this;
            profilesTable.ObjectMethod='selectionChange';
            profilesTable.MethodArgs={'%dialog','%value'};
            profilesTable.ArgDataTypes={'handle','mxArray'};
            profilesTable.SelectionChangedCallback=@(dlg,tag)this.selectionChange(dlg,tag);
            profilesTable.Graphical=true;
            profilesTable.Size=size(tableData);
            profilesTable.RowSpan=[row,row];
            profilesTable.ColSpan=[col,col+1];
            profilesTable.MinimumSize=[300,250];

            row=row+1;


            importButton.Type='pushbutton';
            importButton.Tag='importButton';
            importButton.Source=this;
            importButton.ObjectMethod='handleClickImportButton';
            importButton.MethodArgs={};
            importButton.ArgDataTypes={};
            importButton.Enabled=true;
            importButton.ToolTip='';
            importButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','ARCHITECTURE','importProfile_16.png');
            importButton.Name=DAStudio.message('SystemArchitecture:AddRemoveProfileDialog:Import');
            importButton.DialogRefresh=true;
            importButton.RowSpan=[row,row];
            importButton.ColSpan=[col,col];


            removeButton.Type='pushbutton';
            removeButton.Tag='removeButton';
            removeButton.Source=this;
            removeButton.ObjectMethod='handleClickRemoveButton';
            removeButton.MethodArgs={'%dialog'};
            removeButton.ArgDataTypes={'handle'};
            removeButton.ToolTip='';
            removeButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','ARCHITECTURE','delete_16.png');
            removeButton.Name=DAStudio.message('SystemArchitecture:AddRemoveProfileDialog:Remove');
            removeButton.DialogRefresh=true;
            removeButton.RowSpan=[row,row];
            removeButton.ColSpan=[col+1,col+1];

            schema.Type='group';
            schema.Name='';
            schema.Items={desc,profilesTable,importButton,removeButton};
            schema.LayoutGrid=[row,col+1];
        end
    end

end


