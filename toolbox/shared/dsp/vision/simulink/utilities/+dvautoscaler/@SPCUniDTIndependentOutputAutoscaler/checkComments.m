function comments=checkComments(~,blkObj,~)




    comments={};
    udtMaskParamStr='OutDataTypeStr';


    dialogParamTracer=SimulinkFixedPoint.TracingUtils.DialogParameterTracer(blkObj,udtMaskParamStr);



    [~,~,tracingComments]=dialogParamTracer.getDestinationProperties();
    comments(end+(1:numel(tracingComments)))=tracingComments;
end
