function onHardwareSelect(hCS)







    set_param(hCS,'UseToolchainInfoCompliant','on');
    mexCompilerInfo=mex.getCompilerConfigurations('C++');
    if isempty(mexCompilerInfo)
        compiler='';
    else
        compiler=mexCompilerInfo(1).ShortName;
    end
    switch compiler
    case 'MSVCPP160'
        set_param(hCS,'Toolchain','IBIS-AMI Microsoft Visual C++ 2019 v16.0 | nmake (64-bit Windows)');
    case 'MSVCPP150'
        set_param(hCS,'Toolchain','IBIS-AMI Microsoft Visual C++ 2017 v15.0 | nmake (64-bit Windows)');
    case 'MSVCPP140'
        set_param(hCS,'Toolchain','IBIS-AMI Microsoft Visual C++ 2015 v14.0 | nmake (64-bit Windows)');
    case 'mingw64-g++'
        set_param(hCS,'Toolchain','IBIS-AMI MinGW64 | gmake (64-bit Windows)');
    case 'g++'
        set_param(hCS,'Toolchain','IBIS-AMI GNU gcc/g++ | gmake (64-bit Linux)');
    otherwise
        error(message('serdes:export:CompilerNotFound'));
    end


    set_param(hCS,'ModelReferenceCompliant','on');


    set_param(hCS,'ParMdlRefBuildCompliant','on');


    set_param(hCS,'ModelStepFunctionPrototypeControlCompliant','off');


    set_param(hCS,'CompOptLevelCompliant','on');


    set_param(hCS,'SolverType','Fixed-step');
    set_param(hCS,'EnableMultiTasking','off');


    set_param(hCS,'LifeSpan','inf');


    set_param(hCS,'BusObjectLabelMismatch','error');


    set_param(hCS,'ProdWordSize',64);
    set_param(hCS,'ProdBitPerPointer',64);
    set_param(hCS,'ProdBitPerSizeT',64);
    set_param(hCS,'ProdBitPerPtrDiffT',64);
    set_param(hCS,'ProdLongLongMode','on');
    set_param(hCS,'ProdEqTarget','off');
    set_param(hCS,'TargetHWDeviceType','MATLAB Host');


    set_param(hCS,'MATLABDynamicMemAlloc','on');


    set_param(hCS,'TargetLang','C++');


    set_param(hCS,'DefaultParameterBehavior','Inlined');


    set_param(hCS,'GenerateReport','off');


    set_param(hCS,'SupportContinuousTime','on');
    set_param(hCS,'SupportVariableSizeSignals','on');
    set_param(hCS,'CodeInterfacePackaging','Reusable function');
    set_param(hCS,'MultiInstanceErrorCode','None');
    set_param(hCS,'RootIOFormat','Part of model data structure');
    set_param(hCS,'SuppressErrorStatus','off');
    set_param(hCS,'GRTInterface','off');
    set_param(hCS,'GenerateAllocFcn','on');
    set_param(hCS,'CombineOutputUpdateFcns','off');
    set_param(hCS,'IncludeMdlTerminateFcn','on');
    set_param(hCS,'MatFileLogging','off');


    set_param(hCS,'PortableWordSizes','off');






end
