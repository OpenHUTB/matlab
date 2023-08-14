function throwInvBlkErrorForUI(invalidBlockPaths)
    eID="stm:TestFromModelComponents:InvalidBlocksInSelectedComponents";
    throw(MException(eID,message(eID,invalidBlockPaths).getString));
end

