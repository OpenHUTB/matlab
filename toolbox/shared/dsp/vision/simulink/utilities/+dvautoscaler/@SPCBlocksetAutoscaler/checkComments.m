function comments=checkComments(h,blkObj,pathItem)



    comments={};

    [signValStr,wlValStr,flValStr,specifiedDTStr,...
    flDlgStr,modeDlgStr,wlDlgStr]=h.getDataTypeInfoForPathItem(blkObj,pathItem);%#ok

    if isempty(specifiedDTStr)...
        ||isempty(modeDlgStr)...
        ||strcmpi(flValStr,'Best precision')
        comments{end+1}=getString(message('SimulinkFixedPoint:resultinfo:DTUnknown'));
        return;
    end

    levelsUpToTopMask=0;
    if h.isUnderMaskWorkspace(blkObj)||SimulinkFixedPoint.TracingUtils.IsUnderLibraryLink(blkObj)
        [levelsUpToTopMask,comment]=h.checkMaskLinkLevels(blkObj);
        if~isempty(comment)
            comments{end+1}=comment;
            return;
        end
    end

    param=wlDlgStr;
    if isempty(param)
        param=modeDlgStr;
    end
    [~,~,comment]=h.getActualToSetInfo(blkObj,levelsUpToTopMask,param);

    comments(end+(1:numel(comment)))=comment;


end

