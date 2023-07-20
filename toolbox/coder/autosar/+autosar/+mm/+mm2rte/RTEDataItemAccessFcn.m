classdef RTEDataItemAccessFcn<handle




    properties(Access='private')
        RunnableName;
        PortName;
        DataElementName;
        AccessKind;
        TypeInfo;
        IsQueuedRecv;
        IsQueuedSend;
        HasTransformerError;
    end

    methods(Access='public')
        function this=RTEDataItemAccessFcn(runnableName,portName,...
            dataElementName,accessKind,isQueuedRecv,isQueuedSend,...
            typeInfo)
            this.PortName=portName;
            this.DataElementName=dataElementName;
            this.AccessKind=accessKind;
            this.RunnableName=runnableName;
            this.TypeInfo=typeInfo;
            this.IsQueuedRecv=isQueuedRecv;
            this.IsQueuedSend=isQueuedSend;
            this.HasTransformerError=false;
        end

        function setHasTransformerError(this,value)
            this.HasTransformerError=value;
        end

        function rteWithError=hasTransformerError(this)
            rteWithError=this.HasTransformerError;
        end

        function accessFcnName=getAccessFcnName(this)


            switch(this.AccessKind)
            case{'ExplicitWrite','ExplicitReadByArg',...
                'ExplicitReadByValue','IsUpdated',...
                'SignalInvalidationStub','E2ERead',...
                'E2EWrite','E2EReadInit',...
                'E2EWriteInit'}
                runnableOpt='';
            otherwise
                runnableOpt=['_',this.RunnableName];
            end

            switch(this.AccessKind)
            case 'ImplicitWrite'
                APIAccess='Rte_IWrite';
            case 'ImplicitWriteRef'
                APIAccess='Rte_IWriteRef';
            case 'ImplicitRead'
                APIAccess='Rte_IRead';
            case 'ExplicitWrite'
                if this.IsQueuedSend
                    APIAccess='Rte_Send';
                else
                    APIAccess='Rte_Write';
                end
            case 'ExplicitReadByArg'
                if this.IsQueuedRecv
                    APIAccess='Rte_Receive';
                else
                    APIAccess='Rte_Read';
                end
            case 'ExplicitReadByValue'
                APIAccess='Rte_DRead';
            case 'E2ERead'
                if this.IsQueuedRecv
                    APIAccess='E2EPW_Receive';
                else
                    APIAccess='E2EPW_Read';
                end
            case 'E2EWrite'
                if this.IsQueuedSend
                    APIAccess='E2EPW_Send';
                else
                    APIAccess='E2EPW_Write';
                end
            case 'E2EReadInit'
                if this.IsQueuedRecv
                    APIAccess='E2EPW_ReceiveInit';
                else
                    APIAccess='E2EPW_ReadInit';
                end
            case 'E2EWriteInit'
                if this.IsQueuedSend
                    APIAccess='E2EPW_SendInit';
                else
                    APIAccess='E2EPW_WriteInit';
                end
            case 'IStatus'
                APIAccess='Rte_IStatus';
            case 'IsUpdated'
                APIAccess='Rte_IsUpdated';
            case 'SignalInvalidationStub'
                APIAccess='Rte_Invalidate';
            otherwise
                assert(false,'Unexpected AccessKind %s.',this.AccessKind);
            end

            accessFcnName=sprintf('%s%s_%s_%s',...
            APIAccess,...
            runnableOpt,...
            this.PortName,...
            this.DataElementName);
        end

        function rhsString=getAccessFcnRHSArgs(this)

            typeInfo=this.TypeInfo;
            switch(this.AccessKind)
            case{'ImplicitWrite','ExplicitWrite','E2EWrite',...
                'ExplicitReadByArg','E2ERead'}
                if any(strcmp(this.AccessKind,{...
                    'ExplicitReadByArg','E2ERead'}))
                    addConstIfNeeded=false;
                    usePointerIO=true;
                else
                    addConstIfNeeded=true;
                    usePointerIO=typeInfo.UsePointerIO;
                end
                typeStr=autosar.mm.mm2rte.TypeBuilder.getAutosarType(...
                usePointerIO,typeInfo.IsArray,typeInfo.IsVoidPointer,...
                typeInfo.RteType,typeInfo.BaseRteType,addConstIfNeeded);

                transformerArg='';
                if this.HasTransformerError
                    transformerArg=', Rte_TransformerError* e';
                end

                if typeInfo.IsMultiInstantiable
                    rhsString=sprintf('%s, %s u%s',typeInfo.RteInstanceArg,typeStr,transformerArg);
                else
                    rhsString=sprintf('%s u%s',typeStr,transformerArg);
                end
            case{'ImplicitRead','IStatus','IsUpdated',...
                'SignalInvalidationStub','ImplicitWriteRef',...
                'E2EReadInit','E2EWriteInit','ExplicitReadByValue'}
                rhsString=typeInfo.RteInstanceArg;
            otherwise
                assert(false,'Unsupported AccessKind %s',this.AccessKind);
            end
        end

        function lhsString=getAccessFcnLHSArg(this)
            typeInfo=this.TypeInfo;
            switch(this.AccessKind)
            case 'ImplicitWrite'
                lhsString='void';
            case 'ImplicitWriteRef'
                usePointerIO=true;
                addConstIfNeeded=false;
                lhsString=autosar.mm.mm2rte.TypeBuilder.getAutosarType(...
                usePointerIO,typeInfo.IsArray,typeInfo.IsVoidPointer,...
                typeInfo.RteType,typeInfo.BaseRteType,addConstIfNeeded);
            case{'ExplicitReadByArg',...
                'IStatus','ExplicitWrite',...
                'SignalInvalidationStub',...
                'E2EReadInit','E2EWriteInit'}
                lhsString='Std_ReturnType';
            case{'ImplicitRead','ExplicitReadByValue'}
                addConstIfNeeded=true;
                lhsString=autosar.mm.mm2rte.TypeBuilder.getAutosarType(...
                typeInfo.UsePointerIO,typeInfo.IsArray,typeInfo.IsVoidPointer,...
                typeInfo.RteType,typeInfo.BaseRteType,addConstIfNeeded);
            case 'IsUpdated'
                lhsString='boolean';
            case{'E2ERead','E2EWrite'}
                lhsString='uint32';
            otherwise
                assert(false,'Unsupported AccessKind %s',this.AccessKind);
            end
        end
    end
end


