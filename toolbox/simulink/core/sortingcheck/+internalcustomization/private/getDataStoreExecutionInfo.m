function execInfo=getDataStoreExecutionInfo(system,prevResult,type)








    model=bdroot(system);




    origWarn=warning('off');
    cl1=onCleanup(@()warning(origWarn));


    origFeature=slfeature('TaskBasedSorting',4);
    cl2=onCleanup(@()slfeature('TaskBasedSorting',origFeature));

    load_system(model);

    firstTime=isempty(prevResult);

    if(firstTime||strcmp(type,'SIMRTW'))

        execInfo=getTrimedExecInfo(model,type);
    else



        execInfo=updateOrder(model,prevResult);
    end


    function execInfo=getTrimedExecInfo(model,type)
        switch type
        case "FEATUREONOFF"

            execInfo=featureOn(model);


            execInfo=featureOff(model,execInfo);


            execInfo=trimExecInfo(execInfo);
        case "SIMRTW"

            execInfo=simExecInfo(model);


            execInfo=rtwExecInfo(model,execInfo);


            execInfo=trimExecInfo(execInfo);
        otherwise
            assert(false,'Unknown execution order comparison type')

        end


        function passed=checkModelSortedInfo(model)

            passed=false;
            obj=get_param(model,'Object');
            sortedlists=obj.getSortedInfo;
            if length(sortedlists)==1
                passed=true;
            else
                if length(sortedlists)==2

                    for idx=1:2
                        if(sortedlists(idx).TaskIndex==-3)
                            passed=true;
                        end
                    end
                end
            end



            function execInfo=featureOn(model)


                feval(model,[],[],[],'compile');



                if checkModelSortedInfo(model)
                    execInfo={};
                    feval(model,'term');
                    return;
                end



                execInfo=createExecInfoData(model);



                feval(model,'term');



                function result=featureOff(model,execInfo)



                    slfeature('TaskBasedSorting',0);



                    feval(model,[],[],[],'compile');



                    result=collectSortedOrderForComparison(execInfo);



                    feval(model,'term');



                    function execInfo=simExecInfo(model)


                        set_param(model,'InDSMExecOrderCheckMode',1);
                        feval(model,[],[],[],'compile');



                        execInfo=createExecInfoData(model);



                        feval(model,'term');
                        set_param(model,'InDSMExecOrderCheckMode',0);




                        function result=rtwExecInfo(model,execInfo)



                            feval(model,[],[],[],'compileForRTW');



                            result=collectRTWSortedOrderForComparison(execInfo);



                            feval(model,'term');


                            function execInfo=updateOrder(model,prevResult)


                                feval(model,[],[],[],'compile');


                                execInfo=collectFeatureOnSortedOrder(prevResult);


                                feval(model,'term');


                                function retExecInfo=collectSortedOrderForComparison(execInfo)

                                    retExecInfo=execInfo;
                                    for dsmIdx=1:numel(retExecInfo)
                                        dsmInfo=retExecInfo{dsmIdx};
                                        for taskIdx=1:numel(dsmInfo.TaskInfo)
                                            task=dsmInfo.TaskInfo(taskIdx);
                                            for scopedSysIdx=1:numel(task.ScopedSystemInfo)
                                                scopedSys=task.ScopedSystemInfo(scopedSysIdx);
                                                for childSysIdx=1:numel(scopedSys.ChildSystemInfo)
                                                    childSys=scopedSys.ChildSystemInfo(childSysIdx);
                                                    blkSortedInfo=get_param(childSys.SystemHandle,'SortedOrder');

                                                    retExecInfo{dsmIdx}.TaskInfo(taskIdx).ScopedSystemInfo(scopedSysIdx).ChildSystemInfo(childSysIdx).OldSortedOrder=blkSortedInfo.BlockIndex;
                                                end
                                            end
                                        end
                                    end


                                    function retExecInfo=collectRTWSortedOrderForComparison(execInfo)

                                        reducedExecInfo=removeScopeSysNoNeedToCompare(execInfo);

                                        retExecInfo=reducedExecInfo;
                                        for dsmIdx=1:numel(retExecInfo)
                                            dsmInfo=retExecInfo{dsmIdx};
                                            for taskIdx=1:numel(dsmInfo.TaskInfo)
                                                task=dsmInfo.TaskInfo(taskIdx);
                                                for scopedSysIdx=1:numel(task.ScopedSystemInfo)
                                                    scopedSys=task.ScopedSystemInfo(scopedSysIdx);
                                                    for childSysIdx=1:numel(scopedSys.ChildSystemInfo)
                                                        childSys=scopedSys.ChildSystemInfo(childSysIdx);
                                                        blkSortedInfo=get_param(childSys.SystemHandle,'SortedOrder');
                                                        rtwSortedOrder=-1;
                                                        for infoIdx=1:numel(blkSortedInfo)
                                                            if(retExecInfo{dsmIdx}.TaskInfo(taskIdx).TaskIndex==blkSortedInfo(infoIdx).TaskIndex)
                                                                rtwSortedOrder=blkSortedInfo(infoIdx).BlockIndex;
                                                            end
                                                        end


                                                        retExecInfo{dsmIdx}.TaskInfo(taskIdx).ScopedSystemInfo(scopedSysIdx).ChildSystemInfo(childSysIdx).OldSortedOrder=rtwSortedOrder;
                                                    end
                                                end
                                            end
                                        end

                                        function reducedExecInfo=removeScopeSysNoNeedToCompare(execInfo)

                                            reducedExecInfo=execInfo;
                                            for dsmIdx=1:numel(execInfo)
                                                dsmInfo=execInfo{dsmIdx};
                                                for taskIdx=1:numel(dsmInfo.TaskInfo)
                                                    task=dsmInfo.TaskInfo(taskIdx);
                                                    for scopedSysIdx=1:numel(task.ScopedSystemInfo)
                                                        scopedSys=task.ScopedSystemInfo(scopedSysIdx);
                                                        shift=0;
                                                        for childSysIdx=1:numel(scopedSys.ChildSystemInfo)
                                                            childSys=scopedSys.ChildSystemInfo(childSysIdx);
                                                            trigPortBlk=find_system(childSys.SystemHandle,'SearchDepth',1,'BlockType','TriggerPort');
                                                            for portIdx=1:numel(trigPortBlk)
                                                                if strcmp(get_param(trigPortBlk(portIdx),'TriggerType'),'function-call')
                                                                    reducedExecInfo{dsmIdx}.TaskInfo(taskIdx).ScopedSystemInfo(scopedSysIdx).ChildSystemInfo(childSysIdx+shift)=[];
                                                                    shift=shift-1;
                                                                    break;
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end



                                            function retExecInfo=collectFeatureOnSortedOrder(execInfo)

                                                retExecInfo=struct('DataStoreMemoryBlock',{},'DataStoreName',{},'TaskInfo',{});

                                                retDsmIdx=1;

                                                for dsmIdx=1:numel(execInfo)
                                                    dsmInfo=execInfo{dsmIdx};

                                                    retTaskIdx=1;
                                                    for taskIdx=1:numel(dsmInfo.TaskInfo)
                                                        task=dsmInfo.TaskInfo(taskIdx);

                                                        retSysIdx=1;
                                                        for scopedSysIdx=1:numel(task.ScopedSystemInfo)
                                                            scopedSys=task.ScopedSystemInfo(scopedSysIdx);

                                                            newOrderList=zeros(size(scopedSys.ChildSystemInfo));
                                                            oldOrderList=zeros(size(scopedSys.ChildSystemInfo));

                                                            for childSysIdx=1:numel(scopedSys.ChildSystemInfo)

                                                                childSys=scopedSys.ChildSystemInfo(childSysIdx);


                                                                oldOrderList(childSysIdx)=childSys.OldSortedOrder;

                                                                blkSortedInfo=get_param(childSys.SystemHandle,'SortedOrder');

                                                                for idx=1:numel(blkSortedInfo)

                                                                    blk_task=blkSortedInfo(idx).TaskIndex;

                                                                    if(blk_task==task.TaskIndex)
                                                                        newOrderList(childSysIdx)=blkSortedInfo(idx).BlockIndex;
                                                                        scopedSys.ChildSystemInfo(childSysIdx).NewSortedOrder=newOrderList(childSysIdx);
                                                                        break;
                                                                    end
                                                                end
                                                            end


                                                            [~,newChangedIdx]=sort(newOrderList);
                                                            [~,oldChangedIdx]=sort(oldOrderList);

                                                            if~isequal(newChangedIdx,oldChangedIdx)



                                                                retExecInfo{retDsmIdx}.TaskInfo(retTaskIdx).ScopedSystemInfo(retSysIdx)=scopedSys;
                                                                retSysIdx=retSysIdx+1;
                                                            end
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
