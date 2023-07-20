


classdef MatlabFunctionSwitchDatatypeConstraint<...
    slci.compatibility.StateflowDatatypeConstraint

    methods


        function out=getDescription(aObj)%#ok
            out=['Matlab function switch statement must have condition '...
            ,' and case selection of integer data type '...
            ,'or case selection must be of literal '...
            ,'integral value.'];
        end


        function obj=MatlabFunctionSwitchDatatypeConstraint
            obj.setEnum('MatlabFunctionSwitchDatatype');
            obj.setFatal(false);
            obj.fSupportedTypes={'int8','int16','int32',...
            'uint8','uint16','uint32'};
        end


        function out=check(aObj)

            out=[];
            owner=aObj.getOwner();
            assert(isa(owner,'slci.ast.SFAstSwitch'));


            isSupported=aObj.isSupportedConditionDataType(owner)...
            &&aObj.isSupportedCaseDataType(owner);
            if~isSupported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end

        end

    end

    methods(Access=private)

        function out=isSupportedConditionDataType(aObj,switchAst)
            assert(isa(switchAst,'slci.ast.SFAstSwitch'));

            condAst=switchAst.getCondAST();
            condDataType=condAst.getDataType();
            out=true;
            if isempty(condDataType)

                return;
            end

            if~any(strcmp(condDataType,aObj.fSupportedTypes))
                out=false;

                return
            end

        end


        function out=isSupportedCaseDataType(aObj,switchAst)
            assert(isa(switchAst,'slci.ast.SFAstSwitch'));

            caseAsts=switchAst.getCaseAST;
            out=true;
            for i=1:numel(caseAsts)
                condAst=caseAsts{i}.getCondAST;
                caseCondAst=condAst{1};
                [isConst,value]=...
                slci.matlab.astProcessor.AstSlciInferenceUtil.evalValue(caseCondAst);
                if isConst&&all(size(value)==1)

                    isIntegerValue=(value==floor(value));
                    if~isIntegerValue

                        out=false;
                        return;
                    end
                else
                    caseExprType=caseCondAst.getDataType();
                    if~isempty(caseExprType)
                        if~any(strcmp(caseExprType,aObj.fSupportedTypes))

                            out=false;
                            return;
                        end
                    end
                end
            end
        end
    end
end