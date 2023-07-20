classdef ProjectManager<handle







    methods(Abstract=true,Access=protected)

        project=getCurrentProject(obj);

    end

    methods(Access=public,Hidden=true)

        function directory=getRootDirectory(obj)











            warning(message('MATLAB:project:api:FunctionDeprecation','getRootDirectory','getRootFolder'));

            directory=getRootFolder(obj);
        end
    end

    methods(Access=public)

        function folder=getRootFolder(obj)











            project=obj.getCurrentProject();
            folder=char(project.RootFolder);
        end

        function name=getProjectName(obj)










            project=obj.getCurrentProject();
            name=char(project.Name);
        end

        function setProjectName(obj,name)










            checkArgument(name,'char','name');

            project=obj.getCurrentProject();
            project.Name=name;
        end

        function labels=getAttachedLabels(obj,file)















            checkArgument(file,'char','file');

            project=obj.getCurrentProject();
            projectFile=assertFileIsInProject(project,file);

            labels=arrayfun(@(l)Simulink.ModelManagement.Project.Label(char(l.CategoryName),char(l.Name)),projectFile.Labels);
        end

        function attachLabelToFile(obj,file,label)














            checkArgument(file,'char','file');
            checkArgument(label,'Simulink.ModelManagement.Project.Label','label');

            project=obj.getCurrentProject();
            projectFile=assertFileIsInProject(project,file);
            assertLabelExists(project,label);

            projectFile.addLabel(label.CategoryName,label.Name);
        end

        function detachLabelFromFile(obj,file,label)















            checkArgument(file,'char','file');
            checkArgument(label,'Simulink.ModelManagement.Project.Label','label');

            project=obj.getCurrentProject();
            projectFile=assertFileIsInProject(project,file);
            assertLabelExists(project,label);

            projectFile.removeLabel(label.CategoryName,label.Name);
        end


        function categories=getCategories(obj)












            project=obj.getCurrentProject();
            categories=arrayfun(@(c)char(c.Name),project.Categories,UniformOutput=false);
        end


        function createCategory(obj,categoryName)











            checkArgument(categoryName,'char','categoryName');

            project=obj.getCurrentProject();
            category=project.findCategory(categoryName);
            if isempty(category)
                project.createCategory(categoryName);
            end
        end

        function removeCategory(obj,categoryName)











            checkArgument(categoryName,'char','categoryName');

            project=obj.getCurrentProject();
            assertCategoryExists(project,categoryName);

            project.removeCategory(categoryName);
        end

        function labels=getLabels(obj,categoryName)















            checkArgument(categoryName,'char','categoryName');

            project=obj.getCurrentProject();
            category=project.findCategory(categoryName);
            if isempty(category)
                labels=Simulink.ModelManagement.Project.Label.empty(1,0);
            else
                labels=arrayfun(@(l)Simulink.ModelManagement.Project.Label(char(l.CategoryName),char(l.Name)),category.LabelDefinitions);
            end
        end

        function createLabel(obj,label)












            checkArgument(label,'Simulink.ModelManagement.Project.Label','label');

            project=obj.getCurrentProject();
            category=project.findCategory(label.CategoryName);
            if isempty(category)
                category=project.createCategory(label.CategoryName);
            end
            category.createLabel(label.Name);
        end

        function removeLabel(obj,label)











            checkArgument(label,'Simulink.ModelManagement.Project.Label',label);

            project=obj.getCurrentProject();
            category=assertLabelExists(project,label);

            category.removeLabel(label.Name);
        end

        function files=getFilesInProject(obj,includeFolders)

















            if nargin<2
                includeFolders=true;
            else
                checkArgument(includeFolders,'logical','includeFolders');
            end

            project=obj.getCurrentProject();

            files=[project.Files.Path];
            if isempty(files)
                files={};
            else
                files=cellstr(files);
            end

            if~includeFolders
                files(isfolder(files))=[];
            end
        end

        function addFileToProject(obj,file)












            checkArgument(file,'char','file');

            project=obj.getCurrentProject();
            project.addFile(file);
        end

        function removeFileFromProject(obj,file)











            checkArgument(file,'char','file');

            project=obj.getCurrentProject();
            project.removeFile(file);
        end

        function export(obj,file,varargin)














            checkArgument(file,'char','file');


            if~endsWith(file,'.zip')
                file=[file,'.zip'];
            end

            project=obj.getCurrentProject();
            if isempty(varargin)
                project.export(file,archiveReferences=false);
            else
                switch varargin{1}
                case Simulink.ModelManagement.Project.DefinitionFiles.SingleFile
                    type=matlab.project.DefinitionFiles.SingleFile;
                case Simulink.ModelManagement.Project.DefinitionFiles.MultiFile
                    type=matlab.project.DefinitionFiles.MultiFile;
                otherwise
                    checkArgument(varargin{1},'Simulink.ModelManagement.Project.DefinitionFiles','definitionType');
                end
                project.export(file,archiveReferences=false,definitionType=type);
            end
        end
    end

end


function projectCategory=assertLabelExists(project,label)
    projectCategory=assertCategoryExists(project,label.CategoryName);
    if isempty(projectCategory.findLabel(label.Name))
        error(message('MATLAB:project:api:LabelDoesNotExist',label.CategoryName,label.Name));
    end
end

function projectCategory=assertCategoryExists(project,category)
    projectCategory=project.findCategory(category);
    if isempty(projectCategory)
        error(message('MATLAB:project:api:CategoryDoesNotExist',category));
    end
end

function projectFile=assertFileIsInProject(project,file)
    projectFile=project.findFile(file);
    if isempty(projectFile)
        error(message('MATLAB:project:api:FileIsNotInProject',file));
    end
end

function checkArgument(argumentVariable,expectedType,argumentName)
    Simulink.ModelManagement.Project.checkArgument(argumentVariable,expectedType,argumentName);
end
