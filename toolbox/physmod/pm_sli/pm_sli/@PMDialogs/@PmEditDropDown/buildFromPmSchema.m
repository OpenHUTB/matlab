function retStatus=buildFromPmSchema(hThis,pmSchema)











    if(~strcmpi(pmSchema.ClassName,'PMDialogs.PmEditDropDown'))
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
    l_CheckForParam(pmSchema,'LabelAttrb')&&...
    l_CheckForParam(pmSchema,'Choices')&&...
    l_CheckForParam(pmSchema,'ChoiceVals')&&...
    l_CheckForParam(pmSchema,'MapVals'));

    hThis.Label=pmSchema.Parameters.Label;
    hThis.ValueBlkParam=pmSchema.Parameters.ValueBlkParam;
    hThis.LabelAttrb=pmSchema.Parameters.LabelAttrb;
    hThis.Choices=lValidateVectorVals(pmSchema.Parameters.Choices,...
    'Choices');
    hThis.ChoiceVals=lValidateVectorVals(pmSchema.Parameters.ChoiceVals,...
    'ChoiceVals');
    hThis.MapVals=lValidateVectorVals(pmSchema.Parameters.MapVals,...
    'MapVals');
    hThis.PreApplyFcn=pmSchema.Parameters.PreApplyFcn;

end

function retVal=l_CheckForParam(schema,paramName)
    retVal=isfield(schema.Parameters,paramName);
    if(retVal==false)
        error('PmEditDropDown:buildFromPmSchema:InvalidSchema',sprintf('Missing parameter: %s.',paramName));%#ok<SPERR>
    end
end

function newVal=lValidateVectorVals(val,argName)




    newVal=val;

    if(isempty(val))
        return;
    end

    if(~isvector(val))
        error('PmEditDropDown:PmEditDropDown:ExpectVector',...
        'Expected vector (1-D array) for %s array.',argName);
    end
end
