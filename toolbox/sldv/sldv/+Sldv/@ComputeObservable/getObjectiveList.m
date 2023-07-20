function objList=getObjectiveList(obj,MdlIdx,BlkIdx,InportNo)





    blkSID=obj.CovDependency(MdlIdx).Dependency(BlkIdx).BlkName;
    blkH=obj.getHandle(blkSID);
    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","getObjectiveList",...
    "Fetching all the source specifications for the block :: "+Sldv.ComputeObservable.getBlkName(blkH)+" port:: "+InportNo);

    objList=[];

    blkInpDependency=obj.CovDependency(MdlIdx).Dependency(BlkIdx).blkInputDependency;

    for i=1:length(blkInpDependency(InportNo).SrcBlk)
        srcBlkName=blkInpDependency(InportNo).SrcBlk{i};
        srcPortNo=blkInpDependency(InportNo).SrcPort{i};
        [~,srcSpec]=obj.getBlkOutputSpec(MdlIdx,srcBlkName,srcPortNo);
        objList=[objList,srcSpec];%#ok<AGROW>
    end
end
