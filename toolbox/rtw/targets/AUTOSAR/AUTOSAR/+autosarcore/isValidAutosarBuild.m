function validBuild=isValidAutosarBuild(modelName)




    if nargin>0
        modelName=convertStringsToChars(modelName);
    end
    validBuild=true;

    RTWTemplateMakefile=get_param(modelName,'RTWTemplateMakefile');
    RTWGenerateCodeOnly=get_param(modelName,'RTWGenerateCodeOnly');
    CreateSILPILBlock=get_param(modelName,'CreateSILPILBlock');


    modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(modelName);
    if modelCodegenMgr.MdlRefBuildArgs.XilInfo.IsTopModelXil
        isTopModelSilOrPilBuild=true;
    else
        isTopModelSilOrPilBuild=false;
    end




    lMexCompilerKey=coder.internal.CompInfoCacheForAutosar.getModelMexCompilerKeyCache;

    if coder.make.internal.isConvertibleToToolchainApproachSL...
        (getActiveConfigSet(modelName),lMexCompilerKey)

        invalidBuild=true;
    else

        files=dir(fullfile(matlabroot,'rtw','c','ert','*.tmf'));
        ert_tmfs={files.name};
        invalidTMFs=[{'ert_default_tmf'},ert_tmfs];

        invalidBuild=any(strcmp(RTWTemplateMakefile,invalidTMFs));
    end

    if(invalidBuild&&...
        strcmp(RTWGenerateCodeOnly,'off')&&...
        strcmp(CreateSILPILBlock,'None')&&...
        ~isTopModelSilOrPilBuild)
        validBuild=false;
    end
end
