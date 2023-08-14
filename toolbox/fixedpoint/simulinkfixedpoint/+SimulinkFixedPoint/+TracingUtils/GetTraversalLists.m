function[maskDataList,linkDataList,linkAboveMask]=GetTraversalLists(blkObj)

















    linkAboveMask=false;

    curRootPath=bdroot(blkObj.getFullName);


    curParentPath=blkObj.getFullName;

    maskCount=1;
    linkCount=1;

    maskDataList=struct('path',{},'maskNames',{});
    linkDataList=struct('path',{});


    while~strcmp(curParentPath,curRootPath)



        if hasmask(curParentPath)==2

            maskDataList(maskCount).path=curParentPath;
            maskDataList(maskCount).maskNames=get_param(curParentPath,'MaskNames');
            maskCount=maskCount+1;
            if strcmp(get_param(curParentPath,'BlockType'),'SubSystem')
                maskDataList(maskCount)=maskDataList(maskCount-1);
                maskCount=maskCount+1;
            end

        end


        if~any(strcmp(get_param(curParentPath,'LinkStatus'),{'none','inactive'}))
            linkDataList(linkCount).path=curParentPath;
            linkCount=linkCount+1;
        end

        curParentPath=get_param(curParentPath,'parent');

    end


    if maskCount<linkCount
        linkAboveMask=true;
    end
end