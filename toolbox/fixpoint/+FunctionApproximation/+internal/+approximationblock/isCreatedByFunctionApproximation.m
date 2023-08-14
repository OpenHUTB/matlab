function flag=isCreatedByFunctionApproximation(blockPathOrHandle)





    schema=FunctionApproximation.internal.approximationblock.BlockSchema();
    flag=FunctionApproximation.internal.approximationblock.isCreatedBy(blockPathOrHandle,schema.CreatedByParameterValue);
end
