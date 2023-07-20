function retStatus=buildFromPmSchema(hThis,pmSchema)











    if(~strcmpi(pmSchema.ClassName,'PMDialogs.PmLabelSpinner'))
        error(-1,'Incorrect schema passed to BuildFromSchema.');
        retStatus=false;
        return;
    end

    if(~isfield(pmSchema,'Parameters'))
        error(-2,'Incorrect schema passed to BuildFromSchema.');
        retStatus=false;
        return;
    end

    retStatus=(l_CheckForParam(pmSchema,'ValueBlkParam')&&...
    l_CheckForParam(pmSchema,'Value')&&...
    l_CheckForParam(pmSchema,'MinValue')&&...
    l_CheckForParam(pmSchema,'MaxValue')&&...
    l_CheckForParam(pmSchema,'Label'));

    hThis.ValueBlkParam=pmSchema.Parameters.ValueBlkParam;
    hThis.Value=pmSchema.Parameters.Value;
    hThis.MinValue=pmSchema.Parameters.MinValue;
    hThis.MaxValue=pmSchema.Parameters.MaxValue;
    hThis.Label=pmSchema.Parameters.Label;
    retStatus=true;

end

function retVal=l_CheckForParam(pmSchema,paramName)
    retVal=isfield(pmSchema.Parameters,paramName);
    if(retVal==false)
        error(-3,sprintf('Missing parameter: %s.',paramName));
        retStatus=false;
    end
end
