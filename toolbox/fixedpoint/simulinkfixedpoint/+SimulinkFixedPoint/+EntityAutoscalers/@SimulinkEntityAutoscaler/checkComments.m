function comments=checkComments(h,blkObj,pathItem)




    comments={};

    blkAttrib=h.getBlockMaskTypeAttributes(blkObj,pathItem);
    if blkAttrib.IsSettableInSomeSituations
        paramNameOrig=blkAttrib.DataTypeEditField_ParamName;

        dialogParamTracer=SimulinkFixedPoint.TracingUtils.DialogParameterTracer(blkObj,paramNameOrig);


        [~,~,tracingComments]=dialogParamTracer.getDestinationProperties();
        comments(end+(1:numel(tracingComments)))=tracingComments;
    else

        comments{end+1}=message('SimulinkFixedPoint:autoscaling:blockDTCantAutoscale').getString();
    end
end


