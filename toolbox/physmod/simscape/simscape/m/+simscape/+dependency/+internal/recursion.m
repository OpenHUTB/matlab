function[fn_list,missing,reference2fnlist,reference2missing]=recursion(sourceFileList,fullLibraryList,dependencyType,doTMWFile,reference2sflist,reference2libList)





















    if nargin==4
        needReference=false;

        reference2fnlist={};
    else
        needReference=true;

        reference2fnlist=reference2sflist;


        fileReference='Simscape';
    end

    fn_list={};
    missing={};

    reference2missing={};


    pkgNameHandle=ne_private('ne_packagenamefromdirectorypath');




    libraryList={};
    libraryDirList={};
    for i=1:numel(fullLibraryList)
        [parentDir,libName]=pkgNameHandle(fullLibraryList{i});

        if~isempty(libName)


            if~ismember(libName,libraryList)

                libraryList{end+1}=libName;
                libraryDirList{end+1}=parentDir;
            end

        end
    end






    indexFile=0;
    indexLibrary=0;


    while(indexFile<numel(sourceFileList))||(indexLibrary<numel(libraryList))


        while indexFile<numel(sourceFileList)
            indexFile=indexFile+1;


            fileName=sourceFileList{indexFile};



            libDirName=fileparts(fileName);

            if~isempty(libDirName)

                [parentDir,libName]=pkgNameHandle(libDirName);

                if~isempty(libName)

                    [isIn,loc]=ismember(libName,libraryList);


                    if~isIn

                        if~doTMWFile

                            if strfind(parentDir,matlabroot)==1

                            else
                                libraryList{end+1}=libName;
                                libraryDirList{end+1}=parentDir;









                                if needReference&&...
                                    simscape.internal.is_simscape_file(fileName)

                                    ref.names={fileName};
                                    ref.type={fileReference};

                                    reference2libList{end+1}=ref;
                                end

                            end

                        else
                            libraryList{end+1}=libName;
                            libraryDirList{end+1}=parentDir;















                            if needReference&&...
                                simscape.internal.is_simscape_file(fileName)

                                ref.names={fileName};
                                ref.type={fileReference};

                                reference2libList{end+1}=ref;
                            end

                        end

                    else

                        if needReference&&...
                            simscape.internal.is_simscape_file(fileName)

                            [isIn,loc2]=ismember(fileName,reference2libList{loc}.names);



                            if~isIn
                                reference2libList{loc}.names{end+1}=fileName;
                                reference2libList{loc}.type{end+1}=fileReference;
                            else














                                if~strcmpi(reference2libList{loc}.type{loc2},fileReference)
                                    reference2libList{loc}.names{end+1}=fileName;
                                    reference2libList{loc}.type{end+1}=fileReference;
                                end
                            end
                        end

                    end

                    continue;
                end
            end


            if~simscape.internal.is_simscape_file(fileName)




                continue;

            else





                [fileList,missingList]=simscape.dependency.file(...
                fileName,dependencyType,false,doTMWFile);





                for j=1:numel(fileList)
                    [isIn,loc]=ismember(fileList{j},sourceFileList);

                    if~isIn
                        sourceFileList{end+1}=fileList{j};



                        if needReference
                            ref.names={fileName};
                            ref.type={fileReference};

                            reference2fnlist{end+1}=ref;
                        end
                    else









                        if needReference
                            [isIn,loc2]=ismember(fileName,reference2fnlist{loc}.names);



                            if~isIn
                                reference2fnlist{loc}.names{end+1}=fileName;%#ok<*AGROW>
                                reference2fnlist{loc}.type{end+1}=fileReference;
                            else
                                if~strcmpi(reference2fnlist{loc}.type{loc2},fileReference)
                                    reference2fnlist{loc}.names{end+1}=fileName;
                                    reference2fnlist{loc}.type{end+1}=fileReference;
                                end
                            end
                        end
                    end
                end


                for j=1:numel(missingList)
                    [isIn,loc]=ismember(missingList{j},missing);

                    if~isIn
                        missing{end+1}=missingList{j};%#ok<AGROW>



                        if needReference
                            ref.names={fileName};
                            ref.type={fileReference};

                            reference2missing{end+1}=ref;
                        end
                    else







                        if needReference
                            [isIn,loc2]=ismember(fileName,reference2missing{loc}.names);



                            if~isIn
                                reference2missing{loc}.names{end+1}=fileName;
                                reference2missing{loc}.type{end+1}=fileReference;
                            else
                                if~strcmpi(reference2missing{loc}.type{loc2},fileReference)
                                    reference2missing{loc}.names{end+1}=fileName;
                                    reference2missing{loc}.type{end+1}=fileReference;
                                end
                            end
                        end

                    end
                end
            end
        end


        while indexLibrary<numel(libraryList)
            indexLibrary=indexLibrary+1;


            libName=libraryList{indexLibrary};
            libDir=libraryDirList{indexLibrary};


            [fileList,missingList]=lLibAnalysis(libName,libDir,dependencyType,doTMWFile);





            for j=1:numel(fileList)
                [isIn,loc]=ismember(fileList{j},sourceFileList);

                if~isIn
                    sourceFileList{end+1}=fileList{j};%#ok<AGROW>



                    if needReference
                        ref.names=reference2libList{indexLibrary}.names;
                        ref.type=reference2libList{indexLibrary}.type;

                        reference2fnlist{end+1}=ref;
                    end
                else
                    if needReference

                        for i=1:numel(reference2libList{indexLibrary}.names)

                            fileName=reference2libList{indexLibrary}.names{i};
                            refType=reference2libList{indexLibrary}.type{i};

                            [isIn,loc2]=ismember(fileName,reference2fnlist{loc}.names);



                            if~isIn
                                reference2fnlist{loc}.names{end+1}=fileName;
                                reference2fnlist{loc}.type{end+1}=refType;
                            else
                                if~strcmpi(reference2fnlist{loc}.type{loc2},refType)
                                    reference2fnlist{loc}.names{end+1}=fileName;
                                    reference2fnlist{loc}.type{end+1}=refType;
                                end
                            end
                        end
                    end
                end
            end


            for j=1:numel(missingList)
                [isIn,loc]=ismember(missingList{j},missing);

                if~isIn
                    missing{end+1}=missingList{j};%#ok<AGROW>



                    if needReference
                        ref.names=reference2libList{indexLibrary}.names;
                        ref.type=reference2libList{indexLibrary}.type;

                        reference2missing{end+1}=ref;
                    end
                else
                    if needReference
                        for i=1:numel(reference2libList{indexLibrary}.names)

                            fileName=reference2libList{indexLibrary}.names{i};
                            refType=reference2libList{indexLibrary}.type{i};

                            [isIn,loc2]=ismember(fileName,reference2missing{loc}.names);



                            if~isIn
                                reference2missing{loc}.names{end+1}=fileName;
                                reference2missing{loc}.type{end+1}=refType;
                            else
                                if~strcmpi(reference2missing{loc}.type{loc2},refType)
                                    reference2missing{loc}.names{end+1}=fileName;
                                    reference2missing{loc}.type{end+1}=refType;
                                end
                            end
                        end
                    end

                end
            end
        end

    end

    fn_list=[fn_list,sourceFileList];
end

function[fileList,missingList]=lLibAnalysis(libName,libParentDir,dependencyType,doTMWFile)


    currentPath=pwd;

    cd(libParentDir);

    if strcmpi(libParentDir,...
        [fullfile(matlabroot,'toolbox','physmod','simscape',...
        'simscape'),filesep])&&strcmpi(libName,'foundation')





        [fileList,missingList]=...
        simscape.dependency.lib(libName,...
        dependencyType,...
        'fl_lib',false,doTMWFile);
    else





        [fileList,missingList]=simscape.dependency.lib(libName,...
        dependencyType,...
        '',false,doTMWFile);
    end

    cd(currentPath);
end

