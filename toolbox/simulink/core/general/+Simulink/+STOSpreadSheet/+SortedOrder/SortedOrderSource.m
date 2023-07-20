classdef SortedOrderSource<handle




    properties
        mRateData;
        mTaskData;
        mTypeData;
        mModelName;
        mTopModelName;
        mUDD;
        mTabs;
        mComponentName;
        mComponent;
        mResolvedRows;






        isHierarchy;
        mPropertyList;
        studio;
        type='sourceObj';
        currentSelection;
        isBlockToTaskMode;
        currentBlockTaskVec;
        blockListText={};

        systemID;
    end

    methods
        function this=SortedOrderSource(currentModelName,topMdlName,ssComp,studio,taskIdVec,systemID)

            this.mComponent=ssComp;
            ssComp.setConfig('{"hidecolumns":false, "enablemultiselect":false}');
            this.studio=studio;
            this.mPropertyList{1}={DAStudio.message('Simulink:utility:TaskID'),DAStudio.message('Simulink:utility:Details')};
            this.mPropertyList{2}={DAStudio.message('Simulink:utility:TaskID')};

            if(systemID==-101)
                this.systemID=-1;
            else
                this.systemID=systemID;
            end

            if(isequal(get_param(currentModelName,'EffectivelyUsingTaskBasedSorting'),'off'))
                ssComp.setColumns(this.mPropertyList{2},'','',false);
            else
                ssComp.setColumns(this.mPropertyList{1},'','',false);
                this.mComponent.setConfig(['{"columns": {"name": "',DAStudio.message('Simulink:utility:TaskID'),'", "minsize": 75, "maxsize": 75}}']);
            end
            this.isHierarchy=true;
            ssComp.enableHierarchicalView(false);


            this.mModelName=currentModelName;
            this.mTopModelName=topMdlName;
            this.mComponentName=sprintf('GLUE2:SpreadSheet/%s',ssComp.getName);
            this.mRateData=[];
            this.mTaskData=[];
            this.currentSelection=this;
            this.currentBlockTaskVec=[];
            this.isBlockToTaskMode=0;


            if(slfeature('TaskBasedSortedInfoCache')>0)
                this.blockListText=getCurrentTaskBlockList(this,this.mModelName);
            end

            this.mComponent.setTitleViewSource(this);
            this.mComponent.onHelpClicked=@(ss_src)Simulink.STOSpreadSheet.SortedOrder.SortedOrderSource.handleHelpClicked(ss_src,this);
            legendData=getLegendData(this,this.mModelName);
            len=length(legendData);


            this.mComponent.addEventListener('click',@Simulink.STOSpreadSheet.SortedOrder.SortedOrderSource.handleClick);


            this.mComponent.onCloseClicked=@(comp)Simulink.STOSpreadSheet.SortedOrder.SortedOrderSource.onCloseClicked(comp);
            ssComp.setComponentUserData(this);

            mSTLObj=Simulink.SampleTimeLegend;
            firstActiveTask=[];

            if(systemID==-101)

                mSTLObj.clearHilite(this.mModelName);
                mSTLObj.clearHilite(this.mModelName,'task');

                this.mComponent.update();
                this.systemID=-1;
                ssComp.setConfig('{"hidecolumns":true}');
                return;
            end

            for count=1:len

                rowData=legendData(count);
                if(~isempty(rowData.TID))
                    currentRateNode=Simulink.STOSpreadSheet.rateNode(this,rowData,mSTLObj,count,this.mModelName,0);

                    if(slfeature('DisplayConstTasksTogether')>0&&...
                        isequal(currentRateNode.ValueOrig,[inf,inf]))
                        allTasks=get_param(this.mModelName,'tasklist');
                        for eIdx=1:length(allTasks)
                            tsPeriod=allTasks(eIdx).SampleTimes(1).RateSpec.period;
                            tsOffset=allTasks(eIdx).SampleTimes(1).RateSpec.offset;
                            if(isequal(tsPeriod,Inf)&&...
                                (tsOffset==0)||isequal(tsOffset,Inf))
                                currentRateNode.TaskId=allTasks(eIdx).TaskIndex;
                                break;
                            end
                        end
                    end
                    this.mRateData=[this.mRateData,currentRateNode];
                end
            end

            if(isequal(get_param(currentModelName,'EffectivelyUsingTaskBasedSorting'),'off'))

                ssConfigStr='{"hidecolumns":true, "disablepropertyinspectorupdate":true}';
                ssComp.setConfig(ssConfigStr);

                globeTask0=Simulink.STOSpreadSheet.taskNode(this.mRateData,0,this.mModelName,this.mTopModelName,1,this);
                globeTask0.isActive=true;
                this.mTaskData=globeTask0;
                if(~isempty(legendData))
                    this.currentSelection=globeTask0;
                    this.handleSelectionChange(ssComp,this.currentSelection);
                end
            else

                [tmp,ind]=sort([this.mRateData.TaskId]);
                sortedRate=this.mRateData(ind);

                Gnum=tmp(1);
                localRateVec=[];

                for count2=1:length(sortedRate)

                    if isempty(sortedRate(count2).AllBlocks)









                        isTrigSource=false;
                        for count3=1:length(sortedRate)
                            if count3==count2
                                continue;
                            end
                            if~isempty(sortedRate(count3).AllBlocks)&&...
                                strcmp(sortedRate(count3).ValueOrig,...
                                ['Source: ',sortedRate(count2).Annotation])
                                isTrigSource=true;
                                break;
                            end
                        end
                        if~isTrigSource


                            nRatesInThisTask=0;
                            for count3=1:length(sortedRate)
                                if sortedRate(count3).TaskId==sortedRate(count2).TaskId
                                    nRatesInThisTask=nRatesInThisTask+1;
                                end
                            end
                            if nRatesInThisTask>1
                                continue;
                            end
                        end
                    end
                    if(isequal(tmp(count2),Gnum))
                        localRateVec=[localRateVec,sortedRate(count2)];
                    else
                        for rateCount=1:length(localRateVec)
                            if(~isequal('Inherited',localRateVec(rateCount).ValueOrig)&&...
                                (ischar(localRateVec(rateCount).ValueOrig)||...
                                isnan(localRateVec(rateCount).ValueOrig(1))))
                                continue;
                            end
                            currentTaskNode=Simulink.STOSpreadSheet.taskNode(localRateVec,Gnum,this.mModelName,this.mTopModelName,rateCount,this);
                            if~isempty(find(taskIdVec==currentTaskNode.taskIdx,1))
                                currentTaskNode.isActive=true;
                                if(isempty(firstActiveTask))
                                    firstActiveTask=currentTaskNode;
                                end
                            else
                                currentTaskNode.isActive=false;
                            end

                            if(currentTaskNode.taskIdx>=0||isequal(currentTaskNode.taskIdx,-2))
                                this.mTaskData=[this.mTaskData,currentTaskNode];
                            end


                        end
                        Gnum=tmp(count2);
                        localRateVec=sortedRate(count2);
                    end
                end

                for rateCount=1:length(localRateVec)
                    if(~isequal('Inherited',localRateVec(rateCount).ValueOrig)&&...
                        (ischar(localRateVec(rateCount).ValueOrig)||...
                        isnan(localRateVec(rateCount).ValueOrig(1))))
                        continue;
                    end
                    currentTaskNode=Simulink.STOSpreadSheet.taskNode(localRateVec,tmp(count2),this.mModelName,this.mTopModelName,rateCount,this);

                    if~isempty(find(taskIdVec==currentTaskNode.taskIdx,1))
                        currentTaskNode.isActive=true;
                        if(isempty(firstActiveTask))
                            firstActiveTask=currentTaskNode;
                        end
                    else
                        currentTaskNode.isActive=false;
                    end

                    if(~isequal(currentTaskNode.taskIdx,100000)&&currentTaskNode.taskIdx>=0)||isequal(currentTaskNode.taskIdx,-2)
                        this.mTaskData=[this.mTaskData,currentTaskNode];
                    end

                end
                if(~isempty(firstActiveTask))
                    this.currentSelection=firstActiveTask;
                    this.handleSelectionChange(ssComp,firstActiveTask);
                end
            end
            this.mComponent.update();

        end


        function update(this,currentModelName,topMdlName,ssComp,studio,taskIdVec,systemID)
            this.mComponent=ssComp;
            this.studio=studio;
            ssComp.setConfig('{"hidecolumns":false}');

            if(systemID==-101)
                this.systemID=-1;
            else
                this.systemID=systemID;
            end


            this.mModelName=currentModelName;
            this.mTopModelName=topMdlName;
            this.mComponentName=sprintf('GLUE2:SpreadSheet/%s',ssComp.getName);
            this.mRateData=[];
            this.mTaskData=[];
            this.currentBlockTaskVec=[];

            if(slfeature('TaskBasedSortedInfoCache')>0)
                this.blockListText=getCurrentTaskBlockList(this,this.mModelName);
            end

            this.mComponent.setTitleViewSource(this);
            this.mComponent.onHelpClicked=@(ss_src)Simulink.STOSpreadSheet.SortedOrder.SortedOrderSource.handleHelpClicked(ss_src,this);
            legendData=getLegendData(this,this.mModelName);
            len=length(legendData);



            if(isequal(get_param(currentModelName,'EffectivelyUsingTaskBasedSorting'),'off'))
                ssComp.setColumns(this.mPropertyList{2},'','',false);
            else
                ssComp.setColumns(this.mPropertyList{1},'','',false);
            end

            mSTLObj=Simulink.SampleTimeLegend;





            if(isequal(this.currentSelection.type,'task')...
                &&~ismember(this.currentSelection.taskIdx,taskIdVec))


                subsysBlk=find_system(gcs,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
                subsysBlk(1)=[];
                typeHiliteInfo=...
                Simulink.STOSpreadSheet.internal.getTaskHiliteInfo(this.currentSelection,mSTLObj,'all');
                intersection=intersect(typeHiliteInfo.hilitePathSet,cell2mat(get_param(subsysBlk,'handle')'));
                if(~isempty(intersection))
                    taskIdVec=[taskIdVec,this.currentSelection.taskIdx];
                end
            end


            if(systemID==-101)


                mSTLObj.clearHilite(this.mModelName);
                mSTLObj.clearHilite(this.mModelName,'task');

                this.systemID=-1;
                ssComp.setConfig('{"hidecolumns":true}');
                this.mComponent.update();
                return;
            end

            for count=1:len

                rowData=legendData(count);
                if(~isempty(rowData.TID))
                    currentRateNode=Simulink.STOSpreadSheet.rateNode(this,rowData,mSTLObj,count,this.mModelName,0);

                    if(slfeature('DisplayConstTasksTogether')>0&&...
                        isequal(currentRateNode.ValueOrig,[inf,inf]))
                        allTasks=get_param(this.mModelName,'tasklist');
                        for eIdx=1:length(allTasks)
                            tsPeriod=allTasks(eIdx).SampleTimes(1).RateSpec.period;
                            tsOffset=allTasks(eIdx).SampleTimes(1).RateSpec.offset;
                            if(isequal(tsPeriod,Inf)&&...
                                (tsOffset==0)||isequal(tsOffset,Inf))
                                currentRateNode.TaskId=allTasks(eIdx).TaskIndex;
                                break;
                            end
                        end
                    end
                    this.mRateData=[this.mRateData,currentRateNode];
                end
            end

            if(isequal(get_param(currentModelName,'EffectivelyUsingTaskBasedSorting'),'off'))

                ssConfigStr='{"hidecolumns":true, "disablepropertyinspectorupdate":true}';
                ssComp.setConfig(ssConfigStr);

                globeTask0=Simulink.STOSpreadSheet.taskNode(this.mRateData,0,this.mModelName,this.mTopModelName,1,this);
                globeTask0.isActive=true;
                this.mTaskData=globeTask0;
                this.currentSelection=globeTask0;

            else


                [tmp,ind]=sort([this.mRateData.TaskId]);
                sortedRate=this.mRateData(ind);

                Gnum=tmp(1);
                localRateVec=[];

                for count2=1:length(sortedRate)

                    if isempty(sortedRate(count2).AllBlocks)









                        isTrigSource=false;
                        for count3=1:length(sortedRate)
                            if count3==count2
                                continue;
                            end
                            if~isempty(sortedRate(count3).AllBlocks)&&...
                                strcmp(sortedRate(count3).ValueOrig,...
                                ['Source: ',sortedRate(count2).Annotation])
                                isTrigSource=true;
                                break;
                            end
                        end
                        if~isTrigSource


                            nRatesInThisTask=0;
                            for count3=1:length(sortedRate)
                                if sortedRate(count3).TaskId==sortedRate(count2).TaskId
                                    nRatesInThisTask=nRatesInThisTask+1;
                                end
                            end
                            if nRatesInThisTask>1
                                continue;
                            end
                        end
                    end
                    if(isequal(tmp(count2),Gnum))
                        localRateVec=[localRateVec,sortedRate(count2)];
                    else
                        for rateCount=1:length(localRateVec)
                            if(~isequal('Inherited',localRateVec(rateCount).ValueOrig)&&...
                                (ischar(localRateVec(rateCount).ValueOrig)||...
                                isnan(localRateVec(rateCount).ValueOrig(1))))
                                continue;
                            end

                            currentTaskNode=Simulink.STOSpreadSheet.taskNode(localRateVec,Gnum,this.mModelName,this.mTopModelName,rateCount,this);
                            if~isempty(find(taskIdVec==currentTaskNode.taskIdx,1))
                                currentTaskNode.isActive=true;
                            else
                                currentTaskNode.isActive=false;
                            end

                            if(currentTaskNode.taskIdx>=0||isequal(currentTaskNode.taskIdx,-2))
                                this.mTaskData=[this.mTaskData,currentTaskNode];
                            end

                        end

                        Gnum=tmp(count2);
                        localRateVec=sortedRate(count2);
                    end
                end

                for rateCount=1:length(localRateVec)
                    if(~isequal('Inherited',localRateVec(rateCount).ValueOrig)&&...
                        (ischar(localRateVec(rateCount).ValueOrig)||...
                        isnan(localRateVec(rateCount).ValueOrig(1))))
                        continue;
                    end
                    currentTaskNode=Simulink.STOSpreadSheet.taskNode(localRateVec,tmp(count2),this.mModelName,this.mTopModelName,rateCount,this);

                    if~isempty(find(taskIdVec==currentTaskNode.taskIdx,1))
                        currentTaskNode.isActive=true;
                    else
                        currentTaskNode.isActive=false;
                    end

                    if(~isequal(currentTaskNode.taskIdx,100000)&&currentTaskNode.taskIdx>=0)||isequal(currentTaskNode.taskIdx,-2)
                        this.mTaskData=[this.mTaskData,currentTaskNode];
                    end

                end
            end
            this.mComponent.update();
        end





        function b=isHierarchical(this)
            b=this.isHierarchy;
        end

        function children=getChildren(this,~)
            children=this.mTaskData;
        end

        function children=getHierarchicalChildren(this)
            children=this.mTaskData;
        end



        function retVal=resolveSourceSelection(obj,selections,~,~)

            retVal={};
            if(length(selections)~=1)
                obj.currentBlockTaskVec=[];
                obj.mComponent.update();
                return;
            end
            if(isprop(selections,'handle')...
                &&selections.Handle>0...
                &&isequal(get_param(selections.Handle,'type'),'block')...
                &&obj.isBlockToTaskMode==1)



                if(isequal(get_param(obj.mModelName,'EffectivelyUsingTaskBasedSorting'),'off'))
                    taskIdxVec=0;
                else
                    Info=get_param(selections.Handle,'sortedorder');

                    if(Info(1).SystemIndex==-1&&Info(1).BlockIndex==-1)
                        compTs=get_param(selections.Handle,'compiledsampletime');
                        if(iscell(compTs)&&isequal(compTs{end},[inf,inf]))
                            compTs{end+1}=[inf,0];
                        end
                        taskIdxVec=ones(1,length(obj.mRateData))*(-100);

                        if(~iscell(compTs))
                            compTs={compTs};
                        end

                        if(isequal(compTs{1},[-1,-1]))
                            for idx=1:length(obj.mRateData)
                                if(isequal(obj.mRateData(idx).Description,DAStudio.message('Simulink:SampleTime:TriggeredSampleTimeDescription')))
                                    taskIdxVec(idx)=obj.mRateData(idx).TaskId;
                                end
                            end
                        else
                            taskIdxVec=get_param(selections.Handle,'TaskListOfSortedOrderDisplay')';
                            if(isempty(taskIdxVec))
                                get_param(obj.mModelName,'ExecutionOrderUIVirtualBlkMsg')
                            end
                        end
                    else
                        taskIdxVec=get_param(selections.Handle,'TaskListOfSortedOrderDisplay')';
                        for index=1:length(Info)
                            if(Info(index).TaskIndex==-2)
                                taskIdxVec(end)=obj.mTaskData(end).taskIdx;
                            end
                        end

                        if(isempty(taskIdxVec))
                            for index=1:length(Info)
                                taskIdxVec(index)=Info(index).TaskIndex;
                                if(Info(index).TaskIndex==-2)
                                    taskIdxVec(end)=obj.mTaskData(end).taskIdx;
                                end
                            end
                        end
                    end
                end

                obj.currentBlockTaskVec=taskIdxVec;
                obj.mComponent.update();
            else
                obj.currentBlockTaskVec=[];
                obj.mComponent.update();
            end

        end


        function dlgStruct=getDialogSchema(obj,~)

            maxItemsInPanel=12;


            clearButton.Type='pushbutton';

            clearButton.Tag=[obj.mComponentName,'clearTaskHighlighting'];
            clearButton.RowSpan=[1,1];
            if(ismac||ispc)
                clearButton.FilePath=fullfile(matlabroot,'toolbox',...
                'simulink','core','general','+Simulink','+STOSpreadSheet','icon','clear_highlighting.png');
            else
                clearButton.FilePath=fullfile(matlabroot,'toolbox',...
                'simulink','core','general','+Simulink','+STOSpreadSheet','icon','clear_highlighting.ico');
            end
            clearButton.ObjectMethod='clearHighlight';
            clearButton.MethodArgs={'%dialog'};
            clearButton.ArgDataTypes={'handle'};
            clearButton.ColSpan=[maxItemsInPanel,maxItemsInPanel];
            clearButton.ToolTip=DAStudio.message('Simulink:utility:ClearLegendHilite');
            clearButton.Graphical=true;
            clearButton.Enabled=true;




            if(isequal(get_param(obj.mModelName,'EffectivelyUsingTaskBasedSorting'),'off'))
                helpText.Name=DAStudio.message('Simulink:utility:ExecutionOrderAsyncTips');
            else
                if(isequal(obj.isBlockToTaskMode,0))
                    helpText.Name=DAStudio.message('Simulink:utility:ExecutionOrderTips');
                else
                    helpText.Name=DAStudio.message('Simulink:utility:ExecutionOrderTipsBlockToTask');
                end
            end
            helpText.Bold=false;
            helpText.Type='text';
            helpText.RowSpan=[1,1];
            helpText.WordWrap=true;
            helpText.ColSpan=[1,1];

            helpTextPane.Type='panel';
            helpTextPane.Tag='TaskHelpMessage';
            helpTextPane.Items={helpText};

            helpTextPane.ColSpan=[1,maxItemsInPanel-1];
            helpTextPane.RowSpan=[1,1];


            systemIndex.Name=[DAStudio.message('Simulink:utility:SystemIndex'),': ',num2str(obj.systemID)];
            systemIndex.Bold=false;
            systemIndex.Type='text';
            systemIndex.RowSpan=[1,1];
            systemIndex.WordWrap=true;
            systemIndex.ColSpan=[1,1];

            systemIndexPane.Type='panel';
            systemIndexPane.Tag='SystemIndex';
            systemIndexPane.Items={systemIndex};

            systemIndexPane.ColSpan=[1,maxItemsInPanel];
            systemIndexPane.RowSpan=[2,2];

            blockListPanel.Type='listbox';
            blockListPanel.Tag='blockList';
            blockListPanel.Entries=obj.blockListText;
            blockListPanel.BackgroundColor=[230,230,230];
            blockListPanel.ColSpan=[1,maxItemsInPanel];
            blockListPanel.RowSpan=[3,3];


            titlePanel.Type='panel';

            if(slfeature('TaskBasedSortedInfoCache')>0)
                titlePanel.Items={helpTextPane,systemIndexPane,blockListPanel,clearButton};
            else
                titlePanel.Items={helpTextPane,systemIndexPane,clearButton};
            end
            titlePanel.LayoutGrid=[4,maxItemsInPanel];
            titlePanel.ColStretch=[0,0,0,1,0,0,0,0,0,0,1,0];
            titlePanel.RowStretch=[0,0,0,1];



            titlePanel.RowSpan=[1,1];
            titlePanel.ColSpan=[1,1];

            dlgStruct.LayoutGrid=[1,1];
            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.Items={titlePanel};
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};

        end

    end

    methods(Static)


        function handleClick(comp,sel,prop)
            Simulink.STOSpreadSheet.SortedOrder.SortedOrderSource.handleSelectionChange(comp,sel);
        end

        function result=handleSelectionChange(comp,sel)
            mSTLObj=Simulink.SampleTimeLegend;
            if(iscell(sel))
                sel=sel{1};
            end
            if(isequal(sel.type,'task')&&sel.isActive&&sel.source.isBlockToTaskMode==0)

                if(~isequal(sel.source.currentSelection.mModelName,sel.mModelName))
                    mSTLObj.clearHilite(sel.source.currentSelection.mModelName,'task');
                end

                sel.source.currentSelection=sel;

                mSTLObj.clearHilite(sel.mModelName);
                mSTLObj.clearHilite(sel.mModelName,'task');

                comp.setComponentUserData(sel);

                set_param(sel.mModelName,'TaskBasedExecutionOrderTaskID',sel.taskIdx);

                typeHiliteInfo=Simulink.STOSpreadSheet.internal.getTaskHiliteInfo(sel,mSTLObj,'all');
                typeHiliteInfo.type='task';
                mSTLObj.hilite_system_legend(typeHiliteInfo);

                if(slfeature('TaskBasedSortedInfoCache')>0)
                    sel.source.blockListText=getCurrentTaskBlockList(sel.source,sel.mModelName);
                end
                sel.source.currentBlockTaskVec=[];

                comp.updateTitleView;
                comp.update();

                timingLegendCompName=char(sel.source.studio.getStudioTag+"ssCompLegend");
                ssComp=sel.source.studio.getComponent('GLUE2:SpreadSheet',timingLegendCompName);
                if(~isempty(ssComp)&&ssComp.isvalid)
                    ssComp.view({});
                end

            end
            result=1;
        end


        function out=getPropertySchema(this)
            out=this;
        end



        function handleHelpClicked(~,obj)
            helpview(fullfile(docroot,'simulink','helptargets.map'),'controlling_and_displaying_the_sorted_order');
        end



        function onCloseClicked(comp)
            sel=comp.getComponentUserData;
            legendObj=Simulink.SampleTimeLegend;
            legendObj.clearHilite(sel.mModelName,'task');
            set_param(gcb,'selected','off');

            if(isequal(sel.type,'sourceObj'))
                sourceObj=sel;
            else
                sourceObj=sel.source;
            end

            legendObj.clearHilite(sourceObj.currentSelection.mModelName,'task');
            source=comp.getSource;
            source.currentSelection=source;
            comp.update();

            set_param(sel.mModelName,'TaskBasedExecutionOrderTaskID',-100);
            set_param(sel.mModelName,'ExecutionOrderLegendDisplay','off');
            set_param(sel.mTopModelName,'ExecutionOrderLegendDisplay','off');
        end


    end

    methods

        function handleRefresh(obj)
            st=obj.mComponent;
            st.update();
        end



        function clearHighlight(obj,~)

            if(obj.isBlockToTaskMode)


                selectedBlks=find_system(gcs,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Selected','on');
                for idx=1:length(selectedBlks)
                    set_param(selectedBlks{idx},'selected','off');
                end
            end
            set_param(obj.mModelName,'TaskBasedExecutionOrderTaskID',-100);
            legendObj=Simulink.SampleTimeLegend;
            legendObj.clearHilite(obj.mModelName,'task');
            legendObj.clearHilite(obj.mModelName);

            obj.currentBlockTaskVec=[];
            obj.currentSelection=obj;
            obj.mComponent.setComponentUserData(obj);
            obj.mComponent.update();

        end

        function enableBlkToTaskTraceCallBackFcn(obj,~,value)
            obj.isBlockToTaskMode=value;
            if(value==0)
                obj.currentBlockTaskVec=[];
                obj.mComponent.update();
            else
                obj.clearHighlight(obj);
            end

        end

    end
    methods(Access=protected)

        function text=getCurrentTaskBlockList(this,modelName)


            text={};
            currentSortedBlks=[];
            if(isequal(this.currentSelection.type,'task'))

                sortedList=get_param(gcs,'cachedsortedlists');
                currentTaskId=this.currentSelection.taskIdx;

                for index=1:length(sortedList)
                    if(isequal(sortedList(index).TaskIndex,currentTaskId))
                        currentSortedBlks=sortedList(index).SortedBlocks;
                        break;
                    end
                end

                text{1}=['Block List for Task ',num2str(this.currentSelection.taskIdx)];

                for blkCount=1:length(currentSortedBlks)
                    path=currentSortedBlks(blkCount).BlockPath;
                    pos=find(path=='/');
                    if(~isempty(pos)&&(pos(1)+1<length(path)))
                        path=path(pos(1)+1:end);
                    end

                    text{blkCount+1}=['[',num2str(blkCount),']  ',path];
                    if(currentSortedBlks(blkCount).isHidden)
                        text{blkCount+1}=[text{blkCount+1},'  (Hidden)'];
                    end
                end
            end

        end

        function legendData=getLegendData(~,modelName)

            mSTLObj=Simulink.SampleTimeLegend;
            tabIdx=find(strcmp(modelName,mSTLObj.modelList),1);
            if(isempty(tabIdx))
                mSTLObj.addModel(modelName);

                tabIdx=find(strcmp(modelName,mSTLObj.modelList),1);
            end

            warningStruct=warning('off','Simulink:Engine:CompileNeededForSampleTimes');
            tLegendData=get_param(modelName,'SampleTimes');
            rateTaskMap=get_param(modelName,'rateIndexTaskIdxMap');
            mSTLObj.legendBlockInfo{tabIdx}=get_param(modelName,'rateIndexTaskIdxMap');
            warning(warningStruct.state,'Simulink:Engine:CompileNeededForSampleTimes');

            valueDataGroup=mSTLObj.getValueDataGroup(mSTLObj,tLegendData,tabIdx,true);

            unionSudoEntryAdded=1;

            if(isempty(tLegendData))
                legendData=tLegendData;
                return;
            end

            if(isempty(tLegendData(end).TID))
                tLegendData=tLegendData(1:end-1);
                rateTaskMap=rateTaskMap(1:end-1);
            end

            len=length(tLegendData);
            taskIdRateIdMap=containers.Map({tLegendData.TID},{rateTaskMap.taskIdx});

            if(~isempty(tabIdx))
                for count=1:len
                    tLegendData(count).ValueDetails=valueDataGroup{count};
                    tLegendData(count).taskId=rateTaskMap(count).taskIdx;
                    tLegendData(count).STOObj.TaskID=rateTaskMap(count).taskIdx;
                    tLegendData(count).SourceBlocks=rateTaskMap(count).SourceBlocks;
                    tLegendData(count).AllBlocks=rateTaskMap(count).AllBlocks;


                    if(isnan(tLegendData(count).Value(1))&&isnan(tLegendData(count).Value(2))...
                        &&~isempty(tLegendData(count).ComponentSampleTimes))
                        for unionC=1:length(tLegendData(count).ComponentSampleTimes)
                            elementTID=tLegendData(count).ComponentSampleTimes(unionC).TID;
                            if(isKey(taskIdRateIdMap,elementTID))
                                tLegendData(len+unionSudoEntryAdded)=tLegendData(count);
                                tLegendData(len+unionSudoEntryAdded).taskId=taskIdRateIdMap(elementTID);
                                unionSudoEntryAdded=unionSudoEntryAdded+1;
                            end
                        end
                    elseif(ischar(tLegendData(count).Value)&&length(tLegendData(count).Value)>9)
                        sourceAnnotation=tLegendData(count).Value(9:end);
                        sourceIdx=find(strcmp({tLegendData.Annotation},sourceAnnotation));
                        for sIdx=1:length(sourceIdx)
                            if(tLegendData(sourceIdx(sIdx)).taskId>=0)
                                tLegendData(len+unionSudoEntryAdded)=tLegendData(count);
                                tLegendData(len+unionSudoEntryAdded).taskId=tLegendData(sourceIdx(sIdx)).taskId;
                                unionSudoEntryAdded=unionSudoEntryAdded+1;
                            end
                        end
                    end
                end
            end
            legendData=tLegendData;

        end
    end
end
