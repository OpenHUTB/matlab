classdef Category












    properties(GetAccess=public,SetAccess=private)

        Name;

        SingleValued;
    end

    properties(Dependent=true,GetAccess=public,SetAccess=private)

        DataType;
    end

    properties(Dependent=true,GetAccess=public,SetAccess=public)

        LabelDefinitions;
    end

    properties(GetAccess=private,SetAccess=private,Hidden=true)
ProjectContainer
    end

    properties(Dependent=true,Hidden=true,GetAccess=public,SetAccess=private)
        UUID;
    end

    methods(Access=public,Hidden=true)

        function obj=Category(name,singleValued,projectContainer)



            if nargin~=3
                projectContainer=[];
            end
            import matlab.internal.project.util.*;
            privateConstructorInputValidate(...
            projectContainer,...
'matlab.internal.project.containers.ProjectContainer'...
            );

            obj.Name=string(name);
            obj.SingleValued=singleValued;
            obj.ProjectContainer=projectContainer;
        end

        function sortedArray=sort(objArray)

            if numel(objArray)<2
                sortedArray=objArray;
                return
            end
            [~,index]=sort([objArray.Name]);
            sortedArray=objArray(index);
        end

    end

    methods(Access=public)
        function labelDefinition=createLabel(obj,labelName)










            import com.mathworks.toolbox.slproject.project.metadata.label.LabelDefinitionSet
            import matlab.internal.project.util.*;
            validateattributes(obj,{'matlab.project.Category'},{'size',[1,1]},'','category');
            validateattributes(labelName,{'char','string'},{'nonempty'},'','labelName');

            category=obj.getJavaCategory();

            if isstring(labelName)
                labelName=char(labelName);
            end

            jLabelDefinition=LabelDefinitionSet(labelName,LabelDefinitionSet.newUUID());

            labelDefinition=obj.findLabel(labelName);
            if isempty(labelDefinition)
                processJavaCall(@()category.createLabel(jLabelDefinition));
            else
                warning(message('MATLAB:project:api:LabelExists',...
                labelName,obj.Name));
                return;
            end

            labelDefinition=matlab.project.LabelDefinition(obj.Name,labelName);
        end

        function removeLabel(obj,labelName)












            import matlab.internal.project.util.*;
            validateattributes(obj,{'matlab.project.Category'},{'size',[1,1]},'','category');
            validateattributes(labelName,{'char','string','matlab.project.LabelDefinition'},{'nonempty'},'','labelName');

            if isa(labelName,'matlab.project.LabelDefinition')
                labelName=labelName.Name;
            elseif isstring(labelName)
                labelName=char(labelName);
            end

            label=obj.findJavaLabel(labelName);
            category=obj.getJavaCategory();

            processJavaCall(@()category.deleteLabel(label));
        end

        function labelDefinition=findLabel(obj,labelName)









            validateattributes(obj,{'matlab.project.Category'},{'size',[1,1]},'','category');
            validateattributes(labelName,{'char','string'},{'nonempty'},'','labelName');

            if isstring(labelName)
                labelName=char(labelName);
            end

            if~obj.isLabelDefined(labelName)
                labelDefinition=matlab.project.LabelDefinition.empty(1,0);
                return
            end
            import matlab.internal.project.util.convertJavaLabelToMatlabLabel;
            import matlab.internal.project.util.processJavaCall;
            jLabel=obj.findJavaLabel(labelName);
            labelDefinition=processJavaCall(@()convertJavaLabelToMatlabLabel(jLabel));

        end
    end

    methods(Access=private)

        function result=isLabelDefined(obj,labelName)











            result=~isempty(obj.findLabelNoException(labelName));
        end

        function javaCategory=getJavaCategory(obj)

            import matlab.internal.project.util.*;

            javaProjectManager=obj.ProjectContainer.getJavaProjectManager();
            categoryManager=processJavaCall(@()javaProjectManager.getCategoryManager());
            categoryList=processJavaCall(@()categoryManager.getAllCategories());
            matchingCondition=@(category)iJavaStringMatch(category.getName(),obj.Name);
            javaCategory=findElementInJList(categoryList,matchingCondition);

            if isempty(javaCategory)
                error(message('MATLAB:project:api:CategoryDoesNotExist',...
                obj.Name));
            end
        end
        function label=findJavaLabel(obj,labelName)

            label=obj.findLabelNoException(labelName);
            if isempty(label)
                error(message('MATLAB:project:api:LabelDoesNotExist',...
                obj.Name,labelName));
            end

        end
        function label=findLabelNoException(obj,labelName)
            import matlab.internal.project.util.*;

            javaCategory=obj.getJavaCategory();
            labelList=processJavaCall(@()javaCategory.getLabels());
            matchingCondition=@(label)iJavaStringMatch(label.getName(),labelName);

            label=findElementInJList(labelList,matchingCondition);

        end
    end

    methods
        function dataType=get.DataType(obj)
            javaCategory=obj.getJavaCategory();
            dataTypeHandler=javaCategory.getDataTypeHandler();
            dataType=string(dataTypeHandler.getMatlabDataType());
        end

        function labels=get.LabelDefinitions(obj)
            import matlab.internal.project.util.convertJavaLabelToMatlabLabel;
            import matlab.internal.project.util.convertJavaCollectionToCellArray;

            validateattributes(obj,{'matlab.project.Category'},{'size',[1,1]});
            category=obj.getJavaCategory();
            converter=@(x)convertJavaLabelToMatlabLabel(x);
            labels=convertJavaCollectionToCellArray(category.getLabels(),converter);
            labels=sort([labels{:}]);
            if isempty(labels)
                labels=matlab.project.LabelDefinition.empty(1,0);
            end
        end

        function obj=set.LabelDefinitions(obj,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'LabelDefinitions',...
            'matlab.project.Category',...
            'createLabel',...
            'matlab.project.Category');
        end

        function uuid=get.UUID(obj)
            javaCategoryFacade=obj.getJavaCategory();
            javaCategory=javaCategoryFacade.getCategory();
            uuid=string(javaCategory.getUUID());
        end
    end


end

function match=iJavaStringMatch(javaString,matlabString)


    match=logical(...
    javaString.equals(java.lang.String(matlabString))...
    );
end
