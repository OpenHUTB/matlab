



classdef SFAstManualReview<slci.ast.SFAstMatlabDirective

    properties(Access=protected)


        fArg=true;
    end

    methods


        function aObj=SFAstManualReview(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAstMatlabDirective(aAstObj,...
            aParent);

        end


        function arg=getArg(aObj)
            arg=aObj.fArg;
        end

    end

    methods(Access=protected)


        function populateChildrenFromMtreeNode(~,~)

        end

    end


end
