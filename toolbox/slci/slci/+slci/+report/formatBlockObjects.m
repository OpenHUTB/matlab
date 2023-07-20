






function blockList=formatBlockObjects(blockObjs,datamgr)
    numSources=numel(blockObjs);

    blockMap=containers.Map;
    blockReader=datamgr.getBlockReader();
    for k=1:numSources
        blockObj=getVisibleObj(blockObjs{k},blockReader);
        if isa(blockObj,'slci.results.StateflowObject')
            blockSID=blockObj.getSID();
        else
            assert(isa(blockObj,'slci.results.BlockObject'));
            blockSID=blockObj.getBlockSID();
        end
        blockCallBack=blockObj.getCallback(datamgr);

        if isKey(blockMap,blockSID)


        else
            blockMap(blockSID)=blockCallBack;
        end
    end

    blockSIDs=keys(blockMap);
    numBlocks=numel(blockSIDs);
    blockList(numBlocks)=struct('SOURCEOBJ',[]);
    for k=1:numBlocks
        blockCallBack=blockMap(blockSIDs{k});
        blockList(k).SOURCEOBJ.CONTENT=blockCallBack;
    end
end


function visibleObj=getVisibleObj(blockObj,blockReader)
    if~blockObj.getIsVisible()
        visibleKey=blockObj.getVisibleTarget();
        assert(numel(visibleKey)==1);
        assert(blockReader.hasObject(visibleKey{1}));
        visibleObj=getVisibleObj(...
        blockReader.getObject(visibleKey{1}),blockReader);
    else

        visibleObj=blockObj;
    end
end
