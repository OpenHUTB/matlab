function[retStatus,pmSchema]=getPmSchema(hThis,pmSchema)














    mySchema=struct([]);
    mySchema(1).ClassName='PMDialogs.PmCheckUnit';
    mySchema(1).Version='1.0.0';

    mySchema(1).Parameters.Label=hThis.Label;
    mySchema(1).Parameters.LabelAttrb=hThis.LabelAttrb;
    retStatus=true;


    [retStat,myItems]=hThis.getPmSchemaFromChildren();
    mySchema(1).Items=myItems;
    pmSchema=mySchema(1);
