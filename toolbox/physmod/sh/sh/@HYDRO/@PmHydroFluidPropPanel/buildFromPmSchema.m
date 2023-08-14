function retStatus=buildFromPmSchema(hThis,pmSchema)











    if(~strcmpi(pmSchema.ClassName,'HYDRO.PmHydroFluidPropPanel'))
        error('PmHydroFluidPropPanel:buildFromPmSchema:InvalidSchema','Incorrect schema passed to BuildFromSchema.');
        retStatus=false;
        return;
    end

    retStatus=hThis.buildChildrenFromPmSchema(pmSchema);

end

function retVal=l_CheckForParam(schema,paramName)
    retVal=isfield(schema.Parameters,paramName);
    if(retVal==false)
        error('PmHydroFluidPropPanel:buildFromPmSchema:InvalidSchema',sprintf('Missing parameter: %s.',paramName));
        retStatus=false;
    end
end
