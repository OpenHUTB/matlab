






function startingPointH=getSlicerSeed(obj)

    startingPoint=obj.DebugCtx.curBlkSid;
    blockNames=getfullname(convertStringsToChars(startingPoint));
    startingPointH=getSimulinkBlockHandle(blockNames);
end
