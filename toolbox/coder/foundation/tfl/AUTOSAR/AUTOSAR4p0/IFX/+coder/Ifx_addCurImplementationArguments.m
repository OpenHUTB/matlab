function hEnt=Ifx_addCurImplementationArguments(hEnt,datatype_y1,datatype_u3,inputIsBus,inputs)


    arg=hEnt.getTflArgFromString('y1',datatype_y1{2});
    arg.IOType='RTW_IO_OUTPUT';
    hEnt.Implementation.setReturn(arg);

    hEnt=coder.Ifx_addIndexFractionImplementationArguments(hEnt,{inputs{1},inputs{2}},'dpResult','RTW_IO_INPUT',inputIsBus);

    arg=hEnt.getTflArgFromString(inputs{3},strcat(datatype_u3{2},'*'));
    arg.Type.BaseType.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

end