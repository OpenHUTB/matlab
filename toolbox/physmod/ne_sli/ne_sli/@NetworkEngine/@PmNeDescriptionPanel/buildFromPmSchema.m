function retStatus=buildFromPmSchema(hThis,pmSchema)











    if strcmp(pmSchema.Version,'1.0.1')
        hThis.DescrText=pmSchema.Parameters.DescrText;
        hThis.BlockTitle=pmSchema.Parameters.BlockTitle;
    else
        hBlk=pmsl_getdoublehandle(hThis.BlockHandle);
        hThis.DescrText=get_param(hBlk,'MaskDescription');
        hThis.BlockTitle=get_param(hBlk,'MaskType');
    end

    retStatus=true;

end
