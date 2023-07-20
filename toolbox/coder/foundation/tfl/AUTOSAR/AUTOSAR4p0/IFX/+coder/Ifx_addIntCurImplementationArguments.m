function hEnt=Ifx_addIntCurImplementationArguments(hEnt,datatype_y1,datatype_u1,datatype_u2,datatype_u3,datatype_N)


    arg=hEnt.getTflArgFromString('y1',datatype_y1{2});
    arg.IOType='RTW_IO_OUTPUT';
    hEnt.Implementation.setReturn(arg);

    arg=hEnt.getTflArgFromString('u1',datatype_u1{2});
    hEnt.Implementation.addArgument(arg);

    arg=hEnt.getTflArgFromString('u4',datatype_N{2});
    hEnt.Implementation.addArgument(arg);

    arg=hEnt.getTflArgFromString('u2',strcat(datatype_u2{2},'*'));
    arg.Type.BaseType.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hEnt.getTflArgFromString('u3',strcat(datatype_u3{2},'*'));
    arg.Type.BaseType.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

end