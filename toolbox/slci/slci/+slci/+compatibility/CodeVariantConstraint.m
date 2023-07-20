


classdef CodeVariantConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'CodeVariant',...
            aObj.ParentBlock().getName());
        end

    end

    methods

        function obj=CodeVariantConstraint()
            obj.setEnum('CodeVariant');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
            obj.addPreRequisiteConstraint(...
            slci.compatibility.ERTTargetConstraint);
        end

        function out=check(aObj)
            out=[];



            if strcmpi(aObj.ParentModel.getParam('InlineParams'),'on')&&...
                strcmpi(aObj.ParentBlock().getParam('Variant'),'on')
                pp=strcmpi(aObj.ParentBlock().getParam('GeneratePreprocessorConditionals'),'on');
                if pp
                    out=aObj.getIncompatibility();
                end
            end
        end

    end
end
