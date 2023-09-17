classdef Project<handle

    properties(Access=private)
projImpl
    end

    properties(Dependent)
name
rootDir
    end

    methods(Access=public)

        function load(this)
            if~this.isLoaded
                this.projImpl.reload;
            end
        end

        function val=isLoaded(this)
            val=this.projImpl.isLoaded;
        end

        function saveExperiment(this,expDef,path)
            assert(this.isLoaded);
            Experiment=experiments.internal.Experiment.fromStruct(expDef,path);
            save(path,'Experiment');


            this.addFileToProject(path);
        end


        function addFileToProject(this,filePath)
            this.projImpl.addFile(filePath);
            if isfolder(filePath)
                this.projImpl.addFolderIncludingChildFiles(filePath);
            end
        end

        function val=isFileInProject(this,filePath)
            val=false;
            assert(this.isLoaded,'Project is not loaded');
            f=this.projImpl.findFile(filePath);
            if~isempty(f)
                val=true;
            end
        end

        function type=getType(this,filePath)
            this.load();
            type=[];
            if strcmp(filePath,this.rootDir)
                type='Project';
            else
                f=this.projImpl.findFile(filePath);
                if isempty(f)
                    return;
                end
                if~isempty(f.Labels)
                    type=char(f.Labels(1).Name);
                else
                    if isfolder(filePath)
                        type='Folder';
                    else
                        type='File';
                    end
                end
            end
        end

        function delete(this)
            if this.isLoaded
                this.projImpl.close();
            end
        end

        function removeResultFromProject(this,runDir)
            this.projImpl.removeFile(runDir);
        end

        function updateDependencies(this)
            this.projImpl.updateDependencies();
        end


        function removeFileOrFolderFromProject(this,fullPathOfArtifact)

            fileOrFolderExists=exist(fullPathOfArtifact);%#ok<EXIST>
            assert(fileOrFolderExists==2||fileOrFolderExists==7,'File or directory should exist: %s',fullPathOfArtifact);

            isPresentInProject=~isempty(this.projImpl.findFile(fullPathOfArtifact));
            assert(isPresentInProject,'File or directory is not assocaiated with the project');
            this.projImpl.removeFile(fullPathOfArtifact);
        end

        function addPath(this,folderPath)
            assert(isfolder(folderPath)&&...
            startsWith(folderPath,this.rootDir));
            if~ismember(builtin('_canonicalizepath',folderPath),arrayfun(@(p)builtin('_canonicalizepath',p),[this.projImpl.ProjectPath.File]))
                this.projImpl.addPath(folderPath);
            end
        end

        function result=isInProjectPath(this,fullPath)
            if isfolder(fullPath)
                folderPath=fullPath;
            else
                folderPath=fileparts(fullPath);
            end

            assert(isfolder(folderPath)&&...
            startsWith(folderPath,this.rootDir));

            filesInProject=[this.projImpl.ProjectPath.File];
            result=strcmp(folderPath,this.rootDir)||...
            (~isempty(filesInProject)&&...
            ismember(string(folderPath),filesInProject));
        end
    end

    methods(Access=private)

        function this=Project(projImpl)
            this.projImpl=projImpl;

        end

        function createFolderAndApplyLabel(this,name)
            newFolder=fullfile(this.rootDir,name);
            mkdir(newFolder);
            this.projImpl.addFolderIncludingChildFiles(newFolder);
        end
    end

    methods
        function path=get.rootDir(this)
            path=char(this.projImpl.RootFolder);
        end

        function name=get.name(this)
            name=this.projImpl.Name;
        end
    end

    methods(Static)
        function obj=create(prjPath,prjName)


            if isfolder(prjPath)
                error(message('experiments:project:ProjectAlreadyExists',prjName));
            end
            mkdir(prjPath);

            projImpl=matlab.project.createProject('Folder',prjPath,'Name',prjName);

            obj=experiments.internal.Project(projImpl);
            obj.addPath(obj.rootDir);

            mkdir(fullfile(obj.rootDir,'Results'));

        end

        function obj=open(projectFilePath)
            projImpl=matlab.project.loadProject(projectFilePath);
            obj=experiments.internal.Project(projImpl);
        end

        function obj=createFromCurrentProject()
            projImpl=currentProject;
            obj=experiments.internal.Project(projImpl);
            obj.load();
        end
    end

    methods(Hidden=true)
        function proj=getProjectObject(this)
            proj=this.projImpl;
        end
    end
end
