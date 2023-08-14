














classdef SFAstDiag<slci.ast.SFAst
    methods


        function aObj=SFAstDiag(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);

        end


        function ComputeDataDim(aObj)

            children=aObj.getChildren();
            assert(numel(children)>0);
            VDataDim=children{1}.getDataDim();
            if isequal(VDataDim,-1)

                return;
            end
            assert(numel(VDataDim)==2);
            k=0;
            if numel(children)==2
                diagNum=children{2};
                [success,k]=...
                slci.matlab.astProcessor.AstSlciInferenceUtil.evalValue(diagNum);
                if~success


                    return;
                end
            end
            [flag,VDataDim]=slci.internal.resolveDim(aObj.ParentModel.getHandle,VDataDim);
            if~flag
                return;
            end
            if prod(VDataDim)==1

                M=abs(k)+1;
                dim=[M,M];
            elseif(VDataDim(1)==1)||(VDataDim(2)==1)

                M=prod(VDataDim)+abs(k);
                dim=[M,M];
            else

                if k>=0
                    M=min(VDataDim(1),VDataDim(2)-k);
                else
                    M=min(VDataDim(2),VDataDim(1)-abs(k));
                end
                assert(M>0);
                dim=[M,1];
            end
            aObj.setDataDim(dim);
        end


        function ComputeDataType(aObj)
            children=aObj.getChildren();
            assert(numel(children)>0);

            aObj.setDataType(children{1}.getDataType());
        end
    end

    methods(Access=protected)













        function populateChildrenFromMtreeNode(aObj,inputObj)
            assert(any(strcmpi(inputObj.kind,{'CALL','LP'})));
            [successflag,children]=slci.mlutil.getMtreeChildren(inputObj);
            assert(successflag);


            assert(strcmpi(children{1}.kind,'ID'),'Invalid CALL node');
            for idx=2:numel(children)
                [isAstNeeded,cObj]=...
                slci.matlab.astTranslator.createAst(children{idx},aObj);
                assert(isAstNeeded&&~isempty(cObj));
                aObj.fChildren{idx-1}=cObj;
            end
        end
    end

    methods(Access=protected)

        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionMissingDimConstraint...
            ,slci.compatibility.MatlabFunctionMissingDatatypeConstraint...
            ,slci.compatibility.MatlabFunctionDiagNumConstConstraint...
            ,slci.compatibility.MatlabFunctionUnsupportedAstConstraint...
            };
            aObj.setConstraints(newConstraints);
        end
    end
end
