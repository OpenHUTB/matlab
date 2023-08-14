classdef MulticoreDesignerContext<dig.CustomContext





    properties
        NumCores;
        Threshold;
        EnablePipelining;
        DesignLatency;
        ModelH;
    end

    properties(SetObservable=true)
        Mode;
        ProfilingMode;
        IsHighlightingOn;
        IsCriticalPathHighlightingOn;
        IsPipeliningAnnotationOn;
        AnalysisButtonRefresh;
        ProfilingModeEnabled;
        SilPilProfilingModeEnabled;
        SimulationProfilingModeEnabled;
        IsCostValid;
        AnalysisEnabled;
        ThresholdLabel;
        RefreshTrigger;
    end

    properties(Access=private)
        DataModelListener;
        CostRestored;
        AnalysisRestored;
        Status=multicoredesigner.internal.AnalysisPhase.Initial;
        InitRTWDataModelFromMat;
    end

    properties(Constant)
        DefaultNumCores=0;
        DefaultThreshold=25;
    end

    methods
        function obj=MulticoreDesignerContext(app,modelH)
            obj@dig.CustomContext(app);
            obj.ModelH=modelH;
            obj.Mode='SimulationProfiling';
            obj.ProfilingMode='software';
            obj.IsHighlightingOn=false;
            obj.ProfilingModeEnabled=true;
            obj.SilPilProfilingModeEnabled=false;
            obj.SimulationProfilingModeEnabled=true;
            obj.IsCostValid=false;
            obj.AnalysisEnabled=true;
            obj.IsPipeliningAnnotationOn=false;
            obj.InitRTWDataModelFromMat=false;
            obj.ThresholdLabel=getString(message('dataflow:Toolstrip:SetThresholdTextus'));
            obj.RefreshTrigger=false;

            mfModel=get_param(modelH,'MulticoreDataModel');
            mc=slmulticore.MulticoreConfig.getMulticoreConfig(mfModel);
            obj.NumCores=mc.constraint.numCores;
            if mc.constraint.autoNumCores
                obj.NumCores='';
            else
                obj.NumCores=mc.constraint.numCores;
            end
            if mc.constraint.autoThreshold
                obj.Threshold='';
            else
                obj.Threshold=mc.constraint.threshold;
            end
            obj.EnablePipelining=mc.constraint.enablePipelining;
            obj.DesignLatency=mc.constraint.designLatency;

            obj.TypeChain={app.defaultContextType};
            if slfeature('SLMulticore')>0
                if obj.EnablePipelining

                    obj.TypeChain{end+1}='multicoreDesignerPipeliningEnabledContext';
                else

                    obj.TypeChain{end+1}='multicoreDesignerPipeliningDisabledContext';
                end
            end

            mfModel.addObservingListener(@(report)obj.dataModelUpdated(report));
        end

        function notifyResultGalley(obj)
            obj.RefreshTrigger=~obj.RefreshTrigger;
        end

        function updatePipeliningContext(obj)
            if obj.EnablePipelining
                obj.TypeChain{2}='multicoreDesignerPipeliningEnabledContext';
            else
                obj.TypeChain{2}='multicoreDesignerPipeliningDisabledContext';
            end
        end

        function setIsCostValid(obj,newVal)
            if obj.IsCostValid~=newVal
                obj.IsCostValid=newVal;
            end
            updateAnalysisEnabled(obj);
        end

        function updateAnalysisEnabled(obj)
            obj.AnalysisEnabled=obj.SimulationProfilingModeEnabled|obj.IsCostValid;
        end

        function setMode(obj,mode)
            if(~strcmpi(obj.Mode,mode))
                obj.Mode=mode;


                appMgr=multicoredesigner.internal.UIManager.getInstance();
                if isPerspectiveEnabled(appMgr,obj.ModelH)
                    uiObj=getMulticoreUI(appMgr,obj.ModelH);


                    uiObj.setMode(obj.Mode);

                    obj.Status=uiObj.MappingData.Status;


                    if((obj.Status==multicoredesigner.internal.AnalysisPhase.Initial)&&~strcmpi(obj.Mode,'SimulationProfiling')&&~obj.InitRTWDataModelFromMat)



                        obj.Status=multicoredesigner.internal.AnalysisPhase.Analyzing;
                        [obj.CostRestored,obj.AnalysisRestored]=restoreDataModelFromDFCache(obj);
                        obj.InitRTWDataModelFromMat=true;
                        if obj.AnalysisRestored


                            setStatus(obj,multicoredesigner.internal.AnalysisPhase.CostComplete);
                        elseif obj.CostRestored
                            setStatus(obj,multicoredesigner.internal.AnalysisPhase.CostComplete);
                        end
                    end


                    updateAnalysisResults(uiObj);
                end
            end

            if strcmp(mode,'SILPILProfiling')
                obj.ProfilingModeEnabled=true;
                obj.SilPilProfilingModeEnabled=true;
                obj.SimulationProfilingModeEnabled=false;
                obj.ThresholdLabel=getString(message('dataflow:Toolstrip:SetThresholdTextus'));
            elseif strcmp(mode,'SimulationProfiling')
                obj.SimulationProfilingModeEnabled=true;
                obj.ProfilingModeEnabled=true;
                obj.SilPilProfilingModeEnabled=false;
                obj.ThresholdLabel=getString(message('dataflow:Toolstrip:SetThresholdTextus'));
            else
                obj.ProfilingModeEnabled=false;
                obj.SilPilProfilingModeEnabled=false;
                obj.SimulationProfilingModeEnabled=false;
                obj.ThresholdLabel=getString(message('dataflow:Toolstrip:SetThresholdTextcu'));
            end

            refreshCostValidStatus(obj);
            updateAnalysisEnabled(obj);
        end

        function setProfilingMode(obj,mode)
            obj.ProfilingMode=mode;
        end

        function setNumCores(~,newVal,modelH)
            mfModel=get_param(modelH,'MulticoreDataModel');
            mc=slmulticore.MulticoreConfig.getMulticoreConfig(mfModel);
            if isempty(newVal)
                mc.constraint.autoNumCores=true;
                mc.constraint.numCores=multicoredesigner.internal.MulticoreDesignerContext.DefaultNumCores;
            else
                mc.constraint.autoNumCores=false;
                mc.constraint.numCores=newVal;
            end
        end

        function setThreshold(~,newVal,modelH)
            mfModel=get_param(modelH,'MulticoreDataModel');
            mc=slmulticore.MulticoreConfig.getMulticoreConfig(mfModel);
            if isempty(newVal)
                mc.constraint.autoThreshold=true;
                mc.constraint.threshold=multicoredesigner.internal.MulticoreDesignerContext.DefaultThreshold;
            else
                mc.constraint.autoThreshold=false;
                mc.constraint.threshold=newVal;
            end
        end

        function enablePipelining(obj,newVal,modelH)
            obj.EnablePipelining=newVal;
            mfModel=get_param(modelH,'MulticoreDataModel');
            mc=slmulticore.MulticoreConfig.getMulticoreConfig(mfModel);
            mc.constraint.enablePipelining=newVal;
            updatePipeliningContext(obj);
        end

        function setDesignLatency(obj,newVal,modelH)
            obj.DesignLatency=newVal;
            mfModel=get_param(modelH,'MulticoreDataModel');
            mc=slmulticore.MulticoreConfig.getMulticoreConfig(mfModel);
            mc.constraint.designLatency=newVal;
        end

        function refreshCostValidStatus(obj)
            valid=true;
            if slsvTestingHook('SLMCGlobalCostOverride')>0
                setIsCostValid(obj,true);
                return
            end
            if slfeature('SLMulticoreModelRef')==0
                refMdls={get(obj.ModelH,'Name')};
            else
                [refMdls,~]=find_mdlrefs(obj.ModelH,'LookUnderMasks','all','IncludeProtectedModels',true,...
                'IncludeCommented','on','IgnoreVariantErrors',1,'MatchFilter',@Simulink.match.allVariants,'AllLevels',true);
            end
            noData=true;
            for i=1:length(refMdls)
                load_system(refMdls{i});
                mfModel=get_param(get_param(refMdls{i},'Handle'),'MulticoreDataModel');
                mc=slmulticore.MulticoreConfig.getMulticoreConfig(mfModel);



                if xor(strcmpi(obj.Mode,'SimulationProfiling'),mc.costMethod==slmulticore.CostMethod.Simulation)
                    valid=false;
                    break
                end

                regions=mc.regions.toArray;
                for j=1:length(regions)
                    if~regions(j).compiled
                        valid=false;
                        break
                    end
                    blocks=regions(j).blocks.toArray;
                    if~isempty(blocks)
                        noData=false;
                        for b=blocks
                            if(b.allowUserCost==0&&b.cost==intmax('uint64'))||...
                                (b.allowUserCost==1&&b.userCost==intmax('uint64'))
                                valid=false;
                                break
                            end
                        end
                    end
                end
                if~valid
                    break
                end
            end
            if noData
                valid=false;
            end

            setIsCostValid(obj,valid);
        end

        function tf=isHighlightingOn(obj)
            tf=obj.IsHighlightingOn;
        end
        function tf=isCriticalPathHighlightingOn(obj)
            tf=obj.IsCriticalPathHighlightingOn;
        end

        function notifyHighlightingChange(obj,src,evt)
            if strcmp(evt.EventName,'HighlightingOnEvent')
                tf=true;
            else
                tf=false;
            end
            if isa(src,'multicoredesigner.internal.TaskHighlighter')
                obj.IsHighlightingOn=tf;
            else
                obj.IsCriticalPathHighlightingOn=tf;
            end
        end

        function status=isPreviousDataAvailable(obj)
            status=obj.PreviousDataAvailable;
        end

        function costRestored=isCostRestored(obj)
            costRestored=obj.CostRestored;
        end

        function analysisRestored=isAnalysisRestored(obj)
            analysisRestored=obj.AnalysisRestored;
        end

        function status=getStatus(obj)
            status=obj.Status;
        end

        function setStatus(obj,status)
            obj.Status=status;

            appMgr=multicoredesigner.internal.UIManager.getInstance();
            if isPerspectiveEnabled(appMgr,obj.ModelH)
                uiObj=getMulticoreUI(appMgr,obj.ModelH);
                uiObj.MappingData.Status=status;
            end
        end

    end

    methods(Access=private)

        function[costComplete,analysisComplete]=restoreDataModelFromDFCache(obj)
            costComplete=true;
            analysisComplete=true;

            if slfeature('SLMulticoreModelRef')==0
                refMdls={get(obj.ModelH,'Name')};
            else
                [refMdls,~]=find_mdlrefs(obj.ModelH,'LookUnderMasks','all','IncludeProtectedModels',true,...
                'MatchFilter',@Simulink.match.allVariants,...
                'IgnoreVariantErrors',true,'AllLevels',true,'KeepModelsLoaded',true);
            end

            for mdl=1:length(refMdls)
                modelName=refMdls{mdl};

                mfModel=get_param(modelName,'MulticoreDataModel');
                mc=slmulticore.MulticoreConfig.getMulticoreConfig(mfModel);

                mcBlocks=mc.blocks.toArray;
                if(~isempty(mcBlocks)&&(mc.costMethod~=slmulticore.CostMethod.Simulation))






                    analysisComplete=false;
                else

                    cachePath=dfs.getMappingCacheFilePath(modelName,'rtw',false);
                    matFilePath=fullfile(cachePath,[modelName,'_DFCache.mat']);
                    if exist(matFilePath,'file')~=2
                        costComplete=false;
                        analysisComplete=false;
                        break
                    else

                        blocksInDataModelMap=containers.Map('KeyType','char','ValueType','any');
                        regionsInDataModelMap=containers.Map('KeyType','char','ValueType','any');
                        cacheStruct=load(matFilePath,'-regexp','^c\w+');
                        vars=fields(cacheStruct);
                        numRegionsInCache=length(vars);




                        mcRegions=mc.regions.toArray;
                        for i=1:length(mcRegions)
                            regionsInDataModelMap(mcRegions(i).parentSystem)=struct('CostValid',false,...
                            'AnalysisValid',false,...
                            'Region',mcRegions(i));
                        end

                        for i=1:numRegionsInCache
                            regionFoundInDataModel=false;
                            regionInfo=[];
                            dfSubsystemPath='';
                            costStruct=cacheStruct.(vars{i});

                            if~bitget(costStruct.Attributes,9)
                                continue
                            end


                            mc.blocks.clear();
                            mc.regions(i).blocks.clear();
                            mc.tasks(i).blocks.clear();
                            mc.costMethod=slmulticore.CostMethod.User;

                            blocks=costStruct.Blocks;
                            for j=1:length(blocks)
                                hBlk=getSimulinkBlockHandle(blocks(j).Name);
                                if hBlk==-1
                                    continue;
                                end

                                if~regionFoundInDataModel
                                    dfSubsystemPath=multicoredesigner.internal.MappingData.getFirstNonVirtualParent(blocks(j).Name);
                                    if~isKey(regionsInDataModelMap,dfSubsystemPath)

                                        break
                                    end
                                    regionFoundInDataModel=true;
                                    regionInfo=regionsInDataModelMap(dfSubsystemPath);

                                    sep=strfind(dfSubsystemPath,'/');
                                    regionInfo.Region.displayName=dfSubsystemPath(sep+1:end);
                                    regionInfo.Region.compiled=true;
                                end



                                block=slmulticore.Block(mfModel);
                                block.path=blocks(j).Name;
                                block.compPath=blocks(j).Name;
                                block.cost=blocks(j).Cost;
                                mc.blocks.add(block);
                                blocksInDataModelMap(blocks(j).Name)=block;
                                block.region=regionInfo.Region;
                            end
                            if~isempty(regionInfo)
                                regionInfo.CostValid=true;
                                regionsInDataModelMap(dfSubsystemPath)=regionInfo;
                            end
                        end


                        latenciesValid=true;
                        latencyVec=[];
                        taskMap=containers.Map('KeyType','double','ValueType','any');
                        cacheStruct=load(matFilePath,'-regexp','^m\w+');
                        vars=fields(cacheStruct);
                        for i=1:numRegionsInCache
                            regionFoundInDataModel=false;
                            regionInfo=[];
                            dfSubsystemPath='';

                            taskStruct=cacheStruct.(vars{i});

                            if~bitget(taskStruct.Attributes,4)
                                continue
                            end

                            blocks=taskStruct.Blocks;
                            for j=1:length(blocks)
                                if~isKey(blocksInDataModelMap,blocks(j).Name)
                                    continue
                                end
                                block=blocksInDataModelMap(blocks(j).Name);

                                if~regionFoundInDataModel
                                    dfSubsystemPath=multicoredesigner.internal.MappingData.getFirstNonVirtualParent(blocks(j).Name);

                                    if~isKey(regionsInDataModelMap,dfSubsystemPath)

                                        break
                                    end
                                    regionFoundInDataModel=true;
                                    regionInfo=regionsInDataModelMap(dfSubsystemPath);
                                end


                                if latenciesValid
                                    ph=get_param(blocks(j).Name,'PortHandles');
                                    for k=1:size(blocks(j).Latencies,1)
                                        idx=blocks(j).Latencies(k,1)+1;
                                        if idx>length(ph.Inport)
                                            latenciesValid=false;
                                            break;
                                        end
                                        portHandle=ph.Inport(idx);
                                        latency=blocks(j).Latencies(k,2);
                                        latencyVec=[latencyVec,struct('portHandle',portHandle,...
                                        'latency',latency)];
                                    end

                                end

                                if~taskMap.isKey(blocks(j).ThreadID)

                                    task=slmulticore.Task(mfModel);
                                    task.taskId=blocks(j).ThreadID;
                                    task.name=['Task',num2str(blocks(j).ThreadID)];
                                    task.region=block.region;
                                    taskMap(blocks(j).ThreadID)=task;
                                    mc.tasks.add(task);
                                else
                                    task=taskMap(blocks(j).ThreadID);
                                end
                                block.task=task;
                                block.pipelineStage=blocks(j).PipelineStage;
                                task.blocks.add(block);
                            end
                            if~isempty(regionInfo)
                                regionInfo.AnalysisValid=true;
                                regionsInDataModelMap(dfSubsystemPath)=regionInfo;
                            end
                        end

                        if latenciesValid
                            dataflowUI=get_param(modelName,'DataflowUI');
                            if~isempty(dataflowUI)&&~isempty(latencyVec)
                                dataflowUI.setLatencyPortAnnotations(latencyVec);
                            end
                        end

                        keys=regionsInDataModelMap.keys;
                        for i=1:length(keys)
                            if~regionsInDataModelMap(keys{i}).CostValid
                                costComplete=false;
                                analysisComplete=false;
                                break
                            end
                            if~regionsInDataModelMap(keys{i}).AnalysisValid
                                analysisComplete=false;
                            end
                        end
                    end
                end
            end
        end

        function dataModelUpdated(obj,report)
            if obj.Status==multicoredesigner.internal.AnalysisPhase.Analyzing
                return
            end

            blockCostChanged=false;
            regionDeleted=false;
            regionCreated=false;


            if~isempty(report.Modified)
                for i=1:length(report.Modified)
                    el=report.Modified(i).Element;
                    if isa(el,'slmulticore.Constraints')
                        if report.Modified(i).Element.autoNumCores
                            obj.NumCores='';
                        else
                            obj.NumCores=num2str(el.numCores);
                        end
                        if report.Modified(i).Element.autoThreshold
                            obj.Threshold='';
                        else
                            obj.Threshold=num2str(el.threshold);
                        end
                    elseif isa(report.Modified.Element,'slmulticore.Block')
                        blockCostChanged=true;
                    end
                end
            end


            if~isempty(report.Created)
                for j=1:length(report.Created)
                    if isa(report.Created(j),'slmulticore.Region')
                        regionCreated=true;
                        break
                    end
                end
            end

            if~isempty(report.Destroyed)
                for j=1:length(report.Destroyed)
                    if strcmp(report.Destroyed(j).MetaClass.qualifiedName,'slmulticore.Region')
                        regionDeleted=true;
                        break
                    end
                end
            end


            if regionDeleted||regionCreated||blockCostChanged

                appMgr=multicoredesigner.internal.UIManager.getInstance();
                if isPerspectiveEnabled(appMgr,obj.ModelH)
                    uiObj=getMulticoreUI(appMgr,obj.ModelH);

                    if obj.Status==multicoredesigner.internal.AnalysisPhase.AnalysisComplete
                        obj.Status=multicoredesigner.internal.AnalysisPhase.CostComplete;
                    end
                    updateAnalysisResults(uiObj);
                    refreshCostValidStatus(obj);
                end
            end
        end
    end
end




