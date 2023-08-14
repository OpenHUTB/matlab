function targetInfo=compute_compiler_info(modelName)


    [targetInfo.compilerName,targetInfo.gencpp,targetInfo.mexopt]=figure_out_the_required_compiler(modelName);
    targetInfo.codingMSVCMakefile=0;
    targetInfo.codingLccMakefile=0;
    targetInfo.codingUnixMakefile=0;
    targetInfo.codingMinGWMakefile=0;

    switch targetInfo.compilerName
    case cgxeprivate('supportedPCCompilers','microsoft')
        targetInfo.codingMSVCMakefile=1;
    case 'lcc'
        targetInfo.codingLccMakefile=1;
    case 'unix'
        targetInfo.codingUnixMakefile=1;
    case cgxeprivate('supportedPCCompilers','mingw')
        targetInfo.codingMinGWMakefile=1;
    otherwise

    end



    function[compilerName,isCpp,mexopt]=figure_out_the_required_compiler(modelName)
        isCpp=strcmpi(get_param(modelName,'SimTargetLang'),'C++');

        if isunix
            compilerName='unix';
            mexopt='';
            return;
        end
        compilerInfo=compilerman('get_compiler_info',isCpp);
        compilerName=compilerInfo.compilerName;
        mexopt=compilerInfo.MexOpt;
