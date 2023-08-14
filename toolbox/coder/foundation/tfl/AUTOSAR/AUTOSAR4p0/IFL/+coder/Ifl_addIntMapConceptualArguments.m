function hEnt=Ifl_addIntMapConceptualArguments(hEnt,datatype_y1,datatype_u1,datatype_u2,datatype_u3,datatype_u4,...
    datatype_u5,datatype_Nx,datatype_Ny)


    arg=hEnt.getTflArgFromString('y1',datatype_y1);
    arg.IOType='RTW_IO_OUTPUT';
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u1',datatype_u1);
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u2',datatype_u2);
    hEnt.addConceptualArg(arg);

    arg=RTW.TflArgMatrix('u3','RTW_IO_INPUT',datatype_u3);
    arg.DimRange=[1,1;Inf,Inf];
    hEnt.addConceptualArg(arg);

    arg=RTW.TflArgMatrix('u4','RTW_IO_INPUT',datatype_u4);
    arg.DimRange=[1,1;Inf,Inf];
    hEnt.addConceptualArg(arg);

    arg=RTW.TflArgMatrix('u5','RTW_IO_INPUT',datatype_u5);
    arg.DimRange=[1,1;Inf,Inf];
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u6',datatype_Nx);
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString('u7',datatype_Ny);
    hEnt.addConceptualArg(arg);

end