function[retStatus,pmSchema]=getPmSchema(hThis,pmSchema)














    mySchema=struct([]);
    mySchema(1).ClassName='NetworkEngine.PmNeVariableTargets';



    mySchema(1).Version='1.0.1';

    mySchema(1).Parameters.DefaultTargets=hThis.DefaultTargets;
    retStatus=true;


    [retStat,myItems]=hThis.getPmSchemaFromChildren();
    mySchema(1).Items=myItems;
    pmSchema=mySchema(1);
end