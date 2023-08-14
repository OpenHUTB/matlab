









function CopyLocalDllsForRSIM(modelName,codegenFolder)





    try
        strpc=computer();
        if strcmp(strpc,'PCWIN64')
            localDllFolder=fullfile(codegenFolder,[modelName,'.exe.local']);



            if exist(localDllFolder,'dir')
                rmdir(localDllFolder);
            end

            mkdir(localDllFolder);

            copyfile([matlabroot,'\bin\win64\tbb.dll'],localDllFolder);
            fileattrib([localDllFolder,'\tbb.dll'],'+w','');
        end
    catch ME


    end

end
