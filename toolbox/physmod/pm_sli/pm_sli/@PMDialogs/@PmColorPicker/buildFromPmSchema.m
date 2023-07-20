function retStatus=buildFromPmSchema(hThis,pmSchema)











    if(~strcmpi(pmSchema.ClassName,'PmDialogs.PmColorPicker'))
        error(-1,'Incorrect schema passed to BuildFromSchema.');
        retStatus=false;
        return;
    end

    hThis.ColorParamName=pmSchema.Parameters.ColorParamName;
    hThis.ColorVector=pmSchema.Parameters.ColorVector;
    hThis.ColorLabel=pmSchema.Parameters.ColorLabel;

    retStatus=hThis.buildChildrenFromPmSchema(pmSchema);


