


function hEnt=createSelectEntry(key,implName,simdType,maskType)

    hEnt=RTW.TflCFunctionEntry;
    hEnt.setTflCFunctionEntryParameters('Key',key);

    hEnt.addConceptualArg(RTW.SimdHelper.simdArg('y1',simdType,'RTW_IO_OUTPUT'));
    hEnt.addConceptualArg(RTW.SimdHelper.simdArg('u1',maskType,'RTW_IO_INPUT'));
    hEnt.addConceptualArg(RTW.SimdHelper.simdArg('u2',simdType,'RTW_IO_INPUT'));
    hEnt.addConceptualArg(RTW.SimdHelper.simdArg('u3',simdType,'RTW_IO_INPUT'));

    impl=RTW.SimdImplementation;
    impl.Name=implName;

    impl.Return=RTW.SimdHelper.simdArg('y1',simdType,'RTW_IO_OUTPUT');
    impl.addArgument(RTW.SimdHelper.simdArg('u2',simdType,'RTW_IO_INPUT'));
    impl.addArgument(RTW.SimdHelper.simdArg('u3',simdType,'RTW_IO_INPUT'));
    impl.addArgument(RTW.SimdHelper.simdArg('u1',maskType,'RTW_IO_INPUT'));

    hEnt.Implementation=impl;
end
