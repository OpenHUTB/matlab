



function generateSLProtectedModel(~,hC,originalBlkPath,targetBlkPath)

    modelName=strtok(originalBlkPath,'/');
    gmModelName=strtok(targetBlkPath,'/');

    modFile=get_param(originalBlkPath,'ModelFile');
    [~,origModelRefName,~]=fileparts(modFile);

    hDrv=hdlcurrentdriver;
    codegenDirName=hDrv.hdlGetBaseCodegendir;
    if isAbsolutePath(codegenDirName)
        gmProtectedModelPath=fullfile(codegenDirName,origModelRefName);
    else
        gmProtectedModelPath=fullfile(pwd,codegenDirName,origModelRefName);
    end
    if ispc
        gmProtectedModelPath=strrep(gmProtectedModelPath,'/',filesep);
    else
        gmProtectedModelPath=strrep(gmProtectedModelPath,'\',filesep);
    end

    gmPrefix=hdlget_param(modelName,'GeneratedModelNamePrefix');

    if isprop(get_param(hC.SimulinkHandle,'Object'),'ProtectedModel')&&...
        strcmp(get_param(hC.SimulinkHandle,'ProtectedModel'),'on')
        pkgFile=slInternal('getPackageNameForModel',origModelRefName);
        gmProtectedModelName=[gmPrefix,pkgFile];
    else

        gmProtectedModelName=[gmPrefix,origModelRefName,'.slx'];
    end


    oldpath=addpath(gmProtectedModelPath);

    blkH=add_block('simulink/Ports & Subsystems/Model',targetBlkPath,'MakeNameUnique','on');
    set_param(blkH,'ModelName',gmProtectedModelName);


    path(oldpath);


    preLoadFcn=get_param(gmModelName,'PreLoadFcn');
    preloadPath=gmProtectedModelPath;
    preloadfcnForProtectedMdl=sprintf('%s\naddpath(''%s'');\n',preLoadFcn,preloadPath);
    set_param(gmModelName,'PreLoadFcn',preloadfcnForProtectedMdl);


    initFcn=get_param(gmModelName,'InitFcn');
    initPath=gmProtectedModelPath;
    initfcnForProtectedMdl=sprintf('%s\naddpath(''%s'');\n',initFcn,initPath);
    set_param(gmModelName,'InitFcn',initfcnForProtectedMdl);


    closeFcn=get_param(gmModelName,'CloseFcn');
    closefcnForProtectedMdl=sprintf('%s\naddpath(''%s'');\nrmpath(''%s'');\n',...
    closeFcn,preloadPath,preloadPath);
    set_param(gmModelName,'CloseFcn',closefcnForProtectedMdl);

    hC.setGMHandle(blkH);
end


function isAbsPath=isAbsolutePath(aPath)
    if strcmp(filesep,aPath(1))
        isAbsPath=true;
    elseif ispc&&numel(aPath)>1&&isletter(aPath(1))&&strcmp(aPath(2),':')

        isAbsPath=true;
    else
        isAbsPath=false;
    end
end


