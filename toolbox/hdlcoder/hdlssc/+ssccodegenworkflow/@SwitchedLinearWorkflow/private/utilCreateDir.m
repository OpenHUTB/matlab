function utilCreateDir(dirName)


    if~exist(dirName,'dir')
        mkdir(dirName);
    end
end