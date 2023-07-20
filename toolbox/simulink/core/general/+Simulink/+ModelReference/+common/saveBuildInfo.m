function saveBuildInfo(buildInfoPath,buildInfo,buildOpts)




    save(fullfile(buildInfoPath,'buildInfo.mat'),'-v7',...
    'buildInfo','buildOpts');
