



classdef MatlabFunctionInnerFunctionConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Inner function definition is not supported';
        end


        function obj=MatlabFunctionInnerFunctionConstraint
            obj.setEnum('MatlabFunctionInnerFunction');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=check(aObj)

            out=[];

            assert(isa(aObj.getOwner(),'slci.ast.SFAstMatlabFunctionDef'));
            ast=aObj.getOwner();
            if(ast.getFunctionID()~=ast.ParentChart.getRootFunctionID)
                isInnerFunc=aObj.isInnerFunction(ast);
                if isInnerFunc
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum());
                end
            end

        end

    end

    methods(Access=private)


        function out=isInnerFunction(~,funcDef)
            assert(isa(funcDef,'slci.ast.SFAstMatlabFunctionDef'))

            out=funcDef.getParentFuncAst();
        end

    end
end