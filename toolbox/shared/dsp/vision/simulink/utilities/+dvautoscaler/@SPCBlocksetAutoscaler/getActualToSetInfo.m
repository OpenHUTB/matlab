function[blkObjToBeSet,paramNameToBeSet,comments]=getActualToSetInfo(h,blkObj,levelsUpToTopMask,paramNameOrig)%#ok


















    blkObjToBeSet=blkObj;
    paramNameToBeSet=paramNameOrig;
    comments={};

    curBlkObj=blkObj;

    curParamName=paramNameOrig;

    for i=1:levelsUpToTopMask

        curChildParamContents=get_param(curBlkObj.getFullName,curParamName);

        if~isempty(regexp(curChildParamContents,'^[0-9]','ONCE'))

            blkObjToBeSet=curBlkObj;
            paramNameToBeSet=curParamName;
            return;
        end

        curParentObj=blkObjToBeSet.getParent;

        if 2~=hasmask(blkObjToBeSet.getFullName)


            blkObjToBeSet=curParentObj;
            continue
        end

        dialogParams=get_param(curParentObj.getFullName,'DialogParameters');

        if~isfield(dialogParams,curChildParamContents)

            dialogParams=get_param(curParentObj.getFullName,'ObsoleteDialogParameters');

            if~isfield(dialogParams,curChildParamContents)

                comments{end+1}=DAStudio.message('SimulinkFixedPoint:autoscaling:topLinkNotMask');%#ok
                return;
            end
        end

        curDialogParamInfo=dialogParams.(curChildParamContents);

        isEditField=strcmp(curDialogParamInfo.Type,'string');

        if~isEditField

            comments{end+1}=DAStudio.message('SimulinkFixedPoint:autoscaling:topLinkNotMask');%#ok
            return;
        end


        dialogParams=get_param(curParentObj.getFullName,'DialogParameters');

        lockScalingParamNameStr='LockScale';

        if isfield(dialogParams,lockScalingParamNameStr)

            curLockScaleValue=get_param(curParentObj.getFullName,lockScalingParamNameStr);

            if strcmp('on',curLockScaleValue)

                comments{end+1}=DAStudio.message('SimulinkFixedPoint:autoscaling:lockedDTFromMask');%#ok
                return;
            end
        end

        blkObjToBeSet=curParentObj;
        paramNameToBeSet=curChildParamContents;
        curParamName=curChildParamContents;
        curBlkObj=curParentObj;
    end



