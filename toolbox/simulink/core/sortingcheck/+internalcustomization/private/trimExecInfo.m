function retExecInfo=trimExecInfo(execInfo)






    retExecInfo=struct('DataStoreMemoryBlock',{},'DataStoreName',{},'TaskInfo',{});

    retDsmIdx=1;
    for dsmIdx=1:numel(execInfo)

        dsmInfo=execInfo{dsmIdx};

        retTaskIdx=1;
        for taskIdx=1:numel(dsmInfo.TaskInfo)
            task=dsmInfo.TaskInfo(taskIdx);

            if(task.TaskIndex==-3)

                continue;
            end

            retSysIdx=1;
            for scopedSysIdx=1:numel(task.ScopedSystemInfo)
                scopedSys=task.ScopedSystemInfo(scopedSysIdx);

                numChildSys=numel(scopedSys.ChildSystemInfo);

                if(numChildSys<=1)
                    continue;
                else

                    oldOrder=zeros(size(scopedSys.ChildSystemInfo));
                    for childSysIdx=1:numChildSys
                        oldOrder(childSysIdx)=scopedSys.ChildSystemInfo(childSysIdx).OldSortedOrder;
                    end


                    if issorted(oldOrder)
                        continue;
                    end
                end

                retExecInfo{retDsmIdx}.TaskInfo(retTaskIdx).ScopedSystemInfo(retSysIdx)=scopedSys;
                retSysIdx=retSysIdx+1;
            end

            if(retSysIdx>1)

                retExecInfo{retDsmIdx}.TaskInfo(retTaskIdx).TaskIndex=task.TaskIndex;
                retTaskIdx=retTaskIdx+1;
            end
        end

        if(retTaskIdx>1)

            retExecInfo{retDsmIdx}.DataStoreMemoryBlock=dsmInfo.DataStoreMemoryBlock;
            retExecInfo{retDsmIdx}.DataStoreName=dsmInfo.DataStoreName;
            retDsmIdx=retDsmIdx+1;
        end
    end
