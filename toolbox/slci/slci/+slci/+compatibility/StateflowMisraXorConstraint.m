


classdef StateflowMisraXorConstraint<slci.compatibility.Constraint


    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'StateflowMisraXor',...
            aObj.ParentBlock().getName());
        end

    end

    methods


        function out=getDescription(aObj)%#ok
            out='Xor operator of boolean operands is incompatible with CastingMode Standards';
        end


        function obj=StateflowMisraXorConstraint()
            obj.setEnum('StateflowMisraXor');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end






        function out=check(aObj)
            out=[];

            casting_mode=...
            get_param(aObj.ParentModel.getName(),'CastingMode');

            if strcmpi(casting_mode,'Standards')
                asts=aObj.getOwner().getASTs();
                for i=1:numel(asts)
                    ast=asts{i};
                    if aObj.containsInvalidMisraXorType(ast)
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        'StateflowMisraXor',...
                        aObj.ParentBlock().getName(),...
                        aObj.getOwner().getClassNames());
                        return;
                    end
                end
            end
        end
    end


    methods(Access=private)

        function out=containsInvalidMisraXorType(aObj,ast)
            out=(isa(ast,'slci.ast.SFAstBitXor')...
            ||isa(ast,'slci.ast.SFAstXorAssignment'))...
            &&strcmp(ast.getDataType(),'boolean');
            if~out
                children=ast.getChildren();
                for i=1:numel(children)
                    if aObj.containsInvalidMisraXorType(children{i})
                        out=true;
                        return
                    end
                end
            end
        end
    end
end
