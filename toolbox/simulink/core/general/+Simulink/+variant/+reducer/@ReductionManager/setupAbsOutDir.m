









function err=setupAbsOutDir(optArgs)
    err=[];

    outDir=optArgs.getOptions().OutputFolder;
    origModelPath=optArgs.getOptions().OrigModelDirPath;

    try





        [folderStatus,attribs]=fileattrib(outDir);
    catch err
        return;
    end

    if folderStatus
        absOutDirPath=attribs.Name;
    else
        try


            mkdir(outDir);
        catch
            errid='Simulink:Variants:CannotCreateOutputDir';
            errmsg=message(errid,outDir);
            err=MException(errmsg);
            return;
        end

        try
            [~,attribs]=fileattrib(outDir);
        catch err
            return;
        end

        absOutDirPath=attribs.Name;
        optArgs.getOptions().NewDirCreatedNoLog=true;
    end

    optArgs.getOptions().AbsOutDirPath=absOutDirPath;


    if strcmp(origModelPath,absOutDirPath)


        errid='Simulink:Variants:SameSrcAndDstDirs';
        errmsg=message(errid,optArgs.getOptions().TopModelOrigName,absOutDirPath);
        err=MException(errmsg);
        return;
    end



    if contains(origModelPath,absOutDirPath)


        errid='Simulink:Variants:ModelPathUnderOutputDir';
        errmsg=message(errid,optArgs.getOptions().TopModelOrigName,origModelPath,absOutDirPath);
        err=MException(errmsg);
        return;
    end


    if contains(absOutDirPath,matlabroot)


        errid='Simulink:VariantReducer:OutputDirInstall';
        errmsg=message(errid,absOutDirPath);
        err=MException(errmsg);
        return;
    end




    if contains(optArgs.getEnvironment().getPWD(),absOutDirPath)&&~strcmp(optArgs.getEnvironment().getPWD(),absOutDirPath)


        errid='Simulink:Variants:ReducerCWDUnderOutputDir';
        errmsg=message(errid,optArgs.getEnvironment().getPWD(),absOutDirPath);
        err=MException(errmsg);
        return;
    end

    try

        [~,tempFileName,~]=fileparts(tempname);
        tempFileName=[absOutDirPath,filesep,tempFileName];
        fid=fopen(tempFileName,'w');
        if fid==-1
            errid='Simulink:Variants:OutputDirNotWritable';
            errmsg=message(errid,absOutDirPath);
            err=MException(errmsg);
            return;
        else
            fclose(fid);
            delete(tempFileName);
        end
    catch err
        return;
    end

    try
        dirContents=dir(absOutDirPath);
    catch err
        return;
    end

    if numel(dirContents)>2&&~any(strcmp({dirContents.name},'variant_reducer.log'))


        errid='Simulink:Variants:OutputDirPublic';
        errmsg=message(errid,absOutDirPath);
        err=MException(errmsg);
        return;
    end

    try
        Simulink.variant.reducer.utils.deleteDirectoryContents(absOutDirPath,false);
        dirContents=dir(absOutDirPath);
    catch err
        return;
    end

    if numel(dirContents)>2
        errid='Simulink:Variants:OutputDirUnclean';
        errmsg=message(errid,absOutDirPath);
        err=MException(errmsg);
        return;
    end






    try
        addpath(optArgs.getOptions().OrigModelDirPath,'-end');
        addpath(absOutDirPath,'-end');
        optArgs.getOptions().DirAddedToPath=true;

        optArgs.getOptions().RedModelFullName=[absOutDirPath,filesep,optArgs.getOptions().RedModelFullName];

        if~strcmp(optArgs.getEnvironment().getPWD(),absOutDirPath)
            addpath(optArgs.getEnvironment().getPWD());
            cd(absOutDirPath);
        end
    catch err
        return;
    end

end


