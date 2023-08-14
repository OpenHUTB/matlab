function removeTempFiles(obj)




    if isempty(obj.rangeFileLoc)


        parentDir=pwd;
        fixpt_outputDir=fullfile(parentDir,'fixpt_output');
        if isempty(obj.subsystem)
            dirModelName=fullfile(fixpt_outputDir,obj.model);
        else
            newModelName=get_param(obj.subsystem,'Name');
            dirModelName=fullfile(fixpt_outputDir,newModelName);
        end

    else


        result_file_full_path=fullfile(obj.rangeFileLoc.DataFile);
        dirModelName=fileparts(result_file_full_path);

        fixpt_outputDir=fileparts(dirModelName);
        parentDir=fileparts(fixpt_outputDir);

    end

    rtwgen_tlcDir=fullfile(dirModelName,'rtwgen_tlc');
    [success_rtw,~,~]=rmdir(rtwgen_tlcDir);

    wildCardFileNames=fullfile(dirModelName,'*');
    delete(wildCardFileNames);


    [success_mdldir,~,~]=rmdir(dirModelName);%#ok<ASGLU>

    [success_fxpout,~,~]=rmdir(fixpt_outputDir);

    success=success_rtw&&success_mdldir&&success_fxpout;
