classdef RTEDataItemParameter<handle




    properties(Access='private')
        PortName;
        ParamName;
    end

    properties(GetAccess='public',SetAccess='private')
        TypeInfo;
    end

    methods(Access='public')
        function this=RTEDataItemParameter(portName,paramName,typeInfo)
            this.PortName=portName;
            this.ParamName=paramName;
            this.TypeInfo=typeInfo;
        end

        function accessFcnName=writeForHeader(this,ASWCWriter,writerHFile)

            accessFcnName=this.getAccessFcnName;
            rhsArgs=this.getAccessFcnRHSArgs;
            lhsArg=this.getAccessFcnLHSArg;



            preserveDimensions=true;
            [declType,declVarName]=autosar.mm.mm2rte.RTEDataItemUtils.getDeclarationTypeAndVar(...
            this.TypeInfo,...
            this.getDataVarName(),...
            preserveDimensions);
            writerHFile.wLine(...
            'extern %s %s;',...
            declType,...
declVarName...
            );


            ASWCWriter.writeRTEContractPhaseAPIMapping(writerHFile,accessFcnName);


            writerHFile.wLine(...
            '%s %s(%s);',...
            lhsArg,...
            accessFcnName,...
rhsArgs...
            );
        end

        function writeForSource(this,writerCFile,...
            isMultiInstantiable,paramsInitialValueMap)

            accessFcnName=this.getAccessFcnName;
            rhsArgs=this.getAccessFcnRHSArgs;
            lhsArg=this.getAccessFcnLHSArg;



            preserveDimensions=true;
            [declType,declVarName,firstElementIndex]=autosar.mm.mm2rte.RTEDataItemUtils.getDeclarationTypeAndVar(...
            this.TypeInfo,...
            this.getDataVarName,...
            preserveDimensions);




            if isempty(this.PortName)&&paramsInitialValueMap.isKey(this.ParamName)
                initializer=sprintf(' = %s;',paramsInitialValueMap(this.ParamName));
            else
                initializer=';';
            end
            writerCFile.wLine(...
            '%s %s%s',...
            declType,...
            declVarName,...
            initializer);


            writerCFile.wBlockStart(...
            '%s %s(%s)',...
            lhsArg,...
            accessFcnName,...
rhsArgs...
            );

            if isMultiInstantiable
                writerCFile.wLine('(void)%s;',AUTOSAR.CSC.getRTEInstanceName);
            end


            if~isempty(firstElementIndex)

                dataVarName=sprintf('(&%s%s)',this.getDataVarName,firstElementIndex);
            else
                dataVarName=this.getDataVarName;
            end

            ampersand='';
            if this.TypeInfo.IsBus
                ampersand='&';
            end
            writerCFile.wLine(...
            'return %s%s;',...
            ampersand,...
dataVarName...
            );
            writerCFile.wBlockEnd;
        end
    end

    methods(Access='private')
        function dataVarName=getDataVarName(this)
            dataVarName=[this.getAccessFcnName,'_data'];
        end

        function accessFcnName=getAccessFcnName(this)

            if isempty(this.PortName)
                APIAccess='Rte_CData';
            else
                APIAccess='Rte_Prm_';
            end
            accessFcnName=sprintf('%s%s_%s',...
            APIAccess,...
            this.PortName,...
            this.ParamName);
        end

        function rhsString=getAccessFcnRHSArgs(this)
            rhsString=this.TypeInfo.RteInstanceArg;
        end

        function lhsString=getAccessFcnLHSArg(this)
            typeInfo=this.TypeInfo;
            addConstIfNeeded=false;
            lhsString=...
            autosar.mm.mm2rte.TypeBuilder.getAutosarType(...
            typeInfo.UsePointerIO,typeInfo.IsArray,typeInfo.IsVoidPointer,...
            typeInfo.RteType,typeInfo.BaseRteType,addConstIfNeeded);
        end
    end
end


