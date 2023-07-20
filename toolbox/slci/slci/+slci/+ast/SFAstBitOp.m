


classdef SFAstBitOp<slci.ast.SFAst

    properties(Access=private)
        fTypeName='';
    end

    methods


        function aObj=SFAstBitOp(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function out=getTypeName(aObj)
            out=aObj.fTypeName;
        end


        function setTypeName(aObj,aTypeName)
            aObj.fTypeName=aTypeName;
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

                if strcmpi(child.kind,'CHARVECTOR')
                    assert(i==numel(children));
                    aObj.setTypeName(regexprep(child.string,'\''',''));
                else
                    [isAstNeeded,cObj]=...
                    slci.matlab.astTranslator.createAst(child,aObj);
                    assert(isAstNeeded&&~isempty(cObj));
                    aObj.fChildren{end+1}=cObj;
                end
            end
        end


        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionAssumedTypeConstraint,...
            slci.compatibility.MatlabFunctionDoubleTypeBitOperatorConstraint,...
            slci.compatibility.MatlabFunctionMathDatatypeConstraint,...
            slci.compatibility.MatlabFunctionMixedDataDimConstraint,...
            };
            aObj.setConstraints(newConstraints);
        end

    end

end