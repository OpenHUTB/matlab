



classdef MatlabFunctionScalarForIndexConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Index of statement for must be scalar type';
        end


        function obj=MatlabFunctionScalarForIndexConstraint
            obj.setEnum('MatlabFunctionScalarForIndex');
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            owner=aObj.getOwner();
            assert(isa(owner,'slci.ast.SFAstFor'));
            index=owner.getIndexAST();
            indexDim=index{1}.getDataDim();
            scalar=all(indexDim==1);

            if~scalar
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum()...
                );
            end
        end

    end

end
