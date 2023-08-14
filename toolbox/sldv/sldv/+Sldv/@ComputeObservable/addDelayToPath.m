function status=addDelayToPath(obj,MdlIdx,BlkIdx)










    status=true;

    blkStruct=obj.CovDependency(MdlIdx).Dependency(BlkIdx);
    blkH=obj.getHandle(blkStruct.BlkName);

    if isempty(blkStruct.blkOutputSpec(1).OutputObjectives)
        return;
    end



    blkPick.elem=Sldv.ObjectiveSelection.addDelay(blkH,1);
    currOutputSpec=blkStruct.blkOutputSpec(1).OutputObjectives;



    removeSpec=[];
    for idx=1:numel(currOutputSpec)
        compSpec=currOutputSpec(idx);
        if isMaxDelayLengthReached(compSpec,obj.mMaxUnitDelayLength)
            removeSpec(end+1)=idx;%#ok<AGROW>
        end
    end

    currOutputSpec(removeSpec)=[];

    obj.resetBlkOutputSpec(MdlIdx,BlkIdx,1);

    if~isempty(currOutputSpec)
        obj.addBlkOutputSpec(MdlIdx,BlkIdx,1,...
        Sldv.ObjectiveSelection.sldvGroupCompose(currOutputSpec,blkPick));
    end
end



function yesNo=isMaxDelayLengthReached(compSpec,maxLength)
    yesNo=false;
    nBlocks=numel({compSpec.pathList.sid});
    if nBlocks<=maxLength
        return;
    end

    nDelays=0;
    for idx=1:nBlocks
        try
            currSID=compSpec.pathList(idx).sid;
            blockType=get_param(currSID,'BlockType');
            if strcmp(blockType,'UnitDelay')
                nDelays=nDelays+1;
                if nDelays>maxLength
                    yesNo=true;
                    return;
                end
            end
        catch


        end
    end

end
