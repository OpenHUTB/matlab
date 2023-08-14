classdef Folder<classdiagram.app.core.domain.BaseObject


    properties(Constant)
        ConstantType="Folder";
    end

    methods
        function obj=Folder(folderName,globalSettingsFcn)
            obj.Type=classdiagram.app.core.domain.Folder.ConstantType;
            obj.Name=folderName;
            if~classdiagram.app.core.domain.Folder.isOnPath(folderName)
                obj.setState(classdiagram.app.core.domain.ElementState.NotOnPath);
            end
            obj.GlobalSettingsFcn=globalSettingsFcn;
        end

        function subFolders=getSubFolders(self)
            folders=self.getSubFolderPaths();
            subFolders=[];
            if~isempty(folders)
                subFolders=cellfun(@(x)self.createFolder(fullfile(self.Name,x)),folders,'uni',false);
                subFolders=[subFolders{:}];
            end
        end

        function[classnames,enumnames]=getClassFullNames(self)
            import classdiagram.app.core.domain.Folder;
            [fullClassPaths,fullEnumPaths,classFolderName]=self.getClassFullPaths();
            classnames={};
            if~isempty(fullClassPaths)
                classnames=cellfun(@(n)Folder.getClassFullName(n),fullClassPaths,'uni',false);
            end

            enumnames={};
            if~isempty(fullEnumPaths)
                enumnames=cellfun(@(n)Folder.getClassFullName(n),fullEnumPaths,'uni',false);
            end
            if~isempty(classFolderName)
                try
                    metadata=meta.class.fromName(classFolderName);
                catch
                    return;
                end
                if isempty(metadata)
                    return;
                end
                if metadata.Enumeration
                    enumnames{end+1}=classFolderName;
                else
                    classnames{end+1}=classFolderName;
                end
            end
        end

        function hasChild=hasChild(self)
            [class,enum,atClass]=self.getClassFullPaths;
            hasChild=~isempty(self.getSubFolderPaths)||~isempty(class)...
            ||~isempty(enum)||~isempty(atClass);
        end

        function count=childCount(self)
            count=length(self.getSubFolderPaths())+length(self.getClassFullPaths);
        end

        function accept(self,visitor)
            visitor.visitFolder(self);
        end
    end

    methods(Access=private)
        function subFolders=getSubFolderPaths(self)

            allItems=dir(self.Name);

            folderIndex=[allItems.isdir];

            folders={allItems(folderIndex).name}';

            validIndex=~ismember(folders,{'.','..'});
            subFolders=folders(validIndex);

            if ispc
                lowCaseFolders=lower(subFolders);
                [~,uniqueIndex,~]=unique(lowCaseFolders);
                subFolders=subFolders(uniqueIndex);
            end


            projectFiles=self.getMetadataByKey('projectfiles');
            if~isempty(projectFiles)
                validIndex=false(1,length(subFolders));
                for i=1:length(subFolders)
                    validIndex(i)=ismember(string(fullfile(self.Name,subFolders(i))),projectFiles);
                end
                subFolders=subFolders(validIndex);
            end
        end

        function[classpaths,enumpaths,classFolderName]=getClassFullPaths(self)
            classpaths={};
            enumpaths={};
            classFolderName=self.getClassFolderName;

            if~isempty(classFolderName)
                return;
            end

            allItems=dir(self.Name);
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
            if~isempty(fileList)
                for i=1:length(fileList)
                    m=mtree(fullfile(self.Name,fileList{i}),'-file');
                    if m.FileType==mtree.Type.ClassDefinitionFile
                        if~isempty(m.mtfind('Kind','ENUMERATION'))
                            enumIndexes(i)=true;
                        else
                            classIndexes(i)=true;
                        end
                    end
                end
                classpaths=fullfile(self.Name,fileList(classIndexes));
                enumpaths=fullfile(self.Name,fileList(enumIndexes));
            end
        end

        function name=getClassFolderName(self)
            name=[];
            fileParts=regexp(self.Name,filesep,'split');
            folderName=string(fileParts{end});
            if~folderName.startsWith("@")
                return;
            end
            packageParts=fileParts(cellfun(@(f)contains(f,'+'),fileParts));
            fullClassPath="";
            for i=1:length(packageParts)
                fullClassPath=fullClassPath+packageParts{i}(2:end)+".";
            end
            name=fullClassPath+string(regexprep(folderName,'^@','','once'));
        end

        function f=createFolder(obj,folderPath)
            f=classdiagram.app.core.domain.Folder(folderPath,obj.GlobalSettingsFcn);
            meta=obj.getMetadata;
            if~isempty(meta)
                f.setMetadata(meta);
            end
        end
    end

    methods(Static)
        function fullClassPath=getClassFullName(fullPath)
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


        function onPath=isOnPath(folderName)

            function plainFolder=nearestPlainFolder(folderName)
                folderPathCell=string(regexp(folderName,filesep,'split'));
                normalFolderIndex=arrayfun(@(f)~f.startsWith("+")&&~f.startsWith("@"),folderPathCell);
                index=find(normalFolderIndex,1,'last');
                plainFolder=folderPathCell(1:index).join(filesep);
            end


            folderName=regexprep(folderName,[filesep,'\$'],'');
            pathCell=regexp(path,pathsep,'split');
            pathCell{end+1}=pwd;
            if classdiagram.app.core.domain.Folder.isPackageOrClassFolder(folderName)
                parentFolder=nearestPlainFolder(folderName);


                if ispc
                    onPath=any(strcmpi(parentFolder,pathCell));
                else
                    onPath=any(strcmp(parentFolder,pathCell));
                end
            else


                if ispc
                    onPath=any(strcmpi(folderName,pathCell));
                else
                    onPath=any(strcmp(folderName,pathCell));
                end
            end
        end

        function ispkg=isPackageOrClassFolder(fName)
            pathCell=regexp(fName,filesep,'split');
            folderName=string(pathCell{end});
            ispkg=folderName.startsWith("+")||folderName.startsWith("@");
        end

    end
end
