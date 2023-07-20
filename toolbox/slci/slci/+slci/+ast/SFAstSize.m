














classdef SFAstSize<slci.ast.SFAst

    methods


        function aObj=SFAstSize(aAstObj,aParent)
            assert(isa(aAstObj,'mtree'),...
            DAStudio.message('Slci:slci:NotMtreeNode',...
            'SFAstSize'));
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
            aObj.setDataType('double');
        end


        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);


            children=aObj.getChildren();
            assert(~isempty(children));
            arg=children{1};
            argDim=arg.getDataDim();
            if~isequal(argDim,-1)
                if numel(children)==2


                    aObj.setDataDim([1,1]);
                else
                    assert(numel(children)==1);
                    value=argDim;
                    aObj.setDataDim(size(value));
                end
            end
        end
    end

    methods(Access=protected)


        function populateChildrenFromMtreeNode(aObj,inputObj)

            assert(any(strcmp(inputObj.kind,{'SUBSCR','CALL','LP'})));
            [successflag,children]=slci.mlutil.getMtreeChildren(inputObj);
            assert(successflag);


            assert(strcmpi(children{1}.kind,'ID'),...
            DAStudio.message('Slci:slci:NotMtreeNode',...
            'SFAstSize'));

            for k=2:numel(children)
                child=children{k};
                [isAstNeeded,cObj]=slci.matlab.astTranslator.createAst(...
                child,aObj);
                assert(isAstNeeded);
                assert(~isempty(cObj));
                aObj.fChildren{end+1}=cObj;
            end
        end


        function addMatlabFunctionConstraints(aObj)
            constraints={...
            slci.compatibility.MatlabFunctionMissingDatatypeConstraint,...
            slci.compatibility.MatlabFunctionMissingDimConstraint,...
            slci.compatibility.MatlabFunctionUnsupportedAstConstraint,...
            };
            aObj.setConstraints(constraints);

        end

    end

end
