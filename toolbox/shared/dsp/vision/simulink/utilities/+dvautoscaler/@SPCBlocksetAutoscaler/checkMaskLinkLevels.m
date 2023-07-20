function[levelsUpToTopMask,comment]=checkMaskLinkLevels(h,blkObj)%#ok




    comment={};
    levelsUpToTopMask=0;
    levelsUpToTopLink=0;

    curRootPath=bdroot(blkObj.getFullName);
    curParentPath=blkObj.parent;
    curLevelUp=1;

    while~strcmp(curParentPath,curRootPath)


        if 2==hasmask(curParentPath)

            levelsUpToTopMask=curLevelUp;
        end

        if~any(strcmp(get_param(curParentPath,'LinkStatus'),{'none','inactive'}))

            levelsUpToTopLink=curLevelUp;
        end

        curLevelUp=curLevelUp+1;

        curParentPath=get_param(curParentPath,'parent');
    end

    if levelsUpToTopLink>levelsUpToTopMask
        comment{end+1}=DAStudio.message('SimulinkFixedPoint:autoscaling:topLinkNotMask');
        return;
    end


