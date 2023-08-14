function[isResolved,slSignalInfo]=getResolvedSLSignal(h,blkObj)











    isResolved=false;

    slSignalInfo=[];

    isHiddenSigSpec=blkObj.isSynthesized;

    if isHiddenSigSpec&&~isempty(blkObj.CompiledSignalObject)

        isResolved=true;
        slSignalInfo.object=blkObj.CompiledSignalObject;
        slSignalInfo.name=blkObj.CompiledSignalObjectName;
        slSignalInfo.actualSrcID=h.getActualSrcIDs(blkObj);
    end






