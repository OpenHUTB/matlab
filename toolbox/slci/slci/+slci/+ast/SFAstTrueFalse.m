









classdef SFAstTrueFalse<slci.ast.SFAst

    properties
        fTrue=false;

        fLikeChild={};
    end

    methods


        function out=IsTrue(aObj)
            out=aObj.fTrue;
        end


        function aObj=SFAstTrueFalse(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstTrueFalse').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);

            aObj.setTrue();
        end


        function ComputeDataType(aObj)

            assert(~aObj.fComputedDataType,...
            message('Slci:slci:ReComputeDataType',class(aObj)));

            aObj.setDataType('boolean');
        end


        function ComputeDataDim(aObj)

            children=aObj.getChildren();
            if numel(children)==0


                aObj.setDataDim([1,1]);
            end

        end

    end

    methods(Access=protected)


        function setTrue(aObj)
            if aObj.hasMtree()
                mNode=aObj.getMtree();
                [success,children]=slci.mlutil.getMtreeChildren(mNode);
                assert(success&&numel(children)>=1);
                assert(strcmpi(children{1}.kind,'ID'));
                str=children{1}.string;
                assert(any(strcmp(str,{'true','false'})));
                aObj.fTrue=strcmp(str,'true');
            end
        end


        function populateChildrenFromMtreeNode(aObj,inputObj)
            assert(isa(inputObj,'mtree')&&...
            any(strcmpi(inputObj.kind,{'CALL','LP'})));
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
            slci.compatibility.MatlabFunctionMissingDimConstraint,...
            slci.compatibility.MatlabFunctionDimConstraint(...
            {'Scalar','Vector','Matrix'})
            };
            aObj.setConstraints(constraints);

        end

    end
end
