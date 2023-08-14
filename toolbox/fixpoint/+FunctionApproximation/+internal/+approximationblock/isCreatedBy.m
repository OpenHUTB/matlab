function flag=isCreatedBy(blockPathOrHandle,creatorTag)





    isValid=FunctionApproximation.internal.Utils.isBlockPathValid(blockPathOrHandle);
    flag=false;
    if isValid
        blockObject=get_param(blockPathOrHandle,'Object');
        if isa(blockObject,'Simulink.SubSystem')&&...
            strcmp(blockObject.Variant,'on')&&...
            strcmp(blockObject.Mask,'on')
            schema=FunctionApproximation.internal.approximationblock.BlockSchema();
            maskObject=Simulink.Mask.get(blockObject.Handle);
            parameters=maskObject.Parameters;
            if~isempty(parameters)
                v=parameters(strcmp(schema.CreatedByParameterName,{parameters.Name})).Value;
                flag=strcmp(v,creatorTag);
            end
        end
    end
end
