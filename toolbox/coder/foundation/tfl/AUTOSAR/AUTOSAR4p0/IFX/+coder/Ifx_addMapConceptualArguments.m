function hEnt=Ifx_addMapConceptualArguments(hEnt,datatype_y1,datatype_u1,datatype_u2,datatype_u3,...
    datatype_u4,datatype_u5,inputIsBus,inputs)


    arg=hEnt.getTflArgFromString('y1',datatype_y1{1});
    arg.IOType='RTW_IO_OUTPUT';
    arg.CheckSlope=false;
    arg.CheckBias=false;
    hEnt.addConceptualArg(arg);

    hEnt=coder.Ifx_addIndexFractionConceptualArguments(hEnt,{inputs{1},inputs{2}},{datatype_u1,datatype_u2},...
    'RTW_IO_INPUT',inputIsBus);

    hEnt=coder.Ifx_addIndexFractionConceptualArguments(hEnt,{inputs{3},inputs{4}},{datatype_u3,datatype_u4},...
    'RTW_IO_INPUT',inputIsBus);

    arg=RTW.TflArgMatrix(inputs{5},'RTW_IO_INPUT',datatype_u5{1});
    arg.CheckSlope=false;
    arg.CheckBias=false;
    arg.DimRange=[1,1;Inf,Inf];
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString(inputs{6},'uint32');
    arg.CheckType=false;
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString(inputs{7},'uint32');
    arg.CheckType=false;
    hEnt.addConceptualArg(arg);

end