function comments=checkComments(h,blkObj,pathItem)



    comments={};

    [DTConInfo,~,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem);
    specifiedDTStr=DTConInfo.evaluatedDTString;
    if strcmpi(pathItem,'output')&&isempty(paramNames.modeStr)
        paramNames.modeStr='outputMode';
    end

    if isempty(specifiedDTStr)||isempty(paramNames.modeStr)
        comments{end+1}=getString(message('SimulinkFixedPoint:autoscaling:blockDTCantAutoscale'));
        return;
    end

    levelsUpToTopMask=0;
    if h.isUnderMaskWorkspace(blkObj)||SimulinkFixedPoint.TracingUtils.IsUnderLibraryLink(blkObj)
        [levelsUpToTopMask,comments]=h.checkMaskLinkLevels(blkObj);
        if~isempty(comments)
            comments{end+1}=comments;
            return;
        end
    end

    param=paramNames.wlStr;
    if isempty(param)
        param=paramNames.modeStr;
    end
    [~,~,comment]=h.getActualToSetInfo(blkObj,levelsUpToTopMask,param);
    comments(end+(1:numel(comment)))=comment;

    allowDtSet=blkObj.getPropAllowedValues(paramNames.modeStr);
    if~any(strcmpi('Binary point scaling',allowDtSet))
        comments{end+1}=getString(message('SimulinkFixedPoint:autoscaling:blockDTCantAutoscale'));
    end

end



