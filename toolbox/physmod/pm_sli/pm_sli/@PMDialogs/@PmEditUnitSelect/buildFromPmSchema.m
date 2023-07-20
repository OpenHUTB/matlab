function retStatus=buildFromPmSchema(hThis,pmSchema)










    if(~strcmpi(pmSchema.ClassName,'PMDialogs.PmEditUnitSelect'))
        error('PmEditUnitSelect:buildFromPmSchema:InvalidSchema','Incorrect schema passed to BuildFromSchema.');
        retStatus=false;
        return;
    end

    if(~isfield(pmSchema,'Parameters'))
        error('PmEditUnitSelect:buildFromPmSchema:InvalidSchema','Incorrect schema passed to BuildFromSchema.');
        retStatus=false;
        return;
    end

    retStatus=(l_CheckForParam(pmSchema,'Label')&&...
    l_CheckForParam(pmSchema,'ValueBlkParam')&&...
    l_CheckForParam(pmSchema,'LabelAttrb')&&...
    l_CheckForParam(pmSchema,'HideName')&&...
    l_CheckForParam(pmSchema,'UnitDefault'));

    hThis.Label=pmSchema.Parameters.Label;
    if~isempty(hThis.Label)&&...
        strcmp(pmSchema.Version,'1.0.0')&&...
        strcmp(hThis.Label(end),':')

        hThis.Label(end)=[];

    end
    hThis.ValueBlkParam=pmSchema.Parameters.ValueBlkParam;
    hThis.LabelAttrb=pmSchema.Parameters.LabelAttrb;
    hThis.HideName=pmSchema.Parameters.HideName;
    hThis.UnitDefault=pmSchema.Parameters.UnitDefault;

end

function retVal=l_CheckForParam(schema,paramName)
    retVal=isfield(schema.Parameters,paramName);
    if(retVal==false)
        error('PmEditUnitSelect:buildFromPmSchema:InvalidSchema',sprintf('Missing parameter: %s.',paramName));%#ok
    end
end
