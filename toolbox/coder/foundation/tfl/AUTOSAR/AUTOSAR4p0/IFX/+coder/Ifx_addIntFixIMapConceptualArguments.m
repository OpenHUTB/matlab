function hEnt=Ifx_addIntFixIMapConceptualArguments(hEnt,datatype_y1,datatype_u1,datatype_u2,datatype_bp01,...
    datatype_bpI1,datatype_bp02,datatype_bpI2,datatype_T)


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

    arg=hEnt.getTflArgFromString('u3',datatype_bp01{1});
    arg.CheckSlope=false;
    arg.CheckBias=false;
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u4',datatype_bpI1{1});
    arg.CheckSlope=false;

    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u5',datatype_bp02{1});
    arg.CheckSlope=false;
    arg.CheckBias=false;
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u6',datatype_bpI2{1});
    arg.CheckSlope=false;

    hEnt.addConceptualArg(arg);

    arg=RTW.TflArgMatrix('u7','RTW_IO_INPUT',datatype_T{1});
    arg.CheckSlope=false;
    arg.CheckBias=false;
    arg.DimRange=[1,1;Inf,Inf];
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u8','uint32');
    arg.CheckType=false;
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u9','uint32');
    arg.CheckType=false;
    hEnt.addConceptualArg(arg);

end