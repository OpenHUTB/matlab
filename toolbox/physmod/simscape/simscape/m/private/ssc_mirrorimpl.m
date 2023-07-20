function ssc_mirrorimpl(libraryName,mirrorDir,build)




    mirrorDir=pm_charvector(mirrorDir);
    fprintf('Mirroring ''%s'' in to directory ''%s'' ... \n',libraryName,mirrorDir);


    libraryDir=pwd;
    lValidateLibraryName(libraryDir,libraryName)

    fileExtensions={'.m','.p','.mat',['.',mexext],'.ssc','.sscp'};


    includePrivate=true;
    getSourceFiles=ne_private('ne_packagefiles');
    allFiles=getSourceFiles(['+',libraryName],fileExtensions,includePrivate);


    uniquifySourceFiles=ne_private('ne_uniquifysourcefiles');
    filesToMirror=uniquifySourceFiles(allFiles);

    if isempty(filesToMirror)
        pm_warning('physmod:simscape:simscape:ssc_mirror:EmptyPackage',libraryName);
        return;
    end


    if~exist(mirrorDir,'dir')
        status=mkdir(mirrorDir);
        if~status
            pm_error('physmod:simscape:simscape:ssc_mirror:UnableToCreateDir',mirrorDir);
        end
    else
        prevDir=cd(mirrorDir);
        curDir=pwd;
        if strcmp(prevDir,curDir)
            cd(prevDir);
            pm_error('physmod:simscape:simscape:ssc_mirror:SourceDestinationSame',...
            prevDir,libraryName,curDir);
        end
        cd(prevDir);
    end

    mirrorFullPath=pm_fullpath(mirrorDir);






    for idx=1:numel(filesToMirror)
        sourceFile=filesToMirror{idx};
        [sourceFileDir,sourceFileBase,sourceFileExt]=fileparts(sourceFile);



        sourceRelativePath=regexp(sourceFileDir,'\+.*','match','once');
        d=fullfile(mirrorFullPath,sourceRelativePath);


        if~exist(d,'dir')
            s=mkdir(d);
            if~s
                pm_error('physmod:simscape:simscape:ssc_mirror:UnableToCreateDir',d);
            end
        end


        if strcmp(sourceFileExt,'.ssc')
            cwd=cd(d);
            c=onCleanup(@()cd(cwd));
            ssc_protect(sourceFile);
            c=[];%#ok<NASGU>
        elseif strcmp(sourceFileExt,'.m')
            cwd=cd(d);
            c=onCleanup(@()cd(cwd));
            pcode(sourceFile);
            c=[];%#ok<NASGU>
        else
            copyfile(sourceFile,fullfile(d,[sourceFileBase,sourceFileExt]),'f');
        end


        getImageFile=ne_private('ne_imagefilefromsourcefile');
        [imageExists,imageExt,imageFile]=getImageFile(sourceFile);
        if imageExists
            copyfile(imageFile,fullfile(d,[sourceFileBase,imageExt]),'f');
        end

    end
    fprintf('... mirror complete.\n');


    if build

        cwd=cd(mirrorDir);
        c=onCleanup(@()cd(cwd));
        ssc_build(libraryName);
        c=[];%#ok<NASGU>
    end


end

function lValidateLibraryName(libraryDir,libraryName)


    if strcmp(libraryName(1),'+')
        pm_error('physmod:simscape:simscape:ssc_mirror:InvalidArgument');
    end

    if~isvarname(libraryName)
        pm_error('physmod:simscape:simscape:ssc_mirror:InvalidPackage',libraryName);
    end

    if~exist(fullfile(libraryDir,['+',libraryName]),'dir')
        pm_error('physmod:simscape:simscape:ssc_mirror:CannotFindPackage',libraryName,'ssc_mirror',libraryName);
    end

end
