function createBlasImplementationArgsLevel2(this)





    hEnt=this.object;
    hLib=this.parentnode.object;

    arg=hLib.getTflArgFromString('y2','void');
    arg.IOType='RTW_IO_OUTPUT';
    hEnt.Implementation.setReturn(arg);

    arg=RTW.TflArgCharConstant('TRANS');
    arg.PassByType='RTW_PASSBY_POINTER';
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('M','integer',0);
    arg.PassByType='RTW_PASSBY_POINTER';
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('N','integer',0);
    arg.PassByType='RTW_PASSBY_POINTER';
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('ALPHA','double',0);
    arg.PassByType='RTW_PASSBY_POINTER';
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('u1','double*');
    arg.PassByType='RTW_PASSBY_POINTER';
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('LDA','integer',0);
    arg.PassByType='RTW_PASSBY_POINTER';
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('u2','double*');
    arg.PassByType='RTW_PASSBY_POINTER';
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('INCX','integer',0);
    arg.PassByType='RTW_PASSBY_POINTER';
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('BETA','double',0);
    arg.PassByType='RTW_PASSBY_POINTER';
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('y1','double*');
    arg.IOType='RTW_IO_OUTPUT';
    arg.PassByType='RTW_PASSBY_POINTER';
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('INCY','integer',0);
    arg.PassByType='RTW_PASSBY_POINTER';
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

