



















classdef SFAstOnes<slci.ast.SFAst

    properties


        fLikeChild={};

        fTypeName='';
    end

    methods


        function aObj=SFAstOnes(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            DAStudio.message('Slci:slci:NotMtreeNode',...
            'SFAstOnes'));
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
            if~isempty(aObj.fLikeChild)

                assert(numel(aObj.fLikeChild)==1);
                aObj.setDataType(aObj.fLikeChild{1}.getDataType());
            elseif~isempty(aObj.fTypeName)
                if isKey(aObj.fDataTypeRank,aObj.fTypeName)
                    aObj.setDataType(aObj.fTypeName)
                end
            else
                [flag,dataType]=...
                slci.matlab.astProcessor.AstSlciInferenceUtil.evalDataType(aObj);
                if flag
                    assert(~isempty(dataType));
                    aObj.setDataType(dataType);
                end
            end
        end


        function ComputeDataDim(aObj)

            assert(~aObj.fComputedDataDim);
            [flag,dataDim]=...
            slci.matlab.astProcessor.AstSlciInferenceUtil.evalDim(aObj);
            if flag
                assert(~isequal(dataDim,-1));
                aObj.setDataDim(dataDim);
            end
        end

    end

    methods(Access=protected)





        function populateChildrenFromMtreeNode(aObj,inputObj)

            assert(any(strcmp(inputObj.kind,{'CALL','LP'})));



            [successflag,children]=slci.mlutil.getMtreeChildren(inputObj);
            assert(successflag);


            assert(strcmpi(children{1}.kind,'ID'),'Invalid CALL node');

            for k=2:numel(children)
                child=children{k};
                if strcmpi(child.kind,'CHARVECTOR')


                    tokens=regexp(child.string,'^('')(\s*like\s*)('')$','tokens');
                    if~isempty(tokens)

                        assert(numel(children)==(k+1));
                        child=children{k+1};
                        [isAstNeeded,cObj]=slci.matlab.astTranslator.createAst(child,aObj);
                        assert(isAstNeeded&&~isempty(cObj));
                        aObj.fLikeChild{end+1}=cObj;

                        break;
                    else


                        assert(numel(children)==k);
                        aObj.fTypeName=regexprep(child.string,'\''','');
                    end

                else
                    [isAstNeeded,cObj]=...
                    slci.matlab.astTranslator.createAst(child,aObj);
                    assert(isAstNeeded&&~isempty(cObj));
                    aObj.fChildren{end+1}=cObj;
                end
            end
        end


        function addMatlabFunctionConstraints(aObj)
            constraints={...
            slci.compatibility.MatlabFunctionMissingDatatypeConstraint,...
            slci.compatibility.MatlabFunctionMissingDimConstraint,...
            slci.compatibility.MatlabFunctionDimConstraint(...
            {'Scalar','Vector','Matrix'}),...
            slci.compatibility.MatlabFunctionUnsupportedAstConstraint,...
            };
            aObj.setConstraints(constraints);

        end

    end

end
