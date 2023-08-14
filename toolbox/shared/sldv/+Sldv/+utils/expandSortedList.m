function taskToSortedBlockHsMap=expandSortedList(mdlh,expandLib,expandMdlRef,skipSynth,aSkipConstInitTerm)









    if nargin<5
        aSkipConstInitTerm=false;
    end

    if nargin<4
        skipSynth=true;
    end

    if nargin<3
        expandMdlRef=true;
    end

    if nargin<2
        expandLib=false;
    end

    taskToSortedBlockHsMap=containers.Map('keyType','char','valueType','any');

    usingTaskBasedSorting=slfeature('TaskBasedSorting')>0;



    f=slfeature('EngineInterface',Simulink.EngineInterfaceVal.byFiat);
    c=onCleanup(@()slfeature('EngineInterface',f));
    obj=get_param(mdlh,'Object');
    currLvlTaskToSortedBlockHsMap=containers.Map('keyType','char','valueType','any');
    if usingTaskBasedSorting
        sortedInfo=obj.getSortedInfo;


        taskToSortedBlockInfoMap=getSortedBlocksForTaskBasedSorting(sortedInfo,aSkipConstInitTerm);

        tasks=taskToSortedBlockInfoMap.keys;
        for taskId=1:length(tasks)
            sortedBlocks=taskToSortedBlockInfoMap(tasks{taskId});
            currLvlBlockHs=zeros(size(sortedBlocks));
            for bIdx=1:length(sortedBlocks)
                currLvlBlockHs(bIdx)=sortedBlocks(bIdx).BlockHandle;
            end
            currLvlBlockHs=currLvlBlockHs(ishandle(currLvlBlockHs));
            currLvlTaskToSortedBlockHsMap(tasks{taskId})=currLvlBlockHs;
        end
    else
        sortedList=obj.getSortedList;
        currLvlTaskToSortedBlockHsMap('SortedOrderDefiningTasks')=sortedList(ishandle(sortedList));
    end



    taskToSortedBlockHsMapForChildren=containers.Map('keyType','double','valueType','any');
    tasks=currLvlTaskToSortedBlockHsMap.keys;
    for taskId=1:length(tasks)
        currLvlSortedBlockHs=currLvlTaskToSortedBlockHsMap(tasks{taskId});
        sortedBlockHs=[];

        for i=1:length(currLvlSortedBlockHs)
            sortedBlockHs(end+1)=currLvlSortedBlockHs(i);%#ok<*AGROW>get

            if strcmp(get_param(currLvlSortedBlockHs(i),'BlockType'),'SubSystem')&&...
                strcmp(get_param(currLvlSortedBlockHs(i),'TreatAsAtomicUnit'),'on')&&...
                ~slprivate('is_stateflow_based_block',currLvlSortedBlockHs(i))

                sysObj=get_param(currLvlSortedBlockHs(i),'Object');
                if sysObj.isSynthesized&&...
                    (strcmpi(sysObj.getSyntReason,'SL_SYNT_BLK_REASON_UNKNOWN')||...
                    strcmpi(sysObj.getSyntReason,'SL_SYNT_BLK_REASON_SWITCH_CEC_OPT')||...
                    sysObj.getAlgebraicLoopId)&&skipSynth


                    continue;
                end







                if(isempty(get_param(currLvlSortedBlockHs(i),'ReferenceBlock'))||expandLib)

                    libMdlH=currLvlSortedBlockHs(i);



                    if(taskToSortedBlockHsMapForChildren.isKey(libMdlH))
                        taskToSortedBlockHsMapForThisChild=taskToSortedBlockHsMapForChildren(libMdlH);
                    else
                        taskToSortedBlockHsMapForThisChild=Sldv.utils.expandSortedList(libMdlH,...
                        expandLib,expandMdlRef,skipSynth,aSkipConstInitTerm);
                        taskToSortedBlockHsMapForChildren(libMdlH)=taskToSortedBlockHsMapForThisChild;
                    end

                    if taskToSortedBlockHsMapForThisChild.isKey(tasks{taskId})
                        sortedBlockHs=[sortedBlockHs,taskToSortedBlockHsMapForThisChild(tasks{taskId})];
                    end

                end

            elseif(strcmp(get_param(currLvlSortedBlockHs(i),'BlockType'),'ModelReference')&&...
                expandMdlRef)

                mdlRefH=get_param(get_param(currLvlSortedBlockHs(i),'ModelName'),'handle');



                if(taskToSortedBlockHsMapForChildren.isKey(mdlRefH))
                    taskToSortedBlockHsMapForThisChild=taskToSortedBlockHsMapForChildren(mdlRefH);
                else
                    taskToSortedBlockHsMapForThisChild=Sldv.utils.expandSortedList(mdlRefH,expandLib,...
                    expandMdlRef,skipSynth,aSkipConstInitTerm);
                    taskToSortedBlockHsMapForChildren(mdlRefH)=taskToSortedBlockHsMapForThisChild;
                end

                if taskToSortedBlockHsMapForThisChild.isKey(tasks{taskId})
                    sortedBlockHs=[sortedBlockHs,taskToSortedBlockHsMapForThisChild(tasks{taskId})];
                end

            end

        end

        taskToSortedBlockHsMap(tasks{taskId})=sortedBlockHs;
    end

end









function taskToSortedBlockInfoMap=getSortedBlocksForTaskBasedSorting(aSortedInfo,aSkipConstInitTerm)
    taskToSortedBlockInfoMap=containers.Map('keyType','char','valueType','any');


    skippedTaskIndices=[];
    for i=1:length(aSortedInfo)
        currTask=aSortedInfo(i);
        if aSkipConstInitTerm&&isConstantInitOrTermTask(currTask)
            sortedBlocks=[];
            if taskToSortedBlockInfoMap.isKey(currTask.SampleTimes(1).Description)
                sortedBlocks=taskToSortedBlockInfoMap(currTask.SampleTimes(1).Description);
            end
            skippedTaskIndices(end+1)=i;
            sortedBlocks=cat(1,sortedBlocks,aSortedInfo(i).SortedBlocks);
            taskToSortedBlockInfoMap(currTask.SampleTimes(1).Description)=sortedBlocks;
        end
    end


    aSortedInfo(skippedTaskIndices)=[];


    sortedBlocks=[];
    for i=1:length(aSortedInfo)
        sortedBlocks=cat(1,sortedBlocks,aSortedInfo(i).SortedBlocks);
    end

    taskToSortedBlockInfoMap('SortedOrderDefiningTasks')=sortedBlocks;
end






function skipTask=isConstantInitOrTermTask(aCurrElement)



    currDescription=aCurrElement.SampleTimes(1).Description;











    isConstant=contains(currDescription,getString(message('Simulink:SampleTime:ConstantSampleTimeDescription')));

    isInitialize=contains(currDescription,getString(message('Simulink:SampleTime:PowerUpSampleTimeDescription')));

    isTerminate=contains(currDescription,getString(message('Simulink:SampleTime:PowerUpSampleTimeDescription')));

    skipTask=isConstant||isInitialize||isTerminate;
end
