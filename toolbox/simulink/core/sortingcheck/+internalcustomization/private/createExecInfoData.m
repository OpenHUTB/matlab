function execInfo=createExecInfoData(system)









    allDSMs=get_param(system,'CompiledDataStoreMemoryBlocks');

    execInfo=cell(size(allDSMs));
    for dsmIdx=1:numel(allDSMs)
        execInfo{dsmIdx}=createRecordForOneDataStoreBlock(allDSMs(dsmIdx));
    end


    function execInfo=createRecordForOneDataStoreBlock(dsmInfo)

        dsmExecInfo=struct('DataStoreMemoryBlock',{},'DataStoreName',{},'TaskInfo',{},'AccessorBlockArray',{});

        dsmExecInfo(1).DataStoreMemoryBlock=dsmInfo.BlockHandle;
        dsmExecInfo(1).DataStoreName=dsmInfo.DataStoreName;


        accessorBlocks=createRecordForAccessorBlocks(dsmInfo.DataStoreReaders,dsmInfo.DataStoreWriters);

        if isempty(accessorBlocks)

            execInfo=dsmExecInfo;
            return;
        end


        commonParent=findCommonParentSystemForAllAccessors(accessorBlocks);


        tasks=findAllDataStoreAccessorTasks(accessorBlocks);

        dsmExecInfo(1).TaskInfo=createTaskInfoData(commonParent,tasks,accessorBlocks);


        dsmExecInfo(1).AccessorBlockArray=accessorBlocks;

        execInfo=dsmExecInfo;


        function dsaInfo=createRecordForAccessorBlocks(dsrs,dsws)

            numOfDSR=numel(dsrs);
            numOfDSW=numel(dsws);

            dsaInfo=ones(numOfDSR+numOfDSW,1);

            for idx=1:numOfDSR
                dsaInfo(idx)=dsrs(idx);
            end

            for idx=1:numOfDSW
                dsaInfo(idx+numOfDSR)=dsws(idx);
            end


            function system=findCommonParentSystemForAllAccessors(dsaBlks)

                parentSys=cell(numel(dsaBlks),1);

                for idx=1:numel(dsaBlks)
                    parentSys{idx}.Parent=getAllParentSystem(dsaBlks(idx));
                end

                level=1;

                while true

                    if(level>numel(parentSys{1}.Parent))
                        break;
                    end

                    currParent=parentSys{1}.Parent(level);

                    moveNext=true;

                    for idx=2:numel(dsaBlks)
                        if(level>numel(parentSys{idx}.Parent))||(currParent~=parentSys{idx}.Parent(level))
                            moveNext=false;
                            break;
                        end
                    end

                    if(moveNext)
                        level=level+1;
                    else
                        break;
                    end
                end

                system=parentSys{1}.Parent(level-1);


                function list=getAllParentSystem(block)

                    parentList=[];

                    while~isempty(get_param(block,'Parent'))
                        block=get_param(block,'Parent');
                        parentList(end+1)=get_param(block,'handle');
                    end

                    list=flip(parentList);


                    function tasks=findAllDataStoreAccessorTasks(dsaBlks)


                        tasks=[];
                        for index=1:numel(dsaBlks)
                            dsa=dsaBlks(index);
                            blkSortedInfo=get_param(dsa,'SortedOrder');
                            for idx=1:numel(blkSortedInfo)
                                tasks=union(tasks,blkSortedInfo(idx).TaskIndex);
                            end
                        end
