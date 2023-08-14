








classdef SFAstNumel<slci.ast.SFAst

    methods


        function aObj=SFAstNumel(aAstObj,aParent)
            assert(isa(aAstObj,'mtree'),...
            DAStudio.message('Slci:slci:NotMtreeNode',...
            'SFAstNumel'));
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
            aObj.setDataType('double');
        end


        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);

            aObj.setDataDim([1,1]);
        end
    end

    methods(Access=protected)


        function populateChildrenFromMtreeNode(aObj,inputObj)

            assert(any(strcmp(inputObj.kind,{'SUBSCR','CALL','LP'})));
            [successflag,children]=slci.mlutil.getMtreeChildren(inputObj);
            assert(successflag);


            assert(strcmpi(children{1}.kind,'ID'),...
            DAStudio.message('Slci:slci:NotMtreeNode',...
            'SFAstNumel'));

            for k=2:numel(children)
                child=children{k};
                [isAstNeeded,cObj]=slci.matlab.astTranslator.createAst(...
                child,aObj);
                assert(isAstNeeded);
                assert(~isempty(cObj));
                aObj.fChildren{end+1}=cObj;
            end
        end

    end

end
