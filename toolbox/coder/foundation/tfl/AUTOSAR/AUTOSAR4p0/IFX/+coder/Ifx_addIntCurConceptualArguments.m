function hEnt=Ifx_addIntCurConceptualArguments(hEnt,datatype_y1,datatype_u1,datatype_u2,datatype_u3,datatype_N)


    arg=hEnt.getTflArgFromString('y1',datatype_y1{1});
    arg.IOType='RTW_IO_OUTPUT';
    arg.CheckSlope=false;
    arg.CheckBias=false;
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u1',datatype_u1{1});
    arg.CheckSlope=false;
    arg.CheckBias=false;
    hEnt.addConceptualArg(arg);

    arg=RTW.TflArgMatrix('u2','RTW_IO_INPUT',datatype_u2{1});
    arg.CheckSlope=false;
    arg.CheckBias=false;
    arg.DimRange=[1,1;Inf,Inf];
    hEnt.addConceptualArg(arg);

    arg=RTW.TflArgMatrix('u3','RTW_IO_INPUT',datatype_u3{1});
    arg.CheckSlope=false;
    arg.CheckBias=false;
    arg.DimRange=[1,1;Inf,Inf];
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u4','uint32');
    arg.CheckType=false;
    hEnt.addConceptualArg(arg);

end