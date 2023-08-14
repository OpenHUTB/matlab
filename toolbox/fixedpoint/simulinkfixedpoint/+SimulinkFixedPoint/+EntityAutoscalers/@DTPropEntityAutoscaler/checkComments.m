function comment=checkComments(h,blkObj,~)




    comment={};


    paramNameOrig='PropDataType';
    blkObjToBeSet=blkObj;

    if h.isUnderMaskWorkspace(blkObj)||SimulinkFixedPoint.TracingUtils.IsUnderLibraryLink(blkObj)

        [levelsUpToTopMask,levelsUpToTopLink]=getMaskLinkLevels(blkObj);

        if levelsUpToTopLink>levelsUpToTopMask

            comment{end+1}=DAStudio.message('SimulinkFixedPoint:autoscaling:topLinkNotMask');
            return;
        end

        if isUnderLibraryDynamicSaturation(blkObj)


            blkObj=blkObj.getParent;
            paramNameOrig='OutDataTypeStr';
        end


        dialogParamTracer=SimulinkFixedPoint.TracingUtils.DialogParameterTracer(blkObj,paramNameOrig);



        blkObjToBeSet=dialogParamTracer.getDestinationProperties();

    end

    if isempty(comment)&&SimulinkFixedPoint.TracingUtils.IsUnderLibraryLink(blkObjToBeSet)


        comment{end+1}=DAStudio.message('SimulinkFixedPoint:autoscaling:topLinkNotMask');
    end

end

function[levelsUpToTopMask,levelsUpToTopLink]=getMaskLinkLevels(blkObj)


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

end

function isPartOfDynamicSaturation=isUnderLibraryDynamicSaturation(blockObject)

    parentObject=blockObject.getParent;
    isPartOfDynamicSaturation=isa(parentObject,'Simulink.SubSystem')&&strcmp(parentObject.MaskType,'Saturation Dynamic');
end


