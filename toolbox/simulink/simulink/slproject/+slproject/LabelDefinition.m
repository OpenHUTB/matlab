classdef LabelDefinition










































    properties(GetAccess=public,SetAccess=immutable)

        Name(1,:)char;

        CategoryName(1,:)char;
    end

    methods(Access=public)

        function obj=LabelDefinition(categoryName,labelName)












            validateattributes(categoryName,{'char','string'},{'nonempty'})
            validateattributes(labelName,{'char','string'},{'nonempty'})

            obj.CategoryName=categoryName;
            obj.Name=labelName;
        end

    end

    methods(Access=public,Hidden=true)
        function sortedArray=sort(objArray)

            if numel(objArray)<2
                sortedArray=objArray;
                return
            end
            [~,index]=sort({objArray.Name});
            sortedArray=objArray(index);
        end
    end
end
