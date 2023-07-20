
classdef codeContextCreateDialog<handle
    properties(SetObservable=true)
ccOwner
ccInfo
mdlH
ownerH
defaultName
codeContextName
specifyInstance
instanceFileName
instanceModelName
cutCandidates
cutName
cutMap
activateFlag
unhiliteOnClose
libLocked
harnessDescription
hModelCloseListener
hModelStatusListener
hBlockDeleteListener
        forceClose=false
    end

    methods
        function this=codeContextCreateDialog(ccOwner,instanceInfo)
            this.ccOwner=ccOwner;
            this.ownerH=ccOwner.Handle;
            this.mdlH=bdroot(this.ownerH);

            this.defaultName=Simulink.libcodegen.internal.getDefaultCCName(...
            bdroot(this.ccOwner.Path),this.ccOwner.Name);

            this.codeContextName=this.defaultName;
            this.specifyInstance=false;
            if~isempty(instanceInfo)
                this.instanceFileName=instanceInfo.instanceFileName;
                Simulink.libcodegen.dialogs.shared.InstanceFileNameCallback(this);
                this.instanceModelName=instanceInfo.instanceModelName;
                this.cutName=instanceInfo.instanceCUTName;
                this.specifyInstance=true;
                this.hiliteOwner_cb();
            else
                this.instanceFileName='';
                this.instanceModelName='';
                this.cutName='';
                this.cutCandidates={};
                this.cutMap=containers.Map;
            end

            this.libLocked=strcmp(get_param(this.mdlH,'Lock'),'on');

            this.unhiliteOnClose=false;
            this.harnessDescription='';
            this.ccInfo='';
        end

        function varType=getPropDataType(obj,varName)%#ok
            switch(varName)
            case{'specifyInstance',...
                'unhiliteOnClose',...
                'libLocked'}
                varType='bool';
            case{'instanceFileName',...
                'instanceModelName',...
                'codeContextName',...
                'cutName',...
                'harnessDescription'}
                varType='string';
            otherwise
                varType='other';
            end
        end

        function setPropValue(obj,varName,varVal)
            if strcmp(varName,'specifyInstance')
                obj.specifyInstance=(varVal=='1');
            elseif strcmp(varName,'instanceFileName')
                obj.instanceFileName=varVal;
            elseif strcmp(varName,'instanceModelName')
                obj.instanceModelName=varVal;
            elseif strcmp(varName,'codeContextName')
                obj.codeContextName=varVal;
            elseif strcmp(varName,'cutName')
                obj.cutName=varVal;
            elseif strcmp(varName,'harnessDescription')


                obj.harnessDescription=varVal;
            end
        end

        function dlgDescGroup=addDialogDescriptionUI(this)
            lbl.Name=DAStudio.message('Simulink:CodeContext:CodeContextInstructions');
            lbl.Type='text';
            lbl.Tag='CodeContextCreateDescLblTag';
            lbl.Alignment=2;
            lbl.WordWrap=true;
            lbl.RowSpan=[1,1];
            lbl.ColSpan=[1,3];

            lblCUT.Name=DAStudio.message('Simulink:CodeContext:CodeContextComponent');
            lblCUT.Type='text';
            lblCUT.Tag='CodeContextCreateCUTLblTag';
            lblCUT.RowSpan=[2,2];
            lblCUT.ColSpan=[1,1];

            lnk.Name=this.ccOwner.getFullName();
            lnk.Type='hyperlink';
            lnk.Alignment=1;
            lnk.Tag='CodeContextCreateDlgOwnerLinkTag';
            lnk.ToolTip=DAStudio.message('Simulink:CodeContext:CodeContextOwnerTooltip');
            lnk.ObjectMethod='hiliteOwner_cb';
            lnk.RowSpan=[2,2];
            lnk.ColSpan=[2,2];

            btn=Simulink.libcodegen.dialogs.shared.addUnlockLibraryButton(this,2,3);

            dlgDescGroup.Type='group';
            dlgDescGroup.LayoutGrid=[2,3];
            dlgDescGroup.RowSpan=[1,2];
            dlgDescGroup.ColSpan=[1,3];
            dlgDescGroup.ColStretch=[0,0,1];
            dlgDescGroup.Items={lbl,lblCUT,lnk,btn};
            dlgDescGroup.Tag='CodeContextCreateDescGroupTag';
        end

        function[panel,newRow]=addContextNameUI(~,currRow)
            lbl.Name=DAStudio.message('Simulink:CodeContext:CodeContextName');
            lbl.Type='text';
            lbl.Buddy='CodeContextCreateDlgNameEditTag';
            lbl.Alignment=1;
            lbl.RowSpan=[currRow,currRow];
            lbl.ColSpan=[1,1];

            edit.Type='edit';
            edit.ObjectProperty='codeContextName';
            edit.Mode=true;
            edit.Tag='CodeContextCreateDlgNameEditTag';
            edit.RowSpan=[currRow,currRow];
            edit.ColSpan=[2,2];

            panel.Type='panel';
            panel.LayoutGrid=[1,2];
            panel.Items={lbl,edit};

            newRow=currRow+1;
        end

        function cbox=addCodeContextActivationUI(~)
            cbox=Simulink.harness.internal.getCheckBoxSrc(...
            'Simulink:CodeContext:ContextActivate',...
            'activateFlag',...
            'CodeContextCreateDlgActivateCBoxTag');
        end

        function[editArea,newRow]=addCodeContextDescriptionUI(~,currRow)
            editArea.Name=DAStudio.message('Simulink:CodeContext:CodeContextDescription');
            editArea.Type='editarea';
            editArea.MinimumSize=[0,1];
            editArea.RowSpan=[currRow,currRow];
            editArea.WordWrap=true;
            editArea.ObjectProperty='harnessDescription';
            editArea.Tag='CodeContextCreateDlgDescriptionTag';
            newRow=currRow+1;
        end

        function hiliteOwner_cb(this)
            try
                open_system(bdroot(this.ownerH));
                hilite(this.ccOwner);
                this.unhiliteOnClose=true;
            catch ME
                Simulink.harness.internal.error(ME,true);
            end
        end

        function unlocklibrary_cb(this,dlg)
            set_param(this.mdlH,'Lock','off');
            this.libLocked=strcmp(get_param(this.mdlH,'Lock'),'on');
            dlg.refresh();
        end




        function schema=getDialogSchema(this)
            schema.DialogTitle=DAStudio.message('Simulink:CodeContext:CodeContextDialogTitle');
            schema.DialogTag='CodeContextCreateDlgTag';

            schema.Items={};
            mainGroup.Items={};
            currRow=1;
            mainGroup.Type='group';
            [namePanel,currRow]=this.addContextNameUI(currRow);
            [instanceInfo,currRow]=Simulink.libcodegen.dialogs.shared.createInstanceInfoWidget(this,currRow);
            [description,currRow]=this.addCodeContextDescriptionUI(currRow);

            mainGroup.Items={namePanel,instanceInfo,description};
            mainGroup.Name=DAStudio.message('Simulink:CodeContext:PropertiesTab');
            mainGroup.LayoutGrid=[currRow,5];
            mainGroup.RowSpan=[4,currRow+3];
            mainGroup.ColSpan=[1,5];
            mainGroup.RowStretch=[zeros(1,currRow-1),1];
            mainGroup.Enabled=~this.libLocked;

            panel.Type='panel';
            panel.Items={this.addDialogDescriptionUI(),mainGroup};
            panel.Tag='CodeContextCreateDialogPanel';

            schema.Items={panel};
            schema.ExplicitShow=true;
            schema.HelpMethod='dlgHelpMethod';

            schema.PostApplyMethod='dlgPostApplyMethod';
            schema.PostApplyArgs={'%dialog'};
            schema.PostApplyArgsDT={'handle'};
            schema.CloseMethod='dlgCloseMethod';
            schema.IsScrollable=true;

            if~this.libLocked
                schema.StandaloneButtonSet={'OK','Cancel','Help'};
            else
                schema.StandaloneButtonSet={'Cancel','Help'};
            end

        end

        function[status,msg]=dlgPostApplyMethod(this,~)
            status=false;


            harnessCreateStage=Simulink.output.Stage(...
            DAStudio.message('Simulink:CodeContext:CreateCodeContextStage'),...
            'ModelName',bdroot(this.ccOwner.Path),...
            'UIMode',true);%#ok

            try
                [status,msg,this.ccInfo]=Simulink.libcodegen.dialogs.shared.createContextFromDialog(this);
            catch ME

                Simulink.harness.internal.error(ME,true);



                msg=DAStudio.message('Simulink:CodeContext:CreateAborted');

            end

        end

        function dlgHelpMethod(~)
            try
                mapFile=fullfile(docroot,'ecoder','helptargets.map');
                helpview(mapFile,'functionInterfaceCreateHelp');
            catch ME
                dp=DAStudio.DialogProvider;
                dp.errordlg(ME.message,'Error',true);
            end
        end

        function dlgCloseMethod(this)
            if this.forceClose
                return
            end
            if this.unhiliteOnClose
                hilite(this.ccOwner,'none');
            end
        end

        function show(~,dlg)

            if ispc
                width=max(600,dlg.position(3));
            else
                width=max(550,dlg.position(3));
            end
            height=dlg.position(4)+30;
            dlg.position=Simulink.harness.internal.calcDialogGeometry(width,height,'Model');
            dlg.show();
        end

        function registerDAListeners(obj)
            bd=get_param(obj.mdlH,'Object');
            bd.registerDAListeners;
        end
    end

    methods(Static)
        function create(ccOwner,instanceInfo)
            import Simulink.libcodegen.dialogs.codeContextCreateDialog;
            src=codeContextCreateDialog(ccOwner,instanceInfo);
            dlg=DAStudio.Dialog(src);
            src.show(dlg);
            blkDiagram=get_param(bdroot(ccOwner.Handle),'Object');




            src.hModelCloseListener=Simulink.listener(blkDiagram,'CloseEvent',@(hSrc,ev)codeContextCreateDialog.onModelClose(hSrc,ev,src,dlg));
            src.hModelStatusListener=handle.listener(DAStudio.EventDispatcher,'ReadonlyChangedEvent',{@Simulink.libcodegen.dialogs.shared.onReadOnlyChanged,src,dlg});
            src.hBlockDeleteListener=Simulink.listener(ccOwner,'DeleteEvent',@(hSrc,ev)codeContextCreateDialog.onBlockDelete(hSrc,ev,src,dlg));
        end

        function onModelClose(~,~,src,dlg)

            src.forceClose=true;
            if ishandle(dlg)
                delete(dlg);
            end
        end

        function onBlockDelete(~,~,src,dlg)

            src.forceClose=true;
            if ishandle(dlg)
                delete(dlg);
            end
        end
    end
end
