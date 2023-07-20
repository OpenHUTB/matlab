function[gencpp,compilerName,mexSetEnv]=get_cgxe_compiler_info(modelName)
    if~ischar(modelName)

        modelName=get_param(modelName,'Name');
    end

    try
        gencpp=strcmp(get_param(modelName,'SimTargetLang'),'C++');
    catch ME %#ok<NASGU>
        gencpp=false;
    end

    if ispc
        compilerInfo=compilerman('get_compiler_info',gencpp);
        compilerName=compilerInfo.compilerName;
        mexSetEnv=compilerInfo.mexSetEnv;
        if strcmpi(compilerInfo.compilerName,'lcc')
            gencpp=false;
        end
    else
        compilerName=[];
        mexSetEnv=[];
    end
