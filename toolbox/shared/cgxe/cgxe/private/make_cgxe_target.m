function[status,binaryDateNum]=make_cgxe_target(fileNameInfo,modelName)



    currDir=pwd;
    [rootDir,isCustomRootDir]=get_cgxe_proj_root();
    if(isCustomRootDir)
        cd(rootDir);
        c=onCleanup(@()cd(currDir));
    end

    delete_cgxe_mex_func(modelName);

    if ispc
        makeCommand=['call ',fileNameInfo.makeBatchFile];
    else
        gmake=[matlabroot,'/bin/',lower(computer),'/gmake'];
        makeCommand=[gmake,' -f ',fileNameInfo.unixMakeFile];
    end
    modelDirectory=pwd;

    [failed,dosOutput]=safely_execute_dos_command(fileNameInfo.targetDirName,makeCommand);
    if(failed)
        makeException=MException(message('Simulink:cgxe:MakeError',modelName));

        dosOutput=strrep(dosOutput,'\','\\');
        cause=MException('Simulink:cgxe:MakeErrorCause',dosOutput);
        makeException=addCause(makeException,cause);
        throw(makeException);
    end

    dllFileName=[fileNameInfo.mexFunctionName,'.',mexext];
    srcFileName=fullfile(fileNameInfo.targetDirName,dllFileName);

    destFileName=fullfile(modelDirectory,dllFileName);

    if exist(srcFileName,'file')
        move_from_project_dir(fileNameInfo.targetDirName,dllFileName,...
        fileNameInfo.dllDirFromMakeDir);

        if ispc
            csfFile=[fileNameInfo.mexFunctionName,'.csf'];
            csfSourceFile=fullfile(fileNameInfo.targetDirName,csfFile);
            csfDestFile=fullfile(modelDirectory,[fileNameInfo.mexFunctionName,'.csf']);
        else
            csfFile=[dllFileName,'.csf'];
            csfSourceFile=fullfile(fileNameInfo.targetDirName,csfFile);
            csfDestFile=fullfile(modelDirectory,[dllFileName,'.csf']);
        end

        if exist(csfSourceFile,'file')
            if exist(csfDestFile,'file')
                cgxe_delete_file(csfDestFile,true);
            end
            move_from_project_dir(fileNameInfo.targetDirName,csfFile,...
            fileNameInfo.dllDirFromMakeDir);
        end

        if ispc



            pdbFile=[fileNameInfo.mexFunctionName,'.','pdb'];
            pdbFullName=fullfile(fileNameInfo.targetDirName,pdbFile);
            if exist(pdbFullName,'file')
                move_from_project_dir(fileNameInfo.targetDirName,pdbFile,...
                fileNameInfo.dllDirFromMakeDir);
            end
        end





        fschange(pwd);

    else
        throw_make_error(message('Simulink:cgxe:FileNotFound',...
        dllFileName,fileNameInfo.targetDirName));
    end

    binaryFileInfo=dir(destFileName);
    binaryDateNum=binaryFileInfo.datenum;

    status=0;


    function move_from_project_dir(projectDir,fileName,relPath)



        currDir=cd(projectDir);
        if ispc
            cgxe_dos(['copy "',fileName,'" ',relPath]);
            cgxe_delete_file(fileName,true);


        else
            [s,w]=unix(['mv ',fileName,' ',relPath]);%#ok<ASGLU>
        end
        cd(currDir);

        copySuccess=exist(fullfile(pwd,fileName),'file');

        if(~copySuccess)
            throw_make_error(message('Simulink:cgxe:FileMoveFailed',...
            fileName,projectDir,pwd));
        else
            if ispc
                cgxe_dos(['attrib -r "',fileName,'"']);
            else
                [s,w]=unix(['chmod +w ',fileName]);%#ok<ASGLU>
            end
        end



        function delete_cgxe_mex_func(modelName)

            mexFunctionName=[modelName,'_cgxe'];

            if exist(mexFunctionName,'file')==3
                try
                    feval(mexFunctionName,'mex_unlock');
                catch ME %#ok<NASGU> %May fail if mex file is corrupt
                end
                clear(mexFunctionName);
            end;

            mexFcnFileName=[mexFunctionName,'.',mexext];
            mexFcnFullFileName=fullfile(pwd,mexFcnFileName);
            if exist(mexFcnFullFileName,'file')
                cgxe_delete_file(mexFcnFileName);
                fschange(pwd);
            end

            if exist(mexFcnFullFileName,'file')

                cgxe_display(DAStudio.message('Simulink:cgxe:DeleteFileFirstAttempt',mexFcnFullFileName));
                clear('mex');
                cgxe_delete_file(mexFcnFileName);
                fschange(pwd);
            end

            if exist(mexFcnFullFileName,'file')&&~isempty(ls(mexFcnFullFileName))
                cgxe_display(DAStudio.message('Simulink:cgxe:DeleteFileSecondAttempt',mexFcnFullFileName));
                throw_make_error(message('Simulink:cgxe:TwoAttemptsToDeleteFile',mexFcnFileName));
            end


            function throw_make_error(errMsg)

                makeException=MException(errMsg);
                throw(makeException);
