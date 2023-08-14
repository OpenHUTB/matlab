function taskInfoArray=createTaskInfoData(system,tasks,accessorBlocks)









    taskInfoArray=struct('TaskIndex',{},'ScopedSystemInfo',{});

    for idx=1:numel(tasks)
        task=tasks(idx);
        taskInfoArray(idx).TaskIndex=task;
        taskInfoArray(idx).ScopedSystemInfo=createSystemInfoArrayForOneTaskRecursive(system,task,accessorBlocks);
    end


    function systemInfo=createSystemInfoArrayForOneTaskRecursive(systemList,task,accessorBlocks)



        systemInfo=struct('ParentSystem',{},'ChildSystemInfo',{});

        childSystems=[];

        for idx=1:numel(systemList)
            system=systemList(idx);
            oneInfo=createOneSystemInfo(system,task,accessorBlocks);

            if(isempty(oneInfo))

                continue;
            end

            for index=1:numel(oneInfo.ChildSystemInfo)
                childSystems(end+1)=oneInfo.ChildSystemInfo(index).SystemHandle;
            end
            systemInfo(end+1)=oneInfo;
        end

        if~isempty(childSystems)
            childInfo=createSystemInfoArrayForOneTaskRecursive(childSystems,task,accessorBlocks);
            for idx=1:numel(childInfo)
                systemInfo(end+1)=childInfo(idx);
            end
        end


        function systemInfo=createOneSystemInfo(system,task,accessorBlocks)




            systemInfo=struct('ParentSystem',{},'ChildSystemInfo',{});

            blockList=[];
            orderList=[];


            childAndParentSysBlks=find_system(system,'SearchDepth',1,'BlockType','SubSystem');
            childDSMReaderWriter=getChildDSMReaderWriter(system,accessorBlocks);


            childSubSyss=setdiff(childAndParentSysBlks,system);
            childSubSyssAndDSMs=[childSubSyss;childDSMReaderWriter'];

            if isempty(childSubSyssAndDSMs)
                return;
            end


            for index=1:numel(childSubSyssAndDSMs)
                sysBlk=childSubSyssAndDSMs(index);
                blkSortedInfo=get_param(sysBlk,'SortedOrder');
                for idx=1:numel(blkSortedInfo)
                    if(task==blkSortedInfo(idx).TaskIndex)
                        blockList(end+1)=get_param(sysBlk,'handle');
                        orderList(end+1)=blkSortedInfo(idx).BlockIndex;
                    end
                end
            end


            [sortedExecOrder,index]=sort(orderList);
            sortedBlockList=blockList(index);


            systemInfo(1).ParentSystem=system;
            systemInfo(1).ChildSystemInfo=createChildSystemInfo(sortedBlockList,sortedExecOrder);


            function childOrderArray=createChildSystemInfo(blocks,orders)






                childOrderArray=struct('SystemHandle',{},'NewSortedOrder',{},'OldSortedOrder',{});

                for idx=1:numel(blocks)
                    blk=blocks(idx);
                    order=orders(idx);
                    childOrderArray(idx).SystemHandle=blk;
                    childOrderArray(idx).NewSortedOrder=order;
                end


                function childDSMReaderWriter=getChildDSMReaderWriter(system,accessorBlocks)



                    childDSMReaderWriter=[];
                    for i=1:length(accessorBlocks)
                        if(get_param(get_param(accessorBlocks(i),'parent'),'handle')==get_param(system,'handle'))
                            childDSMReaderWriter(end+1)=accessorBlocks(i);
                        end
                    end