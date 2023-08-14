function comments=spc_checkComments(h,blkObj,pathItem)




    comments={};
    prefixStr=getSPCUniDTParamPrefixStr(h,blkObj,pathItem);

    if isempty(prefixStr)
        return;
    end
    udtMaskParamStr=strcat(prefixStr,'DataTypeStr');



    dialogParamTracer=SimulinkFixedPoint.TracingUtils.DialogParameterTracer(blkObj,udtMaskParamStr);



    [~,~,tracingComments]=dialogParamTracer.getDestinationProperties();
    comments(end+(1:numel(tracingComments)))=tracingComments;
end



