





classdef MatlabFunctionArrayIndexNumConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out=['Matlab array indexing could not have subscripts '...
            ,'more than number of base dimension'];
        end


        function aObj=MatlabFunctionArrayIndexNumConstraint
            aObj.setEnum('MatlabFunctionArrayIndexNum');
            aObj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            owner=aObj.getOwner();
            assert(isa(owner,'slci.ast.SFAstArray'));
            children=owner.getChildren();
            assert(numel(children)>1);
            baseDim=children{1}.getDataDim();
            missingBaseDim=isequal(baseDim,-1);
            numIndex=numel(children)-1;

            if~missingBaseDim&&numIndex>numel(baseDim)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end
        end
    end
end