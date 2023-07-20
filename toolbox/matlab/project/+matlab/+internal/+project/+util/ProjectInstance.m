classdef ProjectInstance<handle


    properties(GetAccess=public,Constant=true)
        ValidationLabelDataTypes=...
        containers.Map(...
        {'char','string','double','integer','logical','none'},...
        {'char','string','numeric','numeric','logical',''},...
        'UniformValues',true);
    end

    properties(GetAccess=private,SetAccess=private,Hidden=true)
ProjectContainer
    end

    properties(GetAccess=public,SetAccess=private)
LabelDataTypes
    end

    methods(Access=public)

        function obj=ProjectInstance(varargin)





            if nargin==0
                projectContainer=[];
            else
                projectContainer=varargin{1};
            end

            import matlab.internal.project.util.*;

            privateConstructorInputValidate(...
            projectContainer,...
'matlab.internal.project.containers.ProjectContainer'...
            );

            obj.ProjectContainer=projectContainer;

            import com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIUtils;
            labelDataTypesCollection=MatlabAPIUtils.getAvailableLabelDataTypes();
            obj.LabelDataTypes=convertJavaCollectionToCellArray(labelDataTypesCollection);
        end

        function projectRoot=getProjectRoot(obj)
            javaDirectory=obj.getJavaProjectManager.getProjectRoot();
            projectRoot=char(javaDirectory.getAbsolutePath());
        end

        function files=getFilesInProject(obj,varargin)

















            javaProjectManager=obj.getJavaProjectManager();

            fileCollection=javaProjectManager.getProjectFiles();
            files=obj.convert(fileCollection);
            if(~isempty(files))
                [~,idx]=sort([files.Path]);
                files=files(idx);
            end

            p=inputParser;
            p.addOptional('includeFolders',true,@(x)validateattributes(x,{'logical'},{'nonempty'},'','includeFolders'));
            p.parse(varargin{:});

            if p.Results.includeFolders||isempty(files)||~iscell(files)
                return;
            end

            dirsIdx=cellfun(@(x)isDir(x.Path),files);

            files(dirsIdx)=[];

        end

        function files=listModifiedFiles(obj,varargin)

















            javaProjectManager=obj.getJavaProjectManager();

            fileCollection=javaProjectManager.getModifiedFiles();
            files=obj.convert(fileCollection);
            if(~isempty(files))
                [~,idx]=sort([files.Path]);
                files=files(idx);
            end

            p=inputParser;
            p.addOptional('includeFolders',true,@(x)validateattributes(x,{'logical'},{'nonempty'},'','includeFolders'));
            p.parse(varargin{:});

            if p.Results.includeFolders||isempty(files)||~iscell(files)
                return;
            end

            dirsIdx=cellfun(@(x)isDir(x.Path),files);

            files(dirsIdx)=[];

        end




        function files=convert(obj,JavaFileCollection)

            import matlab.internal.project.util.*;

            projectContainer=obj.ProjectContainer;
            converter=@(jFile)matlab.project.ProjectFile(char(jFile.getAbsolutePath()),projectContainer,obj);
            files=convertJavaCollectionToCellArray(JavaFileCollection,converter);
            files=[files{:}];
        end

        function categoryManager=getCategoryManager(obj)

            javaProjectManager=obj.getJavaProjectManager();

            import matlab.internal.project.util.processJavaCall;
            categoryManager=processJavaCall(...
            @()javaProjectManager.getCategoryManager()...
            );
        end

        function category=getJavaCategoryByName(obj,categoryName)

            import matlab.internal.project.util.*;
            categoryManager=obj.getCategoryManager();

            category=processJavaCall(@()categoryManager.getCategory(categoryName));

        end

        function jLabel=getJavaLabelFromMatlabLabel(obj,mLabel)

            import matlab.internal.project.util.*;
            categoryManager=obj.getCategoryManager();

            labelName=mLabel.Name;
            categoryName=mLabel.CategoryName;
            jLabel=processJavaCall(@()categoryManager.getLabel(categoryName,labelName));

        end

        function categoryNames=getCategoryNamesCellArray(obj)
            import matlab.internal.project.util.convertJavaCollectionToCellArray;

            categoryManager=obj.getCategoryManager();
            categoryList=categoryManager.getAllCategories();
            converter=@(category)char(category.getName());
            categoryNames=convertJavaCollectionToCellArray(categoryList,converter);

        end

        function categories=getCategories(obj)

            converter=@(category)...
            matlab.project.Category(...
            category.getName(),...
            category.isSingleValued(),...
            obj.ProjectContainer...
            );

            import matlab.internal.project.util.*;

            categoryManager=obj.getCategoryManager();
            categoryList=categoryManager.getAllCategories();
            categories=convertJavaCollectionToCellArray(categoryList,converter);
            categories=[categories{:}];

        end

        function found=isFileInProject(obj,file)
            javaProjectManager=obj.getJavaProjectManager();
            javaFile=java.io.File(file);

            import matlab.internal.project.util.processJavaCall;
            found=processJavaCall(...
            @()javaProjectManager.isFileInProject(javaFile)...
            );

        end

        function found=doesCategoryExist(obj,category)

            categories=obj.getCategories();

            found=~isempty(categories)...
            &&any(strcmp(category,{categories.Name}));
        end

        function assertCategoryExists(obj,category)
            if~obj.doesCategoryExist(category)
                error(message(...
                'MATLAB:project:api:CategoryDoesNotExist',...
                category));
            end
        end

        function category=findCategory(obj,categoryName)

            categories=obj.getCategories();
            idx=strcmp(string(categoryName),[categories.Name]);
            categories=categories(idx);

            if isempty(categories)
                category=[];
                return
            end

            category=categories(1);
        end


        function assertLabelExists(obj,label)

            onNoLabel=@(category)...
            error(message('MATLAB:project:api:LabelDoesNotExist',...
            label.LabelName,label.CategoryName));

            obj.actOnMissingLabel(label,onNoLabel);
        end





        function actOnMissingLabel(obj,label,onNoLabel)

            category=obj.findCategory(label.CategoryName);

            if isempty(category)
                error(message('MATLAB:project:api:CategoryDoesNotExist',...
                label.CategoryName));
            end

            label=category.findLabel(label.Name);
            if isempty(label)
                onNoLabel(category);
            end
        end


        function javaProjectManager=getJavaProjectManager(obj)
            javaProjectManager=obj.ProjectContainer.getJavaProjectManager();
        end

        function category=getJavaCategoryFromCollectionByName(~,categoryList,categoryName)

            import matlab.internal.project.util.*;
            searchCondition=@(category)strcmp(char(category.getName),categoryName);
            category=findEntryInJavaCollection(categoryList,searchCondition);

        end


        function assertFileExists(~,file)


            if~exist(file,'file')&&~exist(file,'dir')
                error(message('MATLAB:project:api:FileDoesNotExist',file));
            end

        end

        function sortedArray=sort(objArray)

            if numel(objArray)<2
                sortedArray=objArray;
                return
            end
            projectRoots=arrayfun(@(x)x.getProjectRoot(),objArray,'UniformOutput',false);
            [~,index]=sort(projectRoots);
            sortedArray=objArray(index);
        end
    end

end
