



classdef MatlabFunctionSwitchCondTypeConstraint<...
    slci.compatibility.StateflowDatatypeConstraint

    methods


        function out=getDescription(aObj)%#ok
            out=['Matlab function switch statement condition'...
            ,'could only be homogeneous scalar integer type'];
        end


        function obj=MatlabFunctionSwitchCondTypeConstraint
            obj.setEnum('MatlabFunctionSwitchCondType');
            obj.setFatal(false);
            obj.fSupportedTypes={'int8','int16','int32','uint8',...
            'uint16','uint32'};
        end


        function out=check(aObj)

            out=[];
            owner=aObj.getOwner();
            assert(isa(owner,'slci.ast.SFAstSwitch'));


            condAst=owner.getCondAST;
            [isSupported,condType]=aObj.isSupportedCondType(condAst);

            if isSupported

                caseAsts=owner.getCaseAST;
                for i=1:numel(caseAsts)
                    condAst=caseAsts{i}.getCondAST;
                    assert(iscell(condAst)&&numel(condAst)==1);
                    caseCondAst=condAst{1};

                    if isa(caseCondAst,'slci.ast.SFAstLC')
                        return;
                    end

                    [isSupported,caseCondType]=...
                    aObj.isSupportedCondType(caseCondAst);

                    isSupported=isSupported&&strcmp(condType,caseCondType);
                    if~isSupported
                        break;
                    end
                end
            end
            if~isSupported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end

        end

    end

    methods(Access=private)

        function[isSupported,dataType]=isSupportedCondType(aObj,condAst)
            dataType=condAst.getDataType();
            dataDim=condAst.getDataDim();
            isSupportedType=any(strcmp(dataType,aObj.fSupportedTypes));

            if~isSupportedType
                dt=dataType;
                if strncmp(dataType,'Enum:',5)
                    dt=strtrim(dataType(5:end));
                end
                isSupportedType=isvarname(dt)&&...
                slci.compatibility.isSupportedEnumClass(dt);
            end

            supportedDim=true;
            if~isequal(dataDim,-1)

                [flag,dataDim]=slci.internal.resolveDim(aObj.ParentModel.getHandle,dataDim);
                if~flag
                    return;
                end
                supportedDim=(prod(dataDim)==1);
            end
            isSupported=isSupportedType&&supportedDim;
        end
    end
end