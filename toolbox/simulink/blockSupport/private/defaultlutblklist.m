function list=defaultlutblklist








    list=java.util.Hashtable;

    blkInfo=getDefaultLutBlkInfo;

    for i=1:length(blkInfo)
        list.put(blkInfo{i,1},blkInfo{i,2});
    end




