function retStatus=buildFromPmSchema(hThis,pmSchema)











    if(~strcmpi(pmSchema.ClassName,'PMDialogs.PmGroupPanel'))
        error('PmEditBox:buildFromPmSchema:InvalidSchema','Incorrect schema passed to BuildFromSchema.');
        retStatus=false;
        return;
    end

    if(~isfield(pmSchema,'Parameters'))
        error('PmEditBox:buildFromPmSchema:InvalidSchema','Incorrect schema passed to BuildFromSchema.');
        retStatus=false;
        return;
    end

    retStatus=(l_CheckForParam(pmSchema,'Label')&&...
    l_CheckForParam(pmSchema,'Style'));

    hThis.Label=pmSchema.Parameters.Label;
    hThis.Style=pmSchema.Parameters.Style;
    hThis.StdLayoutCfg=pmSchema.Parameters.StdLayoutCfg;

    if isfield(pmSchema.Parameters,'BoxStretch')
        hThis.BoxStretch=pmSchema.Parameters.BoxStretch;
    else
        hThis.BoxStretch=false;
    end

    retStatus=true;
    retStatus=hThis.buildChildrenFromPmSchema(pmSchema);

end

function retVal=l_CheckForParam(schema,paramName)
    retVal=isfield(schema.Parameters,paramName);
    if(retVal==false)
        error('PmEditBox:buildFromPmSchema:InvalidSchema',sprintf('Missing parameter: %s.',paramName));
        retStatus=false;
    end
end
