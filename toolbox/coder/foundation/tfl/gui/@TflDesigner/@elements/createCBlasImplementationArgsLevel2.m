function createCBlasImplementationArgsLevel2(this)





    hEnt=this.object;
    hLib=this.parentnode.object;

    arg=hLib.getTflArgFromString('y2','void');
    arg.IOType='RTW_IO_OUTPUT';
    hEnt.Implementation.setReturn(arg);

    arg=hLib.getTflArgFromString('ORDER','integer',102);

    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('TRANSA','integer',111);

    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('M','integer',0);
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('N','integer',0);
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('ALPHA','double',1);
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('u1','double*');
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('LDA','integer',0);
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('u2','double*');
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('INCX','integer',0);
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('BETA','double',0);
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('y1','double*');
    arg.IOType='RTW_IO_OUTPUT';
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('INCY','integer',0);
    hEnt.Implementation.addArgument(arg);


