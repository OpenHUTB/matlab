function hEnt=createLoadEntry(key,implName,simdType,varargin)
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

    basetype.ReadOnly=true;
    implBaseType.ReadOnly=true;

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

    impl=RTW.SimdImplementation;
    impl.Name=implName;

    impl.Return=RTW.SimdHelper.simdArg('y1',simdType,'RTW_IO_OUTPUT');

    arg=RTW.TflArgPointer;
    arg.Name='u1';
    arg.IOType='RTW_IO_INPUT';
    arg.Type=implsource;
    impl.addArgument(arg);

    hEnt.Implementation=impl;
end
