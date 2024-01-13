function updatebuildinfo(buildInfo)
    if(ispc())
        emlrtPath=fullfile(matlabroot,'extern','lib','win64','microsoft');
        emlrtLib='libemlrt.lib';
    elseif(ismac())
        emlrtPath=fullfile(matlabroot,'bin','maci64');
        emlrtLib='libemlrt.dylib';
    else
        emlrtPath=fullfile(matlabroot,'bin','glnxa64');
        emlrtLib='libemlrt.so';
    end
    [thisFilePath,~]=fileparts(mfilename('fullpath'));
    addIncludePaths(buildInfo,thisFilePath);
    addLinkObjects(buildInfo,emlrtLib,emlrtPath,1000,false,true);
end


