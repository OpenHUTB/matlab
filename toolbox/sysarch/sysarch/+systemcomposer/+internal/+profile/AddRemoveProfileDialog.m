classdef AddRemoveProfileDialog<systemcomposer.internal.mixin.ModelClose&...
    systemcomposer.internal.mixin.CenterDialog




    properties(Constant)
    end

    properties(Access=private)
        rootArch=[];
        isNullWarnState=[];
        mdlName=[];
        studio=[];
        DialogInstance=[];
    end

    methods(Access=private)
        function this=AddRemoveProfileDialog()

        end
    end

    methods(Static)
        function obj=instance(cbinfo)


            persistent instance
            if isempty(instance)||~isvalid(instance)
                instance=systemcomposer.internal.profile.AddRemoveProfileDialog;
            end


            instance.registerCloseListener(bdroot(cbinfo.studio.App.blockDiagramHandle));




            w=warning('query','dastudio:studio:IsNull');
            instance.isNullWarnState=w.state;
            warning('off','dastudio:studio:IsNull');


            instance.rootArch=[];
            instance.mdlName=SLStudio.Utils.getModelName(cbinfo);
            instance.studio=cbinfo.studio;

            obj=instance;
        end

        function launch(cbinfo)


            instance=systemcomposer.internal.profile.AddRemoveProfileDialog.instance(cbinfo);
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


            ZCStudio.ImportProfileCB(this.rootArch,this.studio);
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
            [~,~,extensions]=cellfun(@fileparts,selectedRows(:,2),'UniformOutput',false);
            mdlProfIdx=find(strcmpi(extensions,'.slx'));
            dictProfIdx=find(strcmpi(extensions,'.sldd'));

            pb=systemcomposer.internal.ProgressBar(...
            DAStudio.message('SystemArchitecture:studio:PleaseWait'),dlg);%#ok<NASGU>
            if~isempty(mdlProfIdx)

                mdlProfiles=selectedRows(mdlProfIdx,1);
                ZCStudio.RemoveProfileCB(this.rootArch,mdlProfiles);
            end
            if~isempty(dictProfIdx)

                ddProfiles=selectedRows(dictProfIdx,1);
                mdlHandle=get_param(this.mdlName,'Handle');
                modelDD=get_param(mdlHandle,'DataDictionary');
                assert(~isempty(modelDD));
                assert(~systemcomposer.internal.modelHasLocallyScopedInterfaces(mdlHandle));
                ZCStudio.RemoveProfileCB(modelDD,ddProfiles);
            end
            pb.setStatus(DAStudio.message('SystemArchitecture:studio:Complete'));%#ok<NASGU>
        end

        function[isValid,msg]=handleClose(this,~)

            isValid=true;
            msg='';


            warning(this.isNullWarnState,'dastudio:studio:IsNull');
        end

        function handleOpenDialog(this,dlg)

            this.positionDialog(dlg,this.mdlName);
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


            mdlHandle=get_param(this.mdlName,'Handle');
            currentArchElem=systemcomposer.utils.getArchitecturePeer(mdlHandle);
            this.rootArch=currentArchElem.getTopLevelArchitecture;



            profileNames=ZCStudio.getAttachedProfiles(this.rootArch);
            sources=repmat({[this.mdlName,'.slx']},size(profileNames));

            modelDD=get_param(mdlHandle,'DataDictionary');
            if~isempty(modelDD)&&~systemcomposer.internal.modelHasLocallyScopedInterfaces(mdlHandle)
                p_validDD=ZCStudio.getAttachedProfiles(modelDD);
                profileNames=[profileNames,p_validDD];
                sources=[sources,repmat({modelDD},size(p_validDD))];
            end

            tableData=[profileNames',sources'];

            row=row+1;
            profilesTable.Tag='profilesTable';
            profilesTable.Type='table';
            profilesTable.SelectionBehavior='row';
            profilesTable.ColumnID={'ProfileNames','ProfileSources'};
            profilesTable.ColHeader={...
            DAStudio.message('SystemArchitecture:AddRemoveProfileDialog:Name'),...
            DAStudio.message('SystemArchitecture:AddRemoveProfileDialog:LinkedTo')};
            profilesTable.ColumnStretchable=[1,1];
            profilesTable.ColumnCharacterWidth=[10,15];
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
            profilesTable.MinimumSize=[500,250];

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
