classdef Commentable<matlabshared.devicetree.util.Printable

    properties(SetAccess=protected)
        Comments string
    end

    methods
        function obj=Commentable
        end

        function addComment(obj,commentStr)

            obj.Comments(end+1)=commentStr;
        end
    end


    methods(Access=protected)
        function printHeader(obj,hDTPrinter,~,~)

            for comment=obj.Comments
                hDTPrinter.addComment(comment);
            end
        end
    end
end