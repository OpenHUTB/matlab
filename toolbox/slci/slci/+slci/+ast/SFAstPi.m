



classdef SFAstPi<slci.ast.SFAst

    methods


        function aObj=SFAstPi(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstPi').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function ComputeDataType(aObj)

            assert(~aObj.fComputedDataType,...
            message('Slci:slci:ReComputeDataType',class(aObj)));

            aObj.setDataType('double');
        end


        function ComputeDataDim(aObj)

            aObj.setDataDim([1,1]);

        end

    end

    methods(Access=protected)


        function populateChildrenFromMtreeNode(~,inputObj)
            assert(isa(inputObj,'mtree')&&...
            any(strcmpi(inputObj.kind,{'CALL','LP'})));
            [successflag,children]=slci.mlutil.getMtreeChildren(inputObj);
            assert(successflag);


            assert(strcmpi(children{1}.kind,'ID'),'Invalid CALL node');

            assert(numel(children)==1);

        end


        function addMatlabFunctionConstraints(aObj)
            constraints={};
            aObj.setConstraints(constraints);

        end

    end
end
