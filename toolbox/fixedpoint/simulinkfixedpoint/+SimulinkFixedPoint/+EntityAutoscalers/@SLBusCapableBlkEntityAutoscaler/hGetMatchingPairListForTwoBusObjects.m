function pairList=hGetMatchingPairListForTwoBusObjects...
    (h,busObj1Name,busObj2Name,busObjHandleMap)








    pairList={};


    if strcmp(busObj1Name,busObj2Name)
        return;
    end

    hBObj1=hGetBusObjHandleFromMap(h,busObj1Name,busObjHandleMap);
    hBObj2=hGetBusObjHandleFromMap(h,busObj2Name,busObjHandleMap);




    L=length(hBObj1.leafChildIndices);

    if L>0






        leafChildEleNames=hBObj1.elementNames(hBObj1.leafChildIndices);
        [busObjID(1,1:L).blkObj]=deal(hBObj1);
        [busObjID(1,1:L).pathItem]=deal(leafChildEleNames{:});

        leafChildEleNames=hBObj2.elementNames(hBObj2.leafChildIndices);
        [busObjID(2,1:L).blkObj]=deal(hBObj2);
        [busObjID(2,1:L).pathItem]=deal(leafChildEleNames{:});


        [pairs{1:L}]=deal([]);
        for i=1:L
            pairs{i}=busObjID(1:2,i);
        end









        pairList=cellfun(@(x)num2cell(x'),pairs,'UniformOutput',false);





    end





    L=length(hBObj1.nonLeafChildIndices);

    if L>0

        nonLeafChildNames1=...
        hBObj1.specifiedDTs(hBObj1.nonLeafChildIndices);
        nonLeafChildNames1=h.hCleanBusName(nonLeafChildNames1);

        nonLeafChildNames2=...
        hBObj2.specifiedDTs(hBObj2.nonLeafChildIndices);
        nonLeafChildNames2=h.hCleanBusName(nonLeafChildNames2);


        for i=1:L
            subPairList=hGetMatchingPairListForTwoBusObjects...
            (h,nonLeafChildNames1{i},nonLeafChildNames2{i},busObjHandleMap);
            pairList=h.hAppendToSharedLists(pairList,subPairList);
        end

    end


