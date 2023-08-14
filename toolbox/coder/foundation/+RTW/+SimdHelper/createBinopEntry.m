


function hEnt=createBinopEntry(key,implName,simdType,varargin)
    if numel(varargin)==1
        outType=varargin{1};
    else
        outType=simdType;
    end

    hEnt=RTW.TflCFunctionEntry;
    hEnt.setTflCFunctionEntryParameters('Key',key);

    hEnt.addConceptualArg(RTW.SimdHelper.simdArg('y1',outType,'RTW_IO_OUTPUT'));
    hEnt.addConceptualArg(RTW.SimdHelper.simdArg('u1',simdType,'RTW_IO_INPUT'));
    hEnt.addConceptualArg(RTW.SimdHelper.simdArg('u2',simdType,'RTW_IO_INPUT'));

    impl=RTW.SimdImplementation;
    impl.Name=implName;

    impl.Return=RTW.SimdHelper.simdArg('y1',outType,'RTW_IO_OUTPUT');
    impl.addArgument(RTW.SimdHelper.simdArg('u1',simdType,'RTW_IO_INPUT'));
    impl.addArgument(RTW.SimdHelper.simdArg('u2',simdType,'RTW_IO_INPUT'));

    hEnt.Implementation=impl;
end
