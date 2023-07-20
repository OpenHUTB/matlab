function isRestricted=ChangeNotAllowedByBlockMask(blkObjToBeSet,paramNameToBeSet,maskDataList)



    isRestricted=~isa(blkObjToBeSet,'Simulink.SubSystem')&&...
    blkObjToBeSet.isLinked&&...
    hasmask(blkObjToBeSet.getFullName)==2&&...
    ~any(ismember(maskDataList(1).maskNames,paramNameToBeSet));



end