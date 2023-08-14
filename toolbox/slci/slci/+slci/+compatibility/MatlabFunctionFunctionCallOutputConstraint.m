



classdef MatlabFunctionFunctionCallOutputConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Matlab Function call output cannot be called in a subfunction';
        end


        function obj=MatlabFunctionFunctionCallOutputConstraint
            obj.setEnum('MatlabFunctionFunctionCallOutput');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=check(aObj)

            out=[];

            assert(isa(aObj.getOwner(),'slci.ast.SFAstMLFunctionCallEvent'));
            ast=aObj.getOwner();


            [isParentFunc,parentFuncAst]=ast.getParentFuncAst();

            if isParentFunc

                assert(isa(parentFuncAst,'slci.ast.SFAstMatlabFunctionDef'));
                if(parentFuncAst.getFunctionID()~=ast.ParentChart.getRootFunctionID)
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum());
                end
            end

        end

    end

end