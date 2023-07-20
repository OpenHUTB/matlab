



















classdef SFAstDotProduct<slci.ast.SFAst
    methods

        function ComputeDataType(aObj)
            assert(aObj.hasMtree());

        end


        function ComputeDataDim(aObj)
            assert(aObj.hasMtree());
        end


        function aObj=SFAstDotProduct(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function out=hasDimOpnd(aObj)
            out=(numel(aObj.getChildren())>2);
        end


        function out=getDimOpnd(aObj)
            assert(aObj.hasDimOpnd());
            children=aObj.getChildren();
            out=children{3};
        end
    end
    methods(Access=protected)

        function populateChildrenFromMtreeNode(aObj,inputObj)

            assert(any(strcmpi(inputObj.kind,{'CALL','LP'})));
            [successflag,children]=slci.mlutil.getMtreeChildren(inputObj);
            assert(successflag&&(numel(children)>=2));


            assert(strcmpi(children{1}.kind,'ID'),'Invalid CALL node');

            for i=2:numel(children)
                child=children{i};

                [isAstNeeded,cObj]=...
                slci.matlab.astTranslator.createAst(child,aObj);
                assert(isAstNeeded&&~isempty(cObj));
                aObj.fChildren{end+1}=cObj;
            end
        end


        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionDimNumConstConstraint,...
            };
            aObj.setConstraints(newConstraints);
        end
    end
end
