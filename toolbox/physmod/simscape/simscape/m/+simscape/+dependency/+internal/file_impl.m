function[fn_list,missing_list]=file_impl(fileName,dependencyType,isRecursive,doTMWFile)





    if~isa(dependencyType,'simscape.DependencyType')
        pm_error('physmod:simscape:simscape:dependency:args:WrongTypeParameter',dependencyType);
    end




    fn_list={};
    missing_list={};



    fullFileName=which(fileName);


    if isempty(fullFileName)||strcmpi(fullFileName,'Not on MATLAB path')
        pm_error('physmod:simscape:simscape:dependency:file:NotOnPath',fileName);
        return;
    end

    [fpath,fname,fsuffix]=fileparts(fullFileName);

    if~doTMWFile



        if strfind(fpath,matlabroot)==1
            fn_list={fullFileName};
            missing_list={};
            return;
        end
    end




    if~simscape.internal.is_simscape_file(fullFileName)
        pm_error('physmod:simscape:simscape:dependency:file:SimscapeFileOnly',fileName);
        return;
    end




    if isRecursive
        sourceFileList={fullFileName};
        libraryList={};

        [fn_list,missing_list]=simscape.dependency.internal.recursion(...
        sourceFileList,libraryList,dependencyType,doTMWFile);
        return;
    end




    if int8(dependencyType)>=int8(simscape.DependencyType.Core)


        if strcmpi(fsuffix,'.sscp')


            fullSourceFileName=fullfile(fpath,[fname,'.ssc']);


            dirResults=dir(fullSourceFileName);
            if numel({dirResults.isdir})==1
                [functionList,missingFiles]=lFileAnalysis(fullSourceFileName);
            else
                functionList={};
                missingFiles={};
            end
        else
            if strcmpi(fsuffix,'.ssc')

                [functionList,missingFiles]=lFileAnalysis(fullFileName);

            else




                functionList={};
                missingFiles={};
            end
        end

        fn_list=[fn_list,fullFileName];
        fn_list=[fn_list,functionList];
        missing_list=[missing_list,missingFiles];
    end

    if int8(dependencyType)>=int8(simscape.DependencyType.Auxiliary)

        fcnHandle=ne_private('ne_imagefilefromsourcefile');
        [imageExists,imageExt,imageFile]=fcnHandle(fullFileName);%#ok
        if imageExists
            fn_list=[fn_list,{pm_fullpath(imageFile)}];
        end
    end

    if int8(dependencyType)>=int8(simscape.DependencyType.Derived)
    end

    if int8(dependencyType)>=int8(simscape.DependencyType.Simulink)

        dlgFileName=lGetFile('ne_dlgfile',fullFileName);
        if exist(dlgFileName,'file')
            fn_list=[fn_list,{dlgFileName}];
        end
    end


    fn_list=unique(fn_list);
    missing_list=unique(missing_list,'legacy');

end

function fullFileName=lGetFile(functionGetter,fileName)



    fcnHandle=ne_private(functionGetter);

    fullFileName=fcnHandle(fileName);

end

function[functionList,missingFiles]=lFileAnalysis(fullFileName)



    [functionList,missingFiles]=...
    simscape.compiler.dependency.internal.ssc_dependency_file(fullFileName);
end

