














classdef SFAstEps<slci.ast.SFAst

    methods


        function aObj=SFAstEps(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstEps').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function ComputeDataType(aObj)

            assert(~aObj.fComputedDataType,...
            message('Slci:slci:ReComputeDataType',class(aObj)));
        end


        function ComputeDataDim(aObj)

            aObj.setDataDim([1,1]);

        end

    end

    methods(Access=protected)


        function populateChildrenFromMtreeNode(aObj,inputObj)
            assert(isa(inputObj,'mtree')&&...
            any(strcmpi(inputObj.kind,{'CALL','LP'})));
            [successflag,children]=slci.mlutil.getMtreeChildren(inputObj);
            assert(successflag);


            assert(strcmpi(children{1}.kind,'ID'),'Invalid CALL node');

            aObj.setDataType('double');

            assert(numel(children)==1||numel(children)==2);
            if numel(children)==2
                type={'double','single'};
                child=children{2};
                if strcmpi(child.kind,'CHARVECTOR')
                    str=lower(regexprep(child.string,'\''',''));
                    if ismember(str,type)
                        aObj.setDataType(str);
                    end
                else


                    [isAstNeeded,cObj]=...
                    slci.matlab.astTranslator.createAst(child,aObj);
                    assert(isAstNeeded&&~isempty(cObj));
                    aObj.fChildren{end+1}=cObj;
                    aObj.setDataType(cObj.getDataType());
                end
            end

        end


        function addMatlabFunctionConstraints(aObj)
            constraints={slci.compatibility.MatlabFunctionDimConstraint(...
            {'Scalar'})};
            aObj.setConstraints(constraints);

        end

    end
end