function retStatus=buildFromPmSchema(hThis,pmSchema)











    if(~strcmpi(pmSchema.ClassName,'NetworkEngine.PmNeCheckBox'))
        error('PmCheckBox:buildFromPmSchema:InvalidSchema','Incorrect schema passed to BuildFromSchema.');
        retStatus=false;
        return;
    end

    if(~isfield(pmSchema,'Parameters'))
        error('PmCheckBox:buildFromPmSchema:InvalidSchema','Incorrect schema passed to BuildFromSchema.');
        retStatus=false;
        return;
    end

    retStatus=(l_CheckForParam(pmSchema,'Label')&&...
    l_CheckForParam(pmSchema,'ValueBlkParam')&&...
    l_CheckForParam(pmSchema,'LabelAttrb'));

    hThis.Label=pmSchema.Parameters.Label;
    hThis.ValueBlkParam=pmSchema.Parameters.ValueBlkParam;
    hThis.LabelAttrb=pmSchema.Parameters.LabelAttrb;

    retStatus=true;

end

function retVal=l_CheckForParam(schema,paramName)
    retVal=isfield(schema.Parameters,paramName);
    if(retVal==false)
        error('PmCheckBox:buildFromPmSchema:InvalidSchema',sprintf('Missing parameter: %s.',paramName));
        retStatus=false;
    end
end
