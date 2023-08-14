classdef EventActionsTab<handle






    properties(Access=public)

        block;
        uddParent;
        selectedEvActionId;
        evActionTabId;
        mOriginalEvActions;
        mEvActionAttribs;

    end


    methods(Abstract)


        evActionAttribs=getEventActionAttributes(this);
    end


    methods(Static)


        function OpenEvtActDialog(blk_hdl,event)


            open_system(blk_hdl);
            dlg=[];
            dialogs=DAStudio.ToolRoot.getOpenDialogs;
            for iDlgs=1:numel(dialogs)
                dlgsrc=dialogs(iDlgs).getDialogSource;
                if isa(dlgsrc,'slde.AttributeBlockDialog')&&...
                    dlgsrc.getBlock.handle==blk_hdl
                    dlg=dialogs(iDlgs);
                    break;
                end
            end

            if isempty(dlg)
                return
            end

            this=dlg.getSource.Impl;
            i_tab=this.evActionTabId;
            if i_tab<0
                return;
            end

            imDlg=DAStudio.imDialog.getIMWidgets(dlg);
            tabs=imDlg.find('-isa','DAStudio.imTabBar');
            if tabs.getCurrentTab~=i_tab
                tabs.setTab(i_tab);
            end



            evtItem=imDlg.find('-isa','DAStudio.imListBox');

            i_evt=-1;
            for i=1:numel(this.mEvActionAttribs)
                if strcmp(this.mEvActionAttribs{i}.ObjectProperty,event)
                    i_evt=i-1;
                    break;
                end
            end
            if(i_evt>=0)&&(evtItem.getCurrentSelections~=i_evt)
                evtItem.select(i_evt);
            end

        end



    end


    methods


        function this=EventActionsTab(blk,udd)


            this.block=get_param(blk,'Object');
            this.uddParent=udd;
            this.selectedEvActionId=1;
            this.evActionTabId=-1;
            this.mOriginalEvActions=[];
            this.mEvActionAttribs=this.getEventActionAttributes();

        end


        function schema=getEventActionsTabSchema(this)



            if isempty(this.mOriginalEvActions)
                this.cacheEventAction();
            end


            evActionEntries=cell(1,length(this.mEvActionAttribs));
            for i=1:length(this.mEvActionAttribs)
                evActionEntry=this.mEvActionAttribs{i}.Name;

                if this.actionHasContent(this.mEvActionAttribs{i}.ObjectProperty)
                    evActionEntry=strcat(evActionEntry,'*');
                end

                evActionEntries{i}=evActionEntry;
            end


            wEvActions.Type='listbox';
            wEvActions.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:EventActions');
            wEvActions.NameLocation=2;
            wEvActions.Tag='EventActions';
            wEvActions.Graphical=true;
            wEvActions.MultiSelect=false;
            wEvActions.Entries=evActionEntries;
            wEvActions.Value=this.selectedEvActionId-1;
            wEvActions.MatlabMethod='showEventActionEditor';
            wEvActions.MatlabArgs=...
            {this,'%value','%dialog'};
            wEvActions.RowSpan=[1,4];
            wEvActions.ColSpan=[1,1];
            curbd=bdroot(this.block.getFullName);
            wEvActions.Enabled=...
            (~strcmpi(get_param(curbd,'LibraryType'),'BlockLibrary')...
            ||strcmpi(get_param(curbd,'lock'),'off'));

            enAttributes=this.getEntityAttributes();
            if~isempty(enAttributes)
                exampleAttribute=enAttributes{1};
            else
                exampleAttribute='Attribute1';
            end

            entityTree=this.createEntityTree(enAttributes);
            wAvailableAttribs.Type='tree';
            wAvailableAttribs.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:EntityInScope');
            wAvailableAttribs.TreeItems=entityTree;
            wAvailableAttribs.TreeMultiSelect=false;
            wAvailableAttribs.ExpandTree=true;
            wAvailableAttribs.RowSpan=[5,12];
            wAvailableAttribs.ColSpan=[1,1];
            wAvailableAttribs.Graphical=true;



            idx=this.selectedEvActionId;
            mLabelTxt.Type='text';
            mLabelTxt.Name=strcat(this.mEvActionAttribs{idx}.Name,' action:');
            mLabelTxt.Buddy='EventActionEditor';
            mLabelTxt.RowSpan=[1,1];
            mLabelTxt.ColSpan=[2,4];
            mLabelTxt.Graphical=true;
            mLabelTxt.Tag='EditorLabel';
            mLabelTxt.Underline=1;

            wHelpTxt.Type='text';
            wHelpTxt.Name=DAStudio.message(...
            this.mEvActionAttribs{idx}.DefaultMsg,exampleAttribute);
            wHelpTxt.RowSpan=[2,2];
            wHelpTxt.ColSpan=[2,4];
            wHelpTxt.Graphical=true;
            wHelpTxt.Tag='EditorHelpText';
            wHelpTxt.ForegroundColor=[100,100,100];

            wEvActionEditor.Type='matlabeditor';
            wEvActionEditor.Name='';
            wEvActionEditor.Tag='EventActionEditor';
            wEvActionEditor.ObjectProperty=...
            this.mEvActionAttribs{idx}.ObjectProperty;
            wEvActionEditor.Source=this.block;
            wEvActionEditor.MatlabMethod='handleEditorEvent';
            wEvActionEditor.MatlabArgs={this,'%value',this.getPrmIdx(...
            this.mEvActionAttribs{idx}.ObjectProperty),'%dialog'};
            wEvActionEditor.Mode=true;
            wEvActionEditor.ToolTip=DAStudio.message(...
            this.mEvActionAttribs{idx}.ToolTip);
            wEvActionEditor.RowSpan=[3,11];
            wEvActionEditor.ColSpan=[2,4];
            wEvActionEditor.MatlabEditorFeatures={...
            'SyntaxHilighting',...
            'LineNumber',...
            'GoToLine',...
            'TabCompletion',...
            };
            wEvActionEditor.Enabled=Simulink.isParameterEnabled...
            (this.block.handle,this.mEvActionAttribs{idx}.ObjectProperty)...
            &&strcmpi(get_param(bdroot(this.block.getFullName),...
            'SimulationStatus'),'stopped');

            wPtrnAssistant.Type='pushbutton';
            wPtrnAssistant.Tag='PatternAssistant';
            wPtrnAssistant.Name='Insert pattern ...';
            wPtrnAssistant.ToolTip='Open pattern assistant';
            wPtrnAssistant.ObjectMethod='openPatternAssistant';
            wPtrnAssistant.Source=this;
            wPtrnAssistant.MethodArgs={'%dialog'};
            wPtrnAssistant.ArgDataTypes={'handle'};
            wPtrnAssistant.DialogRefresh=false;
            wPtrnAssistant.Graphical=true;
            wPtrnAssistant.RowSpan=[12,12];
            wPtrnAssistant.ColSpan=[4,4];


            visible=getIsEventActionVisible(this);
            schema.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:EventActions');
            schema.Items={...
            wEvActions,...
            wAvailableAttribs,...
            mLabelTxt,...
            wEvActionEditor,...
            wHelpTxt,...
            wPtrnAssistant,...
            };
            schema.LayoutGrid=[12,4];
            schema.RowStretch=[0,0,1,1,1,1,1,1,1,1,1,0];
            schema.ColStretch=[1,1,1,1];
            schema.ShowGrid=0;
            schema.Visible=visible;
        end


        function openPatternAssistant(this,dialog)

            pttrnAssistant=slde.ddg.PatternAssistant(dialog,...
            'EventActionEditor',this);
            pttrnDlg=DAStudio.Dialog(pttrnAssistant);

        end


        function getSigHierFromPort()


            pHandles=get_param(this.block.Handle,'PortHandles');
            sigHier=get_param(pHandles.Inport(1),...
            'SignalHierarchy');
        end


        function showEventActionEditor(this,val,dlg)

            this.selectedEvActionId=val+1;
            dlg.refresh;

        end


        function handleEditorEvent(this,val,prmIdx,dlg)

            this.uddParent.handleEditEvent(val,prmIdx,dlg);
            dlg.refresh;

        end


        function has=actionHasContent(this,actionObjProp)

            has=~isempty(strtrim(this.block.(actionObjProp)));

        end


        function idx=getPrmIdx(this,tag)

            prms=this.block.IntrinsicDialogParameters;
            prmNames=fieldnames(prms);
            idx=find(strcmp(prmNames,tag));
            assert(~isempty(idx));
            idx=idx-1;

        end


        function enAttributes=getEntityAttributes(this)

            enAttributes={};
            sigHier=this.getSigHierFromPort();
            if(~isempty(sigHier))
                enAttributes=this.traceSignalHierarchy(sigHier);
            end

        end


        function enAttributes=traceSignalHierarchy(~,sigHier)

            enAttributes={};
            attribs=sigHier.Children;
            if(~isempty(attribs))
                for i=1:length(attribs)
                    subAttribs=attribs(i).Children;
                    sigNames={};
                    for j=1:length(subAttribs)
                        sigNames(end+1)=...
                        {subAttribs(j).SignalName};
                    end

                    enAttributes=[enAttributes...
                    ,{attribs(i).SignalName,sigNames}];
                    enAttributes=...
                    enAttributes(~cellfun('isempty',enAttributes));
                end
            else

                enAttributes(end+1)={''};
            end

        end


        function entityTree=createEntityTree(~,enAttributes)

            if(numel(enAttributes)==1&&...
                (strcmp(enAttributes{1},'')==1))

                entityTree={'entity','entitySys',{'id','priority'}};

            elseif(~isempty(enAttributes))
                entityTree={'entity',enAttributes,'entitySys',...
                {'id','priority'}};

            else
                entityTree={'entity',{'???'}};
            end

        end


        function editTimeAttribs=getEditTimeAttributes(this,sigHier)

            editTimeAttribs=this.getEditTimeAttributesHelper(...
            sigHier,'');

        end


        function editTimeAttribs=getEditTimeAttributesHelper(this,...
            sigHier,sigName)

            editTimeAttribs={};
            if(~isempty(sigHier))
                for j=1:numel(sigHier)
                    attribs=sigHier(j);

                    if(~isempty(attribs))
                        for i=1:length(attribs)
                            if(isempty(sigName))
                                editTimeAttribs=...
                                [editTimeAttribs,...
                                this.getEditTimeAttributesHelper(...
                                attribs(i).Children,...
                                attribs(i).SignalName)];
                            else
                                editTimeAttribs=...
                                [editTimeAttribs,...
                                this.getEditTimeAttributesHelper(...
                                attribs(i).Children,...
                                strcat(sigName,'.',...
                                attribs(i).SignalName))];
                            end
                        end
                    else
                        if(isempty(sigName))



                            editTimeAttribs(end+1)={...
                            sigHier(j).SignalName};
                        else
                            editTimeAttribs(end+1)={strcat(sigName,...
                            '.',sigHier(j).SignalName)};
                        end
                    end
                end
            elseif(isempty(sigName))

                editTimeAttribs(end+1)={'entity'};
            else
                editTimeAttribs(end+1)={sigName};
            end

            editTimeAttribs=unique(editTimeAttribs);

        end


        function cacheEventAction(this)


            for idx=1:length(this.mEvActionAttribs)
                this.mOriginalEvActions.(...
                this.mEvActionAttribs{idx}.Tag)=...
                this.block.(this.mEvActionAttribs{idx}.Tag);
            end

        end


        function revertEventActions(this)


            for idx=1:length(this.mEvActionAttribs)
                this.block.(this.mEvActionAttribs{idx}.Tag)=...
                this.mOriginalEvActions.(this.mEvActionAttribs{idx}.Tag);
            end

            this.mOriginalEvActions=[];

        end


        function status=getIsEventActionVisible(~)

            status=true;
        end



    end



end


