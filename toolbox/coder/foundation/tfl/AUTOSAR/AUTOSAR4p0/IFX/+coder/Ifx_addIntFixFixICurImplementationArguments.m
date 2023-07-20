function hEnt=Ifx_addIntFixFixICurImplementationArguments(hEnt,datatype_y1,datatype_u,datatype_bp0,...
    datatype_T,datatype_AutosarN,datatype_AutosarbpI)


    arg=hEnt.getTflArgFromString('y1',datatype_y1{2});
    arg.IOType='RTW_IO_OUTPUT';
    hEnt.Implementation.setReturn(arg);

    arg=hEnt.getTflArgFromString('u1',datatype_u{2});
    hEnt.Implementation.addArgument(arg);

    arg=hEnt.getTflArgFromString('u5',datatype_AutosarN{2});
    hEnt.Implementation.addArgument(arg);

    arg=hEnt.getTflArgFromString('u4',strcat(datatype_T{2},'*'));
    arg.Type.BaseType.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hEnt.getTflArgFromString('u2',datatype_bp0{2});
    hEnt.Implementation.addArgument(arg);




    arg=hEnt.getTflArgFromString('u3',datatype_AutosarbpI{2});
    hEnt.Implementation.addArgument(arg);

end