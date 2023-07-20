function[succeed,changedSystems,skippedSystems]=updateBlockOrder(execInfo)

    skippedSystems=struct('ParentSystem',{},'ViolationBlocks',{});
    changedSystems=struct('ParentSystem',{},'UpdatedBlocks',{});
    updatedBlocksCache=[];
    violationBlocksCache=[];

    for dsmIdx=1:numel(execInfo)
        dsmInfo=execInfo{dsmIdx};
        for taskIdx=1:numel(dsmInfo.TaskInfo)
            task=dsmInfo.TaskInfo(taskIdx);
            for scopedSysIdx=1:numel(task.ScopedSystemInfo)
                scopedSys=task.ScopedSystemInfo(scopedSysIdx);
                [fixed,changedSys,skippedSys]=doOneScopedSystem(scopedSys,updatedBlocksCache);

                if fixed

                    if~all(ismember(changedSys.UpdatedBlocks,updatedBlocksCache))
                        changedSystems(end+1)=changedSys;
                        updatedBlocksCache=[updatedBlocksCache,changedSys.UpdatedBlocks];
                    end
                else

                    if~all(ismember(skippedSys.ViolationBlocks,violationBlocksCache))
                        skippedSystems(end+1)=skippedSys;
                        violationBlocksCache=[violationBlocksCache,skippedSys.ViolationBlocks];
                    end
                end
            end
        end
    end

    succeed=isempty(skippedSystems);


    function[fixed,changedSystem,skippedSystem]=doOneScopedSystem(scopedSystem,updatedBlocksCache)

        fixed=false;
        changedSystem=struct('ParentSystem',{},'UpdatedBlocks',{});
        skippedSystem=struct('ParentSystem',{},'ViolationBlocks',{});


        violationBlocks=getSpecifiedPriorityBlocks(scopedSystem.ParentSystem,updatedBlocksCache);

        if~isempty(violationBlocks)
            skippedSystem(1).ParentSystem=scopedSystem.ParentSystem;
            skippedSystem(1).ViolationBlocks=violationBlocks;
            return;
        else
            fixed=true;

            updatedBlks=updateOneScopedSystem(scopedSystem);
            changedSystem(1).ParentSystem=scopedSystem.ParentSystem;
            changedSystem(1).UpdatedBlocks=updatedBlks;
        end


        function updatedBlks=updateOneScopedSystem(scopedSystem)
            updatedBlks=[];
            for sysIdx=1:numel(scopedSystem.ChildSystemInfo)
                childSys=scopedSystem.ChildSystemInfo(sysIdx);
                blkPriority=sprintf('%d',childSys.OldSortedOrder);
                set_param(childSys.SystemHandle,'Priority',blkPriority);
                updatedBlks(end+1)=childSys.SystemHandle;
            end


            function blockList=getSpecifiedPriorityBlocks(parentSS,updatedBlocksCache)




                blockList=[];

                allBlks=find_system(parentSS,'SearchDepth',1);
                allBlks=setdiff(allBlks,updatedBlocksCache);


                for idx=2:numel(allBlks)
                    blk=allBlks(idx);
                    if~isempty(get_param(blk,'Priority'))
                        blockList(end+1)=blk;
                    end
                end

