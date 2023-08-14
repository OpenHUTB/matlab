classdef Debugger<handle






    properties
        mModel;
    end

    properties(Access=private)
        mModelRT;
        mStepper;

        mTreeNodeMap=[];
        mSimListeners=[];

        mSimStarted=false;
        mIsAtSimPause=false;
        mIsAtBreakpoint;
        mFirstTimeBPNotified=false;

        mExplorerFindStr;
        mInspectorFindStr;
        mCurrentTreeNode;

        mBlockBreakpoints;
        mBlockBreakpointsCache;

        mBreakPointTreeNode=[];

        mEntityWatches;
        mEntityWatchLocs;

        mRequestRefreshExplorer=0;
        mExplorerTag;
    end

    properties(SetObservable=true,Hidden)
        mShowOnlyNonEmpty;
        mDialog=[];
        mPrintDbgInfo=false;
        mModelTree=[];
    end

    methods



        function this=Debugger(varargin)

            if nargin<1
                error('First argument must be a valid SimEvents model');
            end
            modelname=varargin{1};

            if~private_sl_isDesModel(modelname)
                error('First argument must be a valid SimEvents model');
            end

            if(~openDebugger(modelname,true))
                openDebugger(modelname,false);
                error('A model is already being debugged');
            end

            mHdl=get_param(modelname,'handle');
            this.mModel=modelname;
            this.mModelRT=simevents.ModelRoot.get(mHdl);
            this.mPrintDbgInfo=false;

            this.mCurrentTreeNode=[];
            this.mExplorerFindStr='';
            this.mInspectorFindStr='';
            this.mTreeNodeMap=[];
            this.mBlockBreakpoints={};
            this.mEntityWatches=[];
            this.mEntityWatchLocs={};
            this.mShowOnlyNonEmpty=false;

            this.mStepper=Simulink.SimulationStepper(this.mModel);

            this.mIsAtBreakpoint=false;
            this.mBreakPointTreeNode=[];
            this.mExplorerTag='';

            this.mSimListeners=[this.mSimListeners,Simulink.listener(...
            mHdl,'EngineSimStatusRunning',@this.simRunning)];
            this.mSimListeners=[this.mSimListeners,Simulink.listener(...
            mHdl,'EngineSimStatusPaused',@this.simPaused)];
            this.mSimListeners=[this.mSimListeners,Simulink.listener(...
            mHdl,'EngineSimStatusTerminating',@this.simTerminating)];
        end


        function delete(this)

            openDebugger(this.mModel,false);

            if~isempty(this.mDialog)
                delete(this.mDialog);
            end
        end


        function disp(this)

            fprintf('  <a href="matlab:helpPopup simevents.Debugger">SimEvents Debugger</a>\n\n');
            fprintf('  Attached to model ''<a href="matlab:open_system %s">%s</a>''\n\n',this.mModel,this.mModel);
            fprintf('  To start debugging: Click ''Run'' or ''Step Forward'' in the Simulink model\n');
            fprintf('  To stop debugging : Clear this object from the workspace\n\n');
        end


        function schema=getDialogSchema(this)


            toolbarSchema=this.getSchemaToolbar();
            toolbarSchema.RowSpan=[1,1];
            toolbarSchema.ColSpan=[1,1];

            eventStatusSchema=this.getSchemaEventStatus();
            eventStatusSchema.RowSpan=[1,1];
            eventStatusSchema.ColSpan=[2,2];

            explorerSchema=this.getSchemaExplorer();
            explorerSchema.RowSpan=[2,2];
            explorerSchema.ColSpan=[1,1];

            dataSchema=this.getSchemaInspector();
            dataSchema.RowSpan=[2,2];
            dataSchema.ColSpan=[2,2];

            panel.Type='panel';
            panel.Tag='main_panel';
            panel.Items={toolbarSchema,eventStatusSchema,explorerSchema,dataSchema};
            panel.LayoutGrid=[2,2];
            panel.RowStretch=[0,1];
            panel.ColStretch=[0,1];

            schema.DialogTitle=['SimEvents Debugger: ',this.mModel];
            schema.DisplayIcon=fullfile(matlabroot,'toolbox','shared','dastudio','resources','SLEditor','Debugger_Simulink_24.png');
            schema.Items={panel};
            schema.DialogTag=['simevents_debugger_dialog_',this.mModel];
            schema.Source=this;
            schema.SmartApply=true;
            schema.HelpMethod='handleClickHelp';
            schema.HelpArgs={};
            schema.HelpArgsDT={};
            schema.OpenCallback=@(dlg)this.handleOpenDialog(dlg);
            schema.CloseMethod='handleCloseDialog';
            schema.CloseMethodArgs={'%dialog','%closeaction'};
            schema.CloseMethodArgsDT={'handle','char'};
            schema.StandaloneButtonSet={''};
            schema.MinMaxButtons=true;
            schema.ShowGrid=1;
            schema.DisableDialog=~this.mIsAtSimPause;
        end


        function notifyDialogOnBP(this,tNode,~)


            sTime=tic;
            this.mIsAtBreakpoint=true;
            this.mIsAtSimPause=true;
            this.mBreakPointTreeNode=tNode;


            this.mEntityWatchLocs=...
            this.mModelTree.resetChildren(this.mShowOnlyNonEmpty,...
            this.mExplorerFindStr,...
            this.mEntityWatches);
            if strcmp(tNode.Type,'leafblock')
                hilite_system(tNode.FullPath,'find');
            end


            imDlg=DAStudio.imDialog.getIMWidgets(this.mDialog);
            tree=imDlg.find('Tag',this.mExplorerTag);
            tree.setSelection(tNode.DisplayPath);







            this.requestExplorerRefresh();
            this.mDialog.refresh();

            this.mDialog.enableWidgetHighlight('continueButton',[255,0,0,255]);
            this.mDialog.enableWidgetHighlight('nextEventButton',[255,0,0,255]);


            if~this.mFirstTimeBPNotified
                this.mFirstTimeBPNotified=true;
                disp('-----------------------------------------------------');
                disp('Hit breakpoint in SimEvents Debugger');
                disp(' ');
                disp('Click one of the "Continue" buttons on the SimEvents');
                disp('Debugger toolbar to continue the simulation.');
                disp('-----------------------------------------------------');
            end

            elapTime=toc(sTime);
            if this.mPrintDbgInfo
                fprintf('Breakpoint refresh cost: %.2f\n',elapTime);
            end
        end


        function notifyDialogOnBPExit(this,~,~)


            this.mDialog.disableWidgetHighlight('continueButton');
            this.mDialog.disableWidgetHighlight('nextEventButton');
        end
    end

    methods(Hidden)



        function handleOpenDialog(this,dlg)


            this.mDialog=dlg;
            this.mExplorerFindStr='';
            this.mInspectorFindStr='';
            this.mCurrentTreeNode=[];
        end


        function handleCloseDialog(this,~,~)


            this.commitClearBP('yes');
            if this.mIsAtBreakpoint
                this.mModelTree.continueFromBreak();
                this.mIsAtBreakpoint=false;
            end
            this.mDialog=[];
        end


        function handleClickHelp(~)
            helpview(fullfile(docroot,'simevents','helptargets.map'),'SimEventsDebugger');
        end


        function handleClickGotoModelButton(this)


            open_system(this.mModel);
        end


        function handleClickClearBP(this)


            dp=DAStudio.DialogProvider;
            dp.questdlg('Clear all breakpoints?','Question',...
            {'Yes','No'},'No',@(str)this.commitClearBP(str));
        end


        function commitClearBP(this,str)


            if strcmpi(str,'no')
                return;
            end

            for k=1:length(this.mBlockBreakpoints)
                blk=this.mBlockBreakpoints{k};
                blkNode=this.mTreeNodeMap(blk);
                blkNode.removeBlockBreakPoint(-1,1);
                blkNode.removeBlockBreakPoint(-1,2);
            end
            this.mBlockBreakpoints={};


            for ec=1:length(this.mModelTree.EventCalendarChildNodes)
                ecNode=this.mModelTree.EventCalendarChildNodes(ec);
                ecNode.removeAllEvCalBreakPoints();
            end


            this.mEntityWatches=[];
            this.mEntityWatchLocs={};

            this.mDialog.refresh();
        end


        function handleClickNextEvent(this)



            this.mModelTree.addNextEventBreakPoint();


            handleClickContinueSimulation(this,true);
        end


        function handleClickContinueSimulation(this,calledFromNextEvent)

            if~isempty(this.mBreakPointTreeNode)&&...
                strcmp(this.mBreakPointTreeNode.Type,'leafblock')
                hilite_system(this.mBreakPointTreeNode.FullPath,'none');
            end
            atBP=this.mIsAtBreakpoint;
            this.mIsAtBreakpoint=false;
            this.mIsAtSimPause=false;
            this.mBreakPointTreeNode=[];
            this.mDialog.setEnabled('main_panel',false);

            if~calledFromNextEvent

                this.mModelTree.removeNextEventBreakPoint();
            end

            if atBP
                this.mModelTree.continueFromBreak();
            else
                this.mStepper.continue();
            end
        end

        function handleClickSelectGcbInTree(this,dlg)


            imDlg=DAStudio.imDialog.getIMWidgets(dlg);
            tree=imDlg.find('Tag',this.mExplorerTag);
            name=strrep(gcb,char(10),' ');
            name=strrep(name,[this.mModel,'/'],[this.mModel,'/Storage/']);
            if this.mTreeNodeMap.isKey(name)
                tNode=this.mTreeNodeMap(name);
                tree.setSelection(tNode.DisplayPath);
            end
        end


        function handleExplorerFindStrChanged(this,~,filterStr)


            this.mExplorerFindStr=filterStr;
            this.mModelTree.resetChildren(this.mShowOnlyNonEmpty,filterStr,[]);
            this.requestExplorerRefresh();
            this.mDialog.refresh();
        end


        function handleInspectorFindStrChanged(this,~,filterStr)


            this.mInspectorFindStr=filterStr;
        end


        function handleClickExplorerTreeNode(this,~,value)


            if~isKey(this.mTreeNodeMap,value)
                this.mCurrentTreeNode=[];
                return;
            end

            selNode=this.mTreeNodeMap(value);
            this.mCurrentTreeNode=selNode;


            if~isempty(this.mCurrentTreeNode.FullPath)

            end
        end


        function handleEventCalTableBreakpointChanged(this,~,row,~,...
            value,eventIds)

            evCalNode=this.mCurrentTreeNode;

            event=eventIds(row+1);
            if value==1
                evCalNode.addEvCalBreakPoint('evID',event);
            else
                evCalNode.removeEvCalBreakPoint('evID',event);
            end
        end


        function handleEventCalTableBlockClick(this,~,~,col,value)




            if col==5
                set_param(this.mModel,'HiliteAncestors','none');
                hilite_system([this.mModel,'/',value],'find');
            end
        end


        function handleEventBPTableBreakpointChanged(this,~,row,~,...
            value,ecNodePaths,eventIds)


            event=eventIds(row+1);
            evCalNode=this.mTreeNodeMap(ecNodePaths{row+1});

            if event==-1
                bpType='evcal';
            else
                bpType='evID';
            end

            if value==1
                evCalNode.addEvCalBreakPoint(bpType,event);
            else
                evCalNode.removeEvCalBreakPoint(bpType,event);
            end
        end


        function handleEntityWatchTableValueChanged(this,dlg,row,...
            ~,value,tag)


            entityId=str2double(dlg.getTableItemValue(tag,row,1));
            if value==1
                this.mEntityWatches=[this.mEntityWatches;entityId];
                this.mEntityWatchLocs{end+1}=this.mCurrentTreeNode.FullPath;
            else
                fIdx=find(this.mEntityWatches==entityId,1);
                this.mEntityWatches(fIdx)=[];
                this.mEntityWatchLocs(fIdx)=[];
            end
        end


        function handleEntityWatchChanged(this,dlg,row,~,value,tag)


            entityId=str2double(dlg.getTableItemValue(tag,row,1));
            if value==1
                this.mEntityWatches=[this.mEntityWatches;entityId];
                this.mEntityWatchLocs{end+1}=this.mCurrentTreeNode.FullPath;
            else
                fIdx=find(this.mEntityWatches==entityId,1);
                this.mEntityWatches(fIdx)=[];
                this.mEntityWatchLocs(fIdx)=[];
            end
            dlg.refresh();
        end


        function handleEventCalBPChanged(this,evPath,val)

            evObj=this.mTreeNodeMap(evPath);
            if val
                evObj.addEvCalBreakPoint('evcal',-1);
            else
                evObj.removeEvCalBreakPoint('evcal',-1);
            end
            this.mDialog.refresh();
        end


        function handleStorageBPChanged(this,blkPath,stIdx,bpType,val)

            blkObj=this.mTreeNodeMap(blkPath);
            if val
                blkObj.addBlockBreakPoint(stIdx,bpType);
            else
                blkObj.removeBlockBreakPoint(stIdx,bpType);
            end
            if blkObj.hasBlockBreakPoint(-1,1)||blkObj.hasBlockBreakPoint(-1,2)
                this.mBlockBreakpoints=union(this.mBlockBreakpoints,{blkObj.DisplayPath});
            else
                this.mBlockBreakpoints=setdiff(this.mBlockBreakpoints,{blkObj.DisplayPath});
            end
            this.mDialog.refresh();
        end


        function handleBlockBPChangedSSLevel(this,~,row,col,value,fullpaths)

            blkPath=fullpaths{row+1};
            blkObj=this.mTreeNodeMap(blkPath);
            if value==1
                blkObj.addBlockBreakPoint(-1,col+1);
                this.mBlockBreakpoints=union(this.mBlockBreakpoints,...
                {blkObj.DisplayPath});
            else
                blkObj.removeBlockBreakPoint(-1,col+1);
                this.mBlockBreakpoints=setdiff(this.mBlockBreakpoints,...
                {blkObj.DisplayPath});
            end




        end


        function handleClickRefresh(~,dlg)


            dlg.refresh(true);
        end


        function handleShowOnlyNonEmptyToggleChanged(this,dlg,value)


            this.mShowOnlyNonEmpty=value~=0;
            this.mModelTree.resetChildren(this.mShowOnlyNonEmpty,...
            this.mExplorerFindStr,[]);


            this.requestExplorerRefresh();
            dlg.refresh();
        end


        function handleClickBlockHyperlink(this,blockpath)


            set_param(this.mModel,'HiliteAncestors','none');
            hilite_system(blockpath,'find');
        end
    end

    methods(Access=private)



        function schema=getSchemaEventStatus(this)
            textBox1.Type='text';
            textBox1.Bold=true;
            textBox1.Tag='eventStatusBox1';
            textBox1.ForegroundColor=[255,0,0];
            textBox1.RowSpan=[1,1];
            textBox1.ColSpan=[1,1];

            textBox2.Type='text';
            textBox2.Tag='eventStatusBox2';
            textBox2.RowSpan=[2,2];
            textBox2.ColSpan=[1,1];

            if this.mIsAtBreakpoint
                for ec=1:length(this.mModelTree.EventCalendarChildNodes)
                    ecNode=this.mModelTree.EventCalendarChildNodes(ec);
                    evcal=ecNode.SimRTHandle;
                    ev=evcal.CurrentEvent;
                    if~isempty(ev)
                        break;
                    end
                end

                textBox1.Name='Paused at event: Press continue in debugger toolbar';
                textBox1.ToolTip=sprintf(['Debugger is paused at a breakpoint.\n'...
                ,'Click the "Continue" or "Step to next event" button to continue the simulation. '...
                ,'\n\n'...
                ,'Note that the Simulink toolbar buttons and the MATLAB command window\n'...
                ,'will appear unresponsive while at this breakpoint.']);
                textBox2.Name=sprintf(...
                'Event Time: %.2f s  Type: ''%s''   Priority: %d',...
                ev.Time,ev.Type,ev.Priority);
            elseif this.mIsAtSimPause
                textBox1.Name='Paused: Press continue in debugger toolbar';
                textBox2.Name='';
            else
                textBox1.Name='';
                textBox2.Name='';
            end

            schema.Type='group';
            schema.Items={textBox1,textBox2};
            schema.LayoutGrid=[3,1];
            schema.ColStretch=1;
            schema.RowStretch=[1,1,1];
        end


        function schema=getSchemaToolbar(this)


            col=0;

            col=col+1;
            continueButton.Type='pushbutton';
            continueButton.Tag='continueButton';
            continueButton.Source=this;
            continueButton.ObjectMethod='handleClickContinueSimulation';
            continueButton.MethodArgs={false};
            continueButton.ArgDataTypes={'boolean'};
            continueButton.RowSpan=[1,1];
            continueButton.ColSpan=[col,col];
            continueButton.Enabled=this.mIsAtBreakpoint||this.mIsAtSimPause;
            continueButton.ToolTip='Continue simulation';
            continueButton.FilePath=fullfile(matlabroot,'toolbox',...
            'shared','dastudio','resources','glue','Toolbars','16px','Play_16.png');

            col=col+1;
            nextEventButton.Type='pushbutton';
            nextEventButton.Tag='nextEventButton';
            nextEventButton.Source=this;
            nextEventButton.ObjectMethod='handleClickNextEvent';
            nextEventButton.MethodArgs={};
            nextEventButton.ArgDataTypes={};
            nextEventButton.RowSpan=[1,1];
            nextEventButton.ColSpan=[col,col];
            nextEventButton.Enabled=this.mIsAtBreakpoint||this.mIsAtSimPause;
            nextEventButton.ToolTip='Step to next event';
            nextEventButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio',...
            'resources','glue','Toolbars',...
            '16px','DebuggerStepOver_16.png');

            col=col+1;
            clearBPButton.Type='pushbutton';
            clearBPButton.Tag='clearBPButton';
            clearBPButton.Source=this;
            clearBPButton.ObjectMethod='handleClickClearBP';
            clearBPButton.MethodArgs={};
            clearBPButton.ArgDataTypes={};
            clearBPButton.RowSpan=[1,1];
            clearBPButton.ColSpan=[col,col];
            clearBPButton.Enabled=this.mIsAtBreakpoint||this.mIsAtSimPause;
            clearBPButton.ToolTip='Clear all breakpoints';
            clearBPButton.FilePath=fullfile(matlabroot,'toolbox',...
            'shared','dastudio','resources','delete.png');

            col=col+3;
            refreshButton.Type='pushbutton';
            refreshButton.Tag='refreshButton';
            refreshButton.Source=this;
            refreshButton.ObjectMethod='handleClickRefresh';
            refreshButton.MethodArgs={'%dialog'};
            refreshButton.ArgDataTypes={'handle'};
            refreshButton.RowSpan=[1,1];
            refreshButton.ColSpan=[col,col];
            refreshButton.Enabled=this.mSimStarted;
            refreshButton.ToolTip='Refresh data';
            refreshButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio',...
            'resources','glue','Toolbars','16px','UpdateDiagram_16.png');

            col=col+1;
            handleClickGotoModelButtonButton.Type='pushbutton';
            handleClickGotoModelButtonButton.Tag='handleClickGotoModelButtonButton';
            handleClickGotoModelButtonButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','SimulinkModelIcon.png');
            handleClickGotoModelButtonButton.ToolTip='Go to model window';
            handleClickGotoModelButtonButton.ObjectMethod='handleClickGotoModelButton';
            handleClickGotoModelButtonButton.Source=this;
            handleClickGotoModelButtonButton.MethodArgs={};
            handleClickGotoModelButtonButton.ArgDataTypes={};
            handleClickGotoModelButtonButton.RowSpan=[1,1];
            handleClickGotoModelButtonButton.ColSpan=[col,col];
            handleClickGotoModelButtonButton.DialogRefresh=false;

            col=col+1;
            helpButton.Type='pushbutton';
            helpButton.Tag='helpButton';
            helpButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','help.png');
            helpButton.ToolTip='Help';
            helpButton.ObjectMethod='handleClickHelp';
            helpButton.Source=this;
            helpButton.MethodArgs={};
            helpButton.ArgDataTypes={};
            helpButton.RowSpan=[1,1];
            helpButton.ColSpan=[col,col];
            helpButton.DialogRefresh=false;

            schema.Type='group';
            schema.Items={continueButton,nextEventButton,clearBPButton,refreshButton,handleClickGotoModelButtonButton,helpButton};
            schema.LayoutGrid=[1,col+1];
            schema.ColStretch=[zeros(1,col),1];
        end


        function schema=getSchemaExplorer(this)


            imgFind.Type='image';
            imgFind.Tag='findImage';
            imgFind.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','find.png');
            imgFind.RowSpan=[1,1];
            imgFind.ColSpan=[1,1];

            findEdit.Type='edit';
            findEdit.Tag='findEdit';
            findEdit.Name='';
            findEdit.NameLocation=1;
            findEdit.Source=this;
            findEdit.ObjectMethod='handleExplorerFindStrChanged';
            findEdit.MethodArgs={'%dialog','%value'};
            findEdit.ArgDataTypes={'handle','char'};
            findEdit.Mode=true;
            findEdit.RespondsToTextChanged=true;
            findEdit.Clearable=true;
            findEdit.PlaceholderText='Find block etc.';
            findEdit.Graphical=true;
            findEdit.DialogRefresh=true;
            findEdit.Value=this.mExplorerFindStr;
            findEdit.RowSpan=[1,1];
            findEdit.ColSpan=[2,2];
            if isempty(this.mExplorerFindStr)
                findEdit.ToolTip='Start typing a block or subsystem name to filter down the explorer list';
            else
                findEdit.ToolTip=['Showing only blocks containing ''',this.mExplorerFindStr,''''];
            end

            showOnlyNonEmpty.Type='togglebutton';
            showOnlyNonEmpty.Tag='showOnlyNonEmpty';
            showOnlyNonEmpty.Source=this;
            showOnlyNonEmpty.ObjectMethod='handleShowOnlyNonEmptyToggleChanged';
            showOnlyNonEmpty.MethodArgs={'%dialog','%value'};
            showOnlyNonEmpty.ArgDataTypes={'handle','logical'};
            showOnlyNonEmpty.Mode=true;
            showOnlyNonEmpty.Enabled=this.mSimStarted;
            showOnlyNonEmpty.DialogRefresh=true;
            showOnlyNonEmpty.RowSpan=[1,1];
            showOnlyNonEmpty.ColSpan=[3,3];
            showOnlyNonEmpty.Graphical=true;
            if this.mShowOnlyNonEmpty
                showOnlyNonEmpty.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','SelectionCircle-Off-Pressed.png');
                showOnlyNonEmpty.ToolTip='(ON) Showing only blocks containing entities';
                showOnlyNonEmpty.Value=true;
            else
                showOnlyNonEmpty.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','SelectionCircle-On-Pressed.png');
                showOnlyNonEmpty.ToolTip='Show only blocks containing entities';
                showOnlyNonEmpty.Value=false;
            end

            selectGcbButton.Type='pushbutton';
            selectGcbButton.Tag='selectGcbButton';
            selectGcbButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','BlockIcon.png');
            selectGcbButton.ToolTip='Inspect GCB';
            selectGcbButton.ObjectMethod='handleClickSelectGcbInTree';
            selectGcbButton.Source=this;
            selectGcbButton.MethodArgs={'%dialog'};
            selectGcbButton.ArgDataTypes={'handle'};
            selectGcbButton.RowSpan=[1,1];
            selectGcbButton.ColSpan=[4,4];
            selectGcbButton.Graphical=true;
            selectGcbButton.DialogRefresh=false;
            selectGcbButton.Enabled=this.mSimStarted;


            explorerTree.Type='tree';
            explorerTree.Name='';
            explorerTree.Tag=['explorerTree',num2str(this.mRequestRefreshExplorer)];
            explorerTree.TreeModel={this.mModelTree};
            explorerTree.TreeMultiSelect=false;
            explorerTree.ExpandTree=true;
            explorerTree.Source=this;
            explorerTree.ObjectMethod='handleClickExplorerTreeNode';
            explorerTree.MethodArgs={'%dialog','%value'};
            explorerTree.ArgDataTypes={'handle','char'};
            explorerTree.DialogRefresh=true;
            explorerTree.Graphical=true;
            explorerTree.RowSpan=[2,10];
            explorerTree.ColSpan=[1,4];
            this.mExplorerTag=explorerTree.Tag;

            schema.Type='group';
            schema.Name='Explorer';
            schema.Tag='explorerGroup';
            schema.Items={imgFind,findEdit,showOnlyNonEmpty,...
            selectGcbButton,explorerTree};
            schema.LayoutGrid=[10,4];
            schema.RowStretch=[0,0,0,0,0,0,0,0,0,1];
            schema.ColStretch=[0,1,0,0];
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,4];

        end


        function schema=getSchemaInspector(this)


            if this.mSimStarted
                if isempty(this.mCurrentTreeNode)
                    dataSchema=this.getSchemaEmpty();
                else
                    nodePrototypes=this.mModelTree.getOneNodeOfEachType([]);
                    dataSchemas=[];
                    for i=1:length(nodePrototypes)
                        if strcmp(this.mCurrentTreeNode.Type,nodePrototypes{i}.Type)
                            switch nodePrototypes{i}.Type
                            case 'leafblock'
                                aIsMLSys=this.isMatlabDESSystemBlock(this.mCurrentTreeNode.FullPath);
                                bIsMLSys=this.isMatlabDESSystemBlock(nodePrototypes{i}.FullPath);
                                if aIsMLSys==bIsMLSys

                                    nodePrototypes{i}=this.mCurrentTreeNode;
                                    activeWidget=i-1;
                                    break;
                                end
                            otherwise
                                nodePrototypes{i}=this.mCurrentTreeNode;
                                activeWidget=i-1;
                                break;
                            end
                        end
                    end
                    currNode=this.mCurrentTreeNode;
                    for i=1:length(nodePrototypes)
                        this.mCurrentTreeNode=nodePrototypes{i};

                        switch(this.mCurrentTreeNode.Type)
                        case 'root'
                            widget=this.getSchemaModelRoot();
                        case 'evcal'
                            widget=this.getSchemaEventCalendar();
                        case 'breakpoints'
                            widget=this.getSchemaBreakpoints();
                        case 'subsystem'
                            widget=this.getSchemaChildrenOfSystem();
                        case 'leafblock'
                            if this.isStoragePreserved(this.mCurrentTreeNode)
                                widget=this.getSchemaBlock_PreserveStorages();
                            else
                                widget=this.getSchemaBlock_FlattenStorages();
                            end
                        case 'block_nonstorage'
                            widget=this.getSchemaBlock_NonStorage();
                        otherwise
                            widget=this.getSchemaEmpty();
                        end

                        dummy.Type='panel';
                        dummy.Items={widget};
                        dataSchemas=[dataSchemas,{dummy}];%#ok<AGROW>
                    end

                    this.mCurrentTreeNode=currNode;
                    dataSchema.Type='widgetstack';
                    dataSchema.ActiveWidget=activeWidget;
                    dataSchema.Items=dataSchemas;
                end
            else
                dataSchema=this.getSchemaModelNotRunning();
            end
            this.locAssert(~isempty(dataSchema));
            dataSchema.RowSpan=[1,1];
            dataSchema.ColSpan=[1,1];

            schema.Type='panel';
            schema.Items={dataSchema};
            schema.LayoutGrid=[1,1];
            schema.RowStretch=1;
            schema.ColStretch=1;

        end


        function schema=getSchemaModelRoot(~)
            schema.Type='text';
            schema.Name='';
            schema.Tag='modelRootTxt';
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,4];
        end


        function schema=getSchemaFinderForInspector(this,placeholderText,mangle)


            if nargin<2
                placeholderText='Type to find ...';
            end

            imgFind.Type='image';
            imgFind.Tag=['findImageData',mangle];
            imgFind.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','find.png');
            imgFind.RowSpan=[1,1];
            imgFind.ColSpan=[1,1];

            findEdit.Type='edit';
            findEdit.Tag=['findEditData',mangle];
            findEdit.Name='';
            findEdit.NameLocation=1;
            findEdit.Source=this;
            findEdit.ObjectMethod='handleInspectorFindStrChanged';
            findEdit.MethodArgs={'%dialog','%value'};
            findEdit.ArgDataTypes={'handle','char'};
            findEdit.Mode=true;
            findEdit.RespondsToTextChanged=true;
            findEdit.Clearable=true;
            findEdit.PlaceholderText=placeholderText;
            findEdit.Graphical=true;
            findEdit.DialogRefresh=true;
            findEdit.RowSpan=[1,1];
            findEdit.ColSpan=[2,4];
            if isempty(this.mInspectorFindStr)
                findEdit.ToolTip='Start typing to search or filter items in this display';
            else
                findEdit.ToolTip=['Showing only items containing ''',this.mInspectorFindStr,''''];
            end

            schema.Type='panel';
            schema.Items={imgFind,findEdit};
            schema.LayoutGrid=[2,4];
            schema.RowStretch=[0,0];
            schema.ColStretch=[0,0,0,1];
        end


        function evcal=getDataEventCalendar(this)


            rt=this.mModelRT;
            evcal=rt.getEventCalendars();
        end


        function schema=getSchemaEventCalendar(this)


            evcal=this.mCurrentTreeNode.SimRTHandle;

            findDataSchema=this.getSchemaFinderForInspector('Find events ...','_evcal');
            findDataSchema.RowSpan=[1,1];
            findDataSchema.ColSpan=[1,4];

            isfiltering=~isempty(this.mInspectorFindStr);

            numEvents=length(evcal.PendingEvents)+length(evcal.CurrentEvent);
            tableData=cell(numEvents,6);
            eventIds=zeros(numEvents,1);
            offset=0;
            for idx=1:numEvents
                background=[255,255,255];
                if idx==1&&~isempty(evcal.CurrentEvent)
                    ev=evcal.CurrentEvent;
                    offset=1;
                    background=[204,255,153];
                    check.Type='edit';
                    check.Name='';
                    check.Value='=>';
                    check.BackgroundColor=background;
                else
                    ev=evcal.PendingEvents(idx-offset);
                    hasBP=this.mCurrentTreeNode.hasEvcalBreakPoint('evID',ev.ID);
                    if hasBP
                        background=[255,204,204];
                    end
                    check.Type='checkbox';
                    check.Name='';
                    check.Value=double(hasBP);
                    check.BackgroundColor=background;
                end

                time.Type='edit';
                time.Name='';
                time.Value=sprintf('%.2f',ev.Time);
                time.BackgroundColor=background;

                priority.Type='edit';
                priority.Name='';
                priority.Value=num2str(ev.Priority);
                priority.BackgroundColor=background;

                type.Type='edit';
                type.Name='';
                type.Value=ev.Type;
                type.BackgroundColor=background;

                entity.Type='edit';
                entity.Name='';
                if isempty(ev.Entity)
                    entity.Value='--';
                else
                    entity.Value=num2str(ev.Entity.ID);
                end
                entity.BackgroundColor=background;

                blkPath=ev.Block.BlockPath;
                blkPath=strrep(blkPath,char(10),' ');
                blkPath=strrep(blkPath,[this.mModel,'/'],'');
                blk.Type='hyperlink';
                blk.Name=blkPath;
                blk.Value=blkPath;
                blk.BackgroundColor=background;

                if isfiltering&&(...
                    isempty(strfindi(time.Value,this.mInspectorFindStr))&&...
                    isempty(strfindi(priority.Value,this.mInspectorFindStr))&&...
                    isempty(strfindi(type.Value,this.mInspectorFindStr))&&...
                    isempty(strfindi(entity.Value,this.mInspectorFindStr))&&...
                    isempty(strfindi(blk.Value,this.mInspectorFindStr)))
                    continue;
                end

                tableData{idx,1}=check;
                tableData{idx,2}=time;
                tableData{idx,3}=priority;
                tableData{idx,4}=type;
                tableData{idx,5}=entity;
                tableData{idx,6}=blk;

                eventIds(idx)=ev.ID;
            end


            emptyIdx=cellfun(@(x)isempty(x),tableData(:,1));
            tableData=tableData(~emptyIdx,:);
            eventIds=eventIds(~emptyIdx);

            eventCalendar.Type='table';
            eventCalendar.Tag='eventCalendarTable';
            eventCalendar.Grid=true;
            eventCalendar.SelectionBehavior='cell';
            eventCalendar.HeaderVisibility=[1,1];
            eventCalendar.ColumnHeaderHeight=2;
            eventCalendar.RowHeaderWidth=2;
            eventCalendar.Editable=true;
            eventCalendar.Graphical=true;
            eventCalendar.MinimumSize=[350,250];
            eventCalendar.Size=size(tableData);
            eventCalendar.Data=tableData;
            eventCalendar.ColHeader={'Break','Time','Priority','Type','Entity','Block'};
            eventCalendar.RowHeader=arrayfun(@(x)num2str(x),1:8,'uniformoutput',false);
            eventCalendar.ColumnStretchable=[0,1,1,1,1,1];
            eventCalendar.ReadOnlyColumns=[1,2,3,4];
            eventCalendar.LastColumnStretchable=1;
            eventCalendar.ValueChangedCallback=...
            @(dlg,row,col,val)this.handleEventCalTableBreakpointChanged(...
            dlg,row,col,val,eventIds);
            eventCalendar.ItemClickedCallback=@(dlg,row,col,val)this.handleEventCalTableBlockClick(dlg,row,col,val);
            eventCalendar.RowSpan=[2,10];
            eventCalendar.ColSpan=[1,4];

            breakpointPreExec.Type='checkbox';
            breakpointPreExec.Name='Break before event execution';
            breakpointPreExec.Value=...
            double(this.mCurrentTreeNode.hasEvcalBreakPoint('evcal',-1));
            breakpointPreExec.DialogRefresh=true;
            breakpointPreExec.ObjectMethod='handleEventCalBPChanged';
            breakpointPreExec.MethodArgs={this.mCurrentTreeNode.DisplayPath,'%value'};
            breakpointPreExec.ArgDataTypes={'char','boolean'};
            breakpointPreExec.Mode=true;
            breakpointPreExec.Source=this;
            breakpointPreExec.RowSpan=[11,11];
            breakpointPreExec.ColSpan=[1,4];

            schema.Type='group';
            schema.Name='Event Calendar Events';
            schema.Items={findDataSchema,eventCalendar,breakpointPreExec};
            schema.LayoutGrid=[11,4];
            schema.RowStretch=[0,0,0,0,0,0,0,0,0,1,0];
            schema.ColStretch=[0,0,0,1];

        end


        function schema=getSchemaModelNotRunning(~)


            notRunningTxt.Type='text';
            notRunningTxt.Name='Start simulation to inspect runtime data';
            notRunningTxt.Tag='notRunningTxt';
            notRunningTxt.RowSpan=[1,1];
            notRunningTxt.ColSpan=[1,4];

            schema.Type='group';
            schema.Name='Inspector';
            schema.Items={notRunningTxt};
            schema.LayoutGrid=[2,4];
            schema.RowStretch=[0,1];
            schema.ColStretch=[0,0,0,1];
        end


        function schema=getSchemaChildrenOfSystem(this)




            currBlock.Type='text';
            currBlock.Name='Blocks in';
            currBlock.RowSpan=[1,1];
            currBlock.ColSpan=[1,1];

            currBlockLink.Type='hyperlink';
            currBlockLink.Name=this.mCurrentTreeNode.FullPath;
            currBlockLink.ObjectMethod='handleClickBlockHyperlink';
            currBlockLink.Source=this;
            currBlockLink.MethodArgs={this.mCurrentTreeNode.FullPath};
            currBlockLink.ArgDataTypes={'char'};
            currBlockLink.RowSpan=[1,1];
            currBlockLink.ColSpan=[2,2];

            currBlockPad.Type='text';
            currBlockPad.Name='';
            currBlockPad.RowSpan=[1,1];
            currBlockPad.ColSpan=[3,3];

            currBlockPanel.Type='panel';
            currBlockPanel.Items={currBlock,currBlockLink,currBlockPad};
            currBlockPanel.LayoutGrid=[1,3];
            currBlockPanel.RowSpan=[1,1];
            currBlockPanel.ColSpan=[1,4];
            currBlockPanel.ColStretch=[0,0,1];

            childNodes=this.mCurrentTreeNode.Children;

            findDataSchema=this.getSchemaFinderForInspector('Find children ...','_children');
            findDataSchema.RowSpan=[2,2];
            findDataSchema.ColSpan=[1,4];

            tableData=cell(length(childNodes),4);
            fullpaths=cell(length(childNodes),1);

            isfiltering=~isempty(this.mInspectorFindStr);

            nUsed=0;
            for idx=1:length(childNodes)
                name=childNodes{idx}.DisplayLabel;
                fullpath=childNodes{idx}.DisplayPath;

                if isfiltering&&isempty(strfindi(name,this.mInspectorFindStr))
                    continue;
                end
                nUsed=nUsed+1;
                fullpaths{nUsed}=fullpath;

                background=[255,255,255];
                if childNodes{idx}.hasChildren()
                    checkEntry.Type='edit';
                    checkEntry.Name='';
                    checkEntry.Value='';
                    checkEntry.BackgroundColor=background;

                    checkExit.Type='edit';
                    checkExit.Name='';
                    checkExit.Value='';
                    checkExit.BackgroundColor=background;
                else
                    hasEntryBP=childNodes{idx}.hasBlockBreakPoint(-1,1);
                    hasExitBP=childNodes{idx}.hasBlockBreakPoint(-1,2);
                    if hasEntryBP||hasExitBP
                        background=[255,204,204];
                    end

                    checkEntry.Type='checkbox';
                    checkEntry.Name='';
                    checkEntry.Value=double(hasEntryBP);
                    checkEntry.BackgroundColor=background;
                    checkEntry.Enabled=true;

                    checkExit.Type='checkbox';
                    checkExit.Name='';
                    checkExit.Value=double(hasExitBP);
                    checkExit.BackgroundColor=background;
                    checkExit.Enabled=true;
                end

                child.Type='edit';
                child.Name='';
                child.Value=name;
                child.BackgroundColor=background;

                type.Type='edit';
                type.Name='';
                type.Value=get_param(childNodes{idx}.FullPath,'BlockType');
                type.BackgroundColor=background;

                tableData{nUsed,1}=checkEntry;
                tableData{nUsed,2}=checkExit;
                tableData{nUsed,3}=child;
                tableData{nUsed,4}=type;
            end
            tableData((nUsed+1):end,:)=[];
            fullpaths((nUsed+1):end,:)=[];

            childrenTable.Type='table';
            childrenTable.Tag='childrenTable';
            childrenTable.Grid=true;
            childrenTable.SelectionBehavior='cell';
            childrenTable.HeaderVisibility=[1,1];
            childrenTable.ColumnHeaderHeight=2;
            childrenTable.RowHeaderWidth=2;
            childrenTable.Editable=true;
            childrenTable.Graphical=true;
            childrenTable.MinimumSize=[350,250];
            childrenTable.Size=size(tableData);
            childrenTable.Data=tableData;
            childrenTable.ColHeader={sprintf('PostEntry\nBreak'),sprintf('PreExit\nBreak'),'Child Name','Block Type'};
            childrenTable.RowHeader=arrayfun(@(x)num2str(x),1:size(tableData,1),'uniformoutput',false);
            childrenTable.ColumnStretchable=[0,0,1,1];
            childrenTable.ReadOnlyColumns=[2,3];
            childrenTable.LastColumnStretchable=1;
            childrenTable.ValueChangedCallback=...
            @(dlg,row,col,val)this.handleBlockBPChangedSSLevel(...
            dlg,row,col,val,fullpaths);
            childrenTable.RowSpan=[3,11];
            childrenTable.ColSpan=[1,4];

            schema.Type='group';
            schema.Name='Inspector';

            schema.Items={currBlockPanel,findDataSchema,childrenTable};
            schema.LayoutGrid=[11,4];
            schema.RowStretch=[0,0,0,0,0,0,0,0,0,0,1];
            schema.ColStretch=[0,0,0,1];
        end


        function schema=getSchemaBreakpoints(this)



            tabs=cell(1,3);


            blockData=cell(length(this.mBlockBreakpoints),3);
            for idx=1:length(this.mBlockBreakpoints)
                block=this.mBlockBreakpoints{idx};

                name.Type='edit';
                name.Value=strrep(block,[this.mModel,'/Storage/'],'');

                hasEntryBP=this.mTreeNodeMap(block).hasBlockBreakPoint(-1,1);
                hasExitBP=this.mTreeNodeMap(block).hasBlockBreakPoint(-1,2);

                checkEntry.Type='checkbox';
                checkEntry.Name='';
                checkEntry.Value=double(hasEntryBP);
                checkEntry.Enabled=true;

                checkExit.Type='checkbox';
                checkExit.Name='';
                checkExit.Value=double(hasExitBP);
                checkExit.Enabled=true;

                blockData{idx,1}=checkEntry;
                blockData{idx,2}=checkExit;
                blockData{idx,3}=name;
            end

            blockBreakTable.Type='table';
            blockBreakTable.Tag='blockBreakTable';
            blockBreakTable.Grid=true;
            blockBreakTable.SelectionBehavior='Row';
            blockBreakTable.HeaderVisibility=[1,1];
            blockBreakTable.ColumnHeaderHeight=2;
            blockBreakTable.RowHeaderWidth=2;
            blockBreakTable.ColHeader={sprintf('PostEntry\nBreak'),sprintf('PreExit\nBreak'),'Block Name'};
            blockBreakTable.RowHeader=...
            arrayfun(@(x)num2str(x),1:size(blockData,1),'uniformoutput',false);
            blockBreakTable.Editable=true;
            blockBreakTable.ReadOnlyColumns=3;
            blockBreakTable.RowSpan=[1,10];
            blockBreakTable.ColSpan=[1,4];
            blockBreakTable.MinimumSize=[350,250];
            blockBreakTable.Size=size(blockData);
            blockBreakTable.Data=blockData;
            blockBreakTable.Enabled=true;
            blockBreakTable.Graphical=true;
            blockBreakTable.ColumnStretchable=[0,0,1];
            this.mBlockBreakpointsCache=this.mBlockBreakpoints;
            blockBreakTable.ValueChangedCallback=...
            @(dlg,row,col,val)this.handleBlockBPChangedSSLevel(...
            dlg,row,col,val,this.mBlockBreakpointsCache);

            tabItem.Items={blockBreakTable};
            tabItem.Name=['Block Breakpoints (',num2str(size(blockData,1)),')'];
            tabs{1}=tabItem;




            nWideAdded=0;
            nEventBreakpoints=0;
            for ec=1:length(this.mModelTree.EventCalendarChildNodes)
                ecNode=this.mModelTree.EventCalendarChildNodes(ec);
                if ecNode.hasEvcalBreakPoint('evcal',-1)
                    nWideAdded=nWideAdded+1;
                end
                nEventBreakpoints=nEventBreakpoints+...
                length(ecNode.BreakPointEventIDs);
            end

            idx=1;
            ecNodePaths=cell(1,nWideAdded+nEventBreakpoints);
            evIDs=zeros(1,nWideAdded+nEventBreakpoints);
            background=[255,255,255];
            eventBreakData=cell(nWideAdded+nEventBreakpoints,7);

            for ec=1:length(this.mModelTree.EventCalendarChildNodes)
                ecNode=this.mModelTree.EventCalendarChildNodes(ec);
                if ecNode.hasEvcalBreakPoint('evcal',-1)
                    check.Type='checkbox';
                    check.Name='';
                    check.Value=1;
                    check.BackgroundColor=background;

                    ecEntry.Type='edit';
                    ecEntry.Name='';
                    ecEntry.Value=num2str(ec);
                    ecEntry.BackgroundColor=background;

                    time.Type='edit';
                    time.Name='';
                    time.Value='All';
                    time.BackgroundColor=background;

                    priority.Type='edit';
                    priority.Name='';
                    priority.Value='All';
                    priority.BackgroundColor=background;

                    type.Type='edit';
                    type.Name='';
                    type.Value='All';
                    type.BackgroundColor=background;

                    entity.Type='edit';
                    entity.Name='';
                    entity.Value='All';
                    entity.BackgroundColor=background;

                    blk.Type='edit';
                    blk.Name='';
                    blk.Value='All';
                    blk.BackgroundColor=background;

                    eventBreakData{idx,1}=check;
                    eventBreakData{idx,2}=ecEntry;
                    eventBreakData{idx,3}=time;
                    eventBreakData{idx,4}=priority;
                    eventBreakData{idx,5}=type;
                    eventBreakData{idx,6}=entity;
                    eventBreakData{idx,7}=blk;

                    evIDs(idx)=-1;
                    ecNodePaths{idx}=ecNode.DisplayPath;
                    idx=idx+1;
                end
            end


            for ec=1:length(this.mModelTree.EventCalendarChildNodes)
                ecNode=this.mModelTree.EventCalendarChildNodes(ec);
                evcal=ecNode.SimRTHandle;
                for ei=1:length(ecNode.BreakPointEventIDs)
                    ePending=evcal.PendingEvents;
                    ev=[];
                    for ep=1:length(ePending)
                        if ePending(ep).ID==ecNode.BreakPointEventIDs(ei)
                            ev=ePending(ep);
                            break;
                        end
                    end

                    check.Type='checkbox';
                    check.Name='';
                    check.Value=1;
                    check.BackgroundColor=background;

                    ecEntry.Type='edit';
                    ecEntry.Name='';
                    ecEntry.Value=num2str(ec);
                    ecEntry.BackgroundColor=background;

                    time.Type='edit';
                    time.Name='';
                    time.Value=sprintf('%.2f',ev.Time);
                    time.BackgroundColor=background;

                    priority.Type='edit';
                    priority.Name='';
                    priority.Value=num2str(ev.Priority);
                    priority.BackgroundColor=background;

                    type.Type='edit';
                    type.Name='';
                    type.Value=ev.Type;
                    type.BackgroundColor=background;

                    entity.Type='edit';
                    entity.Name='';
                    if isempty(ev.Entity)
                        entity.Value='--';
                    else
                        entity.Value=num2str(ev.Entity.ID);
                    end
                    entity.BackgroundColor=background;

                    blkPath=ev.Block.BlockPath;
                    blkPath=strrep(blkPath,char(10),' ');
                    blkPath=strrep(blkPath,[this.mModel,'/'],'');
                    blk.Type='hyperlink';
                    blk.Name=blkPath;
                    blk.Value=blkPath;
                    blk.BackgroundColor=background;

                    eventBreakData{idx,1}=check;
                    eventBreakData{idx,2}=ecEntry;
                    eventBreakData{idx,3}=time;
                    eventBreakData{idx,4}=priority;
                    eventBreakData{idx,5}=type;
                    eventBreakData{idx,6}=entity;
                    eventBreakData{idx,7}=blk;

                    evIDs(idx)=ev.ID;
                    ecNodePaths{idx}=ecNode.DisplayPath;
                    idx=idx+1;
                end
            end
            this.locAssert((idx-1)==nEventBreakpoints+nWideAdded);

            eventBreakTable.Type='table';
            eventBreakTable.Tag='eventBreakTable';
            eventBreakTable.Grid=true;
            eventBreakTable.SelectionBehavior='cell';
            eventBreakTable.HeaderVisibility=[1,1];
            eventBreakTable.ColumnHeaderHeight=2;
            eventBreakTable.RowHeaderWidth=2;
            eventBreakTable.Editable=true;
            eventBreakTable.Graphical=true;
            eventBreakTable.MinimumSize=[350,250];
            eventBreakTable.Size=size(eventBreakData);
            eventBreakTable.Data=eventBreakData;
            eventBreakTable.ColHeader=...
            {'Break','Calendar','Time','Priority','Type','Entity','Block'};
            eventBreakTable.RowHeader=arrayfun(@(x)num2str(x),1:8,...
            'uniformoutput',false);
            eventBreakTable.ColumnStretchable=[0,0,1,1,1,1,1];
            eventBreakTable.ReadOnlyColumns=[1,2,3,4,5,6];
            eventBreakTable.LastColumnStretchable=1;
            eventBreakTable.ValueChangedCallback=...
            @(dlg,row,col,val)this.handleEventBPTableBreakpointChanged(...
            dlg,row,col,val,ecNodePaths,evIDs);
            eventBreakTable.RowSpan=[1,10];
            eventBreakTable.ColSpan=[1,4];

            tabItem.Items={eventBreakTable};
            tabItem.Name=['Event Breakpoints ('...
            ,num2str(nEventBreakpoints+nWideAdded),')'];
            tabs{2}=tabItem;


            watchedEntityLocations=this.mEntityWatchLocs;
            watchData=cell(length(this.mEntityWatches),3);
            for idx=1:length(this.mEntityWatches)
                watch.Type='checkbox';
                watch.Name='';
                watch.Value=1;

                entityid=this.mEntityWatches(idx);
                id.Type='edit';
                id.Value=num2str(entityid);

                location.Type='edit';
                if isempty(watchedEntityLocations{idx})
                    location.Value='<destroyed>';
                else
                    location.Value=watchedEntityLocations{idx};
                end

                watchData{idx,1}=watch;
                watchData{idx,2}=id;
                watchData{idx,3}=location;
            end

            watchedEntitiesTable.Type='table';
            watchedEntitiesTable.Tag='watchedEntitiesTable';
            watchedEntitiesTable.Grid=true;
            watchedEntitiesTable.SelectionBehavior='Row';
            watchedEntitiesTable.HeaderVisibility=[1,1];
            watchedEntitiesTable.ColumnHeaderHeight=2;
            watchedEntitiesTable.RowHeaderWidth=2;
            watchedEntitiesTable.ColHeader={'Watch','sys.id','Entity Location'};
            watchedEntitiesTable.RowHeader=arrayfun(@(x)num2str(x),1:size(watchData,1),'uniformoutput',false);
            watchedEntitiesTable.Editable=true;
            watchedEntitiesTable.ReadOnlyColumns=[1,2];
            watchedEntitiesTable.RowSpan=[1,10];
            watchedEntitiesTable.ColSpan=[1,4];
            watchedEntitiesTable.MinimumSize=[350,250];
            watchedEntitiesTable.Size=size(watchData);
            watchedEntitiesTable.Data=watchData;
            watchedEntitiesTable.Enabled=true;
            watchedEntitiesTable.Graphical=true;
            watchedEntitiesTable.ColumnStretchable=[0,0,1];
            watchedEntitiesTable.ValueChangedCallback=...
            @(dlg,row,col,val)this.handleEntityWatchTableValueChanged(...
            dlg,row,col,val,'watchedEntitiesTable');

            tabItem.Items={watchedEntitiesTable};
            tabItem.Name=['Watched Entities (',num2str(size(watchData,1)),')'];
            tabs{3}=tabItem;

            schema.Type='tab';
            schema.Tabs=tabs;
            schema.Tag='breakpointTab';
            schema.Name='';
            schema.RowSpan=[1,10];
            schema.ColSpan=[1,4];

        end


        function[schema,numEntities,breakPointEntry,breakPointExit]=...
            getSchemaStorage(this,blkObj,storageIdx,tag)




            isfiltering=~isempty(this.mInspectorFindStr);
            filteringID=true;


            if isfiltering&&isnan(str2double(this.mInspectorFindStr))
                filteringID=false;
            end


            numEntities=0;
            entityAttribs={};
            entityAttribVals=[];

            for idx=storageIdx
                num=length(blkObj.Storage(idx).Entity);
                if num>0
                    entityAttribVals=this.recFlattenEntityAttributes(...
                    blkObj.Storage(idx).Entity(1).Attributes);
                    if(isstruct(entityAttribVals))
                        entityAttribs=fieldnames(entityAttribVals);
                    else
                        entityAttribs={'data'};
                    end
                end
                numEntities=numEntities+num;
            end

            if numEntities==0
                tableData={'','No entities in storage'};
                colHeaders={'',''};
                findDataSchema.Enabled=false;
                enabled=false;
                colStretch=[0,1];
                tag=[tag,tag];
            else
                enabled=true;
                extraCols={'Watch','sys.id','sys.priority'};
                tableData=cell(numEntities,length(entityAttribs)+length(extraCols));


                eIdx=1;
                for sIdx=storageIdx
                    num=length(blkObj.Storage(sIdx).Entity);
                    if num==0
                        continue;
                    end


                    for idx=1:length(blkObj.Storage(sIdx).Entity)
                        en=blkObj.Storage(sIdx).Entity(idx);


                        entityAttribVals=this.recFlattenEntityAttributes(...
                        en.Attributes);


                        background=[255,255,255];
                        isBeingWatched=any(this.mEntityWatches==en.ID);
                        if isBeingWatched
                            background=[204,255,255];
                        end

                        watch.Type='checkbox';
                        watch.Value=double(isBeingWatched);
                        watch.BackgroundColor=background;

                        id.Type='edit';
                        id.Value=num2str(en.ID);
                        id.BackgroundColor=background;


                        if isfiltering&&filteringID
                            if~strncmp(id.Value,this.mInspectorFindStr,...
                                length(this.mInspectorFindStr))
                                continue;
                            end
                        end

                        priority.Type='edit';
                        priority.Value=num2str(en.Priority);
                        priority.BackgroundColor=background;

                        tableData{eIdx,1}=watch;
                        tableData{eIdx,2}=id;
                        tableData{eIdx,3}=priority;


                        for aIdx=1:length(entityAttribs)
                            attribName=entityAttribs{aIdx};


                            if isfiltering&&~filteringID
                                if isempty(strfindi(attribName,this.mInspectorFindStr))
                                    continue;
                                end
                            end


                            attVal={};
                            if(isstruct(entityAttribVals))

                                attVal=entityAttribVals.(attribName);
                            else
                                attVal=entityAttribVals;
                            end
                            if length(attVal)==1||ischar(attVal)
                                attValStr=num2str(attVal);
                            else

                                dims=size(attVal);
                                attValStr=num2str(dims(1));
                                for dIdx=2:length(dims)
                                    attValStr=[attValStr,'x',num2str(dims(dIdx))];%#ok
                                end


                                if(iscell(attVal))
                                    if(cell2mat(attVal)=='batch')
                                        attValStr=strcat(attValStr,'[batch]');
                                    end
                                end
                            end

                            attribCell.Type='edit';
                            attribCell.Value=attValStr;
                            attribCell.BackgroundColor=background;

                            tableData{eIdx,aIdx+length(extraCols)}=attribCell;
                        end
                        eIdx=eIdx+1;
                    end
                end


                emptyIdx=cellfun(@(x)isempty(x),tableData(:,2));
                tableData=tableData(~emptyIdx,:);

                emptyColIdx=zeros(1,size(tableData,2));
                for c=1:size(tableData,2)
                    tCol=tableData(:,c);
                    emptyIdx=cellfun(@(x)isempty(x),tCol);
                    if all(emptyIdx)
                        emptyColIdx(c)=1;
                    end
                end
                tableData=tableData(:,~emptyColIdx);
                entityAttribs=entityAttribs(~emptyColIdx(length(extraCols)+1:end));

                if isfiltering&&isempty(tableData)
                    tableData={'','All entities filtered out by search criteria'};
                    colHeaders={'',''};
                    colStretch=[0,1];
                else
                    colHeaders={extraCols{:},entityAttribs{:}};%#ok<CCAT>
                    colStretch=[0,zeros(1,length(extraCols)-1),ones(1,length(entityAttribs))];
                end
            end

            schema.Type='table';
            schema.Tag=tag;
            schema.Grid=true;
            schema.SelectionBehavior='cell';
            schema.HeaderVisibility=[1,1];
            schema.ColumnHeaderHeight=2;
            schema.RowHeaderWidth=2;
            schema.ColHeader=colHeaders;
            schema.MinimumSize=[350,250];
            schema.Size=size(tableData);
            schema.Data=tableData;
            schema.ColumnStretchable=colStretch;
            schema.Enabled=enabled;
            schema.Editable=true;
            schema.Graphical=true;
            schema.ReadOnlyColumns=1:size(tableData,2)-1;
            schema.ValueChangedCallback=@(dlg,row,col,val)...
            this.handleEntityWatchChanged(dlg,row,col,val,tag);

            breakPointEntry.Type='checkbox';
            breakPointEntry.Name='Break upon entity entry';
            breakPointEntry.Value=double(this.mCurrentTreeNode.hasBlockBreakPoint(storageIdx,1));
            breakPointEntry.DialogRefresh=true;
            breakPointEntry.ObjectMethod='handleStorageBPChanged';
            breakPointEntry.MethodArgs={this.mCurrentTreeNode.DisplayPath,...
            storageIdx,1,'%value'};
            breakPointEntry.ArgDataTypes={'char','double','double','boolean'};
            breakPointEntry.Mode=true;
            breakPointEntry.Source=this;

            breakPointExit.Type='checkbox';
            breakPointExit.Name='Break prior to entity exit';
            breakPointExit.Value=double(this.mCurrentTreeNode.hasBlockBreakPoint(storageIdx,2));
            breakPointExit.DialogRefresh=true;
            breakPointExit.ObjectMethod='handleStorageBPChanged';
            breakPointExit.MethodArgs={this.mCurrentTreeNode.DisplayPath,...
            storageIdx,2,'%value'};
            breakPointExit.ArgDataTypes={'char','double','double','boolean'};
            breakPointExit.Mode=true;
            breakPointExit.Source=this;
        end


        function schema=getSchemaBlock_FlattenStorages(this)



            currBlock.Type='text';
            currBlock.Name='Storages in';
            currBlock.RowSpan=[1,1];
            currBlock.ColSpan=[1,1];

            currBlockLink.Type='hyperlink';
            currBlockLink.Name=this.mCurrentTreeNode.FullPath;
            currBlockLink.ObjectMethod='handleClickBlockHyperlink';
            currBlockLink.Source=this;
            currBlockLink.MethodArgs={this.mCurrentTreeNode.FullPath};
            currBlockLink.ArgDataTypes={'char'};
            currBlockLink.RowSpan=[1,1];
            currBlockLink.ColSpan=[2,2];

            currBlockPad.Type='text';
            currBlockPad.Name='';
            currBlockPad.RowSpan=[1,1];
            currBlockPad.ColSpan=[3,3];

            currBlockPanel.Type='panel';
            currBlockPanel.Items={currBlock,currBlockLink,currBlockPad};
            currBlockPanel.LayoutGrid=[1,3];
            currBlockPanel.RowSpan=[1,1];
            currBlockPanel.ColSpan=[1,4];
            currBlockPanel.ColStretch=[0,0,1];

            findDataSchema=this.getSchemaFinderForInspector('Enter entity ID or attribute name ...','_storage1');
            findDataSchema.RowSpan=[2,2];
            findDataSchema.ColSpan=[1,4];

            blkObj=this.mCurrentTreeNode.SimRTHandle;

            [entityTable,~,bpEntry,bpExit]=this.getSchemaStorage(...
            blkObj,1:length(blkObj.Storage),'entityTable1');
            entityTable.RowSpan=[3,11];
            entityTable.ColSpan=[1,4];

            schema.Type='group';
            schema.Name='Inspector';
            schema.Items={currBlockPanel,findDataSchema,entityTable,bpEntry,bpExit};
            schema.LayoutGrid=[11,4];
            schema.RowStretch=[0,0,0,0,0,0,0,0,0,1,0];
            schema.ColStretch=[0,0,0,1];
        end


        function schema=getSchemaBlock_PreserveStorages(this)



            currBlock.Type='text';
            currBlock.Name='Storages in: ';
            currBlock.RowSpan=[1,1];
            currBlock.ColSpan=[1,1];

            currBlockLink.Type='hyperlink';
            currBlockLink.Name=this.mCurrentTreeNode.DisplayPath;
            currBlockLink.ObjectMethod='handleClickBlockHyperlink';
            currBlockLink.Source=this;
            currBlockLink.MethodArgs={this.mCurrentTreeNode.FullPath};
            currBlockLink.ArgDataTypes={'char'};
            currBlockLink.RowSpan=[1,1];
            currBlockLink.ColSpan=[2,2];

            currBlockPad.Type='text';
            currBlockPad.Name='';
            currBlockPad.RowSpan=[1,1];
            currBlockPad.ColSpan=[3,3];

            currBlockPanel.Type='panel';
            currBlockPanel.Items={currBlock,currBlockLink,currBlockPad};
            currBlockPanel.LayoutGrid=[1,3];
            currBlockPanel.RowSpan=[1,1];
            currBlockPanel.ColSpan=[1,4];
            currBlockPanel.ColStretch=[0,0,1];

            findDataSchema=this.getSchemaFinderForInspector(...
            'Enter entity ID or attribute name ...','_storage2');
            findDataSchema.RowSpan=[2,2];
            findDataSchema.ColSpan=[1,4];

            blkObj=this.mCurrentTreeNode.SimRTHandle;

            if isempty(blkObj.Storage)



                schema=this.getSchemaBlock_NonStorage();
                return;
            else

                isQueueWithMultipleSotrages=strcmp(get_param(this.mCurrentTreeNode.FullPath,...
                'BlockType'),'Queue');

                tabs=cell(1,length(blkObj.Storage));
                for idx=1:length(blkObj.Storage)
                    [entityTableSchema,numEntities,bpEntry,bpExit]=...
                    this.getSchemaStorage(blkObj,idx,['entityTable',num2str(idx)]);

                    tabItem.Items={entityTableSchema,bpEntry,bpExit};



                    if isQueueWithMultipleSotrages
                        tabItem.Name=[blkObj.Storage(idx).Type,' (',num2str(numEntities),')'];
                    else
                        tabItem.Name=[blkObj.Storage(idx).Type,num2str(idx),' (',num2str(numEntities),')'];
                    end


                    tabs{idx}=tabItem;
                end

                tabCont.Type='tab';
                tabCont.Tabs=tabs;
                tabCont.Tag='storageTabs';
                tabCont.Name='';
                tabCont.RowSpan=[3,11];
                tabCont.ColSpan=[1,4];
            end

            schema.Type='group';
            schema.Name='Storage Inspector';

            schema.Items={currBlockPanel,findDataSchema,tabCont};
            schema.LayoutGrid=[11,4];
            schema.RowStretch=[0,0,0,0,0,0,0,0,0,1,0];
            schema.ColStretch=[0,0,0,1];
        end


        function schema=getSchemaBlock_NonStorage(this)


            findDataSchema=this.getSchemaFinderForInspector('','_nonstorage');
            findDataSchema.RowSpan=[1,1];
            findDataSchema.ColSpan=[1,4];
            findDataSchema.Enabled=false;

            nonStorageTxt.Type='text';
            nonStorageTxt.Name='Block has no storages';
            nonStorageTxt.Tag='nonStorageTxt';
            nonStorageTxt.RowSpan=[2,2];
            nonStorageTxt.ColSpan=[1,4];

            schema.Type='group';
            schema.Name='Block Inspector';
            schema.Items={findDataSchema,nonStorageTxt};
            schema.LayoutGrid=[3,4];
            schema.RowStretch=[0,0,1];
            schema.ColStretch=[0,0,0,1];

        end


        function schema=getSchemaEmpty(~)


            emptyTxt.Type='text';
            emptyTxt.Name='Select an element in the explorer to see its data';
            emptyTxt.Tag='emptyTxt';
            emptyTxt.RowSpan=[1,1];
            emptyTxt.ColSpan=[1,4];

            schema.Type='group';
            schema.Name='Inspector';
            schema.Items={emptyTxt};
            schema.LayoutGrid=[2,4];
            schema.RowStretch=[0,1];
            schema.ColStretch=[0,0,0,1];
        end




        function is=isMatlabDESSystemBlock(~,name)


            is=false;
            bType=get_param(name,'BlockType');
            if strcmp(bType,'MATLABDiscreteEventSystem')
                is=true;
            elseif strcmp(bType,'SubSystem')
                hdl=get_param(name,'handle');
                id=sfprivate('block2chart',hdl);
                is=(id>0);
            end
        end

        function is=isQueueBlockWithMultipleStorages(~,node)


            is=false;
            bType=get_param(node.FullPath,'BlockType');
            if strcmp(bType,'Queue')&&length(node.SimRTHandle.Storage)>1
                is=true;
            end
        end








        function is=isStoragePreserved(this,node)
            is=false;
            if isMatlabDESSystemBlock(this,node.FullPath)||...
                isQueueBlockWithMultipleStorages(this,node)
                is=true;
            else


                entityAttribs={};
                entityAttribVals=[];

                for idx=1:length(node.SimRTHandle.Storage)
                    attribs={};
                    num=length(node.SimRTHandle.Storage(idx).Entity);
                    if num>0
                        entityAttribVals=this.recFlattenEntityAttributes(...
                        node.SimRTHandle.Storage(idx).Entity(1).Attributes);
                        if(isstruct(entityAttribVals))
                            attribs=fieldnames(entityAttribVals);
                        else
                            attribs={'data'};
                        end

                        if isempty(entityAttribs)
                            entityAttribs=attribs;
                        else
                            if~isequal(attribs,entityAttribs)
                                is=true;
                                return;
                            end
                        end
                    end
                end
            end
        end


        function requestExplorerRefresh(this)



            this.mRequestRefreshExplorer=this.mRequestRefreshExplorer+1;
        end


        function outStruct=recFlattenEntityAttributes(this,attrib,accumNames,outStruct)





            if nargin<3
                accumNames={};
                outStruct=struct();
            end

            if(isstruct(attrib)&&numel(attrib)==1)
                flds=fields(attrib);
                for idx=1:length(flds)
                    fldName=flds{idx};
                    fldVal=attrib.(fldName);
                    outStruct=this.recFlattenEntityAttributes(fldVal,[accumNames,['_',fldName]],outStruct);
                end
            else
                if~isempty(accumNames)
                    accumNames=strcat(accumNames{:});
                    accumNames=accumNames(2:end);

                    if(isstruct(attrib)&&numel(attrib)>1)
                        outStruct.(accumNames)=repmat({'batch'},numel(attrib),1);
                    else
                        outStruct.(accumNames)=attrib;
                    end
                else
                    outStruct=attrib;
                end
            end
        end

    end

    methods(Access=private)

        function simRunning(this,~,~)


            if~this.mSimStarted

                sTime=tic;



                [this.mModelTree,this.mTreeNodeMap]=...
                slde.ddg.DebuggerMTreeNode.createModelTreeRunning(this.mModel);
                this.mModelTree.setDebuggerObjHdl(this);


                this.mSimStarted=true;
                this.mIsAtSimPause=false;


                this.mRequestRefreshExplorer=1;
                this.mDialog=DAStudio.Dialog(this);

                elapTime=toc(sTime);
                if this.mPrintDbgInfo
                    fprintf('Initial launch cost: %.2f\n',elapTime);
                end

            else

                this.mIsAtSimPause=false;
                if ishandle(this.mDialog)
                    this.mDialog.refresh();
                end
            end
        end


        function simPaused(this,~,~)

            if this.mSimStarted
                sTime=tic;
                this.mEntityWatchLocs=...
                this.mModelTree.resetChildren(this.mShowOnlyNonEmpty,...
                this.mExplorerFindStr,...
                this.mEntityWatches);
                this.mIsAtSimPause=true;
                if ishandle(this.mDialog)
                    this.requestExplorerRefresh();
                    this.mDialog.refresh();
                end
                elapTime=toc(sTime);
                if this.mPrintDbgInfo
                    fprintf('Pause refresh cost: %.2f\n',elapTime);
                end
            end

        end


        function simTerminating(this,~,~)


            this.mSimStarted=false;
            [modelTree,treeNodeMap]=...
            slde.ddg.DebuggerMTreeNode.createModelTreeStopped(this.mModel);
            if ishandle(this.mDialog)
                delete(this.mDialog);
            end
            this.mModelTree=modelTree;
            this.mTreeNodeMap=treeNodeMap;
            this.mDialog=[];
        end


        function locAssert(~,asCond)



            assert(asCond)
        end
    end
end





function ret=strfindi(s1,s2)


    ret=strfind(lower(s1),lower(s2));
end


function out=openDebugger(modelName,setModelName)

    persistent modelInDebugMode;

    if(~setModelName)
        modelInDebugMode=[];
        out=false;
        return;
    end

    if(isempty(modelInDebugMode))
        modelInDebugMode=modelName;
        out=true;
    else
        out=false;
    end

end


