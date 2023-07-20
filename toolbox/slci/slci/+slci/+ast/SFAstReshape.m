


















classdef SFAstReshape<slci.ast.SFAst
    methods

        function ComputeDataType(aObj)
            assert(aObj.hasMtree());

        end


        function ComputeDataDim(aObj)
            assert(aObj.hasMtree());
        end


        function aObj=SFAstReshape(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
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
            slci.compatibility.MatlabFunctionMissingDatatypeConstraint,...
            slci.compatibility.MatlabFunctionMissingDimConstraint,...
            };
            aObj.setConstraints(newConstraints);
        end
    end
end