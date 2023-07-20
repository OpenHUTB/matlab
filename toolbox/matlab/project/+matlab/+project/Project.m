classdef Project<matlab.mixin.CustomDisplay&dynamicprops





















    properties(Dependent=true,GetAccess=public,SetAccess=public)

Name
    end

    properties(Dependent=true,GetAccess=public,SetAccess=private)


SourceControlIntegration

RepositoryLocation

SourceControlMessages

ReadOnly

TopLevel

Dependencies
    end

    properties(Dependent=true,GetAccess=public,SetAccess=public)

Categories

Files

Shortcuts


ProjectPath

ProjectReferences

StartupFiles

ShutdownFiles

DefinitionFilesType

Description
    end

    properties(GetAccess=public,SetAccess=private)

RootFolder
    end

    properties(GetAccess=private,SetAccess=private,Hidden=true)
ProjectContainer
ProjectInstance
    end

    properties(GetAccess=private,SetAccess=private,Hidden=true,Transient)
        JavaMatlabProjectManager;
    end

    properties(Dependent=true,GetAccess=public,SetAccess=private,Hidden=true)
        HasStartupErrors;
    end


    methods(Access=public,Hidden=true)
        function obj=Project(varargin)





            import matlab.internal.project.util.*;

            if~isDesktopAvailable()
                com.mathworks.toolbox.slproject.Exceptions.ProjectExceptionHandler.setShowDialogs(false);
            end

            if nargin==0
                projectContainer=[];
            else
                projectContainer=varargin{1};
            end

            privateConstructorInputValidate(...
            projectContainer,...
'matlab.internal.project.containers.ProjectContainer'...
            );

            obj.ProjectContainer=projectContainer;
            import matlab.internal.project.util.ProjectInstance;
            obj.ProjectInstance=ProjectInstance(projectContainer);

            obj.RootFolder=string(obj.ProjectInstance.getProjectRoot());

            import matlab.internal.project.util.processJavaCall;
            obj.JavaMatlabProjectManager=processJavaCall(...
            @()obj.ProjectContainer.getMatlabAPIProjectManager()...
            );

            obj.addWorkingFolderProperties();

        end

        function mgr=getMetaDataManagerName(obj)

            mgr=string([obj.JavaMatlabProjectManager.getMetadataManagerName()]');%#ok<NBRAK>
        end

    end

    methods(Access=public)
        function results=runChecks(~)
















            projectControlSet=com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPICurrentContext.get();
            projectChecker=com.mathworks.toolbox.slproject.project.integrity.ProjectChecker(projectControlSet);
            checkIterator=projectChecker.getChecks().iterator;

            results=matlab.project.ProjectCheckResult.empty;
            while(checkIterator.hasNext)
                check=checkIterator.next;
                passed=matlab.internal.project.util.processJavaCall(@()check.runCheck());
                thisResult=matlab.project.ProjectCheckResult(check,passed);
                results=[results;thisResult];%#ok<AGROW>
            end

        end


        function close(obj)









            validateattributes(obj,{'matlab.project.Project'},{'size',[1,1]},'','project')

            assertProjectIsNotRunningAShortcut();

            javaProjectControlSet=obj.ProjectContainer.getJavaProjectControlSet();
            if(isempty(javaProjectControlSet))
                error(message('MATLAB:project:api:CurrentProjectMismatch',obj.RootFolder));
            end

            import matlab.internal.project.util.processJavaCall;
            processJavaCall(@()javaProjectControlSet.close());

        end

        function loaded=isLoaded(obj)










            validateattributes(obj,{'matlab.project.Project'},{'size',[1,1]},'','project');
            loaded=true;
            try
                obj.ProjectContainer.getJavaProjectControlSet();
            catch exception
                if(ismember(exception.identifier,...
                    {'MATLAB:project:api:NoProjectCurrentlyLoaded',...
                    'MATLAB:project:api:CurrentProjectMismatch',...
                    'MATLAB:project:api:StaleProjectHandle'}))
                    loaded=false;
                else
                    exception.rethrow;
                end
            end
        end

        function reload(obj)










            validateattributes(obj,{'matlab.project.Project'},{'size',[1,1]},'','project');

            if isempty(obj.JavaMatlabProjectManager)


                isReadOnlyReference=false;
            else
                import matlab.internal.project.util.processJavaCall;
                isReadOnlyReference=processJavaCall(...
                @()obj.JavaMatlabProjectManager.isReadOnlyReference()...
                );
            end
            if isReadOnlyReference
                matlabException=MException(message('MATLAB:project:api:ReadOnlyReferencedProject'));
                throw(matlabException);
            end

            rootFolder=obj.RootFolder;
            try
                obj.close();
            catch exception
                if(~ismember(exception.identifier,...
                    {'MATLAB:project:api:NoProjectCurrentlyLoaded',...
                    'MATLAB:project:api:CurrentProjectMismatch',...
                    'MATLAB:project:api:StaleProjectHandle'}))
                    exception.rethrow;
                end
            end
            slproject.loadProject(rootFolder);

        end

        function file=findFile(obj,filepath)













            validateattributes(obj,{'matlab.project.Project'},{'size',[1,1]},'','project');
            emptyProjectFileArray=matlab.project.ProjectFile.empty(1,0);
            if ischar(filepath)&&isempty(filepath)


                file=emptyProjectFileArray;
                return;
            end
            filepath=i_validateFileInput(filepath,{'char','string'},'filepath');

            import matlab.internal.project.util.processJavaCall;

            resolvedLocation=processJavaCall(...
            @()obj.JavaMatlabProjectManager.findFile(filepath,pwd)...
            );



            if(isempty(resolvedLocation))
                file=emptyProjectFileArray;
                return
            end

            file=matlab.project.ProjectFile(resolvedLocation,obj.ProjectContainer,obj.ProjectInstance);

        end

        function refs=listAllProjectReferences(obj)










            visitedProjectRoots=obj.RootFolder;
            refs=matlab.project.ProjectReference.empty(1,0);
            toVisit=obj.ProjectReferences;
            while~isempty(toVisit)
                currentReference=toVisit(1);
                toVisit=toVisit(2:end);
                root=currentReference.File;
                if~ismember(root,visitedProjectRoots)
                    refs(end+1)=currentReference;%#ok<AGROW>
                    try
                        newReferences=currentReference.Project.ProjectReferences;
                        toVisit=[toVisit,newReferences];%#ok<AGROW>
                    catch E
                        if strcmp(E.identifier,'MATLAB:project:api:StaleProjectHandle')
                            warning(message('MATLAB:project:api:StaleProjectHandleWhenListingRefs',currentReference.File));
                        else
                            rethrow(E)
                        end
                    end
                    visitedProjectRoots(end+1)=root;%#ok<AGROW>
                end
            end
        end

        function requiredFiles=listRequiredFiles(obj,files)




















            validateattributes(obj,{'matlab.project.Project'},{'size',[1,1]},'','project');
            files=i_parseImpactedRequiredFilesArgument(files);

            obj.updateDependencies();
            deps=obj.Dependencies;

            requiredFiles={};
            for f=files
                requiredFiles=[requiredFiles;obj.getDownstreamDependenciesWithDeps(f,deps)];%#ok<AGROW>
            end
            requiredFiles=unique(requiredFiles);
        end

        function impactedFiles=listImpactedFiles(obj,files)




















            validateattributes(obj,{'matlab.project.Project'},{'size',[1,1]},'','project');
            files=i_parseImpactedRequiredFilesArgument(files);

            obj.updateDependencies();
            deps=obj.Dependencies;

            impactedFiles={};
            for f=files
                impactedFiles=[impactedFiles;obj.getUpstreamDependenciesWithDeps(f,deps)];%#ok<AGROW>
            end
            impactedFiles=unique(impactedFiles);
        end

        function refreshSourceControl(obj)












            validateattributes(obj,{'matlab.project.Project'},{'size',[1,1]},'','project');

            import matlab.internal.project.util.processJavaCall;

            processJavaCall(@()obj.JavaMatlabProjectManager.refreshSourceControlCache());
        end

        function modifiedFiles=listModifiedFiles(obj)











            validateattributes(obj,{'matlab.project.Project'},{'size',[1,1]},'','project');

            import matlab.internal.project.util.processJavaCall;

            modifiedFiles=processJavaCall(@()obj.ProjectInstance.listModifiedFiles());
            if isempty(modifiedFiles)
                modifiedFiles=matlab.project.ProjectFile.empty(1,0);
            end
        end

        function updateDependencies(obj)












            import matlab.internal.project.util.processJavaCall;
            processJavaCall(@()obj.JavaMatlabProjectManager.updateDependencyGraph());
        end

        function shortcut=addShortcut(obj,file)


















            assertProjectIsNotRunningAShortcut()
            file=i_validateFileInput(file,{'char','string','matlab.project.ProjectFile'},'file');

            [javaEntryPointManager,javaEntryPoint]=...
            obj.createEntryPoint(...
file...
            );

            shortcut=matlab.project.Shortcut(javaEntryPointManager,char(javaEntryPoint.getFile()));
        end

        function removeShortcut(obj,shortcut)





















            assertProjectIsNotRunningAShortcut();
            shortcut=i_validateFileInput(shortcut,{'char','string','matlab.project.Shortcut'},'shortcut');

            import matlab.internal.project.util.EntryPointType;
            obj.removeEntryPoint(shortcut,EntryPointType.Basic);
        end

        function startupFile=addStartupFile(obj,file)


















            assertProjectIsNotRunningAShortcut()
            file=i_validateFileInput(file,{'char','string','matlab.project.ProjectFile'},'file');

            import matlab.internal.project.util.EntryPointType;
            [~,javaEntryPoint]=...
            obj.createEntryPoint(...
            file,...
            EntryPointType.StartUp...
            );

            startupFile=string(javaEntryPoint.getFile());
        end


        function removeStartupFile(obj,startupFile)





















            assertProjectIsNotRunningAShortcut()
            startupFile=i_validateFileInput(startupFile,{'char','string','slproject.StartupFile'},'startupFile');

            import matlab.internal.project.util.EntryPointType;
            obj.removeEntryPoint(startupFile,EntryPointType.StartUp);
        end

        function shutdownFile=addShutdownFile(obj,file)

















            assertProjectIsNotRunningAShortcut()
            file=i_validateFileInput(file,{'char','string','matlab.project.ProjectFile'},'file');

            import matlab.internal.project.util.EntryPointType;
            [~,javaEntryPoint]=...
            obj.createEntryPoint(...
            file,...
            EntryPointType.Shutdown...
            );

            shutdownFile=string(javaEntryPoint.getFile());
        end


        function removeShutdownFile(obj,shutdownFile)



















            assertProjectIsNotRunningAShortcut()
            shutdownFile=i_validateFileInput(shutdownFile,{'char','string','slproject.ShutdownFile'},'shutdownFile');

            import matlab.internal.project.util.EntryPointType;
            obj.removeEntryPoint(shutdownFile,EntryPointType.Shutdown);
        end
    end

    methods(Access=private)
        function files=getDownstreamDependenciesWithDeps(obj,file,deps)
            validateattributes(file,{'string'},{},'','file');

            file=obj.findFile(file);
            if isempty(file)||~deps.findnode(file.Path)
                files={};
                return;
            end
            files=deps.bfsearch(file.Path);
            filesExistsIdx=logical(cellfun(@(x)exist(x,'file'),files));
            files=files(filesExistsIdx);
        end

        function files=getUpstreamDependenciesWithDeps(obj,file,deps)
            validateattributes(file,{'string'},{},'','file');

            file=obj.findFile(file);
            if isempty(file)||~deps.findnode(file.Path)
                files={};
                return;
            end
            files=bfsearch(flipedge(deps),file.Path);
            filesExistsIdx=logical(cellfun(@(x)exist(x,'file'),files));
            files=files(filesExistsIdx);
        end

        function[javaEntryPointManager,javaEntryPoint]=createEntryPoint(obj,file,type)
            if isa(file,'matlab.project.ProjectFile')
                file=char(file.Path);
            elseif isstring(file)
                file=char(file);
            end

            import matlab.internal.project.util.processJavaCall;
            javaEntryPointManager=...
            processJavaCall(...
            @()obj.JavaMatlabProjectManager.getEntryPointManager()...
            );

            if nargin>2
                javaEntryPoint=processJavaCall(...
                @()javaEntryPointManager.createShortcut(...
                file,...
                pwd,...
                type.char...
                )...
                );
            else
                javaEntryPoint=processJavaCall(...
                @()javaEntryPointManager.createShortcut(...
                file,...
pwd...
                )...
                );
            end
        end

        function removeEntryPoint(obj,file,type)
            if~ischar(file)&&~isstring(file)
                file=file.File;
            end
            if isstring(file)
                file=char(file);
            end

            import matlab.internal.project.util.processJavaCall;

            javaEntryPointManager=processJavaCall(...
            @()obj.JavaMatlabProjectManager.getEntryPointManager()...
            );

            processJavaCall(...
            @()javaEntryPointManager.removeShortcut(...
            file,...
            pwd,...
            type.char...
            )...
            );
        end

    end

    methods(Hidden=true)

        function entryPoints=getEntryPoints(obj,converter,type)
            import matlab.internal.project.util.processJavaCall;

            javaEntryPointManager=processJavaCall(...
            @()obj.JavaMatlabProjectManager.getEntryPointManager()...
            );

            if nargin>2
                javaCall=@()javaEntryPointManager.getEntryPoints(type.char);
            else
                javaCall=@()javaEntryPointManager.getEntryPoints();
            end

            javaShortcuts=processJavaCall(javaCall);

            import matlab.internal.project.util.convertJavaCollectionToCellArray;

            wrappedConverter=@(entryPoint)converter(javaEntryPointManager,entryPoint);
            entryPoints=convertJavaCollectionToCellArray(javaShortcuts,wrappedConverter);
            entryPoints=[entryPoints{:}];
        end

    end

    methods


        function value=get.HasStartupErrors(obj)
            import matlab.internal.project.util.processJavaCall;
            projectContainer=obj.ProjectContainer;
            projectControlSetRef=projectContainer.getJavaProjectControlSet();
            value=processJavaCall(@()projectControlSetRef.hasStartupErrors());
        end

        function graph=get.Dependencies(obj)










            import matlab.internal.project.util.processJavaCall;
            jGraph=processJavaCall(@()obj.JavaMatlabProjectManager.getDependencyGraph());

            graph=digraph;
            nodes=jGraph.getVertexNames;
            if~isempty(nodes)
                edges=jGraph.getEdges;
                graph=graph.addnode(cellstr(nodes));
                if~isempty(edges)
                    graph=graph.addedge(edges(:,1),edges(:,2));
                    graph=graph.simplify('keepselfloops');
                end
            end
        end
        function type=get.DefinitionFilesType(obj)

            import matlab.internal.project.util.processJavaCall;
            jType=processJavaCall(...
            @()obj.JavaMatlabProjectManager.getMetadataType()...
            );
            type=[];
            switch jType
            case 'com.mathworks.toolbox.slproject.project.metadata.distributed.DistributedMetadataManagerFactory'
                type=matlab.project.DefinitionFiles.MultiFile;
            case 'com.mathworks.toolbox.slproject.project.metadata.fixedpath.FixedPathMetadataManagerFactory'
                type=matlab.project.DefinitionFiles.FixedPathMultiFile;
            case 'com.mathworks.toolbox.slproject.project.metadata.fixedpath_v2.FixedPathMetadataManagerFactoryV2'
                type=matlab.project.DefinitionFiles.FixedPathMultiFile;
            case 'com.mathworks.toolbox.slproject.project.metadata.monolithic.MonolithicManagerFactory'
                type=matlab.project.DefinitionFiles.SingleFile;
            end
        end
        function shortcuts=get.Shortcuts(obj)











            converter=@(javaEntryPointManager,shortcut)matlab.project.Shortcut(javaEntryPointManager,char(shortcut.getFile()));

            shortcuts=obj.getEntryPoints(converter);
            shortcuts=sort(shortcuts);

            if isempty(shortcuts)
                shortcuts=matlab.project.Shortcut.empty(1,0);
            end
        end

        function startupFiles=get.StartupFiles(obj)











            converter=@(javaEntryPointManager,shortcut)string(shortcut.getFile());

            import matlab.internal.project.util.EntryPointType;
            startupFiles=obj.getEntryPoints(converter,EntryPointType.StartUp);

            if isempty(startupFiles)
                startupFiles=string.empty(1,0);
            end
        end

        function shutdownFiles=get.ShutdownFiles(obj)











            converter=@(javaEntryPointManager,shortcut)string(shortcut.getFile());

            import matlab.internal.project.util.EntryPointType;
            shutdownFiles=obj.getEntryPoints(converter,EntryPointType.Shutdown);

            if isempty(shutdownFiles)
                shutdownFiles=string.empty(1,0);
            end
        end

        function paths=get.ProjectPath(obj)

            import matlab.internal.project.util.*;

            javaFolderReferences=processJavaCall(...
            @()obj.ProjectInstance.getJavaProjectManager.getProjectPath()...
            );

            paths=matlab.project.PathFolder(javaFolderReferences);
        end

        function paths=get.ProjectReferences(obj)

            import matlab.internal.project.util.*;

            javaFolderReferences=processJavaCall(...
            @()obj.ProjectInstance.getJavaProjectManager.getProjectReferences()...
            );

            paths=matlab.project.ProjectReference(javaFolderReferences);
        end

        function files=get.Files(obj)

            import matlab.internal.project.util.processJavaCall;

            files=processJavaCall(@()obj.ProjectInstance.getFilesInProject());

            if isempty(files)
                files=matlab.project.ProjectFile.empty(1,0);
            end

        end

        function categories=get.Categories(obj)












            categories=obj.ProjectInstance.getCategories();

            categories=sort(categories);
        end

        function name=get.Name(obj)










            import matlab.internal.project.util.processJavaCall;
            name=processJavaCall(...
            @()obj.JavaMatlabProjectManager.getName()...
            );


            name=string(name);
        end

        function set.Name(obj,name)










            validateattributes(name,{'char','string'},{});

            if isstring(name)
                name=char(name);
            end

            import matlab.internal.project.util.processJavaCall;
            processJavaCall(...
            @()obj.JavaMatlabProjectManager.setName(name)...
            );
        end

        function set.Categories(~,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'Categories',...
            'matlab.project.Project',...
            'createCategory',...
            'matlab.project.Project');
        end

        function set.Files(~,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'Files',...
            'matlab.project.Project',...
            'addFile',...
            'matlab.project.Project');
        end

        function set.Shortcuts(~,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'Shortcuts',...
            'matlab.project.Project',...
            'addShortcut',...
            'matlab.project.Project');
        end

        function set.ProjectPath(~,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'ProjectPath',...
            'matlab.project.Project',...
            'addPath',...
            'matlab.project.Project');
        end

        function set.ProjectReferences(~,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'ProjectReferences',...
            'matlab.project.Project',...
            'addReference',...
            'matlab.project.Project');
        end

        function set.StartupFiles(~,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'StartupFiles',...
            'matlab.project.Project',...
            'addStartupFile',...
            'matlab.project.Project');
        end

        function set.ShutdownFiles(~,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'ShutdownFiles',...
            'matlab.project.Project',...
            'addShutdownFile',...
            'matlab.project.Project');
        end
    end


    methods(Access=public)

        function category=createCategory(obj,categoryName,varargin)





























            p=inputParser;
            p.addRequired('project',@(x)validateattributes(x,{'matlab.project.Project'},{'size',[1,1]},'','project'));
            p.addRequired('categoryName',@(x)validateattributes(x,{'char','string'},{'nonempty'},'','categoryName'));
            p.addOptional('dataType','none',@(x)validateattributes(x,{'char','string'},{'nonempty'},'','dataType'));
            p.addOptional('isSingleValuedString','',@(x)validateattributes(x,{'char','string'},{'nonempty'},'','single-valued'));
            p.parse(obj,categoryName,varargin{:});

            if isstring(categoryName)
                categoryName=char(categoryName);

                validateattributes(categoryName,{'char'},{'nonempty'},'','categoryName');
            end

            if any(strcmp(p.UsingDefaults,'isSingleValuedString'))
                isSingleValued=false;
            else
                isSingleValuedString=p.Results.isSingleValuedString;

                if isstring(isSingleValuedString)
                    isSingleValuedString=char(isSingleValuedString);
                    validateattributes(isSingleValuedString,{'char'},{'nonempty'},'','single-valued');
                end

                isSingleValuedString=validatestring(isSingleValuedString,{'single-valued','singlevalued'},'','single-valued');
                isSingleValued=~isempty(isSingleValuedString);
            end

            dataType=p.Results.dataType;
            if isstring(dataType)
                dataType=char(dataType);
            end
            dataType=validatestring(dataType,obj.ProjectInstance.LabelDataTypes,'','dataType');


            import matlab.internal.project.util.processJavaCall;
            processJavaCall(...
            @()obj.JavaMatlabProjectManager.createCategory(categoryName,dataType,isSingleValued)...
            );

            category=matlab.project.Category(categoryName,isSingleValued,obj.ProjectContainer);

        end

        function category=findCategory(obj,categoryName)












            validateattributes(obj,{'matlab.project.Project'},{'size',[1,1]},'','project');
            validateattributes(categoryName,{'char','string'},{'nonempty'},'','categoryName');

            if isstring(categoryName)
                categoryName=char(categoryName);
            end

            category=obj.ProjectInstance.findCategory(categoryName);

            if isempty(category)
                category=matlab.project.Category.empty(1,0);
            end
        end

        function removeCategory(obj,categoryName)














            validateattributes(obj,{'matlab.project.Project'},{'size',[1,1]},'','project');
            validateattributes(categoryName,{'char','string','matlab.project.Category'},{'nonempty'},'','categoryName');

            if isa(categoryName,'matlab.project.Category')
                categoryName=categoryName.Name;
            elseif isstring(categoryName)
                categoryName=char(categoryName);
            end

            categoryName=validatestring(categoryName,...
            sort([obj.ProjectInstance.getCategories().Name]),'','categoryName');

            categoryManager=obj.ProjectInstance.getCategoryManager();
            categoryList=categoryManager.getAllCategories();

            category=obj.ProjectInstance.getJavaCategoryFromCollectionByName(categoryList,categoryName);

            import matlab.internal.project.util.processJavaCall;
            processJavaCall(@()categoryManager.deleteCategory(category));

        end

        function projectFile=addFile(obj,file)

















            validateattributes(obj,{'matlab.project.Project'},{'size',[1,1]},'','project');
            file=i_validateFileInput(file,{'string','char'},'file');

            import matlab.internal.project.util.processJavaCall;
            fileAdded=processJavaCall(@()obj.JavaMatlabProjectManager.addFile(file,pwd));

            projectFile=matlab.project.ProjectFile(fileAdded,...
            obj.ProjectContainer,obj.ProjectInstance);

        end

        function projectFolder=addFolderIncludingChildFiles(obj,folder)


























            validateattributes(obj,{'matlab.project.Project'},{'size',[1,1]},'','project');
            folder=i_validateFileInput(folder,{'string','char'},'folder');

            import matlab.internal.project.util.processJavaCall;
            fileAdded=processJavaCall(@()obj.JavaMatlabProjectManager.addFolderIncludingChildFiles(folder,pwd));

            projectFolder=matlab.project.ProjectFile(fileAdded,...
            obj.ProjectContainer,obj.ProjectInstance);

        end

        function removeFile(obj,file)










            validateattributes(obj,{'matlab.project.Project'},{'size',[1,1]},'','project');
            file=i_validateFileInput(file,{'string','char','matlab.project.ProjectFile'},'file');

            import matlab.internal.project.util.processJavaCall;
            processJavaCall(@()obj.JavaMatlabProjectManager.removeFile(file,pwd));

        end

        function projectFile=addPath(obj,file)




















            assertProjectIsNotRunningAShortcut();

            validateattributes(obj,{'matlab.project.Project'},{'size',[1,1]},'','project');

            file=i_validateFileInput(file,{'string','char','matlab.project.ProjectFile'},'file');

            import matlab.internal.project.util.processJavaCall;
            fileAdded=processJavaCall(@()obj.JavaMatlabProjectManager.addFolderToProjectPath(file,pwd));

            projectFile=matlab.project.PathFolder(fileAdded);
        end



        function removePath(obj,file)























            assertProjectIsNotRunningAShortcut();

            validateattributes(obj,{'matlab.project.Project'},{'size',[1,1]},'','project');
            file=i_validateFileInput(file,{'string','char','matlab.project.ProjectFile','matlab.project.PathFolder'},'file');

            import matlab.internal.project.util.processJavaCall;
            processJavaCall(@()obj.JavaMatlabProjectManager.removeFolderFromProjectPath(file,pwd));
        end

        function projectReference=addReference(obj,project,varargin)



















            assertProjectIsNotRunningAShortcut();

            p=inputParser;
            p.addRequired('project',@(x)validateattributes(x,{'matlab.project.Project'},{'size',[1,1]},'','project'));
            p.addRequired('folder',@(x)validateattributes(x,{'char','string','matlab.project.Project'},{'nonempty'},'','folder'));
            p.addOptional('type','relative',@(x)validateattributes(x,{'char','string'},{'nonempty'},'','type'));
            p.parse(obj,project,varargin{:});

            type=p.Results.type;
            if isstring(type)
                type=char(type);
            end
            type=validatestring(type,{'relative','absolute'},'','type');

            folder=p.Results.folder;
            folder=i_validateFileInput(folder,{'char','string','matlab.project.Project'},'folder');

            relativeReference=strcmp(type,'relative');

            import matlab.internal.project.util.processJavaCall;
            referenceAdded=processJavaCall(@()obj.JavaMatlabProjectManager.addProjectReference(folder,pwd,relativeReference));

            projectReference=matlab.project.ProjectReference(referenceAdded);
        end

        function removeReference(obj,folder)















            assertProjectIsNotRunningAShortcut();

            validateattributes(obj,{'matlab.project.Project'},{'size',[1,1]},'','project');
            validateattributes(folder,{'char','string','matlab.project.Project','matlab.project.ProjectReference'},{'nonempty'},'','file');

            if isa(folder,'matlab.project.ProjectReference')
                folder=folder.File;
            elseif isa(folder,'matlab.project.Project')
                folder=folder.RootFolder;
            end
            folder=char(folder);

            import matlab.internal.project.util.processJavaCall;
            processJavaCall(@()obj.JavaMatlabProjectManager.removeProjectReference(folder,pwd));

        end

        function export(obj,file,varargin)




























            results=matlab.internal.project.util.validateExportArguments(obj,file,varargin{:});

            file=matlab.internal.project.util.getAbsoluteExistingPath(file);

            metaDataManagerFactory=[];
            if~isempty(results.definitionType)
                factoryName=results.definitionType.getFactoryByIndex(results.version);
                metaDataManagerFactory=com.mathworks.toolbox.slproject.project.metadata.MetadataFactoryFinder.getNamedFactory(factoryName);
            end

            if~i_isAcceptableMetadataRoot(results.definitionFolder)
                error(message('MATLAB:project:api:InvalidMetadataRoot',results.definitionFolder));
            end

            import matlab.internal.project.util.processJavaCall;
            processJavaCall(@()obj.JavaMatlabProjectManager.export(...
            file,...
            metaDataManagerFactory,...
            results.definitionFolder,...
            results.archiveReferences,...
            results.exportUUIDMetaDataFile,...
            results.specifiedFilesOnly,...
            results.preventExportWithMissingFiles));
        end
    end




    methods(Sealed=true,Access=protected,Hidden=true)

        function s=getFooter(obj)
            s=getFooter@matlab.mixin.CustomDisplay(obj);
            if length(obj)==1
                if~obj.isLoaded
                    s=[s,message('MATLAB:project:api:SpecifiedProjectNotLoaded',obj.RootFolder).getString()];
                end
            end
        end

        function displayEmptyObject(obj)
            displayEmptyObject@matlab.mixin.CustomDisplay(obj);
        end

        function displayNonScalarObject(obj)
            displayNonScalarObject@matlab.mixin.CustomDisplay(obj);
        end

        function displayScalarHandleToDeletedObject(obj)
            displayScalarHandleToDeletedObject@matlab.mixin.CustomDisplay(obj);
        end

        function displayScalarObject(obj)
            displayScalarObject@matlab.mixin.CustomDisplay(obj);
        end

        function header=getHeader(obj)
            header=getHeader@matlab.mixin.CustomDisplay(obj);
        end

        function propertyGroups=getPropertyGroups(obj)
            propertyGroups=getPropertyGroups@matlab.mixin.CustomDisplay(obj);
        end
    end

    methods(Access=public,Hidden=true)
        function javaProjectManagerFacade=connectPlugin(obj,~)
            javaProjectManagerFacade=obj.JavaMatlabProjectManager;
        end
    end
    methods
        function information=get.SourceControlMessages(obj)












            import matlab.internal.project.util.*;

            information=processJavaCall(...
            @()obj.JavaMatlabProjectManager.getGenericLabels()...
            );

            information=convertJavaCollectionToCellArray(information);
            information=string(information);
        end

        function adapter=get.SourceControlIntegration(obj)










            import matlab.internal.project.util.*;

            adapter=processJavaCall(...
            @()obj.JavaMatlabProjectManager.getSystemName()...
            );

            adapter=string(adapter);
        end

        function file=get.RepositoryLocation(obj)










            import matlab.internal.project.util.*;

            file=processJavaCall(...
            @()obj.JavaMatlabProjectManager.getRepositorySpecifier()...
            );

            file=string(file);
        end

        function description=get.Description(obj)










            import matlab.internal.project.util.*;

            description=processJavaCall(...
            @()obj.JavaMatlabProjectManager.getProjectDescription()...
            );
            description=string(description);
        end

        function set.Description(obj,description)










            import matlab.internal.project.util.*;

            validateattributes(description,{'char','string'},{});

            if isstring(description)
                description=char(description);
            end

            processJavaCall(...
            @()obj.JavaMatlabProjectManager.setProjectDescription(...
            description)...
            );
        end

        function readonly=get.ReadOnly(obj)










            import matlab.internal.project.util.*;

            readonly=processJavaCall(...
            @()obj.JavaMatlabProjectManager.isReadOnlyReference()...
            );

        end

        function topLevel=get.TopLevel(obj)











            import matlab.internal.project.util.*;

            topLevel=processJavaCall(...
            @()obj.JavaMatlabProjectManager.isTopLevel()...
            );
        end
    end

    methods(Access=private)
        function addWorkingFolderProperties(obj)
            charWorkingFolderNames=obj.JavaMatlabProjectManager.getWorkingFolderNames();
            if isempty(charWorkingFolderNames)
                return
            end

            workingFolderNames=string(charWorkingFolderNames);
            propertyNames=workingFolderNames.strip(char(0));

            import matlab.internal.project.util.setProperty
            dynamicProperties=arrayfun(@(x)obj.addprop(x),propertyNames);
            arrayfun(@(x)...
            setProperty(x,'GetMethod',...
            @(obj)getWorkingFolderValue(obj,x.Name)),...
dynamicProperties...
            );
            arrayfun(@(x)...
            setProperty(x,'SetMethod',...
            @(obj,val)setWorkingFolderValue(obj,x.Name,val)),...
dynamicProperties...
            );
        end

        function value=getWorkingFolderValue(obj,workingFolderSpecifier)
            import matlab.internal.project.util.*;

            value=processJavaCall(...
            @()obj.JavaMatlabProjectManager.getWorkingFolderValue(workingFolderSpecifier,false)...
            );
            value=string(value);
        end

        function setWorkingFolderValue(obj,workingFolderSpecifier,value)
            import matlab.internal.project.util.*;

            validateattributes(value,{'char','string','matlab.project.ProjectFile'},{},'','file');
            if isa(value,'matlab.project.ProjectFile')
                value=value.Path;
            end
            if isstring(value)
                value=char(value);
            end

            processJavaCall(...
            @()obj.JavaMatlabProjectManager.setWorkingFolderValue(workingFolderSpecifier,value,pwd)...
            );
        end
    end

end

function assertProjectIsNotRunningAShortcut()
    import matlab.internal.project.util.assertProjectNotShuttingDown;
    import matlab.internal.project.util.assertProjectNotStartingUp;



    assertProjectNotShuttingDown();
    assertProjectNotStartingUp();
end

function trueOrFalse=i_isAcceptableMetadataRoot(root)
    trueOrFalse=isempty(root)||strlength(root)==0||i_isSelectableMetadataRoot(root);
end

function trueOrFalse=i_isSelectableMetadataRoot(root)
    accettableRoots=string(com.mathworks.toolbox.slproject.project.metadata.MetadataRoots.getSelectableRoots().toArray());
    trueOrFalse=any(strcmp(accettableRoots,root));
end

function file=i_validateFileInput(file,supportedTypes,fileVarName)
    try
        validateattributes(file,supportedTypes,{'nonempty'},'',fileVarName);
        if~isa(file,'char')
            validateattributes(file,supportedTypes,{'size',[1,1]},'',fileVarName);
        end
        if isa(file,'matlab.project.ProjectFile')
            file=file.Path;
        end
        if isa(file,'matlab.project.PathFolder')
            file=file.File;
        end
        if isa(file,'matlab.internal.project.util.EntryPoint')
            file=file.File;
        end
        if isa(file,'matlab.project.Project')
            file=file.RootFolder;
        end
        if isstring(file)
            file=char(file);
            validateattributes(file,supportedTypes,{'nonempty'},'',fileVarName);
        end
    catch ME
        throwAsCaller(ME);
    end
end

function files=i_parseImpactedRequiredFilesArgument(files)
    validateattributes(files,{'char','string','matlab.project.ProjectFile','cell'},{},'','file');
    if isa(files,'cell')
        cellfun(@(file)validateattributes(file,{'char'},{},'','files'),files);
    end

    if isa(files,"matlab.project.ProjectFile")
        files=[files.Path];
    else
        files=string(files);
    end

    files=reshape(files,1,numel(files));
end
