


function yesNo=checkBlkOutputSpecNeedsUpdate(obj,MdlIdx,BlkIdx)





















    yesNo=false;

    blkStruct=obj.CovDependency(MdlIdx).Dependency(BlkIdx);
    blkName=blkStruct.BlkName;
    blockH=obj.getHandle(blkName);
    isPassThrough=~Sldv.ComputeObservable.blockHasSLDVCoverage(blockH,obj.testcomp);

    numInport=length(blkStruct.blkInputDependency);

    for i=1:numInport
        srcEffects=getSrcBlkSpecEffects(obj,MdlIdx,BlkIdx,i);
        currSpecEffects=blkStruct.blkEffectsOnSpec(i).blkList;

        if(isempty(currSpecEffects)&&(~isPassThrough||Sldv.ComputeObservable.isTestObjBlock(blockH)))||...
            srcSpecHasAdditionalEffects(currSpecEffects,srcEffects)
            yesNo=true;
            obj.CovDependency(MdlIdx).Dependency(BlkIdx).blkEffectsOnSpec(i).blkList...
            =[srcEffects,BlkIdx];
        end
    end

    if yesNo

        numOutport=length(blkStruct.blkOutputSpec);
        for i=1:numOutport
            obj.resetBlkOutputSpec(MdlIdx,BlkIdx,i);
        end


        Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","checkBlkOutputSpecNeedsUpdate",...
        "Updated blkEffectsOnSpec & resetBlkOutputSpec for Block:: "+Sldv.ComputeObservable.getBlkName(blockH));
    end
end

function yesNo=srcSpecHasAdditionalEffects(currEffects,srcEffects)
    yesNo=false;
    for i=1:length(srcEffects)
        if isempty(find(currEffects==srcEffects(i),1))
            yesNo=true;
        end
    end
end
