function srcEffects=getSrcBlkSpecEffects(obj,MdlIdx,BlkIdx,inPort)












    srcEffects=[];

    blkInpDependency=obj.CovDependency(MdlIdx).Dependency(BlkIdx).blkInputDependency;

    for i=1:length(blkInpDependency(inPort).SrcBlk)
        srcBlkName=blkInpDependency(inPort).SrcBlk{i};

        if strcmp(srcBlkName,'DefaultBlockDiagram')
            continue;
        end

        [srcFound,srcIdx]=find(...
        strcmp({obj.CovDependency(MdlIdx).Dependency.BlkName},srcBlkName));



        if~srcFound
            continue;
        end


        srcStruct=obj.CovDependency(MdlIdx).Dependency(srcIdx);
        if~isempty(srcStruct)
            numsrcInports=length(srcStruct.blkInputDependency);
        else
            numsrcInports=0;
        end

        for j=1:numsrcInports
            srcEffects=[srcEffects,...
            srcStruct.blkEffectsOnSpec(j).blkList];%#ok<AGROW>
        end
    end
    srcEffects=unique(srcEffects);
end
