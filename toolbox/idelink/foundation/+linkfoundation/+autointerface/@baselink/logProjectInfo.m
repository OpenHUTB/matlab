function logProjectInfo(h,ProjectBuildInfo)





    toolinfo=struct('Install_Dir',h.getHomeDir,...
    'modelPath',fileparts(pwd),...
    'pjtPath',pwd);
    filename=fullfile(toolinfo.pjtPath,[ProjectBuildInfo.mModelName,'_projectInfo.mat']);
    save(filename,'toolinfo');