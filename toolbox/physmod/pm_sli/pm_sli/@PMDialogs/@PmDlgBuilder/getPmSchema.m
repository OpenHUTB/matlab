function[retStat,pmSchema]=getPmSchema(hThis,pmSchema)














    pmSchema=struct([]);
    pmSchema(1).Name='PMDialogs.PMDlgBuilder';
    pmSchema(1).Version='1.0.0';
    retStat=true;


    [retStat,myItems]=hThis.getPmSchemaFromChildren();
    pmSchema(1).Items=myItems;
