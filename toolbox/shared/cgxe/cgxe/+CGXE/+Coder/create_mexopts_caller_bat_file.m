function create_mexopts_caller_bat_file(file,fileNameInfo)



    if~isempty(fileNameInfo.mexSetEnv)

        fprintf(file,'@echo off\n');
        fprintf(file,'%s\n',fileNameInfo.mexSetEnv);
    end
