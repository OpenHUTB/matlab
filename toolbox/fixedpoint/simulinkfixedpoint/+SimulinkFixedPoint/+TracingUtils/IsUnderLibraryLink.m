function flag=IsUnderLibraryLink(blkObj)




    flag=false;
    curRoot=get_param(bdroot(blkObj.Handle),'Name');
    curParent=blkObj.parent;



    while~strcmp(curParent,curRoot)
        if~any(strcmp(get_param(curParent,'LinkStatus'),{'none','inactive'}))
            flag=true;
            return;
        end
        curParent=get_param(curParent,'parent');
    end
end