function hEnt=createBroadcastEntry(key,implName,simdType)
    basetype=simdType.BaseType;

    hEnt=RTW.TflCFunctionEntry;
    hEnt.setTflCFunctionEntryParameters('Key',key);

    hEnt.addConceptualArg(RTW.SimdHelper.simdArg('y1',simdType,'RTW_IO_OUTPUT'));

    arg=RTW.TflArgNumeric;
    arg.Name='u1';
    arg.IOType='RTW_IO_INPUT';
    arg.Type=basetype;
    hEnt.addConceptualArg(arg);

    impl=RTW.SimdImplementation;
    impl.Name=implName;

    impl.Return=RTW.SimdHelper.simdArg('y1',simdType,'RTW_IO_OUTPUT');

    arg=RTW.TflArgNumeric;
    arg.Name='u1';
    arg.IOType='RTW_IO_INPUT';
    arg.Type=basetype;
    impl.addArgument(arg);

    hEnt.Implementation=impl;
end
