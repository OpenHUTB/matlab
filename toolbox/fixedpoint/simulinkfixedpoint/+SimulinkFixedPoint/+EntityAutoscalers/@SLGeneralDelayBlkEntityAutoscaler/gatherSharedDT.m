function sharedLists=gatherSharedDT(h,blkObj)



    sharedLists={};

    ph=blkObj.PortHandles;
    if~isempty(ph)&&~isempty(ph.Outport(1))


        if(hIsVirtualBus(h,ph.Outport(1)))
            return;
        end
    end

    sharedAllPorts=shareDataForSpecificPorts(h,isBlocksRequireSameDtAllPorts(blkObj),-1,-1);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedAllPorts);

    sharedFirstInOutput=shareDataForSpecificPorts(h,isBlocksRequireSameDtFirstInputOutput(blkObj),1,1);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedFirstInOutput);

    sameDatatype=sameDataTypeForSpecificPorts(h,blkObj);
    sharedLists=h.hAppendToSharedLists(sharedLists,sameDatatype);

    sharedParams=SimulinkFixedPoint.AutoscalerUtils.shareDataTypeWithSigObj(h,blkObj);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedParams);


    function sharedListPorts=shareDataForSpecificPorts(h,blk,inportSet,outportSet)

        sharedListPorts='';

        if~isempty(blk)

            sharedListPorts=h.hShareDTSpecifiedPorts(blk,inportSet,outportSet);

        end




        function sharedListPorts=sameDataTypeForSpecificPorts(h,blk)

            sharedListPorts={};

            switch class(blk)
            case 'Simulink.Delay'
                if strcmp(blk.InitialConditionSource,'Dialog')
                    return;
                end
                delayLenPort=false;
                if strcmp(blk.DelayLengthSource,'Input port')
                    delayLenPort=true;
                end
                resetPort=false;
                if~strcmp(blk.ExternalReset,'None')
                    resetPort=true;
                end
                icPortIdx=3;
                if delayLenPort&&resetPort
                    icPortIdx=4;
                elseif~delayLenPort&&~resetPort
                    icPortIdx=2;
                end
                sharedListPorts=h.hShareDTSpecifiedPorts(blk,icPortIdx,1);
                return;
            end


            function isAllPorts=isBlocksRequireSameDtAllPorts(blk)


                searchPairSets={
                {'BlockType','UnitDelay'}
                {'MaskType','Integer Delay'}
                {'BlockType','Memory'}
                {'BlockType','ZeroOrderHold'}

                {'BlockType','RateTransition'}



                {'BlockType','SignalConversion','ConversionOutput','Signal copy'}
                {'BlockType','SignalConversion','ConversionOutput','Contiguous copy'}


                };

                isAllPorts=searchPairs2Blk(blk,searchPairSets);


                function isFirstInOut=isBlocksRequireSameDtFirstInputOutput(blk)


                    searchPairSets={
                    {'BlockType','Delay'}
                    };

                    isFirstInOut=searchPairs2Blk(blk,searchPairSets);


                    function existBlk=searchPairs2Blk(blk,searchPairSets)


                        existBlk=[];

                        for i=1:length(searchPairSets)
                            existBlk=find(blk,searchPairSets{i});
                            if~isempty(existBlk)
                                break;
                            end
                        end




