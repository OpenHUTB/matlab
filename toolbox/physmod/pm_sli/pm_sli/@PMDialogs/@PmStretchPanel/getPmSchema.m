function[retStatus,pmSchema]=getPmSchema(hThis,pmSchema)













    mySchema.ClassName='PMDialogs.PmStretchPanel';
    mySchema.Version='1.0.0';


    [retStatus,myItems]=hThis.getPmSchemaFromChildren();
    mySchema(1).Items=myItems;
    pmSchema=mySchema(1);
