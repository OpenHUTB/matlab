classdef ProjectManager<matlab.mixin.CustomDisplay




















    properties(Dependent,GetAccess=public,SetAccess=public)

Name
    end

    properties(Dependent,GetAccess=public,SetAccess=private)

Information

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
    end

    properties(Dependent,GetAccess=public,SetAccess=private)

RootFolder
    end

    properties(GetAccess=public,SetAccess=immutable,Hidden=true)
Project
    end

    methods(Access=public,Hidden=true)
        function obj=ProjectManager(project)
            if nargin~=1||~(isa(project,'matlab.project.Project')||isa(project,'matlab.internal.project.api.Project'))
                error(message('MATLAB:project:api:PrivateConstructor'));
            end
            obj.Project=project;
        end
    end

    methods(Access=public)

        function close(obj)









            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            obj.Project.close();
        end

        function loaded=isLoaded(obj)











            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            loaded=obj.Project.isLoaded();
        end

        function reload(obj)










            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            obj.Project.reload();
        end

        function file=findFile(obj,filepath)













            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            mFile=obj.Project.findFile(filepath);
            if isempty(mFile)
                file=slproject.ProjectFile.empty(1,0);
            else
                file=slproject.ProjectFile(mFile);
            end
        end

        function files=listRequiredFiles(obj,file)

















            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            validateattributes(file,{'char','string','slproject.ProjectFile','cell'},{},'','file');
            if isa(file,'slproject.ProjectFile')
                file={file.Path};
            end
            mFiles=obj.Project.listRequiredFiles(file);
            files=cellstr(mFiles);
        end

        function refreshSourceControl(obj)











            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            obj.Project.refreshSourceControl();
        end

        function modifiedFiles=listModifiedFiles(obj)











            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            mFiles=obj.Project.listModifiedFiles();
            if isempty(mFiles)
                modifiedFiles=slproject.ProjectFile.empty(1,0);
            else
                modifiedFiles=arrayfun(@slproject.ProjectFile,mFiles);
            end
        end

        function shortcut=addShortcut(obj,file)



















            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            if isa(file,'slproject.ProjectFile')
                file=file.Path;
            end
            mShortcut=obj.Project.addShortcut(file);
            shortcut=slproject.Shortcut(mShortcut);
        end

        function removeShortcut(obj,shortcut)






















            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            validateattributes(shortcut,{'char','string','slproject.Shortcut'},{'nonempty'});
            if isa(shortcut,'slproject.Shortcut')
                shortcut=shortcut.File;
            end
            obj.Project.removeShortcut(shortcut);
        end

        function startupFile=addStartupFile(obj,file)



















            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            if isa(file,'slproject.ProjectFile')
                file=file.Path;
            end
            mStartupFile=obj.Project.addStartupFile(file);
            startupFile=slproject.StartupFile(mStartupFile);
        end

        function removeStartupFile(obj,startupFile)






















            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            if isa(startupFile,'slproject.StartupFile')
                startupFile=startupFile.File;
            end
            obj.Project.removeStartupFile(startupFile);
        end

        function shutdownFile=addShutdownFile(obj,file)














            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            if isa(file,'slproject.ProjectFile')
                file=file.Path;
            end
            mShutdownFile=obj.Project.addShutdownFile(file);
            shutdownFile=slproject.ShutdownFile(mShutdownFile);
        end

        function removeShutdownFile(obj,shutdownFile)

















            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            if isa(shutdownFile,'slproject.ShutdownFile')
                shutdownFile=shutdownFile.File;
            end
            obj.Project.removeShutdownFile(shutdownFile);
        end
    end

    methods
        function information=get.Information(obj)











            information=slproject.Information(obj.Project);
        end

        function dependencies=get.Dependencies(obj)











            dependencies=slproject.Dependencies(obj.Project);
        end

        function shortcuts=get.Shortcuts(obj)












            shortcuts=arrayfun(@slproject.Shortcut,obj.Project.Shortcuts);
            if isempty(shortcuts)
                shortcuts=slproject.Shortcut.empty(1,0);
            end
        end

        function startupFiles=get.StartupFiles(obj)












            startupFiles=arrayfun(@slproject.StartupFile,obj.Project.StartupFiles);
            if isempty(startupFiles)
                startupFiles=slproject.StartupFile.empty(1,0);
            end
        end

        function shutdownFiles=get.ShutdownFiles(obj)












            shutdownFiles=arrayfun(@slproject.ShutdownFile,obj.Project.ShutdownFiles);
            if isempty(shutdownFiles)
                shutdownFiles=slproject.ShutdownFile.empty(1,0);
            end
        end

        function paths=get.ProjectPath(obj)
            paths=arrayfun(@slproject.PathFolder,obj.Project.ProjectPath);
            if isempty(paths)
                paths=slproject.PathFolder.empty(1,0);
            end
        end

        function refs=get.ProjectReferences(obj)
            refs=arrayfun(@slproject.ProjectReference,obj.Project.ProjectReferences);
            if isempty(refs)
                refs=slproject.ProjectReference.empty(1,0);
            end
        end

        function files=get.Files(obj)
            files=arrayfun(@slproject.ProjectFile,obj.Project.Files);
            if isempty(files)
                files=slproject.ProjectFile.empty(1,0);
            end
        end

        function categories=get.Categories(obj)












            categories=arrayfun(@slproject.Category,obj.Project.Categories);
            if isempty(categories)
                categories=slproject.Category.empty(1,0);
            end
        end

        function name=get.Name(obj)











            name=char(obj.Project.Name);

        end

        function obj=set.Name(obj,name)











            obj.Project.Name=name;
        end

        function folder=get.RootFolder(obj)
            folder=char(obj.Project.RootFolder);
        end

        function obj=set.Categories(obj,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'Categories',...
            'slproject.ProjectManager',...
            'createCategory',...
            'slproject.ProjectManager');
        end

        function obj=set.Files(obj,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'Files',...
            'slproject.ProjectManager',...
            'addFile',...
            'slproject.ProjectManager');
        end

        function obj=set.Shortcuts(obj,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'Shortcuts',...
            'slproject.ProjectManager',...
            'addShortcut',...
            'slproject.ProjectManager');
        end

        function obj=set.ProjectPath(obj,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'ProjectPath',...
            'slproject.ProjectManager',...
            'addPath',...
            'slproject.ProjectManager');
        end

        function obj=set.ProjectReferences(obj,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'ProjectReferences',...
            'slproject.ProjectManager',...
            'addReference',...
            'slproject.ProjectManager');
        end

        function obj=set.StartupFiles(obj,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'StartupFiles',...
            'slproject.ProjectManager',...
            'addStartupFile',...
            'slproject.ProjectManager');
        end

        function obj=set.ShutdownFiles(obj,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'ShutdownFiles',...
            'slproject.ProjectManager',...
            'addShutdownFile',...
            'slproject.ProjectManager');
        end
    end


    methods(Access=public)

        function category=createCategory(obj,categoryName,varargin)





























            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            mCategory=obj.Project.createCategory(categoryName,varargin{:});
            category=slproject.Category(mCategory);
        end

        function category=findCategory(obj,categoryName)













            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');

            mCategory=obj.Project.findCategory(categoryName);
            if isempty(mCategory)
                category=slproject.Category.empty(1,0);
            else
                category=slproject.Category(mCategory);
            end
        end

        function removeCategory(obj,categoryName)















            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            validateattributes(categoryName,{'char','string','slproject.Category'},{'nonempty'},'','categoryName');

            if isa(categoryName,'slproject.Category')
                categoryName=categoryName.Name;
            end

            obj.Project.removeCategory(categoryName);
        end

        function projectFile=addFile(obj,file)



















            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            validateattributes(file,{'char','string'},{'nonempty'},'','file');

            mProjectFile=obj.Project.addFile(file);
            projectFile=slproject.ProjectFile(mProjectFile);

        end

        function projectFolder=addFolderIncludingChildFiles(obj,folder)




























            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            validateattributes(folder,{'char','string'},{'nonempty'},'','folder');

            mProjectFolder=obj.Project.addFolderIncludingChildFiles(folder);
            projectFolder=slproject.ProjectFile(mProjectFolder);
        end

        function removeFile(obj,file)











            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            validateattributes(file,{'char','string','slproject.ProjectFile'},{'nonempty'},'','file');

            if isa(file,'slproject.ProjectFile')
                file=file.Path;
            end

            obj.Project.removeFile(file);
        end

        function projectFile=addPath(obj,file)





















            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            validateattributes(file,{'char','string','slproject.ProjectFile'},{'nonempty'},'','file');

            if isa(file,'slproject.ProjectFile')
                file=file.Path;
            end

            mProjectFolder=obj.Project.addPath(file);
            projectFile=slproject.PathFolder(mProjectFolder);
        end

        function removePath(obj,file)
























            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            validateattributes(file,{'char','string','slproject.ProjectFile','slproject.PathFolder'},{'nonempty'},'','file');

            if isa(file,'slproject.ProjectFile')
                file=file.Path;
            elseif isa(file,'slproject.PathFolder')
                file=file.File;
            end

            obj.Project.removePath(file);
        end

        function projectReference=addReference(obj,project,varargin)




















            p=inputParser;
            p.addRequired('project',@(x)validateattributes(x,{'slproject.ProjectManager'},{'size',[1,1]},'','project'));
            p.addRequired('folder',@(x)validateattributes(x,{'char','string','slproject.ProjectManager'},{'nonempty'},'','folder'));
            p.addOptional('type','relative',@(x)validateattributes(x,{'char','string'},{'nonempty'},'','type'));
            p.parse(obj,project,varargin{:});

            type=p.Results.type;
            type=validatestring(type,{'relative','absolute'},'','type');

            folder=p.Results.folder;
            if isa(folder,'slproject.ProjectManager')
                folder=folder.RootFolder;
            end

            mProjectReference=obj.Project.addReference(folder,type);
            projectReference=slproject.ProjectReference(mProjectReference);
        end

        function removeReference(obj,folder)
















            validateattributes(obj,{'slproject.ProjectManager'},{'size',[1,1]},'','project');
            validateattributes(folder,{'char','string','slproject.ProjectManager','slproject.ProjectReference'},{'nonempty'},'','file');

            if isa(folder,'slproject.ProjectReference')
                folder=folder.File;
            elseif isa(folder,'slproject.ProjectManager')
                folder=folder.RootFolder;
            end

            obj.Project.removeReference(folder);
        end

        function export(obj,file,varargin)

















            p=inputParser;
            p.addRequired('obj',@(x)validateattributes(x,{'slproject.ProjectManager'},{'size',[1,1]},'','project'));
            p.addRequired('file',@(x)validateattributes(x,{'char','string'},{'nonempty'},'','file'));
            p.addOptional('definitionType',[],@(x)validateattributes(x,{'slproject.DefinitionFiles'},{'nonempty'},'','definitionType'));

            p.addOptional('archiveReferences',false,@(x)validateattributes(x,{'logical'},{},'','archiveReferences'));
            p.addOptional('definitionFolder','',@(x)validateattributes(x,{'char','string'},{'nonempty'},'','definitionFolder'));
            p.addOptional('exportUUIDMetaDataFile',true,@(x)validateattributes(x,{'logical'},{},'','exportUUIDMetaDataFile'));
            p.addOptional('specifiedFilesOnly',{},@(x)validateattributes(x,{'cell'},{},'specifiedFilesOnly'));
            p.addOptional('preventExportWithMissingFiles',true,@(x)validateattributes(x,{'logical'},{},'','preventExportWithMissingFiles'));
            p.parse(obj,file,varargin{:});

            params={
            'archiveReferences',p.Results.archiveReferences,...
            'exportUUIDMetaDataFile',p.Results.exportUUIDMetaDataFile,...
            'specifiedFilesOnly',p.Results.specifiedFilesOnly,...
            'preventExportWithMissingFiles',p.Results.preventExportWithMissingFiles...
            };

            type=p.Results.definitionType;
            if~isempty(type)
                params=[params,{'definitionType',matlab.project.DefinitionFiles.(char(type))}];
            end
            if~isempty(p.Results.definitionFolder)
                params=[params,{'definitionFolder',p.Results.definitionFolder}];
            end

            obj.Project.export(file,params{:});
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

    methods(Hidden)
        function javaProjectManagerFacade=connectPlugin(obj,plugin)
            javaProjectManagerFacade=obj.Project.connectPlugin(plugin);
        end
    end

end
