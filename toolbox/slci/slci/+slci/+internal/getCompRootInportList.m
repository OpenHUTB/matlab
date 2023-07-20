function blkHandles=getCompRootInportList(sys)




    rootInports=slci.internal.getRootInportList(sys);
    blkHandles=slci.internal.replaceOrigRootWithSyntRootIOBlock(rootInports);
end
