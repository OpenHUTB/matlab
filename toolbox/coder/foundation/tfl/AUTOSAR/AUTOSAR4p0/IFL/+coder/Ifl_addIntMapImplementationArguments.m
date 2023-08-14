function hEnt=Ifl_addIntMapImplementationArguments(hEnt,datatype_y1,datatype_u1,datatype_u2,datatype_u3,...
    datatype_u4,datatype_u5,datatype_Nx,datatype_Ny,createRowMajorRoutine)

    if~createRowMajorRoutine



        argumentOrder={'y1','u2','u1','u7','u6','u4','u3','u5'};
        datatypeOrder={datatype_y1,datatype_u2,datatype_u1,datatype_Ny,datatype_Nx,datatype_u4,...
        datatype_u3,datatype_u5};
    else








        argumentOrder={'y1','u1','u2','u6','u7','u3','u4','u5'};
        datatypeOrder={datatype_y1,datatype_u1,datatype_u2,datatype_Nx,datatype_Ny,datatype_u3,...
        datatype_u4,datatype_u5};
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

    arg=hEnt.getTflArgFromString(argumentOrder{7},strcat(datatypeOrder{7},'*'));
    arg.Type.BaseType.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hEnt.getTflArgFromString(argumentOrder{8},strcat(datatypeOrder{8},'*'));
    arg.Type.BaseType.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

end