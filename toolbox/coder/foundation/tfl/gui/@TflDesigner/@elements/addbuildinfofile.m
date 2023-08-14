function addbuildinfofile(this,dlghandle,widgettag)%#ok







    switch widgettag

    case 'Tfldesigner_AddHeaderFile'
        [filename,path]=uigetfile({'*.h;*.hpp','Header File (*.h, *.hpp)'},...
        DAStudio.message('RTW:tfldesigner:BrowseImplHeaderFile'));
        if filename~=0
            this.object.Implementation.HeaderFile=filename;
            this.object.Implementation.HeaderPath=path;
        end

    case 'Tfldesigner_AddSourceFile'
        if strcmp(class(this.object.Implementation),'RTW.CPPImplementation')
            [filename,path]=uigetfile({'*.c;*.cpp','Source File (*.c, *.cpp)';
            '*.*','All files (*.*)'},...
            DAStudio.message('RTW:tfldesigner:BrowseImplSourceFile'));
            if filename~=0
                this.object.Implementation.SourceFile=filename;
                this.object.Implementation.SourcePath=path;
            end
        else
            [filename,path]=uigetfile({'*.c','Source File (*.c)';
            '*.*','All files (*.*)'},...
            DAStudio.message('RTW:tfldesigner:BrowseImplSourceFile'));
            if filename~=0
                this.object.Implementation.SourceFile=filename;
                this.object.Implementation.SourcePath=path;
            end
        end

    case 'Tfldesigner_AddAdditionalHeadFiles'
        [filename,path]=uigetfile({'*.h;*.hpp','Header Files (*.h, *.hpp)'},...
        DAStudio.message('RTW:tfldesigner:BrowseAddHeaderFiles'),...
        'MultiSelect','on');
        loc_addAdditionalHeaderFiles(this,filename,path);

    case 'Tfldesigner_AddAdditionalHeadPaths'
        dirname=uigetdir(pwd,DAStudio.message('RTW:tfldesigner:BrowseAddIncludeFiles'));
        if dirname~=0
            if isempty(find(strcmp(this.object.AdditionalIncludePaths,dirname),1))
                this.object.AdditionalIncludePaths=[this.object.AdditionalIncludePaths;dirname];
            end
        end

    case 'Tfldesigner_AddAdditionalSourceFiles'
        if strcmp(class(this.object.Implementation),'RTW.CPPImplementation')
            [filename,path]=uigetfile({'*.c;*.cpp','Source Files (*.c, *.cpp)';
            '*.*','All files (*.*)'},...
            DAStudio.message('RTW:tfldesigner:BrowseAddSourceFiles'),...
            'MultiSelect','on');
        else
            [filename,path]=uigetfile({'*.c','Source Files(*.c)';
            '*.*','All files (*.*)'},...
            DAStudio.message('RTW:tfldesigner:BrowseAddSourceFiles'),...
            'MultiSelect','on');
        end
        loc_addAdditionalSourceFiles(this,filename,path);

    case 'Tfldesigner_AddAdditionalSourcePaths'
        dirname=uigetdir(pwd,DAStudio.message('RTW:tfldesigner:BrowseAddSourcePath'));
        if dirname~=0
            if isempty(find(strcmp(this.object.AdditionalSourcePaths,dirname),1))

                this.object.AdditionalSourcePaths=[this.object.AdditionalSourcePaths;dirname];
            end
        end

    case 'Tfldesigner_AddAdditionalLinkFiles'
        if ispc
            [filename,path]=uigetfile({'*.o;*.lib','Link Files (*.o, *.lib)'},...
            DAStudio.message('RTW:tfldesigner:BrowseAddLinkObjFiles'),...
            'MultiSelect','on');
        elseif ismac
            [filename,path]=uigetfile({'*.o;*.dylib;.a','Link Files (*.o, *.a, *.dylib)'},...
            DAStudio.message('RTW:tfldesigner:BrowseAddLinkObjFiles'),...
            'MultiSelect','on');
        else
            [filename,path]=uigetfile({'*.o;*.so;*.a','Link Files (*.o, *.so, *.a)'},...
            DAStudio.message('RTW:tfldesigner:BrowseAddLinkObjFiles'),...
            'MultiSelect','on');
        end
        loc_addAdditionalLinkFiles(this,filename,path);

    case 'Tfldesigner_AddAdditionalLinkPath'
        dirname=uigetdir(pwd,DAStudio.message('RTW:tfldesigner:BrowseAddLinkPath'));
        if dirname~=0
            if isempty(find(strcmp(this.object.AdditionalLinkObjsPaths,dirname),1))
                this.object.AdditionalLinkObjsPaths=[this.object.AdditionalLinkObjsPaths;dirname];
            end
        end
    end
    wasDirty=this.parentnode.isDirty;
    this.isValid=false;
    this.parentnode.isDirty=true;
    this.isDirty=true;

    if~wasDirty
        this.parentnode.firehierarchychanged;
    end


    function loc_addAdditionalHeaderFiles(this,filename,path)
        if iscell(filename)||~isnumeric(filename)
            if iscell(filename)
                include=false;
                for id=1:length(filename)
                    this.object.AdditionalHeaderFiles=[this.object.AdditionalHeaderFiles;filename{id}];
                    include=true;
                end
                if include&&isempty(find(strcmp(this.object.AdditionalIncludePaths,path(1:end-1)),1))
                    this.object.AdditionalIncludePaths=[this.object.AdditionalIncludePaths;path(1:end-1)];
                end
            else
                this.object.AdditionalHeaderFiles=[this.object.AdditionalHeaderFiles;filename];
                if isempty(find(strcmp(this.object.AdditionalIncludePaths,path(1:end-1)),1))
                    this.object.AdditionalIncludePaths=[this.object.AdditionalIncludePaths;path(1:end-1)];
                end
            end
        end

        function loc_addAdditionalSourceFiles(this,filename,path)
            if iscell(filename)||~isnumeric(filename)
                if iscell(filename)
                    include=false;
                    for id=1:length(filename)
                        this.object.AdditionalSourceFiles=[this.object.AdditionalSourceFiles;filename{id}];
                        include=true;
                    end
                    if include&&isempty(find(strcmp(this.object.AdditionalSourcePaths,path(1:end-1)),1))
                        this.object.AdditionalSourcePaths=[this.object.AdditionalSourcePaths;path(1:end-1)];
                    end
                else
                    this.object.AdditionalSourceFiles=[this.object.AdditionalSourceFiles;filename];
                    if isempty(find(strcmp(this.object.AdditionalSourcePaths,path(1:end-1)),1))
                        this.object.AdditionalSourcePaths=[this.object.AdditionalSourcePaths;path(1:end-1)];
                    end
                end
            end

            function loc_addAdditionalLinkFiles(this,filename,path)
                if iscell(filename)||~isnumeric(filename)
                    if iscell(filename)
                        include=false;
                        for id=1:length(filename)
                            this.object.AdditionalLinkObjs=[this.object.AdditionalLinkObjs;filename{id}];
                            include=true;
                        end
                        if include&&isempty(find(strcmp(this.object.AdditionalLinkObjsPaths,path(1:end-1)),1))
                            this.object.AdditionalLinkObjsPaths=[this.object.AdditionalLinkObjsPaths;path(1:end-1)];
                        end
                    else
                        this.object.AdditionalLinkObjs=[this.object.AdditionalLinkObjs;filename];
                        if isempty(find(strcmp(this.object.AdditionalLinkObjsPaths,path(1:end-1)),1))
                            this.object.AdditionalLinkObjsPaths=[this.object.AdditionalLinkObjsPaths;path(1:end-1)];
                        end
                    end
                end


