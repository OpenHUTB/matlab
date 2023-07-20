classdef Category












    properties(Dependent,GetAccess=public,SetAccess=private)

        Name;

        SingleValued;

        DataType;
    end

    properties(Dependent,GetAccess=public,SetAccess=public)

        LabelDefinitions;
    end

    properties(GetAccess=private,SetAccess=private,Hidden)
        mCategory;
    end

    methods(Access=public,Hidden=true)
        function obj=Category(mCategory)



            obj.mCategory=mCategory;
        end
    end

    methods(Access=public)
        function labelDefinition=createLabel(obj,labelName)











            validateattributes(obj,{'slproject.Category'},{'size',[1,1]},'','category');
            mLabelDefinition=obj.mCategory.createLabel(labelName);
            labelDefinition=iConvert(mLabelDefinition);
        end

        function removeLabel(obj,labelName)














            validateattributes(obj,{'slproject.Category'},{'size',[1,1]},'','category');
            validateattributes(labelName,{'char','string','slproject.LabelDefinition'},{'nonempty'},'','labelName');

            if isa(labelName,'slproject.LabelDefinition')
                labelName=labelName.Name;
            end
            obj.mCategory.removeLabel(labelName);
        end

        function labelDefinition=findLabel(obj,labelName)










            validateattributes(obj,{'slproject.Category'},{'size',[1,1]},'','category');

            mLabelDefinition=obj.mCategory.findLabel(labelName);
            if isempty(mLabelDefinition)
                labelDefinition=slproject.LabelDefinition.empty(1,0);
            else
                labelDefinition=iConvert(mLabelDefinition);
            end
        end
    end

    methods
        function name=get.Name(obj)
            name=char(obj.mCategory.Name);
        end

        function value=get.SingleValued(obj)
            value=obj.mCategory.SingleValued;
        end

        function dataType=get.DataType(obj)
            dataType=char(obj.mCategory.DataType);
        end

        function labels=get.LabelDefinitions(obj)
            labels=arrayfun(@iConvert,obj.mCategory.LabelDefinitions);
            if isempty(labels)
                labels=slproject.LabelDefinition.empty(1,0);
            end
        end

        function obj=set.LabelDefinitions(obj,~)
            import matlab.internal.project.util.SettablePropertyError;
            SettablePropertyError.createAndThrowAsCaller(...
            'LabelDefinitions',...
            'slproject.Category',...
            'createLabel',...
            'slproject.Category');
        end
    end
end

function labelDefinition=iConvert(mLabelDefinition)
    labelDefinition=slproject.LabelDefinition(...
    mLabelDefinition.CategoryName,...
    mLabelDefinition.Name);
end
