function[retStatus,pmSchema]=getPmSchema(hThis,pmSchema)















    mySchema=struct([]);
    mySchema(1).ClassName='PMDialogs.PmLabelSpinner';
    mySchema(1).Version='1.0.0';
    mySchema(1).Parameters.ValueBlkParam=hThis.ValueBlkParam;
    mySchema(1).Parameters.Value=hThis.Value;
    mySchema(1).Parameters.MinValue=hThis.MinValue;
    mySchema(1).Parameters.MaxValue=hThis.MaxValue;
    mySchema(1).Parameters.Label=hThis.Label;
    retStatus=true;


    [retStat,myItems]=hThis.getPmSchemaFromChildren();
    mySchema(1).Items=myItems;
    pmSchema=mySchema(1);
