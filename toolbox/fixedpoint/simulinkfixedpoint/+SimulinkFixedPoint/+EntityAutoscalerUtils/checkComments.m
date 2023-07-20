function comments=checkComments(entityAutoscaler,blkObj,pathItem)





    comments={};


    [DTConInfo,~,paramNames]=gatherSpecifiedDT(entityAutoscaler,blkObj,pathItem);
    if isempty(DTConInfo.evaluatedDTString)||isempty(paramNames.modeStr)
        comments{end+1}=getString(message('SimulinkFixedPoint:autoscaling:blockDTCantAutoscale'));
        return;
    end



    if~any(strcmpi('Binary point scaling',blkObj.getPropAllowedValues(paramNames.modeStr)))
        comments{end+1}=getString(message('SimulinkFixedPoint:autoscaling:blockDTCantAutoscale'));
        return;
    end


    dialogParamTracer=SimulinkFixedPoint.TracingUtils.DialogParameterTracer(blkObj,paramNames.wlStr);



    [~,~,tracingComments]=dialogParamTracer.getDestinationProperties();
    comments(end+(1:numel(tracingComments)))=tracingComments;

end

