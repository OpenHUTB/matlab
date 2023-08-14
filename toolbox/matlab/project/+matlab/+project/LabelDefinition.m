
classdef LabelDefinition







































    properties(GetAccess=public,SetAccess=private)

        Name;

        CategoryName;
    end

    methods(Access=public)

        function obj=LabelDefinition(varargin)












            narginchk(2,2)
            categoryName=varargin{1};
            labelName=varargin{2};

            validateattributes(categoryName,{'char','string'},{'nonempty'})
            validateattributes(labelName,{'char','string'},{'nonempty'})

            obj.CategoryName=string(categoryName);
            obj.Name=string(labelName);
        end

    end

    methods(Access=public,Hidden=true)
        function sortedArray=sort(objArray)

            if numel(objArray)<2
                sortedArray=objArray;
                return
            end
            [~,index]=sort([objArray.Name]);
            sortedArray=objArray(index);
        end
    end
end
