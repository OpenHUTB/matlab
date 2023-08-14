


































classdef SFAstSum<slci.ast.SFAst
    properties(Access=private)
        fTypeName='default';
        fNanFlag='includenan';
    end

    methods

        function ComputeDataType(aObj)
            assert(aObj.hasMtree());

        end


        function ComputeDataDim(aObj)
            assert(aObj.hasMtree());
        end


        function aObj=SFAstSum(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function out=getTypeName(aObj)
            out=aObj.fTypeName;
        end


        function setTypeName(aObj,aTypeName)
            aObj.fTypeName=aTypeName;
        end


        function out=getNanFlag(aObj)
            out=aObj.fNanFlag;
        end


        function setNanFlag(aObj,aNanFlag)
            aObj.fNanFlag=aNanFlag;
        end


        function out=isIncludeNan(aObj)
            out=strcmpi(aObj.fNanFlag,'includenan');
        end


        function out=hasDimOpnd(aObj)
            out=(numel(aObj.getChildren())>1);
        end


        function out=getDimOpnd(aObj)
            assert(aObj.hasDimOpnd());
            children=aObj.getChildren();
            out=children{2};
        end
    end
    methods(Access=protected)

        function populateChildrenFromMtreeNode(aObj,inputObj)

            assert(any(strcmpi(inputObj.kind,{'CALL','LP'})));
            [successflag,children]=slci.mlutil.getMtreeChildren(inputObj);
            assert(successflag&&(numel(children)>=2));


            assert(strcmpi(children{1}.kind,'ID'),'Invalid CALL node');

            type={'double','native','default'};
            nanflag={'includenan','omitnan'};
            for i=2:numel(children)
                child=children{i};

                if strcmpi(child.kind,'CHARVECTOR')
                    str=lower(regexprep(child.string,'\''',''));
                    if ismember(str,type)
                        aObj.setTypeName(str);
                        continue;
                    elseif ismember(str,nanflag)
                        aObj.setNanFlag(str);
                        continue;
                    end
                end
                [isAstNeeded,cObj]=...
                slci.matlab.astTranslator.createAst(child,aObj);
                assert(isAstNeeded&&~isempty(cObj));
                aObj.fChildren{end+1}=cObj;
            end
        end


        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionNanFlagConstraint,...
            slci.compatibility.MatlabFunctionDimNumConstConstraint,...
            slci.compatibility.MatlabFunctionMathDatatypeConstraint,...
            };
            aObj.setConstraints(newConstraints);
        end
    end
end
