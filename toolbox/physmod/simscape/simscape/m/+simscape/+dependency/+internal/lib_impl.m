function[fn_list,missing]=lib_impl(libName,dependencyType,mdlFileName,isRecursive,doTMWFile)







    fn_list={};
    missing={};




    if int8(dependencyType)>=int8(simscape.DependencyType.Auxiliary)

        fcnHandle=ne_private('ne_libfilename');
        libFileName=fullfile(libName,[fcnHandle(),'.m']);
        if exist(libFileName,'file')
            fn_list=[fn_list,{pm_fullpath(libFileName)}];
        end


        fcnHandle=ne_private('ne_imagefilefromsourcefile');
        [imageExists,imageExt,imageFile]=fcnHandle(libFileName);%#ok
        if imageExists
            fn_list=[fn_list,{pm_fullpath(imageFile)}];
        end
    end

    if int8(dependencyType)>=int8(simscape.DependencyType.Derived)

    end

    if int8(dependencyType)>=int8(simscape.DependencyType.Simulink)


        fcnHandle=ne_private('ne_slpostprocessfilename');
        slppFileName=fullfile(libName,[fcnHandle(),'.m']);
        if exist(slppFileName,'file')
            fn_list=[fn_list,{pm_fullpath(slppFileName)}];
        end
    end




    dirList=dir(libName);




    fileNameList=dirList(~[dirList.isdir]);






    dirNameList=dirList([dirList.isdir]);


    dirNameList=dirNameList(~strcmp({dirNameList.name},'.'));


    dirNameList=dirNameList(~strcmp({dirNameList.name},'..'));


    dirNameList=dirNameList(cellfun(@(a)strcmp(a(1),'+'),{dirNameList.name}));




    for i=1:size(fileNameList,1)
        item=fileNameList(i);




        if simscape.internal.is_simscape_file(fullfile(libName,item.name))
            [fileList,missingList]=simscape.dependency.file(...
            fullfile(libName,item.name),...
            dependencyType,isRecursive,doTMWFile);

            fn_list=[fn_list,fileList];%#ok<AGROW>
            missing=[missing,missingList];%#ok<AGROW>
        end
    end




    for i=1:size(dirNameList,1)
        item=dirNameList(i);


        [fileList,missingList]=simscape.dependency.internal.lib_impl(...
        fullfile(libName,item.name),dependencyType,mdlFileName,isRecursive,doTMWFile);
        fn_list=[fn_list,fileList];%#ok<AGROW>
        missing=[missing,missingList];%#ok<AGROW>

    end


    fn_list=unique(fn_list);
    missing=unique(missing);

end

