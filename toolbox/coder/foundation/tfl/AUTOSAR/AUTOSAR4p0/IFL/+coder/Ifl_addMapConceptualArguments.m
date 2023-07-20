function hEnt=Ifl_addMapConceptualArguments(hEnt,datatype_y1,datatype_u1,datatype_u2,datatype_u3,...
    datatype_u4,datatype_u5,datatype_num_value,inputIsBus,inputs)


    arg=hEnt.getTflArgFromString('y1',datatype_y1);
    arg.IOType='RTW_IO_OUTPUT';
    hEnt.addConceptualArg(arg);

    hEnt=coder.Ifl_addIndexFractionConceptualArguments(hEnt,{inputs{1},inputs{2}},{datatype_u1,datatype_u2},...
    'RTW_IO_INPUT',inputIsBus);

    hEnt=coder.Ifl_addIndexFractionConceptualArguments(hEnt,{inputs{3},inputs{4}},{datatype_u3,datatype_u4},...
    'RTW_IO_INPUT',inputIsBus);

    arg=RTW.TflArgMatrix(inputs{5},'RTW_IO_INPUT',datatype_u5);
    arg.DimRange=[1,1;Inf,Inf];
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString(inputs{6},datatype_num_value);
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString(inputs{7},datatype_num_value);
    hEnt.addConceptualArg(arg);

end