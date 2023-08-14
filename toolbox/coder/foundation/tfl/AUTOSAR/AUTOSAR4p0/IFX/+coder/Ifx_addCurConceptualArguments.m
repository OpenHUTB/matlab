function hEnt=Ifx_addCurConceptualArguments(hEnt,datatype_y1,datatype_u1,datatype_u2,datatype_u3,inputIsBus,inputs)


    arg=hEnt.getTflArgFromString('y1',datatype_y1{1});
    arg.IOType='RTW_IO_OUTPUT';
    arg.CheckSlope=false;
    arg.CheckBias=false;
    hEnt.addConceptualArg(arg);

    hEnt=coder.Ifx_addIndexFractionConceptualArguments(hEnt,{inputs{1},inputs{2}},{datatype_u1,datatype_u2},...
    'RTW_IO_INPUT',inputIsBus);

    arg=RTW.TflArgMatrix(inputs{3},'RTW_IO_INPUT',datatype_u3{1});
    arg.CheckSlope=false;
    arg.CheckBias=false;
    arg.DimRange=[1,1;Inf,Inf];
    hEnt.addConceptualArg(arg);

    arg=hEnt.getTflArgFromString(inputs{4},'uint32');
    arg.CheckType=false;
    hEnt.addConceptualArg(arg);

end