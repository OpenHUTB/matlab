function retStatus=buildFromPmSchema(hThis,pmSchema)











    if(~strcmpi(pmSchema.ClassName,'NetworkEngine.PmNeSolverPanel'))
        error('PmNeSolverPanel:buildFromPmSchema:InvalidSchema','Incorrect schema passed to BuildFromSchema.');
        retStatus=false;
        return;
    end

    retStatus=hThis.buildChildrenFromPmSchema(pmSchema);

end
