classdef MappingData<handle

    properties
ModelH
NumRegions
BlockCacheData
CriticalPathData
RegionCacheData
ModelNames
ModelPaths
TaskInfo
ModelUpdateListener
BlockListeners
BlockPathMap
CriticalPathCost
HasPipelineDelays
TaskInfoAvailable
CriticalPathInfoAvailable
SpeedupInfoAvailable
HasHierarchy
MultiTaskBlocks
CostMethod
MultithreadingThreshold
NumCores
Status
    end


    events
BlockRemovedEvent
TaskRemovedEvent
    end


    methods

        function obj=MappingData(modelH,costMethod)
            obj.ModelH=modelH;
            obj.NumRegions=0;
            obj.BlockPathMap=containers.Map('KeyType','double','ValueType','char');
            obj.BlockListeners=[];
            obj.HasPipelineDelays=false;
            obj.CostMethod=costMethod;

            modelObj=get_param(obj.ModelH,'Object');
            obj.ModelUpdateListener=Simulink.listener(modelObj,'EngineCompPassed',@(src,event)update(obj));

            clearMappingData(obj);
            obj.Status=multicoredesigner.internal.AnalysisPhase.Initial;
        end

        function[allMdls,modelBlocks,costMethod]=getAllModels(obj)

            if slfeature('SLMulticoreModelRef')==0
                allMdls={get(obj.ModelH,'Name')};
                modelBlocks=[];
            else
                [allMdls,modelBlocks]=find_mdlrefs(obj.ModelH,'LookUnderMasks','all','IncludeProtectedModels',true,...
                'IgnoreVariantErrors',true,'AllLevels',true,'KeepModelsLoaded',true);
            end
            topModelName=allMdls{end};
            mfModel=get_param(topModelName,'MulticoreDataModel');
            mc=slmulticore.MulticoreConfig.getMulticoreConfig(mfModel);
            costMethod=mc.costMethod;
        end

        function clearMappingData(obj)
            obj.RegionCacheData=[];
            obj.BlockCacheData=[];
            obj.CriticalPathData=[];
            obj.ModelNames=[];
            obj.ModelPaths=[];
            obj.NumRegions=0;
            obj.TaskInfo=[];
            obj.BlockPathMap.remove(obj.BlockPathMap.keys);
            obj.HasPipelineDelays=false;
            obj.HasHierarchy=false;
            obj.MultiTaskBlocks=[];
            obj.MultithreadingThreshold=0;
            obj.NumCores=0;
            for i=1:length(obj.BlockListeners)
                if ishandle(obj.BlockListeners{i})
                    delete(obj.BlockListeners{i});
                end
            end
            obj.BlockListeners=[];
        end


        function update(obj)

            [allMdls,modelBlocks,costMethod]=getAllModels(obj);

            if xor(obj.CostMethod==slmulticore.CostMethod.Simulation,costMethod==slmulticore.CostMethod.Simulation)
                return;
            end

            clearMappingData(obj);

            globalRegionIdx=1;
            numInitialTasks=0;
            for modelIdx=1:length(allMdls)
                numTasks=0;

                modelName=allMdls{end+1-modelIdx};
                modelPath=multicoredesigner.internal.MappingData.findModelPath(modelName,modelBlocks,allMdls{end});
                mfModel=get_param(modelName,'MulticoreDataModel');
                mc=slmulticore.MulticoreConfig.getMulticoreConfig(mfModel);
                if modelIdx==1
                    obj.CostMethod=mc.costMethod;
                    obj.MultithreadingThreshold=mc.constraint.threshold;
                    obj.NumCores=mc.constraint.numCores;
                end

                taskArray=mc.tasks.toArray;
                regionArray=mc.regions.toArray;
                criticalPathArray=mc.criticalPaths.toArray;

                numRegionsInModel=length(regionArray);
                if numRegionsInModel>0&&modelIdx~=1

                    obj.HasHierarchy=true;
                end

                for regionId=1:numRegionsInModel
                    regionInfoData=struct('ParentSystem',regionArray(regionId).parentSystem,...
                    'DisplayName',regionArray(regionId).displayName,...
                    'NumTasks',regionArray(regionId).numTasks,...
                    'Cost',regionArray(regionId).cost,...
                    'Share',regionArray(regionId).share,...
                    'DesignLatency',regionArray(regionId).designLatency,...
                    'OptimalLatency',regionArray(regionId).optimalLatency,...
                    'Compiled',regionArray(regionId).compiled,...
                    'IsSingleThread',regionArray(regionId).isSingleThread,...
                    'IsInsufficientWork',regionArray(regionId).isInsufficientWork,...
                    'TallPoleBlock',regionArray(regionId).tallPoleBlock,...
                    'TallPoleRatio',regionArray(regionId).tallPoleRatio);
                    obj.RegionCacheData{globalRegionIdx}=regionInfoData;

                    blockDataArr=[];
                    multiTaskBlocks=[];
                    multiTaskCandidate=containers.Map('KeyType','double','ValueType','any');
                    blocksMappedToTask=containers.Map('KeyType','double','ValueType','logical');

                    blocksInRegion=regionArray(regionId).blocks.toArray;
                    for j=1:length(blocksInRegion)
                        block=blocksInRegion(j);

                        if block.isHidden
                            continue;
                        end

                        hBlk=getSimulinkBlockHandle(block.path);
                        if hBlk==-1
                            continue
                        end

                        task=block.task;
                        if isempty(task)
                            uniqueTaskId=0;
                        else
                            uniqueTaskId=numInitialTasks+task.taskId;
                            if~isKey(blocksMappedToTask,task.taskId)
                                blocksMappedToTask(task.taskId)=true;
                            end
                        end


                        blockData=struct('Cost',block.cost,...
                        'Path',block.path,...
                        'PipelineStage',block.pipelineStage,...
                        'UserCost',block.userCost,...
                        'OverrideCostData',block.allowUserCost,...
                        'TaskId',uniqueTaskId,...
                        'Show',true);
                        if isKey(obj.BlockPathMap,hBlk)


                            if isKey(multiTaskCandidate,hBlk)&&multiTaskCandidate(hBlk)~=uniqueTaskId


                                multiTaskBlocks=[multiTaskBlocks,hBlk];
                                remove(multiTaskCandidate,hBlk);
                            end

                            blockData.Show=false;
                        else

                            obj.BlockPathMap(hBlk)=block.path;
                            obj.BlockListeners{end+1}=Simulink.listener(hBlk,'DeleteEvent',@(hSrc,hData)cbBlockDeleted(obj,hBlk,regionId,uniqueTaskId));
                            obj.BlockListeners{end+1}=Simulink.listener(hBlk,'NameChangeEvent',@(hSrc,hData)cbNameChanged(obj,hBlk));
                            multiTaskCandidate(hBlk)=uniqueTaskId;
                        end

                        blockDataArr=[blockDataArr,blockData];%#ok<AGROW>

                        if block.pipelineStage>1
                            obj.HasPipelineDelays=true;
                        end
                    end


                    regionNamesForTasks=arrayfun(@(x)(x.region.displayName),taskArray,'UniformOutput',false);
                    taskIndexes=find(strcmp(regionNamesForTasks,regionArray(regionId).displayName));


                    taskInfoArr=[];
                    for j=1:length(taskIndexes)
                        numTasks=numTasks+1;
                        uniqueTaskId=taskArray(taskIndexes(j)).taskId+numInitialTasks;
                        taskType='Periodic';
                        if isequal(taskArray(taskIndexes(j)).type,slmulticore.TaskType.Init)
                            taskType='Init';
                        elseif isequal(taskArray(taskIndexes(j)).type,slmulticore.TaskType.Terminate)
                            taskType='Terminate';
                        elseif isequal(taskArray(taskIndexes(j)).type,slmulticore.TaskType.Reset)
                            taskType='Reset';
                        end

                        if isKey(blocksMappedToTask,taskArray(taskIndexes(j)).taskId)
                            hasBlocks=true;
                        else
                            hasBlocks=false;
                        end

                        taskInfoData=struct('TaskId',uniqueTaskId,...
                        'TaskType',taskType,...
                        'HasBlocks',hasBlocks,...
                        'Cost',taskArray(taskIndexes(j)).cost);
                        taskInfoArr=[taskInfoArr,taskInfoData];%#ok<AGROW>
                    end

                    regionNamesForCriticalPaths=arrayfun(@(x)(x.region.displayName),criticalPathArray,'UniformOutput',false);
                    criticalPathIndex=find(strcmp(regionNamesForCriticalPaths,regionArray(regionId).displayName),1);
                    nodeDataArr=[];
                    if~isempty(criticalPathIndex)
                        nodesArr=criticalPathArray(criticalPathIndex).nodes.toArray;
                        for k=1:length(nodesArr)
                            portsArr=nodesArr(k).ports.toArray;
                            nodeData=struct('Block',nodesArr(k).block.path,'Ports',portsArr);
                            nodeDataArr=[nodeDataArr,nodeData];
                        end
                        obj.CriticalPathCost(regionId)=criticalPathArray(criticalPathIndex).cost;
                    else
                        obj.CriticalPathCost(regionId)=0;
                    end

                    obj.CriticalPathData{globalRegionIdx}=nodeDataArr;
                    obj.BlockCacheData{globalRegionIdx}=blockDataArr;
                    obj.TaskInfo{globalRegionIdx}=taskInfoArr;
                    obj.MultiTaskBlocks{globalRegionIdx}=multiTaskBlocks;


                    obj.ModelNames{globalRegionIdx}=modelName;
                    obj.ModelPaths{globalRegionIdx}=modelPath;
                    globalRegionIdx=globalRegionIdx+1;
                end
                obj.NumRegions=obj.NumRegions+numRegionsInModel;

                numInitialTasks=numInitialTasks+numTasks;
            end
        end

        function[blocks,ports]=getCriticalPath(obj,regionId)
            blocks=[];
            ports=[];
            nodes=obj.CriticalPathData{regionId};
            for i=1:length(nodes)
                hBlk=getSimulinkBlockHandle(nodes(i).Block);
                if hBlk==-1
                    continue
                end
                blocks(end+1)=hBlk;%#ok<AGROW>
                ports{end+1}=nodes(i).Ports;%#ok<AGROW>
            end
        end

        function blockInfos=getBlocksByTask(obj,regionId,taskId)
            blockInfos=[];
            if(regionId<=obj.NumRegions)&&(taskId<=obj.RegionCacheData{regionId}.NumTasks)
                blockDataArr=obj.BlockCacheData{regionId};
                if~isempty(blockDataArr)
                    uniqueTaskId=getUniqueIdForTask(obj,regionId,taskId);
                    blockArrIndexes=[blockDataArr.TaskId]==uniqueTaskId;
                    blockInfos=blockDataArr(blockArrIndexes);
                end
            end
        end

        function blockHandles=getMultiTaskBlocks(obj,regionId,taskId)
            blockHandles=[];
            if isempty(obj.MultiTaskBlocks{regionId})
                return
            end
            if(regionId<=obj.NumRegions)&&(taskId<=obj.RegionCacheData{regionId}.NumTasks)
                blockDataArr=obj.BlockCacheData{regionId};
                multiTaskBlockArr=obj.MultiTaskBlocks{regionId};
                uniqueTaskId=getUniqueIdForTask(obj,regionId,taskId);
                blockArrIndexes=[blockDataArr.TaskId]==uniqueTaskId;
                allMatchingBlocks=blockDataArr(blockArrIndexes);
                for i=1:length(multiTaskBlockArr)
                    path=getfullname(multiTaskBlockArr(i));
                    if any(arrayfun(@(x)strcmp(x.Path,path),allMatchingBlocks))
                        blockHandles=[blockHandles,multiTaskBlockArr(i)];
                    end
                end
            end
        end

        function isMulti=isBlockMultiTask(obj,regionId,blockPath)
            hdl=getSimulinkBlockHandle(blockPath);
            isMulti=any(obj.MultiTaskBlocks{regionId}==hdl);
        end

        function blockInfos=getBlocksByRegion(obj,regionId)
            blockInfos=[];
            if(regionId<=obj.NumRegions)
                blockDataArr=obj.BlockCacheData{regionId};
                for i=1:length(blockDataArr)
                    blockInfos=[blockInfos,blockDataArr(i)];%#ok<AGROW>
                end
            end
        end

        function ret=hasBlocksWithMultipleTasks(obj,regionId)
            ret=false;
            allParents=[];
            if(regionId<=obj.NumRegions)
                if~isempty(obj.MultiTaskBlocks{regionId})
                    ret=true;
                    return
                end

                numTasks=getNumTasksBySystem(obj,regionId);
                for j=1:numTasks
                    blockInfos=getBlocksByTask(obj,regionId,j);
                    blocks=arrayfun(@(x)(getSimulinkBlockHandle(x.Path)),blockInfos);
                    parents=obj.getAllVirtualAncestors(blocks(blocks~=-1));
                    if~isempty(allParents)&&~isempty(find(allParents==parents(:),1))
                        ret=true;
                        return;
                    end
                    allParents=[allParents,parents];
                end
            end
        end

        function numMapping=getNumMapping(obj)
            numMapping=obj.NumRegions;
        end

        function systemName=getParentSystemName(obj,regionId)
            systemName=obj.RegionCacheData{regionId}.ParentSystem;
        end

        function regionName=getRegionName(obj,regionId)
            regionName=obj.RegionCacheData{regionId}.DisplayName;
            modelName=obj.ModelNames{regionId};
            if obj.HasHierarchy&&~strcmp(modelName,regionName)
                regionName=[modelName,'/',regionName];
            end
        end

        function modelName=getModelName(obj,regionId)
            modelName=obj.ModelNames{regionId};
        end

        function modelName=getModelPath(obj,regionId)
            modelName=obj.ModelPaths{regionId};
        end

        function numTasks=getNumTasksBySystem(obj,regionId)
            if regionId>obj.NumRegions
                numTasks=0;
            else
                numTasks=obj.RegionCacheData{regionId}.NumTasks;
            end
        end

        function cost=getRegionCost(obj,regionId)
            cost=0;
            if regionId<=obj.NumRegions
                cost=obj.RegionCacheData{regionId}.Cost;
            end
        end

        function share=getRegionShare(obj,regionId)
            share=0;
            if regionId<=obj.NumRegions
                share=obj.RegionCacheData{regionId}.Share;
            end
        end


        function cost=getCriticalPathCost(obj,regionId)
            cost=0;
            if regionId<=obj.NumRegions
                cost=obj.CriticalPathCost(regionId);
            end
        end

        function cost=getMaxTaskCost(obj,regionId)
            cost=0;
            if regionId<=obj.NumRegions
                for i=1:obj.RegionCacheData{regionId}.NumTasks
                    cost=max(cost,obj.TaskInfo{regionId}(i).Cost);
                end
            end
        end

        function numTasks=getNumAllTasks(obj)
            numTasks=0;
            for i=1:obj.NumRegions
                numTasks=numTasks+obj.RegionCacheData{i}.NumTasks;
            end
        end

        function taskType=getTaskType(obj,regionId,taskId)
            taskType=obj.TaskInfo{regionId}(taskId).TaskType;
        end

        function uniqueId=getUniqueIdForTask(obj,regionId,taskId)
            uniqueId=obj.TaskInfo{regionId}(taskId).TaskId;
        end

        function relativeId=getRelativeIdForTask(obj,uniqueId)
            relativeId=-1;
            for i=1:obj.NumRegions
                numTasks=getNumTasksBySystem(obj,i);
                for j=1:numTasks
                    if getUniqueIdForTask(obj,i,j)==uniqueId
                        relativeId=j;
                        break;
                    end
                end
                if relativeId~=-1
                    break;
                end
            end
        end

        function cbNameChanged(obj,hBlk)
            oldPath=obj.BlockPathMap(hBlk);
            newPath=getfullname(hBlk);
            if~strcmp(oldPath,newPath)
                obj.BlockPathMap(hBlk)=newPath;
                mfModel=get_param(obj.ModelH,'MulticoreDataModel');
                mc=slmulticore.MulticoreConfig.getMulticoreConfig(mfModel);
                mcBlocks=mc.blocks.toArray;
                idx=find(strcmp({mcBlocks.path},regexprep(oldPath,'[\n\r]+',' ')),1);
                if~isempty(idx)
                    mcBlocks(idx).path=newPath;
                end
                update(obj);
            end
        end

        function cbBlockDeleted(obj,hBlk,regionId,taskId)
            if~is_simulink_handle(obj.ModelH)||...
                slInternal('isBDClosing',obj.ModelH)
                return
            end
            if isKey(obj.BlockPathMap,hBlk)
                obj.BlockPathMap.remove(hBlk);
            end

            blockDataArr=obj.BlockCacheData{regionId};
            path=regexprep(getfullname(hBlk),'[\n\r]+',' ');
            obj.BlockCacheData{regionId}=blockDataArr(arrayfun(@(x)~strcmp(x.Path,path),blockDataArr));
            notify(obj,'BlockRemovedEvent');

            blocksInTask=find(arrayfun(@(x)x.TaskId==taskId,obj.BlockCacheData{regionId}),1);
            if isempty(blocksInTask)&&taskId~=0
                notify(obj,'TaskRemovedEvent');
            end
        end

        function ret=get.TaskInfoAvailable(obj)
            ret=~isempty(obj.TaskInfo)&&~isempty([obj.TaskInfo{:}]);
        end

        function ret=get.CriticalPathInfoAvailable(obj)
            ret=~isempty(obj.CriticalPathData)&&~isempty([obj.CriticalPathData{:}]);
        end

        function ret=get.SpeedupInfoAvailable(obj)
            ret=~isempty(obj.CriticalPathCost)&&~isempty(find(obj.CriticalPathCost,1));
        end

        function ret=getCostMethod(obj)
            ret=obj.CostMethod;
        end

        function ret=getNumCores(obj)
            ret=obj.NumCores;
        end

        function ret=getMultithreadingThreshold(obj)
            ret=obj.MultithreadingThreshold;
        end

        function ret=getLatencySuggestion(obj,regionId)
            ret=[];
            if regionId<=obj.NumRegions&&...
                obj.RegionCacheData{regionId}.OptimalLatency~=...
                obj.RegionCacheData{regionId}.DesignLatency
                ret=obj.RegionCacheData{regionId}.OptimalLatency;
            end
        end

        function ret=isRegionAnalyzed(obj,regionId)
            ret=false;
            if regionId<=obj.NumRegions
                ret=obj.RegionCacheData{regionId}.Compiled;
            end
        end

        function ret=isRegionSingleThread(obj,regionId)
            ret=false;
            if regionId<=obj.NumRegions
                ret=obj.RegionCacheData{regionId}.IsSingleThread;
            end
        end

        function ret=isRegionInsufficientWork(obj,regionId)
            ret=false;
            if regionId<=obj.NumRegions
                ret=obj.RegionCacheData{regionId}.IsInsufficientWork;
            end
        end

        function[blockName,ratio]=getTallPoleData(obj,regionId)
            blockName='';
            ratio=0;
            if regionId<=obj.NumRegions
                blockName=obj.RegionCacheData{regionId}.TallPoleBlock;
                ratio=obj.RegionCacheData{regionId}.TallPoleRatio;
            end
        end
    end

    methods(Static)
        function subsystems=getAllVirtualAncestors(blocks)
            subsystems=[];
            visited=containers.Map('KeyType','double','ValueType','any');
            for i=1:length(blocks)
                cur=get_param(get(blocks(i),'Parent'),'Handle');
                while~strcmpi(get(cur,'Type'),'block_diagram')&&...
                    strcmp(get(cur,'IsSubsystemVirtual'),'on')&&...
                    ~isKey(visited,cur)
                    subsystems=[subsystems,get_param(cur,'Handle')];
                    visited(cur)=1;
                    cur=get_param(get(cur,'Parent'),'Handle');
                end
            end
        end

        function parent=getFirstNonVirtualParent(block)
            parent=get_param(block,'Parent');
            while~strcmpi(get_param(parent,'Type'),'block_diagram')&&...
                strcmp(get_param(parent,'IsSubsystemVirtual'),'on')
                parent=get_param(parent,'Parent');
            end
        end

        function[refMdls,modelBlocks]=updateDataModelHierarchy(modelH)
            if slfeature('SLMulticoreModelRef')==0
                refMdls={get(modelH,'Name')};
                modelBlocks=[];
            else
                [refMdls,modelBlocks]=find_mdlrefs(modelH,'LookUnderMasks','all','IncludeProtectedModels',true,...
                'MatchFilter',@Simulink.match.allVariants,...
                'IgnoreVariantErrors',true,'AllLevels',true,'KeepModelsLoaded',true);

                model=refMdls{end};
                mfModel=get_param(model,'MulticoreDataModel');
                mcTop=slmulticore.MulticoreConfig.getMulticoreConfig(mfModel);

                for i=1:length(modelBlocks)
                    refModelName=refMdls{i};


                    mfModel=get_param(refModelName,'MulticoreDataModel');
                    mcRef=slmulticore.MulticoreConfig.getMulticoreConfig(mfModel);
                    mcRef.constraint.threshold=mcTop.constraint.threshold;
                    mcRef.constraint.numCores=mcTop.constraint.numCores;
                    mcRef.constraint.enablePipelining=mcTop.constraint.enablePipelining;
                    mcRef.constraint.designLatency=mcTop.constraint.designLatency;
                end
            end
        end

        function modelPath=findModelPath(modelName,modelBlocks,topLevelModel)
            modelPath=[];
            if strcmp(modelName,topLevelModel)
                return
            end
            for i=1:length(modelBlocks)
                if strcmp(get_param(modelBlocks{i},'ModelName'),modelName)

                    parentModel=get_param(modelBlocks{i},'Parent');
                    modelPath=[multicoredesigner.internal.MappingData.findModelPath(parentModel,modelBlocks,topLevelModel),...
                    modelBlocks(i)];
                    return
                end
            end
        end
    end
end


