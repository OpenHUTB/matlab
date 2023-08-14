function[retStatus,pmSchema]=getPmSchema(hThis,pmSchema)















    mySchema=struct([]);
    mySchema(1).ClassName='PMDialogs.PmEditDropDown';
    mySchema(1).Version='1.0.0';

    mySchema(1).Parameters.Label=hThis.Label;
    mySchema(1).Parameters.ValueBlkParam=hThis.ValueBlkParam;
    mySchema(1).Parameters.LabelAttrb=hThis.LabelAttrb;
    mySchema(1).Parameters.Choices=hThis.Choices;
    mySchema(1).Parameters.ChoiceVals=hThis.ChoiceVals;
    mySchema(1).Parameters.MapVals=hThis.MapVals;
    mySchema(1).Parameters.PreApplyFcn=hThis.PreApplyFcn;
    retStatus=true;


    [retStat,myItems]=hThis.getPmSchemaFromChildren();
    mySchema(1).Items=myItems;
    pmSchema=mySchema(1);
