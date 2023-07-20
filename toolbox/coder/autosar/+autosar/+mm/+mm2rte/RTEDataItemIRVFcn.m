classdef RTEDataItemIRVFcn<handle




    properties(Access='private')
        IRVName;
        RunnableName;
        IsWrite;
        AccessKind;
        TypeInfo;
        IsExplicitReadAndNonScalar;
    end

    methods(Access='public')
        function this=RTEDataItemIRVFcn(irvName,runnableName,...
            isWrite,accessKind,typeInfo)
            this.IRVName=irvName;
            this.RunnableName=runnableName;
            this.IsWrite=isWrite;
            this.AccessKind=accessKind;
            this.TypeInfo=typeInfo;

            this.IsExplicitReadAndNonScalar=~isWrite&&...
            (this.TypeInfo.UsePointerIO&&...
            strcmp(this.AccessKind,'Explicit'));
        end

        function accessFcnName=getAccessFcnName(this)

            optI='';
            if strcmp(this.AccessKind,'Implicit')
                optI='I';
            end

            if this.IsWrite
                readOrWrite='Write';
            else
                readOrWrite='Read';
            end

            accessFcnName=sprintf('Rte_Irv%s%s_%s_%s',...
            optI,...
            readOrWrite,...
            this.RunnableName,...
            this.IRVName);
        end

        function rhsString=getAccessFcnRHSArgs(this)

            typeInfo=this.TypeInfo;
            if this.IsExplicitReadAndNonScalar
                addConstIfNeeded=false;
                usePointerIO=true;
            else
                addConstIfNeeded=true;
                usePointerIO=typeInfo.UsePointerIO;
            end

            if this.IsWrite||this.IsExplicitReadAndNonScalar
                typeStr=autosar.mm.mm2rte.TypeBuilder.getAutosarType(...
                usePointerIO,typeInfo.IsArray,typeInfo.IsVoidPointer,...
                typeInfo.RteType,typeInfo.BaseRteType,addConstIfNeeded);

                if typeInfo.IsMultiInstantiable
                    rhsString=sprintf('%s, %s u',typeInfo.RteInstanceArg,typeStr);
                else
                    rhsString=sprintf('%s u',typeStr);
                end
            else
                rhsString=typeInfo.RteInstanceArg;
            end
        end

        function lhsString=getAccessFcnLHSArg(this)
            typeInfo=this.TypeInfo;
            if this.IsWrite||this.IsExplicitReadAndNonScalar
                lhsString='void';
            else
                addConstIfNeeded=true;
                lhsString=autosar.mm.mm2rte.TypeBuilder.getAutosarType(...
                typeInfo.UsePointerIO,typeInfo.IsArray,typeInfo.IsVoidPointer,...
                typeInfo.RteType,typeInfo.BaseRteType,addConstIfNeeded);
            end
        end
    end
end
