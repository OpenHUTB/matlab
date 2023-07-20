



classdef MatlabFunctionRecursiveFunctionConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Recursive function call is not supported';
        end


        function obj=MatlabFunctionRecursiveFunctionConstraint
            obj.setEnum('MatlabFunctionRecursiveFunction');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=check(aObj)

            out=[];

            assert(isa(aObj.getOwner(),'slci.ast.SFAstMatlabFunctionDef'));
            ast=aObj.getOwner();

            if(ast.getFunctionID()~=ast.ParentChart.getRootFunctionID)
                unSupported=aObj.IsRecursiveFunction(ast);
                if unSupported
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum());
                end
            end

        end

    end

    methods(Access=private)


        function out=IsRecursiveFunction(~,funcDef)
            out=false;
            assert(isa(funcDef,'slci.ast.SFAstMatlabFunctionDef'))
            if funcDef.getFunctionID~=-1

                funcId=funcDef.getFunctionID;
                emChart=funcDef.ParentChart;
                out=emChart.isRecursiveFunc(funcId);
            end
        end

    end
end