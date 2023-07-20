function[retStatus,pmSchema]=getPmSchema(hThis,pmSchema)















    mySchema=struct([]);
    mySchema(1).ClassName='PMDialogs.PmColorPicker';
    mySchema(1).Version='1.0.0';

    mySchema(1).Parameters.ColorParamName=hThis.ColorParamName;
    mySchema(1).Parameters.ColorVector=hThis.ColorVector;
    mySchema(1).Parameters.ColorLabel=hThis.ColorLabel;
    retStatus=true;


    [retStat,myItems]=hThis.getPmSchemaFromChildren();
    mySchema(1).Items=myItems;
    pmSchema=mySchema(1);
