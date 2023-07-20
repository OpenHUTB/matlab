function assertIsDirectory(file)



    if~exist(file,'dir')
        error(message('MATLAB:project:api:IsNotDirectory',file));
    end

end