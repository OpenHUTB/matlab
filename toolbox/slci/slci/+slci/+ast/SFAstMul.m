





classdef SFAstMul<slci.ast.SFAst

    methods(Access=protected)




        function out=IsInvalidMixedType(aObj)
            out=aObj.IsMixedType;
        end


        function out=supportsEnumOperation(aObj)%#ok
            out=false;
        end

    end

    methods

        function ComputeDataType(aObj)

            assert(~aObj.fComputedDataType,...
            message('Slci:slci:ReComputeDataType',class(aObj)));

            aObj.fDataType=aObj.ResolveDataType();
        end



        function ComputeDataDim(aObj)

            children=aObj.getChildren();
            assert(numel(children)==2);
            l_dim=children{1}.getDataDim();
            r_dim=children{2}.getDataDim();


            if isequal(l_dim,-1)||isequal(r_dim,-1)
                return;
            end


            if(numel(l_dim)==2)&&(numel(r_dim)==2)
                if(l_dim(2)==r_dim(1))
                    aObj.setDataDim([l_dim(1),r_dim(2)]);
                elseif all(l_dim==1)
                    aObj.setDataDim(r_dim);
                elseif all(r_dim==1)
                    aObj.setDataDim(l_dim);
                else
                    assert(false,'wrong dimension for matrix multiplication opnd');
                end

                return;
            end


            [flag1,l_dim]=slci.internal.resolveDim(aObj.ParentModel.getHandle,l_dim);
            [flag2,r_dim]=slci.internal.resolveDim(aObj.ParentModel.getHandle,r_dim);
            if~flag1||~flag2
                return;
            end
            if prod(l_dim)==1
                aObj.setDataDim(r_dim);
            elseif prod(r_dim)==1
                aObj.setDataDim(l_dim);
            end

        end


        function aObj=SFAstMul(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstMul').getString);

            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

    methods(Access=protected)


        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionMathDatatypeConstraint,...
            slci.compatibility.MatlabFunctionRollThresholdConstraint,...
            };
            aObj.setConstraints(newConstraints);

            addMatlabFunctionConstraints@slci.ast.SFAst(aObj);
        end
    end
end
