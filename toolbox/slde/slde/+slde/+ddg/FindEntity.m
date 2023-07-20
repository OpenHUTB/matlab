classdef FindEntity<slde.ddg.EventActionsTab





    properties(Access=public)
        mBlock;
        mUddParent;
        mChildErrorDlgs;
        mAllTags;
    end

    properties(Access=private)
        isParamAvailable=false;
    end


    methods


        function this=FindEntity(blk,udd)


            this@slde.ddg.EventActionsTab(blk,udd);


            this.mBlock=get_param(blk,'Object');
            this.mUddParent=udd;

            this.mChildErrorDlgs=[];


            this.evActionTabId=1;
        end


        function schema=getDialogSchema(this)


            this.refreshPropagatedData();

            blockDesc=this.getBlockDescriptionSchema();


            mainTab=this.getMainTabSchema();
            eventActionsTab=this.getEventActionsTabSchema();
            statsTab=this.getStatisticsSchema();

            tabCont.Type='tab';
            tabCont.Tabs={mainTab,eventActionsTab,statsTab};
            tabCont.Name='';
            tabCont.RowSpan=[2,2];
            tabCont.ColSpan=[1,1];

            schema.DialogTitle=DAStudio.message('Simulink:dialog:BlockParameters',this.mBlock.Name);
            schema.Items={blockDesc,tabCont};
            schema.DialogTag=this.mBlock.BlockType;
            schema.Source=this.mUddParent;
            schema.SmartApply=false;
            schema.HelpMethod='slhelp';
            schema.HelpArgs={this.mBlock.Handle};
            schema.HelpArgsDT={'double'};
            schema.CloseMethod='doCloseCallback';
            schema.CloseMethodArgs={'%dialog','%closeaction'};
            schema.CloseMethodArgsDT={'handle','string'};
            schema.PreApplyCallback='doPreApplyCallback';
            schema.PreApplyArgs={'%source','%dialog'};
            schema.PreApplyArgsDT={'handle','handle'};
            schema.ExplicitShow=true;
        end


        function schema=getEventActionsTabSchema(this)

            isOutputEnabled=get_param(this.mBlock.Handle,'EnableOutput');

            if isequal(isOutputEnabled,'on')
                attribs=getEventActionAttributes(this);
                this.mEvActionAttribs=attribs(2:length(attribs));
            else
                attribs=getEventActionAttributes(this);
                this.mEvActionAttribs=attribs(1);
                this.selectedEvActionId=1;
            end

            schema=getEventActionsTabSchema@slde.ddg.EventActionsTab(this);




















            if isequal(schema.Items{4}.Tag,'EventActionEditor')
                schema.Items{4}.MinimumSize=[290,1];
            end
        end



        function evActionAttribs=getEventActionAttributes(~)

            i=0;


            i=i+1;
            evActionAttribs{i}.Name='OnFound';
            evActionAttribs{i}.Tag='OnFoundAction';
            evActionAttribs{i}.ObjectProperty='OnFoundAction';
            evActionAttribs{i}.DefaultMsg='SimulinkDiscreteEvent:dialog:DefaultMsgOnfindAction';
            evActionAttribs{i}.ToolTip='SimulinkDiscreteEvent:dialog:ToolTipOnfoundAction';


            i=i+1;
            evActionAttribs{i}.Name='Entry';
            evActionAttribs{i}.Tag='EntryAction';
            evActionAttribs{i}.ObjectProperty='EntryAction';
            evActionAttribs{i}.DefaultMsg='SimulinkDiscreteEvent:dialog:DefaultMsgEntryAction';
            evActionAttribs{i}.ToolTip='SimulinkDiscreteEvent:dialog:ToolTipEntryAction';


            i=i+1;
            evActionAttribs{i}.Name='Exit';
            evActionAttribs{i}.Tag='ExitAction';
            evActionAttribs{i}.ObjectProperty='ExitAction';
            evActionAttribs{i}.DefaultMsg='SimulinkDiscreteEvent:dialog:DefaultMsgExitAction';
            evActionAttribs{i}.ToolTip='SimulinkDiscreteEvent:dialog:ToolTipExitAction';


            i=i+1;
            evActionAttribs{i}.Name='Blocked';
            evActionAttribs{i}.Tag='BlockedAction';
            evActionAttribs{i}.ObjectProperty='BlockedAction';
            evActionAttribs{i}.DefaultMsg='SimulinkDiscreteEvent:dialog:DefaultMsgBlockedAction';
            evActionAttribs{i}.ToolTip='SimulinkDiscreteEvent:dialog:ToolTipBlockedAction';

        end


        function[status,msg]=preApplyCallback(this,dialog)

            try
                this.cacheEventAction();
                [status,msg]=this.mUddParent.preApplyCallback(dialog);
            catch me
                status=0;
                msg=me.message;
            end
        end


        function closeCallback(this,dialog,closeAction)



            for idx=1:length(this.mChildErrorDlgs)
                errDlg=this.mChildErrorDlgs(idx);
                if ishandle(errDlg)
                    delete(errDlg);
                end
            end
            this.mChildErrorDlgs=[];

            if strcmp(closeAction,'cancel')
                this.revertEventActions();
            end

            this.mUddParent.closeCallback(dialog);
        end



        function sigHier=getSigHierFromPort(this)
            isOutputEnabled=get_param(this.mBlock.Handle,'EnableOutput');
            isEntityBasedFind=get_param(this.mBlock.Handle,'EnableOutput');

            params=get_param(this.mBlock.Handle,'DialogParameters');
            this.isParamAvailable=isfield(params,'EntityTypeBasedFind');
            isFindTypeEnabled=false;
            if(this.isParamAvailable)
                isFindTypeEnabled=isequal(get_param(this.mBlock.Handle,'EntityTypeBasedFind'),'on');
            end

            sigHier=[];
            pHandles=get_param(this.mBlock.Handle,'PortHandles');
            if(~isFindTypeEnabled)
                blk=getResourceAcquirerBlockHandle(this,'EntityResourceAcquirer');
            else

                blk=getResourceAcquirerBlockHandle(this,'EntityGenerator');


                if isempty(blk)
                    blk=getResourceAcquirerBlockHandle(this,'CompositeEntityCreator');
                end


                if isempty(blk)
                    blk=getResourceAcquirerBlockHandle(this,'EntityBatchCreator');
                end
            end

            if isequal(isOutputEnabled,'on')&&~isempty(pHandles.Outport)
                if~isempty(blk)

                    sigHier=get_param(pHandles.Outport(numel(pHandles.Outport)),...
                    'SignalHierarchy');
                end
            else
                if~isempty(blk)
                    handles=get_param(blk,'PortHandles');
                    sigHier=get_param(handles.Outport(numel(handles.Outport)),...
                    'SignalHierarchy');
                    return;
                end



            end
        end


    end



    methods


        function schema=getBlockDescriptionSchema(this)



            blockDesc.Type='text';
            blockDesc.Name=this.mBlock.BlockDescription;
            blockDesc.WordWrap=true;

            schema.Type='group';
            schema.Name='Find Entity';
            schema.Items={blockDesc};
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,2];
        end


        function schema=getMainTabSchema(this)


            isOutputEnabled=isequal(get_param(this.mBlock.Handle,'EnableOutput'),'on');
            params=get_param(this.mBlock.Handle,'DialogParameters');
            this.isParamAvailable=isfield(params,'EntityTypeBasedFind');
            isFindTypeEnabled=false;
            if(this.isParamAvailable)
                isFindTypeEnabled=isequal(get_param(this.mBlock.Handle,'EntityTypeBasedFind'),'on');
            end


            rowIdx=1;
            wResourceTag.Type='combobox';
            wResourceTag.Name=DAStudio.message('SimulinkDiscreteEvent:FindEntity:ResourceTag');

            wResourceTag.Tag='ResourceName';
            wResourceTag.ObjectProperty='ResourceName';
            wResourceTag.Editable=true;
            wResourceTag.Entries=this.mAllTags;
            wResourceTag.Value='Resource1';
            wResourceTag.Source=this.mBlock;
            wResourceTag.RowSpan=[rowIdx,rowIdx];
            wResourceTag.ColSpan=[1,1];
            wResourceTag.Mode=true;
            wResourceTag.DialogRefresh=true;
            wResourceTag.MatlabMethod='handleEditEventAction';
            wResourceTag.MatlabArgs={this,'%value','%dialog'};


            rowIdx=rowIdx+1;
            wEnableOutput.Type='checkbox';
            wEnableOutput.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:FindEntity:EnableEntityOutput');
            wEnableOutput.Tag='EnableOutput';
            wEnableOutput.ObjectProperty='EnableOutput';
            wEnableOutput.Source=this.mBlock;
            wEnableOutput.Mode=true;
            wEnableOutput.DialogRefresh=true;
            wEnableOutput.RowSpan=[rowIdx,rowIdx];
            wEnableOutput.ColSpan=[1,1];
            wEnableOutput.MatlabMethod='handleCheckEvent';
            wEnableOutput.MatlabArgs={this.mUddParent,...
            '%value',...
            this.getPrmIdx(wEnableOutput.ObjectProperty),...
            '%dialog'};


            if(this.isParamAvailable)
                rowIdx=rowIdx+1;
                wEnableEntityTypeFind.Type='checkbox';
                wEnableEntityTypeFind.Name='Find based on entity type';
                wEnableEntityTypeFind.Tag='EntityTypeBasedFind';
                wEnableEntityTypeFind.ObjectProperty='EntityTypeBasedFind';
                wEnableEntityTypeFind.Source=this.mBlock;
                wEnableEntityTypeFind.Mode=true;
                wEnableEntityTypeFind.DialogRefresh=true;
                wEnableEntityTypeFind.RowSpan=[rowIdx,rowIdx];
                wEnableEntityTypeFind.ColSpan=[1,1];
                wEnableEntityTypeFind.MatlabMethod='handleCheckEvent';
                wEnableEntityTypeFind.MatlabArgs={this.mUddParent,...
                '%value',...
                this.getPrmIdx(wEnableOutput.ObjectProperty),...
                '%dialog'};
            end





















            rowIdx=rowIdx+1;
            wEnableFilter.Type='checkbox';
            wEnableFilter.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:FindEntity:AdditionalFilteringCondition');
            wEnableFilter.Tag='EntityFilter';
            wEnableFilter.ObjectProperty='EntityFilter';
            wEnableFilter.Source=this.mBlock;
            wEnableFilter.Mode=true;
            wEnableFilter.DialogRefresh=true;
            wEnableFilter.RowSpan=[rowIdx,rowIdx];
            wEnableFilter.ColSpan=[1,1];
            wEnableFilter.MatlabMethod='handleCheckEvent';
            wEnableFilter.MatlabArgs={this.mUddParent,...
            '%value',this.getPrmIdx(wEnableFilter.ObjectProperty),'%dialog'};



            rowIdx=rowIdx+1;
            wSvcTimeEditor.Type='matlabeditor';
            wSvcTimeEditor.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:FindEntity:MatchingCondition');
            wSvcTimeEditor.Tag='MatchingCondition';
            wSvcTimeEditor.Mode=false;
            wSvcTimeEditor.ToolTip=DAStudio.message(...
            'SimulinkDiscreteEvent:FindEntity:MatchingConditionTip');
            wSvcTimeEditor.ObjectProperty='MatchingCondition';
            wSvcTimeEditor.Source=this.mBlock;
            wSvcTimeEditor.MatlabMethod='handleEditEvent';
            wSvcTimeEditor.MatlabArgs={this.mUddParent,...
            '%value',rowIdx-1,'%dialog'};
            wSvcTimeEditor.MatlabEditorFeatures={...
            'SyntaxHilighting',...
            'LineNumber',...
            'GoToLine',...
            'TabCompletion'};
            wSvcTimeEditor.RowSpan=[rowIdx,rowIdx];
            wSvcTimeEditor.ColSpan=[1,1];
            wSvcTimeEditor.Visible=Simulink.isParameterVisible(...
            this.mBlock.Handle,wSvcTimeEditor.ObjectProperty);
            wSvcTimeEditor.Enabled=strcmpi(get_param(...
            bdroot(this.mBlock.getFullName),'SimulationStatus'),...
            'stopped');

            schema.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:Main');
            if(this.isParamAvailable)
                schema.Items={wResourceTag,wEnableOutput,wEnableEntityTypeFind,wEnableFilter,wSvcTimeEditor};
            else
                schema.Items={wResourceTag,wEnableOutput,wEnableFilter,wSvcTimeEditor};
            end

            schema.LayoutGrid=[length(schema.Items),1];
            schema.RowStretch=[zeros(1,length(schema.Items)-1),1];
        end


        function schema=getStatisticsSchema(this)


            isOutputEnabled=isequal(get_param(this.mBlock.Handle,'EnableOutput'),'on');


            rowIdx=1;
            wNumDeparted.Type='checkbox';
            wNumDeparted.Name=DAStudio.message('SimulinkDiscreteEvent:FindEntity:NumberEntitiesDeparted');
            wNumDeparted.Mode=true;
            wNumDeparted.RowSpan=[rowIdx,rowIdx];
            wNumDeparted.ColSpan=[1,1];
            wNumDeparted.Tag='NumberEntitiesDeparted';
            wNumDeparted.ObjectProperty='NumberEntitiesDeparted';
            wNumDeparted.Source=this.mBlock;
            wNumDeparted.Visible=isOutputEnabled;


            rowIdx=rowIdx+1;
            wNumFound.Type='checkbox';
            wNumFound.Name=DAStudio.message('SimulinkDiscreteEvent:FindEntity:NumberEntitiesFound');
            wNumFound.Mode=true;
            wNumFound.RowSpan=[rowIdx,rowIdx];
            wNumFound.ColSpan=[1,1];
            wNumFound.Tag='NumberEntitiesFound';
            wNumFound.ObjectProperty='NumberEntitiesFound';
            wNumFound.Source=this.mBlock;
            wNumFound.Visible=~isOutputEnabled;


            rowIdx=rowIdx+1;
            wNumInBlock.Type='checkbox';
            wNumInBlock.Name=DAStudio.message('SimulinkDiscreteEvent:FindEntity:NumberEntitiesInBlock');
            wNumInBlock.Mode=true;
            wNumInBlock.RowSpan=[rowIdx,rowIdx];
            wNumInBlock.ColSpan=[1,1];
            wNumInBlock.Tag='NumberEntitiesInBlock';
            wNumInBlock.ObjectProperty='NumberEntitiesInBlock';
            wNumInBlock.Source=this.mBlock;
            wNumInBlock.Visible=isOutputEnabled;


            rowIdx=rowIdx+1;
            wAvgWait.Type='checkbox';
            wAvgWait.Name=DAStudio.message('SimulinkDiscreteEvent:FindEntity:AverageWait');
            wAvgWait.Mode=true;
            wAvgWait.RowSpan=[rowIdx,rowIdx];
            wAvgWait.ColSpan=[1,1];
            wAvgWait.Tag='AverageWait';
            wAvgWait.ObjectProperty='AverageWait';
            wAvgWait.Source=this.mBlock;
            wAvgWait.Visible=isOutputEnabled;


            rowIdx=rowIdx+1;
            wAvgQueueLength.Type='checkbox';
            wAvgQueueLength.Name=DAStudio.message('SimulinkDiscreteEvent:FindEntity:AverageStoreSize');
            wAvgQueueLength.Mode=true;
            wAvgQueueLength.RowSpan=[rowIdx,rowIdx];
            wAvgQueueLength.ColSpan=[1,1];
            wAvgQueueLength.Tag='AverageStoreSize';
            wAvgQueueLength.ObjectProperty='AverageStoreSize';
            wAvgQueueLength.Source=this.mBlock;
            wAvgQueueLength.Visible=isOutputEnabled;













            rowIdx=rowIdx+1;
            wNumExtracted.Type='checkbox';
            wNumExtracted.Name=DAStudio.message('SimulinkDiscreteEvent:FindEntity:NumberEntitiesExtracted');
            wNumExtracted.Mode=true;
            wNumExtracted.RowSpan=[rowIdx,rowIdx];
            wNumExtracted.ColSpan=[1,1];
            wNumExtracted.Tag='NumEntitiesExtracted';
            wNumExtracted.ObjectProperty='NumEntitiesExtracted';
            wNumExtracted.Source=this.mBlock;
            wNumExtracted.Visible=isOutputEnabled;

            schema.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:Statistics');
            schema.Items={wNumFound,wNumDeparted,wNumInBlock,wAvgWait,wAvgQueueLength,wNumExtracted};
            schema.LayoutGrid=[length(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,length(schema.Items)),1];
        end

        function refreshPropagatedData(this)


            try
                allTags=[];
                rootHdl=bdroot(this.mBlock.Handle);
                parentSS=get_param(this.mBlock.Handle,'Parent');
                parentHdl=get_param(parentSS,'Handle');
                while true
                    curPools=find_system(parentHdl,...
                    'LookUnderMasks','all',...
                    'FollowLinks','on',...
                    'SearchDepth','1',...
                    'BlockType','EntityResourcePool');
                    allTags=union(allTags,curPools);
                    if(parentHdl==rootHdl)
                        break;
                    else
                        parentSS=get_param(parentHdl,'Parent');
                        parentHdl=get_param(parentSS,'Handle');
                    end
                end

                allModelPools=find_system(rootHdl,'LookUnderMasks',...
                'all','FollowLinks','on','SearchDepth','Inf',...
                'BlockType','EntityResourcePool');

                globalPools=[];
                for i=1:length(allModelPools)
                    vis=get_param(allModelPools(i),'PoolVisibility');
                    if strcmp(vis,'Global')
                        globalPools=[globalPools,allModelPools(i)];
                    end
                end

                allTags=union(allTags,globalPools);

                if isempty(allTags)
                    this.mAllTags={};
                else
                    allTypes=get_param(allTags,'ResourceName');
                    if length(allTags)>1
                        allTypes=unique(allTypes);
                    else
                        allTypes={allTypes};
                    end
                    this.mAllTags=allTypes;
                end


                if this.isParamAvailable
                    dtt=Simulink.internal.DataTypeTable(gcs);
                    this.mAllTags=dtt.getAllStructTypeNames;
                    rmTypes=[{'slMsgManager'},{'slMsgQueue'},{'slMsgMemPool'},...
                    {'slMsgWrapper'},{'slMsgLink'},{'slMessage'}];
                    this.mAllTags=setdiff(this.mAllTags,rmTypes);
                end

                if isempty(this.mAllTags)
                    if this.isParamAvailable
                        this.mAllTags={'Entity1'};
                    else
                        this.mAllTags={'Resource1'};
                    end
                end
            catch me %#ok<NASGU>
                this.mAllTags={};
            end
        end

        function handleCheckEventAction(~,~,dlg)
            dlg.refresh;
        end

        function handleEditEventAction(~,~,dlg)
            dlg.refresh;
        end

        function block=getResourceAcquirerBlockHandle(this,blockType)
            block={};
            resourceTag=get_param(this.mBlock.Handle,'ResourceName');
            try

                allRscBlocks=[];
                rootHdl=bdroot(this.mBlock.Handle);
                parentSS=get_param(this.mBlock.Handle,'Parent');
                parentHdl=get_param(parentSS,'Handle');

                while true
                    curPools=find_system(parentHdl,...
                    'LookUnderMasks','all',...
                    'FollowLinks','on',...
                    'SearchDepth','1',...
                    'BlockType',blockType);
                    allRscBlocks=union(allRscBlocks,curPools);
                    if(parentHdl==rootHdl)
                        break;
                    else
                        parentSS=get_param(parentHdl,'Parent');
                        parentHdl=get_param(parentSS,'Handle');
                    end
                end


                if isempty(allRscBlocks)
                    block={};
                    return;
                end

                for idx=1:numel(allRscBlocks)
                    blk=allRscBlocks(idx);

                    if(strcmp(blockType,'EntityResourceAcquirer'))
                        resourceNames=get_param(blk,'ResourceName');
                        resources=strsplit(resourceNames,"|");

                        IsAMatch=any(strcmp(resources,resourceTag));
                    elseif(strcmp(blockType,'EntityGenerator'))
                        typeName=get_param(blk,'EntityTypeName');
                        IsAMatch=strcmp(typeName,resourceTag);
                    elseif(strcmp(blockType,'CompositeEntityCreator'))
                        typeName=get_param(blk,'EntityTypeName');
                        IsAMatch=strcmp(typeName,resourceTag);
                    elseif(strcmp(blockType,'EntityBatchCreator'))
                        typeName=get_param(blk,'EntityTypeName');
                        IsAMatch=strcmp(typeName,resourceTag);
                    end

                    if(IsAMatch)
                        handles=get_param(blk,'PortHandles');

                        if~isempty(handles.Outport)
                            block=blk;
                            break;
                        end
                    end
                end

            catch me %#ok<NASGU>
                block={};
            end
        end


    end

end




