function hEnt=Ifx_addMapImplementationArguments(hEnt,datatype_y1,datatype_u5,datatype_num_value,inputIsBus,inputs,createRowMajorRoutine)

    if~createRowMajorRoutine



        argumentOrder={{inputs{3},inputs{4}},{inputs{1},inputs{2}}};
        argumentName={'dpResultX','dpResultY'};



        stride=inputs{6};
    else








        argumentOrder={{inputs{1},inputs{2}},{inputs{3},inputs{4}}};
        argumentName={'dpResultY','dpResultX'};



        stride=inputs{7};
    end

    arg=hEnt.getTflArgFromString('y1',datatype_y1{2});
    arg.IOType='RTW_IO_OUTPUT';
    hEnt.Implementation.setReturn(arg);

    hEnt=coder.Ifx_addIndexFractionImplementationArguments(hEnt,argumentOrder{1},argumentName{1},'RTW_IO_INPUT',inputIsBus);

    hEnt=coder.Ifx_addIndexFractionImplementationArguments(hEnt,argumentOrder{2},argumentName{2},'RTW_IO_INPUT',inputIsBus);

    arg=hEnt.getTflArgFromString(stride,datatype_num_value{2});
    hEnt.Implementation.addArgument(arg);

    arg=hEnt.getTflArgFromString(inputs{5},strcat(datatype_u5{2},'*'));
    arg.Type.BaseType.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

end