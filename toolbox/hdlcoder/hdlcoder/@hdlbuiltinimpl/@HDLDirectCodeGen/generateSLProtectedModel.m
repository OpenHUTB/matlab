


function generateSLProtectedModel(~,hC,originalBlkPath,targetBlkPath)

    modelName=strtok(originalBlkPath,'/');
    gmModelName=strtok(targetBlkPath,'/');

    modFile=get_param(originalBlkPath,'ModelFile');
    [~,origModelRefName,~]=fileparts(modFile);

    codegenDirName=hdlget_param(modelName,'TargetDirectory');
    if ispc
        codegenDirName=strrep(codegenDirName,'/',filesep);
    else
        codegenDirName=strrep(codegenDirName,'\',filesep);
    end
    gmProtectedModelPath=fullfile(codegenDirName,modelName,origModelRefName);
    gmPrefix=hdlget_param(modelName,'GeneratedModelNamePrefix');
    pkgFile=slInternal('getPackageNameForModel',origModelRefName);
    gmProtectedModelName=[gmPrefix,pkgFile];


    addpath(gmProtectedModelPath);

    blkH=add_block('simulink/Ports & Subsystems/Model',targetBlkPath,'MakeNameUnique','on');
    set_param(blkH,'ModelName',gmProtectedModelName);
    currDir=pwd;
    preloadPath=fullfile(currDir,gmProtectedModelPath);
    preloadfcnForProtectedMdl=['addpath(','''',preloadPath,'''',');'];
    set_param(gmModelName,'PreloadFcn',preloadfcnForProtectedMdl);
    hC.setGMHandle(blkH);
end


