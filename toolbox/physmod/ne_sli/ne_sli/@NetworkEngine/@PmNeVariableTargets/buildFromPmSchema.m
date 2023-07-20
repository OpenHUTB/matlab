function retStatus=buildFromPmSchema(hThis,pmSchema)











    if(~strcmpi(pmSchema.ClassName,'NetworkEngine.PmNeVariableTargets'))
        error('PmNeVariableTargets:buildFromPmSchema:InvalidSchema','Incorrect schema passed to BuildFromSchema.');
    end

    if(~isfield(pmSchema,'Parameters'))
        error('PmNeVariableTargets:buildFromPmSchema:InvalidSchema','Incorrect schema passed to BuildFromSchema.');
    end

    hThis.DefaultTargets=pmSchema.Parameters.DefaultTargets;

    retStatus=buildChildrenFromPmSchema(hThis,pmSchema);

end