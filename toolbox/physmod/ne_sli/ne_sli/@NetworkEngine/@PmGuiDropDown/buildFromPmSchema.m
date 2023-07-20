function retStatus=buildFromPmSchema(hThis,pmSchema)











    if(~strcmpi(pmSchema.ClassName,'NetworkEngine.PmGuiDropDown'))
        error('PmGuiDropDown:buildFromPmSchema:InvalidSchema','Incorrect schema passed to BuildFromSchema.');
        retStatus=false;
        return;
    end

    if(~isfield(pmSchema,'Parameters'))
        error('PmGuiDropDown:buildFromPmSchema:InvalidSchema','Incorrect schema passed to BuildFromSchema.');
        retStatus=false;
        return;
    end

    retStatus=(...
    l_CheckForParam(pmSchema,'ValueBlkParam')&&...
    l_CheckForParam(pmSchema,'Label')&&...
    l_CheckForParam(pmSchema,'LabelAttrb')&&...
    l_CheckForParam(pmSchema,'Choices')&&...
    l_CheckForParam(pmSchema,'ChoiceVals')&&...
    l_CheckForParam(pmSchema,'MapVals')...
    );

    hThis.ValueBlkParam=pmSchema.Parameters.ValueBlkParam;
    hThis.Label=pmSchema.Parameters.Label;
    hThis.LabelAttrb=pmSchema.Parameters.LabelAttrb;
    hThis.Choices=pmSchema.Parameters.Choices;
    hThis.ChoiceVals=pmSchema.Parameters.ChoiceVals;
    hThis.MapVals=pmSchema.Parameters.MapVals;

end

function retVal=l_CheckForParam(schema,paramName)
    retVal=isfield(schema.Parameters,paramName);
    if(retVal==false)
        error('PmGuiDropDown:buildFromPmSchema:InvalidSchema',sprintf('Missing parameter: %s.',paramName));
        retStatus=false;
    end
end