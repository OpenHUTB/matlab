function hEnt=Ifx_addIntFixFixIMapImplementationArguments(hEnt,datatype_y1,datatype_u1,datatype_u2,datatype_bp01,...
    datatype_bp02,datatype_T,datatype_AutosarN,datatype_AutosarbpI,createRowMajorRoutine)

    if~createRowMajorRoutine



        argumentOrder={'y1','u2','u1','u9','u8','u7','u5','u6','u3','u4'};
        datatypeOrder={datatype_y1{2},datatype_u2{2},datatype_u1{2},datatype_AutosarN{2},datatype_AutosarN{2},datatype_T{2},...
        datatype_bp02{2},datatype_AutosarbpI{2},datatype_bp01{2},datatype_AutosarbpI{2}};
    else








        argumentOrder={'y1','u1','u2','u8','u9','u7','u3','u4','u5','u6'};
        datatypeOrder={datatype_y1{2},datatype_u1{2},datatype_u2{2},datatype_AutosarN{2},datatype_AutosarN{2},datatype_T{2},...
        datatype_bp01{2},datatype_AutosarbpI{2},datatype_bp02{2},datatype_AutosarbpI{2}};
    end

    arg=hEnt.getTflArgFromString(argumentOrder{1},datatypeOrder{1});
    arg.IOType='RTW_IO_OUTPUT';
    hEnt.Implementation.setReturn(arg);

    arg=hEnt.getTflArgFromString(argumentOrder{2},datatypeOrder{2});
    hEnt.Implementation.addArgument(arg);

    arg=hEnt.getTflArgFromString(argumentOrder{3},datatypeOrder{3});
    hEnt.Implementation.addArgument(arg);

    arg=hEnt.getTflArgFromString(argumentOrder{4},datatypeOrder{4});
    hEnt.Implementation.addArgument(arg);

    arg=hEnt.getTflArgFromString(argumentOrder{5},datatypeOrder{5});
    hEnt.Implementation.addArgument(arg);

    arg=hEnt.getTflArgFromString(argumentOrder{6},strcat(datatypeOrder{6},'*'));
    arg.Type.BaseType.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);




    arg=hEnt.getTflArgFromString(argumentOrder{7},datatypeOrder{7});
    hEnt.Implementation.addArgument(arg);

    arg=hEnt.getTflArgFromString(argumentOrder{8},datatypeOrder{8});
    hEnt.Implementation.addArgument(arg);

    arg=hEnt.getTflArgFromString(argumentOrder{9},datatypeOrder{9});
    hEnt.Implementation.addArgument(arg);

    arg=hEnt.getTflArgFromString(argumentOrder{10},datatypeOrder{10});
    hEnt.Implementation.addArgument(arg);

end