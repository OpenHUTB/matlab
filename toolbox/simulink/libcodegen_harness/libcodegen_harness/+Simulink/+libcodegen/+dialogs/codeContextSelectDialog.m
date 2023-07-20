classdef codeContextSelectDialog<handle


    properties(SetObservable=true)
        mdlH=[];
        instanceName='';
        instanceHandle=[];
        libName='';
        refBlockH='';
        refBlockName='';
        activeContextName='';
        ccList={};
        selIdx=1;
        currIdx=1;
readOnly
hModelCloseListener
studioApp
    end

    methods

        function varType=getPropDataType(this,varName)%#ok
            assert(strcmp(varName,'selIdx'));
            varType='double';
        end

        function setPropValue(this,varName,varVal)
            if(strcmp(varName,'selIdx'))
                this.selIdx=str2double(varVal);
            else
                DAStudio.Protocol.setPropValue(obj,varName,varVal);
            end
        end

        function this=codeContextSelectDialog(model,selection)

            this.mdlH=get_param(model,'handle');

            this.studioApp=SLM3I.SLDomain.getLastActiveStudioApp();
            this.readOnly=false;

            this.instanceName=getfullname(selection);
            this.instanceHandle=get_param(selection,'Handle');
            refBlock=get_param(selection,'ReferenceBlock');
            this.refBlockH=get_param(refBlock,'Handle');
            this.refBlockName=getfullname(this.refBlockH);
            this.libName=bdroot(this.refBlockName);
            codeContexts=Simulink.libcodegen.internal.getBlockCodeContexts(this.libName,this.refBlockH);
            this.activeContextName=Simulink.libcodegen.internal.getActiveContextForSS(this.mdlH,this.instanceHandle);
            if isempty(this.activeContextName)
                this.activeContextName=codeContexts(1).name;
                Simulink.libcodegen.internal.setActiveContextForSS(this.mdlH,this.instanceHandle,this.activeContextName);
            end
            this.ccList{1}=this.activeContextName;
            for i=1:length(codeContexts)
                if~strcmp(codeContexts(i).name,this.activeContextName)
                    this.ccList{end+1}=codeContexts(i).name;
                end
            end

        end

        function dlgDescGroup=addDialogDescriptionUI(this)
            desc.Type='text';
            desc.Name=DAStudio.message('Simulink:CodeContext:ContextSelectDialogInstructions',this.instanceName);
            desc.Alignment=1;
            desc.WordWrap=true;
            desc.Tag='CodeContextSelectDlgDescTag';
            desc.RowSpan=[1,1];
            desc.ColSpan=[1,3];

            refLabel.Type='text';
            refLabel.Name=DAStudio.message('Simulink:CodeContext:ContextSelectDialogReferenceBlock');
            refLabel.Alignment=1;
            refLabel.WordWrap=true;
            refLabel.Tag='CodeContextSelectDlgRefLabelTag';
            refLabel.RowSpan=[2,2];
            refLabel.ColSpan=[1,1];

            refLink.Type='hyperlink';
            refLink.Name=this.refBlockName;
            refLink.Tag='CodeContextSelectDlgRefBlockLink';
            refLink.RowSpan=[2,2];
            refLink.ColSpan=[2,3];
            refLink.ToolTip=DAStudio.message('Simulink:CodeContext:ContextSelectDialogGoToLibraryBlock');
            refLink.ObjectMethod='refBlockLink_cb';
            refLink.MethodArgs={'%dialog'};
            refLink.ArgDataTypes={'handle'};

            dlgDescGroup.Type='group';
            dlgDescGroup.Items={desc,refLabel,refLink};
            dlgDescGroup.Tag='CodeContextSelectDlgDescGroupTag';
            dlgDescGroup.RowSpan=[1,2];
            dlgDescGroup.ColSpan=[1,3];
            dlgDescGroup.LayoutGrid=[2,3];
            dlgDescGroup.ColStretch=[0,1,0];
        end

        function activeGroup=addActiveContextLink(this)

            lnk.Type='hyperlink';
            lnk.Name=this.activeContextName;
            lnk.Alignment=1;
            lnk.Tag='HarnessListDlgActiveLinkTag';
            lnk.ToolTip=DAStudio.message('Simulink:CodeContext:ContextSelectDialogOpenActiveTooltip');
            lnk.ObjectMethod='activeLink_cb';
            lnk.MethodArgs={'%dialog'};
            lnk.ArgDataTypes={'handle'};
            lnk.RowSpan=[1,1];
            lnk.ColSpan=[1,3];

            activeGroup.Type='group';
            activeGroup.Name=DAStudio.message('Simulink:CodeContext:ContextSelectDialogActive');
            activeGroup.Items={lnk};
            activeGroup.Tag='CodeContextSelectDlgActiveLinkGroupTag';
            activeGroup.RowSpan=[3,3];
            activeGroup.ColSpan=[1,3];
            activeGroup.LayoutGrid=[1,3];
            activeGroup.ColStretch=[0,1,0];
        end

        function selectorGroup=addContextSelector(this)
            selector.Type='combobox';
            selector.Entries=this.ccList;
            selector.Values=1:length(this.ccList);
            selector.ObjectProperty='selIdx';
            selector.ObjectMethod='selectionChanged_cb';
            selector.DialogRefresh=true;
            selector.MethodArgs={'%dialog'};
            selector.ArgDataTypes={'handle'};
            selector.Mode=true;
            selector.Tag='CodeContextSelector';
            selector.RowSpan=[1,1];
            selector.ColSpan=[1,3];

            selectorGroup.Type='group';
            selectorGroup.Name=DAStudio.message('Simulink:CodeContext:ContextSelectDialogSelector');
            selectorGroup.Items={selector};
            selectorGroup.Tag='CodeContextSelectDlgDescGroupTag';
            selectorGroup.RowSpan=[4,4];
            selectorGroup.ColSpan=[1,3];
            selectorGroup.LayoutGrid=[1,3];
            selectorGroup.ColStretch=[0,1,0];
        end

        function schema=getDialogSchema(this)
            schema.DialogTitle=DAStudio.message('Simulink:CodeContext:ContextSelectDialogTitle');
            schema.DialogTag='HarnessSelectDlgTag';
            schema.LayoutGrid=[4,3];
            schema.RowStretch=[0,0,0,1];
            schema.ColStretch=[0,0,1];

            if~isempty(this.ccList)
                schema.Items={this.addDialogDescriptionUI(),this.addActiveContextLink(),this.addContextSelector()};
            end

            schema.ExplicitShow=true;
            schema.HelpMethod='dlgHelpMethod';

            schema.PostApplyMethod='dlgPostApplyMethod';
            schema.PostApplyArgs={'%dialog'};
            schema.PostApplyArgsDT={'handle'};
            schema.CloseMethod='dlgCloseMethod';
            schema.IsScrollable=0;

            schema.StandaloneButtonSet={'OK','Cancel','Help'};

        end

        function selectionChanged_cb(this,dlg)


            if this.selIdx~=this.currIdx
                this.currIdx=this.selIdx;
                this.activeContextName=this.ccList{this.selIdx};
                dlg.refresh;
            end
        end

        function activeLink_cb(this,~)
            Simulink.libcodegen.internal.openCodeContext(this.refBlockH,this.activeContextName);
        end

        function refBlockLink_cb(this,~)
            open_system(this.libName);
            hilite(get_param(this.refBlockH,'Object'));
        end


        function dlgHelpMethod(~)
            try
                mapFile=fullfile(docroot,'sltest','helptargets.map');
                helpview(mapFile,'harnessCreateHelp');
            catch ME
                dp=DAStudio.DialogProvider;
                dp.errordlg(ME.message,'Error',true);
            end
        end

        function[status,msg]=dlgPostApplyMethod(this,~)
            status=true;
            msg=[];
            try
                ccName=this.ccList{this.selIdx};
                Simulink.libcodegen.internal.setActiveContextForSS(this.mdlH,this.instanceHandle,ccName);
            catch me
                status=false;
                msg=me.message;
            end

        end

        function dlgCloseMethod(this)

        end

        function show(~,dlg)
            width=dlg.position(3);
            height=dlg.position(4);
            dlg.position=Simulink.harness.internal.calcDialogGeometry(width,height,'ModelCenter');
            dlg.show();
        end
    end


    methods(Static)
        function create(model,selection)
            import Simulink.libcodegen.dialogs.codeContextSelectDialog;

            currDlgList=DAStudio.ToolRoot.getOpenDialogs();



            for j=1:numel(currDlgList)
                currDlg=currDlgList(j);
                currSrc=currDlg.getSource();
                if strcmp(currDlg.dialogTag,'HarnessSelectDlgTag')&&strcmp(getfullname(currSrc.mdlH),model)
                    currDlg.show();
                    return;
                end
            end

            src=codeContextSelectDialog(model,selection);
            dlg=DAStudio.Dialog(src);
            src.show(dlg);
            blkDiagram=get(src.mdlH,'Object');




            src.hModelCloseListener=Simulink.listener(blkDiagram,'CloseEvent',@(hSrc,ev)Simulink.libcodegen.dialogs.codeContextSelectDialog.onModelClose(hSrc,ev,dlg));
        end

        function onModelClose(~,~,dlg)

            if ishandle(dlg)
                delete(dlg);
            end
        end

    end

end



