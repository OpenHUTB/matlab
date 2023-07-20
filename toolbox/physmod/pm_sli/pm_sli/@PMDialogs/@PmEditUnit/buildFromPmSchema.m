function retStatus=buildFromPmSchema(hThis,pmSchema)











    if(~strcmpi(pmSchema.ClassName,'PMDialogs.PmEditUnit'))
        error('PmEditUnit:buildFromPmSchema:InvalidSchema','Incorrect schema passed to BuildFromSchema.');
        retStatus=false;
        return;
    end

    if(~isfield(pmSchema,'Parameters'))
        error('PmEditUnit:buildFromPmSchema:InvalidSchema','Incorrect schema passed to BuildFromSchema.');
        retStatus=false;
        return;
    end

    retStatus=(l_CheckForParam(pmSchema,'Label')&&...
    l_CheckForParam(pmSchema,'LabelAttrb'));

    hThis.Label=pmSchema.Parameters.Label;
    if~isempty(hThis.Label)&&...
        strcmp(pmSchema.Version,'1.0.0')&&...
        strcmp(hThis.Label(end),':')

        hThis.Label(end)=[];

    end
    hThis.LabelAttrb=pmSchema.Parameters.LabelAttrb;

    retStatus=hThis.buildChildrenFromPmSchema(pmSchema);

end

function retVal=l_CheckForParam(schema,paramName)
    retVal=isfield(schema.Parameters,paramName);
    if(retVal==false)
        error('PmEditUnit:buildFromPmSchema:InvalidSchema',sprintf('Missing parameter: %s.',paramName));
        retStatus=false;
    end
end
