function makeInfo=rtwmakecfg()





    makeInfo.includePath={...
    fullfile(matlabroot,'toolbox','physmod','powersys','facts','facts'),...
    fullfile(matlabroot,'toolbox','physmod','powersys','DR','DR')};

    makeInfo.sourcePath={...
    fullfile(matlabroot,'toolbox','physmod','powersys','powersys')};


