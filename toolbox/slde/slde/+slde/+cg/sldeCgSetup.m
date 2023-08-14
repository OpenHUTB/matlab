function setupFilePath=sldeCgSetup(nativeBlk,allowedTargets)







    modelHdl=bdroot(nativeBlk);
    setupFilePath='';



    modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(modelHdl);
    if isempty(modelCodegenMgr)
        return;
    end


    directory=[];
    params=get_param(modelHdl,'RTWGenSettings');
    if isstruct(params)&&isfield(params,'RelativeBuildDir')
        directory=[fullfile(pwd,params.RelativeBuildDir),filesep];
    end

    if~isempty(directory)&&exist(directory,'dir')



        targetlang=get_param(modelHdl,'TargetLang');









    end


