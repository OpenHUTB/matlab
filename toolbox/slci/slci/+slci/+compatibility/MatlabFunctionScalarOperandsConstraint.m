



classdef MatlabFunctionScalarOperandsConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Operands of MATLAB operator or function must be scalar type';
        end


        function obj=MatlabFunctionScalarOperandsConstraint
            obj.setEnum('MatlabFunctionScalarOperands');
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            owner=aObj.getOwner();

            children=owner.getChildren();
            scalar=true;
            for i=1:numel(children)
                dataDim=children{i}.getDataDim();
                isMissingDim=isscalar(dataDim)&&(dataDim==-1);
                if~isMissingDim&&~all(dataDim==1)
                    scalar=false;
                    break;
                end
            end
            if~scalar
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum()...
                );
            end
        end

    end

end
