classdef Project<classdiagram.app.core.domain.BaseObject


    properties(Access=private)
project
    end
    properties(Constant)
        ConstantType="Project";
        Stale=classdiagram.app.core.domain.ElementState.Stale;
    end

    methods
        function obj=Project(projectName,globalSettingsFcn)
            obj=obj@classdiagram.app.core.domain.BaseObject();
            obj.Type=classdiagram.app.core.domain.Project.ConstantType;
            obj.GlobalSettingsFcn=globalSettingsFcn;
            if isfile(projectName)
                [path,~,~]=fileparts(projectName);
                obj.Name=path;
            else
                obj.Name=projectName;
            end

            try
                obj.project=matlab.internal.project.api.makeProjectAvailable(obj.Name);
            catch EX
                rethrow(EX);
            end

            try
                cProject=currentProject;
                if cProject.RootFolder~=obj.Name

                    obj.setState(classdiagram.app.core.domain.ElementState.Stale);
                else

                    try
                        obj.project.Files;
                    catch
                        obj.project=currentProject;
                    end
                end
            catch

                obj.setState(obj.Stale);
            end
        end


        function subFolders=getSubFolders(self)
            folders=self.getSubFolderPaths();
            subFolders=[];
            if~isempty(folders)
                subFolders=cellfun(@(x)self.createFolder(x),folders,'uni',false);
                subFolders=[subFolders{:}];
            end
        end

        function[classnames,enumnames]=getClassFullNames(self)
            [fullClassPaths,fullEnumPaths]=self.getClassFullPaths();
            classnames={};
            if~isempty(fullClassPaths)
                classnames=cellfun(@(n)self.getClassFullName(n),fullClassPaths,'uni',false);
            end

            enumnames={};
            if~isempty(fullEnumPaths)
                enumnames=cellfun(@(n)self.getClassFullName(n),fullEnumPaths,'uni',false);
            end
        end

        function hasChild=hasChild(self)
            hasChild=~isempty(self.getSubFolderPaths())||~isempty(self.getClassFullPaths());
        end

        function count=childCount(self)
            count=length(self.getSubFolderPaths())+length(self.getClassFullPaths);
        end

        function onPath=isOnPath(self)
            pathCell=regexp(path,pathsep,'split');
            pathCell{end+1}=pwd;
            if ispc
                onPath=any(strcmpi(self.project.RootFolder,pathCell));
            else
                onPath=any(strcmp(self.project.RootFolder,pathCell));
            end
        end

        function accept(self,visitor)
            visitor.visitProject(self);
        end
    end

    methods(Access=private)
        function fullClassPath=getClassFullName(~,fullPath)
            fileParts=split(fullPath,filesep);

            if~isempty(fileParts)
                packageParts=fileParts(cellfun(@(f)contains(f,'+'),fileParts));
            end

            fullClassPath="";
            for i=1:length(packageParts)
                fullClassPath=fullClassPath+packageParts{i}(2:end)+".";
            end

            [~,name,~]=fileparts(fullPath);
            fullClassPath=fullClassPath+name;
        end

        function subFolders=getSubFolderPaths(self)
            rootCount=self.project.RootFolder.count(filesep)+1;
            try
                allFilePaths=[self.project.Files.Path];
                subFolders=allFilePaths(arrayfun(@(f)isfolder(f)&&f.count(filesep)==rootCount,allFilePaths));
            catch

                self.setState(self.Stale);
                subFolders=[];
            end
        end

        function[classpaths,enumpaths]=getClassFullPaths(self)
            classpaths={};
            enumpaths={};
            allItems=dir(self.project.RootFolder);
            dirIndex=[allItems.isdir];
            fileList={allItems(~dirIndex).name}';


            fileList=fileList(endsWith(fileList,".m"));
            if ispc
                lowCaseFiles=lower(fileList);
                [~,uniqueIndex,~]=unique(lowCaseFiles);
                fileList=fileList(uniqueIndex);
            end

            classIndexes=false(1,length(fileList));
            enumIndexes=false(1,length(fileList));
            try
                ProjectFiles=[self.project.Files.Path];
            catch

                self.setState(self.Stale);
                return;
            end
            if~isempty(fileList)
                for i=1:length(fileList)
                    fullName=fullfile(self.project.RootFolder,fileList{i});
                    if ismember(fullName,ProjectFiles)
                        m=mtree(fullName,'-file');
                        if m.FileType==mtree.Type.ClassDefinitionFile
                            if~isempty(m.mtfind('Kind','ENUMERATION'))
                                enumIndexes(i)=true;
                            else
                                classIndexes(i)=true;
                            end
                        end
                    end
                end
                classpaths=fullfile(self.project.RootFolder,fileList(classIndexes));
                enumpaths=fullfile(self.project.RootFolder,fileList(enumIndexes));
            end
        end

        function f=createFolder(self,folderPath)
            f=classdiagram.app.core.domain.Folder(folderPath,self.GlobalSettingsFcn);
            metadata=containers.Map;
            try
                metadata('projectfiles')=[self.project.Files.Path];
            catch

                self.setState(self.Stale);
                metadata('projectfiles')=[];
            end
            f.setMetadata(metadata);
        end

    end
end
