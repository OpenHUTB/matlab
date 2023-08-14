function hEnt=Ifx_addIntFixICurConceptualArguments(hEnt,datatype_y1,datatype_u,datatype_bp0,datatype_bpI,datatype_T)


    arg=hEnt.getTflArgFromString('y1',datatype_y1{1});
    arg.IOType='RTW_IO_OUTPUT';
    arg.CheckSlope=false;
    arg.CheckBias=false;
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u1',datatype_u{1});
    arg.CheckSlope=false;
    arg.CheckBias=false;
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u2',datatype_bp0{1});
    arg.CheckSlope=false;
    arg.CheckBias=false;
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u3',datatype_bpI{1});
    arg.CheckSlope=false;

    hEnt.addConceptualArg(arg);

    arg=RTW.TflArgMatrix('u4','RTW_IO_INPUT',datatype_T{1});
    arg.CheckSlope=false;
    arg.CheckBias=false;
    arg.DimRange=[1,1;Inf,Inf];
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u5','uint32');
    arg.CheckType=false;
    hEnt.addConceptualArg(arg);

end