function fixSortedOrderForDSM(obj,replacementModelH)





    try
        isSlicerActive=~isempty(modelslicerprivate('slicerMapper','get',obj.MdlInfo.OrigModelH));
    catch
        isSlicerActive=false;
    end

    dsmInfo=[];
    if~isempty(obj.MdlInfo)&&~isempty(obj.MdlInfo.ModelRefBlkTree)
        dsmInfo=obj.MdlInfo.ModelRefBlkTree.DSMRWInformation;
    end

    if isSlicerActive||isempty(dsmInfo)||obj.MdlInlinerOnlyMode||...
        isempty(replacementModelH)||~ishandle(replacementModelH)||...
        replacementModelH==obj.MdlInfo.OrigModelH



        return;
    end

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>






    analysisInfo=sldvprivate('getDefaultAnalysisInfo',obj.MdlInfo.OrigModelH);
    analysisInfo.designModelH=obj.MdlInfo.OrigModelH;
    analysisInfo.analyzedModelH=replacementModelH;
    analysisInfo.extractedModelH=[];
    analysisInfo.analyzedSubsystemH=[];
    analysisInfo.replacementInfo.replacementsApplied=true;
    analysisInfo.replacementInfo.replacementModelH=replacementModelH;
    analysisInfo.replacementInfo.tempReplacement=~obj.BlockReplacementsEnforced;
    analysisInfo.replacementInfo.replacementTable=obj.ReplacedBlocksTable;
    analysisInfo.replacementInfo.notReplacedBlksTable=obj.NotReplacedBlocksTable;
    analysisInfo.replacementInfo.mdlsLoadedForMdlRefTree=obj.MdlInfo.MdlsLoadedForMdlRefTree;
    analysisInfo.analyzedAtomicSubchartWithParam=false;



    refMdls=find_mdlrefs(obj.MdlInfo.OrigModelH,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    refMdlH=get_param(refMdls,'handle');
    refMdlH=[refMdlH{:}];
    allMdlH=unique([obj.MdlInfo.OrigModelH,refMdlH]);



    origMdlSortedIdxMap=containers.Map('keytype','double','valuetype','any');

    origMdlH=obj.MdlInfo.OrigModelH;



    assert(strcmp(get_param(origMdlH,'SolverMode'),'SingleTasking')||...
    strcmp(get_param(origMdlH,'SampleTimeConstraint'),'STIndependent'));


    Sldv.xform.MdlInfo.compileBlkDiagram(origMdlH,false);
    cleanupOrig=onCleanup(@()terminateBlockDiagram(origMdlH));

    for i=1:length(allMdlH)
        taskToSortedBlockHsMap=Sldv.utils.expandSortedList(allMdlH(i),true,false,true,true);
        tasks=taskToSortedBlockHsMap.keys;
        taskSortedOrderMap=containers.Map('keyType','char','valueType','any');
        for taskId=1:length(tasks)
            sortedOrderMap=containers.Map(taskToSortedBlockHsMap(tasks{taskId}),1:length(taskToSortedBlockHsMap(tasks{taskId})));
            taskSortedOrderMap(tasks{taskId})=sortedOrderMap;
        end
        origMdlSortedIdxMap(allMdlH(i))=taskSortedOrderMap;
    end
    delete(cleanupOrig);


    assert(strcmp(get_param(replacementModelH,'SolverMode'),'SingleTasking')||...
    strcmp(get_param(replacementModelH,'SampleTimeConstraint'),'STIndependent'));

    Sldv.xform.MdlInfo.compileBlkDiagram(replacementModelH,false);
    cleanupReplacement=onCleanup(@()terminateBlockDiagram(replacementModelH));
    repMdlTaskToSortedBlockHsMap=Sldv.utils.expandSortedList(replacementModelH,true,false,true,true);


    delete(cleanupReplacement);

    repMdlTaskSortedOrderMap=containers.Map('keytype','double','valuetype','double');
    repMdlDiscreteTaskSortedBlockHs=repMdlTaskToSortedBlockHsMap('SortedOrderDefiningTasks');
    for i=1:length(repMdlDiscreteTaskSortedBlockHs)
        try
            blkH=repMdlDiscreteTaskSortedBlockHs(i);
            if~isPriorityValid(blkH)
                continue;
            end
            origH=Sldv.DataUtils.mapReplacementObject(blkH,analysisInfo.designModelH,analysisInfo);
            if isempty(origH)
                continue;
            end
            bdH=get_param(bdroot(origH),'handle');
            taskSortedOrderMap=origMdlSortedIdxMap(bdH);
            sMap=taskSortedOrderMap('SortedOrderDefiningTasks');
            idx=sMap(origH);

            set_param(blkH,'Priority',num2str(idx));
            repMdlTaskSortedOrderMap(blkH)=idx;
        catch MEx

            continue;
        end
    end

    priority=repMdlTaskSortedOrderMap.values;
    [priority,idx]=sort([priority{:}]);
    repMdlDiscreteTaskSortedBlockHs=repMdlTaskSortedOrderMap.keys;

    repMdlDiscreteTaskSortedBlockHs=[repMdlDiscreteTaskSortedBlockHs{idx}];


    fixVirtualSubsysPriorities(repMdlDiscreteTaskSortedBlockHs,priority);

    [isBlockSortedOrderValid,taskFailedForSortedOrder]=...
    validateSortedOrder(repMdlTaskToSortedBlockHsMap,origMdlSortedIdxMap,repMdlTaskSortedOrderMap,analysisInfo);

    if~isBlockSortedOrderValid
        error(message('Sldv:xform:BlkReplacer:BlkReplacer:FailedToHonourBlockSortedOrderForTask',taskFailedForSortedOrder));
    end

    save_system(replacementModelH);
end

function[isBlockSortedOrderValid,taskFailedForSortedOrder]=...
    validateSortedOrder(repMdlTaskToSortedBlockHsMap,origMdlSortedIdxMap,repMdlTaskSortedOrderMap,analysisInfo)







    isBlockSortedOrderValid=true;
    taskFailedForSortedOrder='';

    repMdlTaskSortedValidBlockHs=containers.Map('keyType','char','valueType','any');
    tasks=repMdlTaskToSortedBlockHsMap.keys;
    for taskId=1:length(tasks)
        sampleTimeDescrForConstants=...
        getString(message('Simulink:SampleTime:ConstantSampleTimeDescription'));
        if strcmp('SortedOrderDefiningTasks',tasks{taskId})||...
            strcmp(sampleTimeDescrForConstants,tasks{taskId})
            continue;
        end
        repMdlSortedBlockHs=repMdlTaskToSortedBlockHsMap(tasks{taskId});

        invalidBlkIndices=[];
        for currBlkIdx=1:length(repMdlSortedBlockHs)
            repMdlCurrBlkH=repMdlSortedBlockHs(currBlkIdx);

            if~ishandle(repMdlCurrBlkH)
                invalidBlkIndices(end+1)=currBlkIdx;
                continue;
            end

            if~isPriorityValid(repMdlCurrBlkH)
                invalidBlkIndices(end+1)=currBlkIdx;
                continue;
            end
        end

        repMdlSortedBlockHs(invalidBlkIndices)=[];

        repMdlTaskSortedValidBlockHs(tasks{taskId})=repMdlSortedBlockHs;
    end

    tasks=repMdlTaskSortedValidBlockHs.keys;
    for taskId=1:length(tasks)
        repMdlSortedBlockHs=repMdlTaskSortedValidBlockHs(tasks{taskId});
        for currBlkIdx=1:(length(repMdlSortedBlockHs)-1)

            repMdlCurrBlkH=repMdlSortedBlockHs(currBlkIdx);
            repMdlNextBlkH=repMdlSortedBlockHs(currBlkIdx+1);

            origMdlCurrBlkH=Sldv.DataUtils.mapReplacementObject(repMdlCurrBlkH,analysisInfo.designModelH,analysisInfo);
            origMdlNextBlkH=Sldv.DataUtils.mapReplacementObject(repMdlNextBlkH,analysisInfo.designModelH,analysisInfo);

            if isempty(origMdlCurrBlkH)||isempty(origMdlNextBlkH)
                continue;
            end

            origBdH=get_param(bdroot(origMdlCurrBlkH),'handle');
            taskSortedOrderMap=origMdlSortedIdxMap(origBdH);
            sMap=taskSortedOrderMap(tasks{taskId});

            if sMap.isKey(origMdlCurrBlkH)&&...
                sMap.isKey(origMdlNextBlkH)&&...
                repMdlTaskSortedOrderMap.isKey(repMdlCurrBlkH)&&...
                repMdlTaskSortedOrderMap.isKey(repMdlNextBlkH)

                origMdlCurrBlkPriority=sMap(origMdlCurrBlkH);
                origMdlNextBlkPriority=sMap(origMdlNextBlkH);

                repMdlCurrBlkPriority=repMdlTaskSortedOrderMap(repMdlCurrBlkH);
                repMdlNextBlkPriority=repMdlTaskSortedOrderMap(repMdlNextBlkH);

                if((origMdlCurrBlkPriority<origMdlNextBlkPriority)&&(repMdlCurrBlkPriority>repMdlNextBlkPriority))||...
                    ((origMdlCurrBlkPriority>origMdlNextBlkPriority)&&(repMdlCurrBlkPriority<repMdlNextBlkPriority))

                    isBlockSortedOrderValid=false;
                    taskFailedForSortedOrder=tasks{taskId};
                    break;
                end
            end
        end
    end
end

function fixVirtualSubsysPriorities(blkH,priority)



    VirtSubsysMap=containers.Map('keytype','double','ValueType','any');
    for i=1:length(blkH)
        parentH=get_param(get_param(blkH(i),'parent'),'handle');




        while~strcmp(get_param(parentH,'type'),'block_diagram')

            if strcmp(get_param(parentH,'IsSubsystemVirtual'),'on')
                if VirtSubsysMap.isKey(parentH)
                    val=VirtSubsysMap(parentH);
                    minp=val(1);
                    maxp=val(2);
                    if(maxp~=0)
                        if(priority(i)~=maxp+1)
                            maxp=0;
                        else
                            maxp=priority(i);
                        end
                        VirtSubsysMap(parentH)=[minp,maxp];
                    end
                else



                    VirtSubsysMap(parentH)=[priority(i),priority(i)];
                end
            else

                break;
            end

            parentH=get_param(get_param(parentH,'parent'),'handle');
        end
    end
    vSubsys=keys(VirtSubsysMap);
    for i=1:length(vSubsys)
        val=VirtSubsysMap(vSubsys{i});
        p=val(1);
        valid=val(2);
        if valid
            vSubsysH=vSubsys{i};
            set_param(vSubsysH,'Priority',num2str(p));
        end
    end
end

function yesno=isPriorityValid(blockH)
    yesno=true;
    bType=get_param(blockH,'blocktype');
    if~strcmpi(bType,'SubSystem')
        if strcmp(get(blockH,'Virtual'),'on')
            if strcmp(bType,'Outport')
                yesno=(get_param(get_param(blockH,'parent'),'handle')==bdroot(blockH));
                return;
            end

            yesno=false;
        end
    else

        [~,~,ssTriggerBlkH]=Sldv.utils.getSubSystemPortBlks(blockH);
        if~isempty(ssTriggerBlkH)
            yesno=~strcmpi(get_param(ssTriggerBlkH,'TriggerType'),'fcn-call');
        end
    end
end

function terminateBlockDiagram(aModel)
    Sldv.xform.MdlInfo.termBlkDiagram(aModel,true);


    Sldv.utils.switchObsMdlsToStandaloneMode(aModel);
end
