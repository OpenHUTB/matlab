function checkRootLocation(mlRootLoc)




    mlExeFile=fullfile(mlRootLoc,'bin','matlab');
    if(ispc)
        mlExeFile=[mlExeFile,'.exe'];
    end
    if(~exist(mlExeFile,'file'))
        error(message('stm:MultipleReleaseTesting:MATLABRootPathError'));
    end
end
