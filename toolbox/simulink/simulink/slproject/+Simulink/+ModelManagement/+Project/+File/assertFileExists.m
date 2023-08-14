function assertFileExists(file)



    if~exist(file,'file')&&~exist(file,'dir')
        error(message('MATLAB:project:api:FileDoesNotExist',file));
    end

end