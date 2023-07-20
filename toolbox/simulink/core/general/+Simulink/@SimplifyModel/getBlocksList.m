function[allBlocks,cutLocations]=getBlocksList(FullPath,excludeBlocks,maxIterations)

    if nargin<2
        excludeBlocks={};
    end
    if nargin<3
        maxIterations=100;
    end

    mdlName=Simulink.SimplifyModel.getSubsystemName(FullPath);
    sortedOrderList={};
    load_system(mdlName);


    removeInportShadows(FullPath);
    aBlocks=find_system(FullPath,'SearchDepth',1,'LookUnderMasks','all','Type','Block');

    for pp=1:length(aBlocks)
        currentBlockHandle=get_param(aBlocks{pp},'Handle');
        if currentBlockHandle~=get_param(FullPath,'Handle')
            [~,~,~,dstBlkList]=Simulink.SimplifyModel.getSrcDstList(currentBlockHandle,false);
            sortedOrderList{end+1}=[currentBlockHandle,dstBlkList];%#ok<*AGROW>
        end
    end


    partsList=bundleConnectedBlocks(sortedOrderList);


    [allBlocks,cutLocations]=sortEachBundle(aBlocks,partsList,maxIterations,FullPath,excludeBlocks,sortedOrderList);


    function removable=isBlockRemovable(blockName,rootName,excludeBlocks)

        removable=true;
        if strcmp(blockName,rootName)
            removable=false;
            return;
        end

        if ismember(blockName,excludeBlocks)
            removable=false;
        end



        function sortedOrderList=sortTheList(sortedOrderList,maxIterations)


            for pp=1:maxIterations
                changeMade=false;
                i=1;
                blocksVisited=[];
                while(i<=length(sortedOrderList))
                    lenSortedOrder=length(sortedOrderList{i});
                    blocksVisited(end+1)=sortedOrderList{i}(1);
                    for j=2:lenSortedOrder
                        for k=1:i-1
                            if sortedOrderList{k}(1)==sortedOrderList{i}(j)


                                changeMade=true;
                                temp1=sortedOrderList{k};
                                for m=k:i-1
                                    sortedOrderList{m}=sortedOrderList{m+1};
                                end
                                sortedOrderList{i}=temp1;
                                i=i-1;
                                break;
                            end
                        end
                    end

                    while i<=length(sortedOrderList)&&any(sortedOrderList{i}(1)==blocksVisited)
                        i=i+1;
                    end
                end

                if~changeMade
                    break;
                end
            end


            function partsList=bundleConnectedBlocks(sortedOrderList)
                partsList={};
                for i=1:length(sortedOrderList)
                    alreadyInList=[];
                    for j=1:length(partsList)
                        if any(ismember(sortedOrderList{i},partsList{j}))
                            alreadyInList(end+1)=j;
                        end
                    end

                    if isempty(alreadyInList)
                        partsList{end+1}=sortedOrderList{i};
                    else
                        partsList{alreadyInList(1)}=[partsList{alreadyInList(1:end)},sortedOrderList{i}];
                        partsList(alreadyInList(2:end))=[];
                    end
                end

                for i=1:length(partsList)
                    for j=1:length(partsList)
                        if i~=j&&any(ismember(partsList{i},partsList{j}))

                        end
                    end
                end


                function removeInportShadows(FullPath)
                    inportShadowBlocks=find_system(FullPath,'SearchDepth',1,'LookUnderMasks','all','BlockType','InportShadow');
                    inportBlocks=find_system(FullPath,'SearchDepth',1,'LookUnderMasks','all','BlockType','Inport');

                    for i=1:length(inportShadowBlocks)
                        [~,dstPortList]=Simulink.SimplifyModel.getSrcDstList(inportShadowBlocks{i},true);
                        for j=1:length(inportBlocks)
                            if strcmp(get_param(inportShadowBlocks{i},'Port'),get_param(inportBlocks{j},'Port'))
                                inPortHandle=get_param(inportBlocks{j},'PortHandles');
                                for k=1:length(dstPortList)
                                    add_line(FullPath,inPortHandle.Outport,dstPortList(k));
                                end
                            end
                        end
                        delete_block(inportShadowBlocks{i});
                    end



                    function[allBlocks,cutLocations]=sortEachBundle(aBlocks,partsList,maxIterations,FullPath,excludeBlocks,sortedOrderList)

                        cutLocations=0;
                        allBlocks={};
                        totalNum=0;

                        for i=1:length(partsList)
                            newSortedOrder={};
                            partsList{i}=unique(partsList{i});
                            for j=1:length(sortedOrderList)
                                if any(sortedOrderList{j}(1)==partsList{i})
                                    newSortedOrder{end+1}=sortedOrderList{j};
                                end
                            end
                            if isempty(newSortedOrder)

                            end

                            newSortedOrder=sortTheList(newSortedOrder,maxIterations);
                            totalNum=totalNum+length(newSortedOrder);


                            for j=length(newSortedOrder):-1:1
                                for k=1:length(aBlocks)
                                    if get_param(aBlocks{k},'Handle')==newSortedOrder{j}(1)&&isBlockRemovable(aBlocks{k},FullPath,excludeBlocks)
                                        allBlocks{end+1}=aBlocks{k};
                                    end
                                end
                            end
                            cutLocations(end+1)=length(allBlocks);
                        end

                        if totalNum~=length(sortedOrderList)

                        end
