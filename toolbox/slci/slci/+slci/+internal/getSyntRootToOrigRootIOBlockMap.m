function out=getSyntRootToOrigRootIOBlockMap(blkHandles)





    out=containers.Map('KeyType','double','ValueType','double');

    origToSyntMap=slci.internal.getOrigRootToSyntRootIOBlockMap(blkHandles);

    if~isempty(origToSyntMap)
        origBlkHdls=origToSyntMap.keys;
        for i=1:numel(origBlkHdls)
            aOrigBlk=origBlkHdls{i};
            syntBlkHdls=origToSyntMap(aOrigBlk);
            for j=1:numel(syntBlkHdls)
                aSyntBlk=syntBlkHdls(j);
                out(aSyntBlk)=aOrigBlk;
            end
        end
    end

end
