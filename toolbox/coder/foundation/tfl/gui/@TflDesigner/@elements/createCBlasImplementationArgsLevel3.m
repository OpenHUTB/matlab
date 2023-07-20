function createCBlasImplementationArgsLevel3(this)






    hEnt=this.object;
    hLib=this.parentnode.object;

    arg=hLib.getTflArgFromString('y2','void');
    arg.IOType='RTW_IO_OUTPUT';
    hEnt.Implementation.setReturn(arg);

    arg=hLib.getTflArgFromString('ORDER','integer',102);
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('TRANSA','integer',111);
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('TRANSB','integer',111);
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('M','integer',0);
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('N','integer',0);
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('K','integer',0);
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('ALPHA','double',1);
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);


    name=hEnt.ConceptualArgs(2).Name;
    arg=hLib.getTflArgFromString(name,'double*');
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('LDA','integer',0);
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);


    name=hEnt.ConceptualArgs(3).Name;
    arg=hLib.getTflArgFromString(name,'double*');
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('LDB','integer',0);
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('BETA','double',0);
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);


    name=hEnt.ConceptualArgs(1).Name;
    arg=hLib.getTflArgFromString(name,'double*');
    arg.IOType='RTW_IO_OUTPUT';
    hEnt.Implementation.addArgument(arg);

    arg=hLib.getTflArgFromString('LDC','integer',0);
    arg.Type.ReadOnly=true;
    hEnt.Implementation.addArgument(arg);


