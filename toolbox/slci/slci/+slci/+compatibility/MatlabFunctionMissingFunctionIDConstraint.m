



classdef MatlabFunctionMissingFunctionIDConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Flag a function call node with no function ID ';
        end


        function obj=MatlabFunctionMissingFunctionIDConstraint
            obj.setEnum('MatlabFunctionMissingFunctionID');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=check(aObj)

            out=[];

            assert(isa(aObj.getOwner(),...
            'slci.ast.SFAstMatlabFunctionCall'));

            if aObj.getOwner().getFunctionID()==-1
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'MatlabFunctionMissingFunctionID',...
                aObj.ParentBlock().getName());
            end

        end

    end


end
