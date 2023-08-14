function[retStatus,pmSchema]=getPmSchema(hThis,pmSchema)














    mySchema=struct([]);
    mySchema(1).ClassName='HYDRO.PmHydroFluidPropPanel';
    mySchema(1).Version='1.0.0';

    retStatus=true;


    [retStat,myItems]=hThis.getPmSchemaFromChildren();
    mySchema(1).Items=myItems;
    pmSchema=mySchema(1);