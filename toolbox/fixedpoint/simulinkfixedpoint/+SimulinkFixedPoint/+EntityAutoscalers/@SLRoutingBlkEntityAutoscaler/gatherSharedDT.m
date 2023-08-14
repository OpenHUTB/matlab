function sharedLists=gatherSharedDT(h,blkObj)



    sharedLists={};

    sharedAllPorts=hShareDataForSpecificPortsWithoutBus(h,...
    isBlocksRequireSameDtAllPorts(blkObj),-1,-1);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedAllPorts);

    sharedFirstThird=hShareDataForSpecificPortsWithoutBus(h,...
    isBlocksRequireSameDtInput1st3rd(blkObj),[1,3],[]);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedFirstThird);

    sharedSecondToEnd=hShareDataForSpecificPortsWithoutBus(h,...
    isBlocksRequireSameDtInput2ndToEnd(blkObj),'2:end',[]);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedSecondToEnd);


    shareDTCorrespondingSrc=shareDTforInPutVirBusSrc(h,blkObj);
    sharedLists=h.hAppendToSharedLists(sharedLists,shareDTCorrespondingSrc);



    function shareDTCorrespondingSrc=shareDTforInPutVirBusSrc(h,blk)




        ph=blk.PortHandles;
        shareDTCorrespondingSrc={};

        for portNumb=1:length(ph.Inport)
            hPort=ph.Inport(portNumb);
            if~hIsVirtualBus(h,hPort)
                continue;
            end
            portObj=get_param(hPort,'Object');
            srcSigIDs=getAllSourceSignal(h,portObj,true);
            shareDTCorrespondingSrc=...
            appendToshareDTCorrespondingSrc(srcSigIDs,shareDTCorrespondingSrc);
        end

        shareDTCorrespondingSrc=...
        shareDTCorrespondingSrc(cellfun('isempty',shareDTCorrespondingSrc)==0);


        function shareDTCorrespondingSrc=appendToshareDTCorrespondingSrc(srcSigIDs,shareDTCorrespondingSrc_in)


            if isempty(shareDTCorrespondingSrc_in)
                for srcIdx=1:length(srcSigIDs)
                    oneSrcSigID=srcSigIDs{srcIdx};
                    if~isempty(oneSrcSigID.blkObj)&&~isempty(oneSrcSigID.pathItem)
                        oneList{1}=srcSigIDs{srcIdx};
                    else
                        oneList={};
                    end
                    shareDTCorrespondingSrc{srcIdx}=oneList;%#ok
                end
            else
                shareDTCorrespondingSrc=shareDTCorrespondingSrc_in;
                if length(shareDTCorrespondingSrc_in)~=length(srcSigIDs)


                    return;
                end
                for srcIdx=1:length(srcSigIDs)
                    oneList=shareDTCorrespondingSrc{srcIdx};
                    oneSrcSigID=srcSigIDs{srcIdx};
                    if~isempty(oneSrcSigID.blkObj)&&~isempty(oneSrcSigID.pathItem)
                        oneList{end+1}=oneSrcSigID;%#ok
                    end
                    shareDTCorrespondingSrc{srcIdx}=oneList;
                end
            end


            function isAllPorts=isBlocksRequireSameDtAllPorts(blk)


                searchPairSets={
                {'BlockType','Merge'}
                };

                isAllPorts=searchPairs2Blk(blk,searchPairSets);


                function isFirstThird=isBlocksRequireSameDtInput1st3rd(blk)


                    searchPairSets={
                    {'BlockType','Switch','InputSameDT','on'}
                    };

                    isFirstThird=searchPairs2Blk(blk,searchPairSets);


                    function isToEnd=isBlocksRequireSameDtInput2ndToEnd(blk)


                        searchPairSets={
                        {'BlockType','MultiPortSwitch','InputSameDT','on'}
                        };

                        isToEnd=searchPairs2Blk(blk,searchPairSets);


                        function existBlk=searchPairs2Blk(blk,searchPairSets)


                            existBlk=[];

                            for i=1:length(searchPairSets)
                                existBlk=find(blk,searchPairSets{i});
                                if~isempty(existBlk)
                                    break;
                                end
                            end

