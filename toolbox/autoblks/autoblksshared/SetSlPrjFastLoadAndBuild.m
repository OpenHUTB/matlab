function SetSlPrjFastLoadAndBuild()



    p=slproject.getCurrentProject;

    projectRoot=p.RootFolder;
    myCacheFolder=fullfile(projectRoot,'Work');
    if~exist(myCacheFolder,'dir')
        mkdir(myCacheFolder);
    end
    Simulink.fileGenControl('set','CacheFolder',myCacheFolder,...
    'CodeGenFolder',myCacheFolder);

end
