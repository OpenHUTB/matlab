function sharedLists=gatherSharedDT(h,blkObj)






    sharedLists={};
    sharedFirstInOutput=shareDataForSpecificPorts(h,isBlocksRequireSameDtFirstInputOutput(blkObj),1,1);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedFirstInOutput);


    function sharedListPorts=shareDataForSpecificPorts(h,blk,inportSet,outportSet)

        sharedListPorts='';
        if~isempty(blk)
            sharedListPorts=h.hShareDTSpecifiedPorts(blk,inportSet,outportSet);
        end


        function isFirstInOut=isBlocksRequireSameDtFirstInputOutput(blk)


            searchPairSets={{'BlockType','dsp.simulink.DigitalDownConverter','outputDataTypeStr','Inherit: Same as input'},...
            {'BlockType','dsp.simulink.DigitalUpConverter','outputDataTypeStr','Inherit: Same as input'}};
            isFirstInOut=searchPairs2Blk(blk,searchPairSets);


            function existBlk=searchPairs2Blk(blk,searchPairSets)


                existBlk=[];

                for i=1:length(searchPairSets)
                    existBlk=find(blk,searchPairSets{i});
                    if~isempty(existBlk)
                        break;
                    end
                end
