




classdef SFAstDirectCast<slci.ast.SFAst
    properties(Access=private)
        fCastName=[];
    end

    methods


        function aObj=SFAstDirectCast(aAstObj,aCastName,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
            assert(any(strcmpi(aCastName,...
            {'uint8','uint16','uint32','int8',...
            'int16','int32','double','single'})));
            aObj.fCastName=aCastName;
        end


        function ComputeDataDim(aObj)
            children=aObj.getChildren();

            assert(numel(children)>0);
            aObj.setDataDim(children{1}.getDataDim());
        end


        function ComputeDataType(aObj)
            assert(~isempty(aObj.fCastName));

            aObj.setDataType(aObj.fCastName);
        end
    end

    methods(Access=protected)







        function populateChildrenFromMtreeNode(aObj,inputObj)
            assert(any(strcmpi(inputObj.kind,{'CALL','LP'})));
            [successflag,children]=slci.mlutil.getMtreeChildren(inputObj);
            assert(successflag&&numel(children)==2);


            assert(strcmpi(children{1}.kind,'ID'),'Invalid CALL node');

            [isAstNeeded,cObj]=...
            slci.matlab.astTranslator.createAst(children{2},aObj);
            assert(isAstNeeded&&~isempty(cObj));
            aObj.fChildren{1}=cObj;
        end
    end

    methods(Access=protected)

        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionMissingDimConstraint...
            };
            aObj.setConstraints(newConstraints);
        end
    end
end