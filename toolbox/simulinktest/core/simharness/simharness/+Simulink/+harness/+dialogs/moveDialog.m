classdef moveDialog<handle




    properties(SetObservable=true)
        mdl='';
        harnessName='';
        newName='';
        harnessOwnerPath='';
        operType='';
studioApp
readOnly
    end

    methods
        function this=moveDialog(model,name,ownerPath,operationType)
            this.mdl=model;
            this.operType=operationType;
            this.studioApp=SLM3I.SLDomain.getLastActiveStudioApp();
            this.readOnly=false;
            this.harnessName=name;
            this.harnessOwnerPath=ownerPath;
            this.newName=Simulink.harness.internal.getDefaultName(model,[],[]);
        end

        function grp=addHarnessOwnerPathGroup(this)
            grp.Type='group';
            grp.Tag='HarnessOwnerPathGroup';
            grp.Items={this.addHarnessOwnerPathText(),...
            this.addHarnessOwnerPathRefreshBtn(),...
            this.addHarnessOwnerPathTree()};
            grp.LayoutGrid=[2,3];
            grp.RowStretch=[0,1];
            grp.ColStretch=[0,1,0];
            grp.RowSpan=[1,1];
            grp.ColSpan=[1,1];
        end

        function txt=addHarnessOwnerPathText(~)
            txt.Name=DAStudio.message('Simulink:Harness:MoveDialogEditOwnerPath');
            txt.Tag='HarnessOwnerPathText';
            txt.Type='text';
            txt.RowSpan=[1,1];
            txt.ColSpan=[1,1];
        end

        function btn=addHarnessOwnerPathRefreshBtn(~)
            btn.Name=DAStudio.message('Simulink:Harness:RefreshToolTip');
            btn.Tag='HarnessOwnerPathRefreshButton';
            btn.Type='pushbutton';
            btn.RowSpan=[1,1];
            btn.ColSpan=[3,3];
            btn.ObjectMethod='refresh_cb';
            btn.MethodArgs={'%dialog'};
            btn.ArgDataTypes={'handle'};
        end

        function tree=addHarnessOwnerPathTree(this)
            tree.Name=DAStudio.message('Simulink:Harness:MoveDialogEditOwnerPath');
            tree.Type='tree';
            tree.TreeItems=this.generateTreeItems();
            tree.TreeMultiSelect=0;
            tree.TreeExpandItems=this.generateExpandedNodeSequence(get_param(this.harnessOwnerPath,'Object'));
            tree.Tag='HarnessOwnerPathTree';
            tree.RowSpan=[2,2];
            tree.ColSpan=[1,3];
        end

        function txt=addHarnessNameWidget(~)
            txt.Name=DAStudio.message('Simulink:Harness:MoveDialogEditName');
            txt.Type='edit';
            txt.Tag='HarnessNameEdit';
            txt.RowSpan=[2,2];
            txt.ColSpan=[1,1];
            txt.PreferredSize=[300,-1];
        end

        function[status,err]=dlgPostApplyMethod(this,dlg)
            status=true;
            err='';
            npath=dlg.getWidgetValue('HarnessOwnerPathTree');
            nname=dlg.getWidgetValue('HarnessNameEdit');
            warning('backtrace','off');
            harnessCreateStage=Simulink.output.Stage(dlg.getTitle,...
            'ModelName',this.mdl,'UIMode',true);%#ok
            try
                if strcmp(this.operType,'move')
                    Simulink.harness.move(this.harnessOwnerPath,this.harnessName,...
                    'DestinationOwner',npath,'Name',nname);
                else
                    Simulink.harness.clone(this.harnessOwnerPath,this.harnessName,...
                    'DestinationOwner',npath,'Name',nname);
                end
            catch ME
                status=false;
                err=ME.message;
            end
            warning('backtrace','on');

            Simulink.harness.internal.refreshHarnessListDlg(this.mdl);
        end

        function schema=getDialogSchema(this)
            if strcmp(this.operType,'move')
                schema.DialogTitle=DAStudio.message('Simulink:Harness:MoveDialogTitleMove');
            else
                schema.DialogTitle=DAStudio.message('Simulink:Harness:MoveDialogTitleClone');
            end
            schema.DialogTag='MoveDlgTag';
            schema.LayoutGrid=[2,1];
            schema.RowStretch=[0,0];
            schema.ColStretch=1;

            schema.Items={this.addHarnessOwnerPathGroup(),...
            this.addHarnessNameWidget()};

            schema.ExplicitShow=true;
            schema.IsScrollable=0;
            schema.StandaloneButtonSet={'OK','Cancel'};

            schema.PostApplyMethod='dlgPostApplyMethod';
            schema.PostApplyArgs={'%dialog'};
            schema.PostApplyArgsDT={'handle'};
        end

        function show(~,dlg)
            width=dlg.position(3);
            height=dlg.position(4);
            dlg.position=Simulink.harness.internal.calcDialogGeometry(width,height,'ModelCenter');
            dlg.show();
        end

        function refresh_cb(this,dlg)
            if getSimulinkBlockHandle(this.harnessOwnerPath)<0
                return;
            end
            dlg.refresh;
        end

        function ret=generateExpandedNodeSequence(~,obj)
            ret={};
            while~isa(obj,'Simulink.Root')
                ret=[ret,{obj.getFullName}];%#ok<AGROW>
                obj=obj.up;
            end
        end

        function ret=generateTreeItems(this)


            blks=find_system('MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Open','on');
            mdls=unique(cellfun(@(x)Simulink.harness.internal.getBlockDiagram(x),blks,'UniformOutput',false)');
            mdls=mdls(cellfun(@(x)~Simulink.harness.isHarnessBD(x),mdls));
            ret={};
            for j=1:numel(mdls)
                ret=[ret,this.generateValidDestinationTree(get_param(mdls{j},'Object'))];%#ok<AGROW>
            end
        end

        function ret=generateValidDestinationTree(this,obj)
            subblks=[];
            if isa(obj,'Simulink.BlockDiagram')||isa(obj,'Simulink.SubSystem')
                for child=obj.getChildren'
                    if isa(child,'Stateflow.Object')
                        actualBlk=get_param(child.Path,'Object');
                        if isa(actualBlk,'Simulink.SubSystem')&&strcmp(actualBlk.Commented,'off')
                            subblks=[subblks,{strrep(child.Name,sprintf('\n'),' ')}];%#ok<AGROW>
                        end
                    elseif Simulink.harness.internal.isValidHarnessOwnerObject(child)&&strcmp(child.Commented,'off')
                        subblks=[subblks,this.generateValidDestinationTree(child)];%#ok<AGROW>
                    end
                end
            end
            if~isempty(subblks)
                ret={strrep(obj.Name,sprintf('\n'),' '),subblks};
            else
                ret={strrep(obj.Name,sprintf('\n'),' ')};
            end
        end
    end

    methods(Static)
        function create(model,name,ownerPath,operationType)
            import Simulink.harness.dialogs.moveDialog;

            currDlgList=DAStudio.ToolRoot.getOpenDialogs();



            for j=1:numel(currDlgList)
                currDlg=currDlgList(j);
                currSrc=currDlg.getSource();
                if strcmp(currDlg.dialogTag,'MoveDlgTag')&&strcmp(currSrc.mdl,model)
                    currDlg.show();
                    return;
                end
            end

            src=moveDialog(model,name,strrep(ownerPath,sprintf('\n'),' '),operationType);
            dlg=DAStudio.Dialog(src);
            if~strcmp(src.operType,'move')
                dlg.setWidgetValue('HarnessNameEdit',src.newName);
            else
                dlg.setWidgetValue('HarnessNameEdit',src.harnessName);
            end
            dlg.setWidgetValue('HarnessOwnerPathTree',src.harnessOwnerPath);
            src.show(dlg);
        end
    end
end
