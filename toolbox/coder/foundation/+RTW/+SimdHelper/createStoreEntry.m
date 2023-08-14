function hEnt=createStoreEntry(key,implName,simdType,varargin)
    hEnt=RTW.TflCFunctionEntry;
    hEnt.setTflCFunctionEntryParameters('Key',key);
    hEnt.SideEffects=false;

    simdTypeAsSourceType=~isempty(varargin)&&varargin{1};

    basetype=simdType.BaseType;

    if simdTypeAsSourceType
        implBaseType=simdType;
    else
        implBaseType=simdType.BaseType;
    end


    sourcetype=embedded.pointertype;
    sourcetype.BaseType=basetype;

    implsource=embedded.pointertype;
    implsource.BaseType=implBaseType;

    hEnt.addConceptualArg(RTW.SimdHelper.simdArg('y1',simdType,'RTW_IO_OUTPUT'));

    arg=RTW.TflArgPointer;
    arg.Name='u1';
    arg.IOType='RTW_IO_INPUT';
    arg.Type=sourcetype;
    hEnt.addConceptualArg(arg);

    hEnt.addConceptualArg(RTW.SimdHelper.simdArg('u2',simdType,'RTW_IO_INPUT'));

    impl=RTW.SimdImplementation;
    impl.Name=implName;


    impl.Return=RTW.SimdHelper.simdArg('y1',simdType,'RTW_IO_OUTPUT');


    arg=RTW.TflArgPointer;
    arg.Name='u1';
    arg.IOType='RTW_IO_INPUT';
    arg.Type=implsource;
    impl.addArgument(arg);


    impl.addArgument(RTW.SimdHelper.simdArg('u2',simdType,'RTW_IO_INPUT'));

    hEnt.Implementation=impl;
end
