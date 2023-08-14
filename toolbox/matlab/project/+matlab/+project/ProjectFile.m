classdef ProjectFile






























    properties(SetAccess=private,GetAccess=public)

Path
    end
    properties(SetAccess=private,GetAccess=private,Hidden=true)
ProjectContainer
ProjectInstance
    end

    properties(Dependent=true,GetAccess=public,SetAccess=public)

Labels
    end

    properties(Dependent=true,GetAccess=public,SetAccess=private)


Revision


SourceControlStatus
    end


    methods(Access=public,Hidden=true)
        function obj=ProjectFile(file,projectContainer,projectInstance)




            obj.ProjectContainer=projectContainer;
            obj.ProjectInstance=projectInstance;

            obj.Path=string(file);

        end
    end

    methods(Access=public)

        function label=findLabel(obj,varargin)







            narginchk(2,3);

            validateattributes(obj,{'matlab.project.ProjectFile'},{},'','file');

            filesInProjects=arrayfun(@(x)x.ProjectInstance.isFileInProject(x.Path),obj);
            if any(~filesInProjects)
                file=obj(~filesInProjects);
                error(message('MATLAB:project:api:FileIsNotInProject',file.Path));
            end

            if ischar(varargin{1})||isstring(varargin{1})

                p=inputParser;
                p.addRequired('categoryName',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
                p.addRequired('labelName',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
                p.parse(varargin{:});
                categoryName=p.Results.categoryName;
                if isstring(categoryName)
                    categoryName=char(categoryName);
                end
                possibleCategoryNames=arrayfun(@(x)x.ProjectInstance.getCategoryNamesCellArray(),obj,'UniformOutput',false);
                categoryName=validatestring(categoryName,...
                sort(unique([possibleCategoryNames{:}])),'','categoryName');
                labelName=p.Results.labelName;
                if isstring(labelName)
                    labelName=char(labelName);
                end
            else

                p=inputParser;
                p.addRequired('labelDefinition',@(x)validateattributes(x,{'matlab.project.LabelDefinition'},{}));
                p.parse(varargin{:});
                if isempty(p.Results.labelDefinition)
                    label=matlab.project.LabelDefinition.empty(1,0);
                    return
                end
                categoryName=p.Results.labelDefinition.CategoryName;
                labelName=p.Results.labelDefinition.Name;
            end

            label=arrayfun(@(x)x.findLabelByName(categoryName,labelName),obj,'UniformOutput',false);
            label=[label{:}];
        end

        function label=addLabel(obj,varargin)

























            narginchk(2,4);

            validateattributes(obj,{'matlab.project.ProjectFile'},{'size',[1,1]},'','file');
            dataTypes=obj.ProjectInstance.ValidationLabelDataTypes.values;
            dataTypes=unique(dataTypes(~cellfun('isempty',dataTypes)));

            if ischar(varargin{1})||isstring(varargin{1})


                p=inputParser;
                p.addRequired('categoryName',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
                p.addRequired('labelName',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
                p.addOptional('data','',@(x)validateattributes(x,dataTypes,{}));
                p.parse(varargin{:});
                categoryName=p.Results.categoryName;
                if isstring(categoryName)
                    categoryName=char(categoryName);
                end
                categoryName=validatestring(categoryName,...
                sort(obj.ProjectInstance.getCategoryNamesCellArray()),'','categoryName');
                labelName=p.Results.labelName;
                if isstring(labelName)
                    labelName=char(labelName);
                end
            else

                p=inputParser;
                p.addRequired('labelDefinition',@(x)validateattributes(x,{'matlab.project.LabelDefinition'},{'nonempty'}));
                p.addOptional('data','',@(x)validateattributes(x,dataTypes,{}));
                p.parse(varargin{:});
                categoryName=p.Results.labelDefinition.CategoryName;
                labelName=p.Results.labelDefinition.Name;
            end




            if(~any(strcmp('data',p.UsingDefaults)))
                clearUpOnError=isempty(obj.findLabel(categoryName,labelName));
            end

            label=obj.addLabelToFileByName(categoryName,labelName);

            if(~any(strcmp('data',p.UsingDefaults)))
                expectedDataType=obj.ProjectInstance.ValidationLabelDataTypes(label.DataType);
                try
                    if isempty(expectedDataType)
                        error(message('MATLAB:project:api:LabelDataTypeMismatchValues',...
                        labelName,categoryName,label.DataType));
                    end

                    if strcmp(expectedDataType,'char')
                        attributes={'row'};
                    else
                        attributes={'scalar'};
                    end
                    data=p.Results.data;
                    if isstring(data)
                        data=char(data);
                    end

                    validateattributes(data,{expectedDataType},attributes,'','data');
                    label.Data=data;
                catch E
                    if clearUpOnError
                        obj.removeLabelFromFileByLabelDefinition(label);
                    end
                    rethrow(E)
                end
            end

        end

        function removeLabel(obj,varargin)





            narginchk(2,3);

            validateattributes(obj,{'matlab.project.ProjectFile'},{'size',[1,1]},'','file');

            if ischar(varargin{1})||isstring(varargin{1})

                p=inputParser;
                p.addRequired('categoryName',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
                p.addRequired('labelName',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
                p.parse(varargin{:});

                categoryName=p.Results.categoryName;
                if isstring(categoryName)
                    categoryName=char(categoryName);
                end
                categoryName=validatestring(categoryName,...
                sort(obj.ProjectInstance.getCategoryNamesCellArray()),'','categoryName');

                labelName=p.Results.labelName;
                if isstring(labelName)
                    labelName=char(labelName);
                end

                labelDefinition=obj.getLabelDefinition(categoryName,labelName);
            else

                p=inputParser;
                p.addRequired('labelDefinition',@(x)validateattributes(x,{'matlab.project.LabelDefinition'},{}));
                p.parse(varargin{:});
                labelDefinition=p.Results.labelDefinition;
            end

            obj.removeLabelFromFileByLabelDefinition(labelDefinition);

        end

    end

    methods(Access=public,Hidden=true)
        function value=evaluate(obj,onProject)
            value=onProject(obj.ProjectContainer());
        end
    end

    methods


        function labels=get.Labels(obj)









            import matlab.internal.project.util.*;

            javaProjectManager=obj.ProjectContainer.getJavaProjectManager();


            jFileLabelList=processJavaCall(@()javaProjectManager.getLabels(java.io.File(obj.Path)));

            converter=@(label)matlab.project.Label(...
            char(label.getCategory.getName),char(label.getName),...
            obj.ProjectInstance,obj.Path...
            );

            labelsCellArray=convertJavaCollectionToCellArray(jFileLabelList,converter);

            labels=[labelsCellArray{:}];

            if isempty(labels)
                labels=matlab.project.Label.empty(1,0);
            end
        end

        function obj=set.Labels(obj,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'Labels',...
            'matlab.project.ProjectFile',...
            'addLabel',...
            'matlab.project.ProjectFile');
        end

        function sourceControlStatus=get.SourceControlStatus(obj)









            import matlab.internal.project.util.processJavaCall;
            import matlab.internal.project.util.convertLocalStatusJava2Matlab;

            projectContainer=obj.ProjectContainer;
            projectControlSetRef=projectContainer.getJavaProjectControlSet();
            cmStatusCache=processJavaCall(@()projectControlSetRef.getCMStatusCache());

            usingSourceControl=processJavaCall(@()cmStatusCache.usingCM());

            if(~usingSourceControl)
                sourceControlStatus=matlab.sourcecontrol.Status.NotUnderSourceControl;
            else
                filePath=obj.Path;
                newFile=java.io.File(filePath);
                fileState=processJavaCall(@()cmStatusCache.getFileState(newFile));
                if isempty(fileState)
                    sourceControlStatus=matlab.sourcecontrol.Status.Unknown;
                else
                    localStatus=processJavaCall(@()fileState.getLocalStatus());
                    matlabEnumStatus=convertLocalStatusJava2Matlab(localStatus.name);
                    sourceControlStatus=matlab.sourcecontrol.Status.(matlabEnumStatus);
                end
            end
        end

        function stringRepresentation=get.Revision(obj)








            import matlab.internal.project.util.processJavaCall;

            projectContainer=obj.ProjectContainer;
            projectControlSetRef=projectContainer.getJavaProjectControlSet();
            cmStatusCache=processJavaCall(@()projectControlSetRef.getCMStatusCache());

            filePath=obj.Path;
            newFile=java.io.File(filePath);
            revision=processJavaCall(@()cmStatusCache.getRevision(newFile));

            if~isempty(revision)
                stringRepresentation=string(processJavaCall(@()revision.getStringRepresentation()));
            else
                stringRepresentation="";
            end

        end

    end

    methods(Access=private)

        function label=findLabelByName(obj,categoryName,labelName)

            javaProjectManager=obj.ProjectContainer.getJavaProjectManager();
            javaLabels=javaProjectManager.getLabels(java.io.File(obj.Path));

            label=matlab.project.Label.empty(0,0);

            javaCatName=java.lang.String(categoryName);
            javaLabelName=java.lang.String(labelName);

            for labelIndex=0:javaLabels.size()-1
                javaLabel=javaLabels.get(labelIndex);
                if(javaLabel.getName.equals(javaLabelName)&&javaLabel.getCategory.getName.equals(javaCatName))
                    label=matlab.project.Label(categoryName,labelName,obj.ProjectInstance,obj.Path);
                    return
                end
            end

        end

        function label=addLabelToFileByName(obj,categoryName,labelName)

            javaProjectManager=obj.ProjectInstance.getJavaProjectManager();
            import matlab.internal.project.util.processJavaCall;
            import matlab.internal.project.util.exceptions.CatchAndRunExceptionHandler;

            exceptionHandler=CatchAndRunExceptionHandler('MATLAB:undefinedFunction',...
            @(exception)checkNameArguments(exception,categoryName,labelName));

            processJavaCall(...
            @()javaProjectManager.addLabelToFile(char(obj.Path),char(categoryName),char(labelName)),...
            {exceptionHandler}...
            );

            label=matlab.project.Label(categoryName,labelName,obj.ProjectInstance,obj.Path);

            function checkNameArguments(exception,catName,labName)
                validateattributes(catName,{'char','string'},{'nonempty'});
                validateattributes(labName,{'char','string'},{'nonempty'});
                rethrow(exception);
            end

        end

        function labelDefinition=getLabelDefinition(obj,categoryName,labelName)
            validateattributes(categoryName,{'char','string'},{'nonempty'});
            validateattributes(labelName,{'char','string'},{'nonempty'});

            categoryName=validatestring(categoryName,...
            sort(obj.ProjectInstance.getCategoryNamesCellArray()),'','categoryName');
            category=obj.ProjectInstance.findCategory(categoryName);

            if isstring(labelName)
                labelName=char(labelName);
            end

            categories={category.LabelDefinitions.Name};
            categories=sort(cellfun(@(x)char(x),categories,'UniformOutput',false));

            labelName=validatestring(labelName,categories,'','labelName');
            labelDefinition=category.findLabel(labelName);

        end

        function removeLabelFromFileByLabelDefinition(obj,labelDefinition)
            file=obj.Path;


            if isempty(obj.findLabel(labelDefinition))

                if isempty(labelDefinition)
                    warning(message('MATLAB:project:api:EmptyLabelOperation'))
                end
                return
            end

            obj.ProjectInstance.assertLabelExists(labelDefinition);

            javaProjectManager=obj.ProjectInstance.getJavaProjectManager();
            import matlab.internal.project.util.createFileListFromString;
            fileList=createFileListFromString(file);

            import matlab.internal.project.util.asArrayList;
            jlabel=asArrayList(...
            obj.ProjectInstance.getJavaLabelFromMatlabLabel(labelDefinition)...
            );

            import matlab.internal.project.util.processJavaCall;
            processJavaCall(@()javaProjectManager.removeLabels(fileList,jlabel))

        end


    end


end
