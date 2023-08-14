function hEnt=Ifx_addIntMapConceptualArguments(hEnt,datatype_y1,datatype_u1,datatype_u2,datatype_u3,datatype_u4,datatype_u5)


    arg=hEnt.getTflArgFromString('y1',datatype_y1{1});
    arg.IOType='RTW_IO_OUTPUT';
    arg.CheckSlope=false;
    arg.CheckBias=false;
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u1',datatype_u1{1});
    arg.CheckSlope=false;
    arg.CheckBias=false;
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u2',datatype_u2{1});
    arg.CheckSlope=false;
    arg.CheckBias=false;
    hEnt.addConceptualArg(arg);

    arg=RTW.TflArgMatrix('u3','RTW_IO_INPUT',datatype_u3{1});
    arg.CheckSlope=false;
    arg.CheckBias=false;
    arg.DimRange=[1,1;Inf,Inf];
    hEnt.addConceptualArg(arg);

    arg=RTW.TflArgMatrix('u4','RTW_IO_INPUT',datatype_u4{1});
    arg.CheckSlope=false;
    arg.CheckBias=false;
    arg.DimRange=[1,1;Inf,Inf];
    hEnt.addConceptualArg(arg);

    arg=RTW.TflArgMatrix('u5','RTW_IO_INPUT',datatype_u5{1});
    arg.CheckSlope=false;
    arg.CheckBias=false;
    arg.DimRange=[1,1;Inf,Inf];
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u6','uint32');
    arg.CheckType=false;
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u7','uint32');
    arg.CheckType=false;
    hEnt.addConceptualArg(arg);

end