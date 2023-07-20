



classdef MatlabFunctionScalarIntegerOperandsConstraint<...
    slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out=['Matlab function data must not be vectors or matrices '...
            ,'of type integer'];
        end


        function obj=MatlabFunctionScalarIntegerOperandsConstraint
            obj.setEnum('MatlabFunctionScalarIntegerOperands');
            obj.setFatal(false);
        end


        function out=check(aObj)

            out=[];
            owner=aObj.getOwner();
            assert(isa(owner,'slci.ast.SFAst'));

            children=owner.getChildren();
            for i=1:numel(children)
                dataType=children{i}.getDataType();

                isInteger=any(strcmp(dataType,{'int8','uint8',...
                'int16','uint16',...
                'int32','uint32'}));
                if isInteger


                    if~aObj.isScalarDim(children{i}.getDataDim())
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        aObj.getEnum());
                        break;
                    end
                end
            end
        end
    end

    methods(Access=private)

        function out=isScalarDim(aObj,dataDim)
            out=true;
            isMissingDim=isscalar(dataDim)&&(dataDim==-1);
            if~isMissingDim&&~all(dataDim==1)
                out=false;
            end
        end
    end

end