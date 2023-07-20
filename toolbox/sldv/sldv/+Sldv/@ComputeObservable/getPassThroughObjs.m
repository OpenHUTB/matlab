function updated=getPassThroughObjs(obj,MdlIdx,BlkIdx)






    updated=false;
    blkSt=obj.CovDependency(MdlIdx).Dependency(BlkIdx);
    blkH=obj.getHandle(blkSt.BlkName);
    blkSid=blkSt.BlkName;


    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","getPassThroughObjs",...
    "Copying Specification from inport to outport for pass through block :: "+Sldv.ComputeObservable.getBlkName(blkH));






    numInPorts=length(blkSt.blkInputDependency);



    if~numInPorts
        return;
    end

    blkPick.elem=[];
    if~obj.isGeneratedSID(blkSid)
        blkPick.pathList=struct('sid',blkSid,'port',1);
    end

    for i=1:numInPorts
        if obj.portSpecificStop(blkH,i)

            blkPortCompose{i}=[];%#ok<AGROW>
            continue;
        end
        if~obj.isGeneratedSID(blkSid)
            blkPick.pathList.port=i;
        end

        srcObjList=obj.getPathObjectiveListToPass(MdlIdx,BlkIdx,i);
        if~isempty(srcObjList)



            blkPortCompose{i}=Sldv.ObjectiveSelection.sldvGroupCompose(srcObjList,blkPick);%#ok<AGROW>
            updated=true;
        else
            blkPortCompose{i}=[];%#ok<AGROW>

            obj.resetBlkEffectsOnSpec(MdlIdx,BlkIdx,i);
        end
    end


    blkCompose=[blkPortCompose{1:numInPorts}];



    numOutPorts=length(blkSt.blkOutputSpec);
    for i=1:numOutPorts
        obj.addBlkOutputSpec(MdlIdx,BlkIdx,i,blkCompose);
    end
end
