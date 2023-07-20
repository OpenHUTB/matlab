classdef Inspector<handle





    properties(Access=private)


        blockToDataMap;


        informer;


        pathHighlighter;


        sldvData;
        resultFiles;
        model;
        mIsQuickDeadLogicAndPostAnalysisAndHasDeadLogic;












        multilinkChartIds;
        sfIdToSidMap;
    end

    methods
        function obj=Inspector(sldvData,resultFiles)

            obj.blockToDataMap=containers.Map...
            ('KeyType','char','ValueType','any');
            obj.sldvData=sldvData;
            obj.resultFiles=resultFiles;
            obj.informer=[];
            obj.model=sldvData.ModelInformation.Name;




            obj.mIsQuickDeadLogicAndPostAnalysisAndHasDeadLogic=isfield(sldvData,'DeadLogic')&&~isempty(sldvData.DeadLogic)&&...
            ~Sldv.utils.isSldvAnalysisRunning(obj.model);

            if Sldv.utils.isPathBasedTestGeneration(obj.sldvData.AnalysisInformation.Options)
                obj.pathHighlighter=...
                Sldv.HighlightingWorkflows.PathHighlighter(obj.model,sldvData);
            end
            obj.multilinkChartIds=obj.find_multi_instance_links(obj.model);
            obj.sfIdToSidMap=containers.Map...
            ('KeyType','double','ValueType','any');

        end
        function clearInformer(obj)
            obj.informer=[];
            obj.pathHighlighter.clearHighlighter;
            obj.pathHighlighter=[];
            obj.blockToDataMap=[];
            obj.sldvData=[];
            obj.model=[];
            obj.resultFiles=[];
            obj.sfIdToSidMap=[];
        end
    end
    methods

        function updateSldvData(obj,sldvData)
            obj.sldvData=sldvData;
        end
        function updateResultFiles(obj,resultFiles)
            obj.resultFiles=resultFiles;
        end
        function populateInspectorData(obj,justifiedObjectives)




            if nargin<2
                justifiedObjectives=[];
            end




            obj.mIsQuickDeadLogicAndPostAnalysisAndHasDeadLogic=isfield(obj.sldvData,'DeadLogic')&&~isempty(obj.sldvData.DeadLogic)&&...
            ~Sldv.utils.isSldvAnalysisRunning(obj.model);

            obj.blockToDataMap=containers.Map('KeyType','char','ValueType','any');
            obj.sfIdToSidMap=containers.Map...
            ('KeyType','double','ValueType','any');


            obj.addObjectiveIdxToSldvObjective();
            obj.updateModelObjectInformation(justifiedObjectives);
            obj.updateReducedBlockInformation();
        end
    end
    methods

        function pathHighlighter=getPathHighlighter(obj)
            pathHighlighter=obj.pathHighlighter;
        end

        function informer=getInformer(obj)
            informer=obj.informer;
        end

        function updateUI(obj,isModelHighlighted,justifiedObjs)
            if nargin<3
                justifiedObjs=[];
            end
            if isempty(obj.informer)
                obj.initializeUI();
            end
            obj.updateSummary(isModelHighlighted,justifiedObjs);
            obj.populateUIData;
        end

        function displayUI(obj,isModelHighlighted,justifiedObjs)
            if nargin<3
                justifiedObjs=[];
            end
            if isempty(obj.informer)
                obj.initializeUI();
                obj.updateUI(isModelHighlighted,justifiedObjs);
            end
            obj.informer.show;
        end

        function bringInformerToFront(obj)
            obj.informer.show;
        end

        function displayDataforSid(obj,SID)
            block=obj.getBlockDisplayData(SID);
            htmlString=...
            Sldv.InspectorWorkflow.InspectorUtils.buildDisplayData(block);
            obj.informer.text=htmlString;
        end

        function htmlString=getPrintStringForBlock(obj,blockSID)
            htmlString=Sldv.InspectorWorkflow.InspectorUtils.buildDisplayDataWithView(...
            obj.blockToDataMap(blockSID));
        end
        function htmlString=getPrintStringForMultilink(obj,sfId)
            linkedSIDs=obj.sfIdToSidMap(sfId);
            sfDataSet={};
            for sid=linkedSIDs
                sfDataSet{end+1}=obj.blockToDataMap(sid{:});
            end

            htmlString=Sldv.InspectorWorkflow.InspectorUtils.buildMultilinkChartData(...
            sfDataSet);
        end
        function setInspectorText(obj,text)
            obj.informer.text=text;
        end

    end
    methods
        function text=getInformerText(obj)
            if(~isempty(obj.informer))
                text=obj.informer.text;
            end
        end
        function blkData=getBlockDisplayData(obj,highlightSID)
            if isKey(obj.blockToDataMap,highlightSID)
                blkData=obj.blockToDataMap(highlightSID);
            end
        end

    end

    methods(Access=private)



        function updateModelObjectInformation(obj,justifiedObjectives)
            mode=obj.sldvData.AnalysisInformation.Options.Mode;
            for modelObjIndex=1:length(obj.sldvData.ModelObjects)
                modelObject=obj.sldvData.ModelObjects(modelObjIndex);
                designSid=modelObject.designSid;
                if~isempty(modelObject.objectives)
                    if isempty(designSid)
                        continue;
                    end

                    highlightSid=Sldv.InspectorWorkflow.InspectorUtils.getHighlightSid(designSid);
                    obj.getBlockInformation(highlightSid,modelObject,mode,justifiedObjectives);
                end
            end
            obj.updateBlockSummaryForBlocks;
        end

        function addObjectiveIdxToSldvObjective(obj)

            for i=1:length(obj.sldvData.Objectives)
                obj.sldvData.Objectives(i).ObjectiveIdx=i;
            end
        end

        function updateBlockSummaryForBlocks(obj)
            allHighlightSIDs=keys(obj.blockToDataMap);
            for sidIterator=1:length(allHighlightSIDs)
                blockSID=allHighlightSIDs{sidIterator};
                blk=obj.blockToDataMap(blockSID);


                rangeObjList=blk.getRanges;
                if numel(rangeObjList)>1
                    indexOrdering=[rangeObjList.portIdx];
                    [~,I]=sort(indexOrdering);
                    blk.setRanges(rangeObjList(I));
                end

                blk.updateSummary;
                obj.blockToDataMap(blockSID)=blk;
            end
        end

        function getBlockInformation(obj,blockSid,modelObject,mode,justifiedObjectives)
            try
                handle=Simulink.ID.getHandle(blockSid);
                if~isfloat(handle)&&...
                    handle.isa('Stateflow.Object')
                    chartId=handle.Chart.Id;
                    if ismember(chartId,obj.multilinkChartIds)
                        sfId=handle.Id;
                        if isKey(obj.sfIdToSidMap,sfId)
                            data=obj.sfIdToSidMap(sfId);
                            obj.sfIdToSidMap(sfId)=[data,blockSid];
                        else

                            obj.sfIdToSidMap(sfId)={blockSid};
                        end
                    end
                end
            catch


                return;
            end
            blockDataObject=Sldv.InspectorWorkflow.Block;
            structuralObjectives=[];
            rangeObjectives=[];

            blockObjectiveIndices=[modelObject.objectives];
            blockObjectives=obj.sldvData.Objectives(blockObjectiveIndices);

            if isfield(modelObject,'deadLogicIdx')
                blockDeadLogic=obj.sldvData.DeadLogic(modelObject.deadLogicIdx);
            else
                blockDeadLogic=[];
            end

            isBlkNameDescr=false;
            try
                blockName=getfullname(blockSid);
            catch MEx %#ok<NASGU>


                blockName=modelObject.descr;
                isBlkNameDescr=true;

            end
            if~isempty(blockObjectives)


                structuralObjectives=blockObjectives(...
                ~strcmp({blockObjectives(:).type},'Range'));
                rangeObjectives=obj.getRangeObjsOfModelObject(modelObject,blockName,isBlkNameDescr);
            end
            blockPath=modelObject.slPath;
            utils=Sldv.InspectorWorkflow.InspectorUtils;




            newBlockToDataMap=...
            blockDataObject.updateDataForBlock(...
            blockName,blockSid,blockPath,...
            mode,obj.model,structuralObjectives,...
            rangeObjectives,obj.mIsQuickDeadLogicAndPostAnalysisAndHasDeadLogic,...
            blockDeadLogic,obj.sldvData,...
            modelObject.descr,justifiedObjectives);
            if~isempty(newBlockToDataMap.keys)
                obj.blockToDataMap=utils.concatenateBlockDataMap(obj.blockToDataMap,...
                newBlockToDataMap);
            end
        end

        function updateReducedBlockInformation(obj)
            reducedBlocks=obj.sldvData.AnalysisInformation.ReducedBlocks;
            for reducedBlockIndex=1:length(reducedBlocks)
                blockSid=reducedBlocks(reducedBlockIndex).designSid;
                try
                    blockName=getfullname(blockSid);
                    reducedBlockData=Sldv.InspectorWorkflow.ReducedBlock(blockName,blockSid);
                    if~isKey(obj.blockToDataMap,blockSid)
                        obj.blockToDataMap(blockSid)=reducedBlockData;
                    end
                catch



                    continue;
                end

            end
        end



        function initializeUI(obj)
            informerContainer=DAStudio.Informer;
            informerContainer.position=[0,0,500,200];
            informerContainer.title=getString(message(...
            'Sldv:Informer:SimulinkDesignVerifierResultsInspector',...
            obj.sldvData.ModelInformation.Name));
            informerContainer.preCloseFcn=['sldvprivate(''closeModelView'', ''',obj.sldvData.ModelInformation.Name,''');'];

            obj.informer=informerContainer;
        end

        function populateUIData(obj)
            blocksReported=obj.blockToDataMap.keys;
            if~isempty(blocksReported)
                for idx=1:length(blocksReported)
                    sid=blocksReported{idx};
                    try
                        handle=Simulink.ID.getHandle(sid);
                        if isfloat(handle)
                            htmlString=obj.getPrintStringForBlock(sid);
                        elseif handle.isa('Stateflow.Object')
                            chartId=handle.Chart.Id;
                            if ismember(chartId,obj.multilinkChartIds)
                                sfId=handle.Id;
                                htmlString=obj.getPrintStringForMultilink(sfId);
                            else
                                htmlString=obj.getPrintStringForBlock(sid);
                            end
                        else
                        end

                        if~isempty(htmlString)
                            obj.informer.mapData(handle,htmlString);
                        end


                    catch
                        continue;
                    end

                end
            end
        end

        function updateSummary(obj,isModelHighlighted,justifiedObjs)





            summary=Sldv.InspectorWorkflow.InspectorUtils.getInformerSummary(...
            obj.sldvData,obj.resultFiles,isModelHighlighted,justifiedObjs);
            defaultT=['<div>',summary,'</div>'];
            obj.informer.buffer={defaultT};
            obj.informer.defaultText=defaultT;
        end














        function[blocks,charts]=machine_linked_charts(obj,machineId)%#ok<INUSL>
            blocks=sf('get',machineId,'.sfLinks');
            charts=zeros(size(blocks));

            for idx=1:length(blocks)
                charts(idx)=sf('Private','block2chart',blocks(idx));
            end
        end













        function chartIds=find_multi_instance_links(obj,modelName)

            chartIds=[];
            machineId=sf('find','all','machine.name',modelName);
            if~isempty(machineId)
                [~,linkCharts]=obj.machine_linked_charts(machineId);

                [count,uniqueElems]=groupcounts(linkCharts');
                chartIds=uniqueElems(count>1);
            end
        end

        function rangeObjectives=getRangeObjsOfModelObject(obj,modelObject,blockName,isBlkNameDescr)
            rangeObjectives=[];
            if isBlkNameDescr||~strcmp(get_param(blockName,'Type'),'block_diagram')




                blockObjectiveIndices=[modelObject.objectives];
                blockObjectives=obj.sldvData.Objectives(blockObjectiveIndices);
                rangeObjectives=blockObjectives(strcmp({blockObjectives(:).type},'Range'));
            end
        end
    end
end

