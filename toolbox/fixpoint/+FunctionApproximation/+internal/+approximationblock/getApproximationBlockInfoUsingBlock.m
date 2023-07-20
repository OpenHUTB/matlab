function output=getApproximationBlockInfoUsingBlock(blockPathOrHandle)





    output=FunctionApproximation.internal.approximationblock.ApproximationBlockInfo.empty();
    blockObject=get_param(blockPathOrHandle,'Object');
    if isa(blockObject,'Simulink.SubSystem')&&...
        strcmp(blockObject.Variant,'on')&&...
        strcmp(blockObject.Mask,'on')
        schema=FunctionApproximation.internal.approximationblock.BlockSchema();
        maskObject=Simulink.Mask.get(blockObject.Handle);
        parameters=maskObject.Parameters;
        matches=strcmp(schema.VariantTagParameterName,{parameters.Name});
        if any(matches)
            variantSystemTag=parameters(matches).Value;
            output=FunctionApproximation.internal.approximationblock.ApproximationBlockInfo(variantSystemTag);
        end
    end
end
