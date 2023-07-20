classdef GetComparisonTypesVisitor<evolutions.internal.filetypehandler.Visitor




    properties
ComparisonTypes
    end

    methods
        function obj=GetComparisonTypesVisitor
            obj.ComparisonTypes=cell.empty;
        end
    end
    methods(Access=protected)
        function visitModelFile(obj,~)
            obj.ComparisonTypes={'Model','Binary'};
        end

        function visitXMLFile(obj,~)
            obj.ComparisonTypes={'Text','xml','Binary'};
        end

        function visitOtherFile(obj,~)
            obj.ComparisonTypes={'File','Binary'};
        end
    end
end
