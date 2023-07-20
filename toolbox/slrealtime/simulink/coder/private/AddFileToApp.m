function res=AddFileToApp(first,system,partName,fileName)









    try
        modelName=system.SystemSourceFileName;
        buildDirStruct=RTW.getBuildDir(modelName);

        if~isModelRef(modelName)
            appInfoFile=fullfile(buildDirStruct.BuildDirectory,...
            'slrtappartifacts.mat');
        else
            appInfoFile=fullfile(buildDirStruct.CodeGenFolder,...
            buildDirStruct.ModelRefRelativeBuildDir,...
            'slrtappartifacts.mat');
        end

        if first==1
            appArtifactsToAdd={};
        else
            if exist(appInfoFile,'file')
                variableInfo=who('-file',appInfoFile);
                if~ismember('appArtifactsToAdd',variableInfo)
                    appArtifactsToAdd={};
                else
                    load(appInfoFile,'appArtifactsToAdd')
                end
            else
                appArtifactsToAdd={};
            end
        end

        if~(ismember(fileName,appArtifactsToAdd)&&ismember(partName,appArtifactsToAdd))
            appArtifactsToAdd=[appArtifactsToAdd;{partName,fileName}];
            save(appInfoFile,'appArtifactsToAdd');
        end
        res=1;
    catch

        res=0;
    end

    function res=isModelRef(mdl)
        res=strcmpi(get_param(mdl,'ModelReferenceTargetType'),'RTW');
