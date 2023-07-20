function baseRoot=getBaseDir()




    filePath=fileparts(mfilename('fullpath'));
    tmp=regexp(filePath,'(.+)toolbox.+$','tokens','once');
    baseRoot=tmp{1};
end

