function[retStatus,pmSchema]=getPmSchema(hThis,pmSchema)













    mySchema.ClassName='PMDialogs.PmGroupPanel';
    mySchema.Version='1.0.0';
    pmSchema=mySchema;

    mySchema(1).Parameters.Label=hThis.Label;
    mySchema(1).Parameters.Style=hThis.Style;
    mySchema(1).Parameters.StdLayoutCfg=hThis.StdLayoutCfg;
    mySchema(1).Parameters.BoxStretch=hThis.BoxStretch;

    retStatus=true;


    [retStat,myItems]=hThis.getPmSchemaFromChildren();
    mySchema(1).Items=myItems;
    pmSchema=mySchema(1);
