function[retStatus,pmSchema]=getPmSchema(hThis,pmSchema)%#ok














    mySchema=struct([]);
    mySchema(1).ClassName=class(hThis);
    mySchema(1).Version='1.0.0';

    retStatus=true;



    [retStat,myItems]=hThis.getPmSchemaFromChildren();
    mySchema(1).Items=myItems;
    pmSchema=mySchema(1);



