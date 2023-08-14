function fullBlockPath=constructBlockPathToDisplay(blkPathArr)













    if~iscell(blkPathArr)
        fullBlockPath=blkPathArr;
        return;
    end

    nPaths=length(blkPathArr);
    basePath=blkPathArr{1};


    blocksHier=strings(1,nPaths);
    blocksHier(1)=basePath;
    for indx=2:nPaths
        blocksHier(indx)=getBaseBlock(blkPathArr{indx});
    end

    fullBlockPath=char(join(blocksHier,'/'));
end

function blk=getBaseBlock(blkPath)
    tmp=strfind(blkPath,'/');
    blk=blkPath(tmp+1:end);
end