function[retStatus,pmSchema]=getPmSchema(hThis,pmSchema)














    mySchema=struct([]);
    mySchema(1).ClassName='PMDialogs.PmUnitSelect';
    mySchema(1).Version='1.0.0';

    mySchema(1).Parameters.Label=hThis.Label;
    mySchema(1).Parameters.ValueBlkParam=hThis.ValueBlkParam;
    mySchema(1).Parameters.LabelAttrb=hThis.LabelAttrb;
    mySchema(1).Parameters.HideName=hThis.HideName;
    mySchema(1).Parameters.UnitDefault=hThis.UnitDefault;
    retStatus=true;


    [retStat,myItems]=hThis.getPmSchemaFromChildren();
    mySchema(1).Items=myItems;
    pmSchema=mySchema(1);
