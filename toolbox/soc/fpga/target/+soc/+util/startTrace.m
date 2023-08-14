function startTrace(JTAGMaster,PMInfo)
    JTAGMaster.writememory(PMInfo.TRCE_CR,uint32(1));
    JTAGMaster.writememory(PMInfo.TRCE_CR,uint32(0));
    JTAGMaster.writememory(PMInfo.TRCE_CR,uint32(2));
end