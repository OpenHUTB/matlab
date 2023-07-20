



classdef MatlabFunctionCastArgConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Cast in Matlab function data does not support dynamic casting type';
        end


        function obj=MatlabFunctionCastArgConstraint()
            obj.setEnum('MatlabFunctionCastArg');
            obj.setFatal(false);
        end


        function out=check(aObj)

            out=[];
            owner=aObj.getOwner();
            assert(isa(owner,'slci.ast.SFAstCastFunction'));
            typeValue=aObj.getOwner().getTypeValue();
            if~isempty(typeValue)&&...
                ~isa(typeValue,'slci.ast.SFAstString')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getID());
            end
        end

    end

end
