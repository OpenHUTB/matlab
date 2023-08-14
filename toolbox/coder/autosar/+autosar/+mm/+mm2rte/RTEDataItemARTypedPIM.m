classdef RTEDataItemARTypedPIM<autosar.mm.mm2rte.RTEDataItemPIM




    properties(Access='private')
        TypeInfo;
    end

    methods(Access='public')
        function this=RTEDataItemARTypedPIM(pimName,typeInfo)
            this=this@autosar.mm.mm2rte.RTEDataItemPIM(pimName);
            this.TypeInfo=typeInfo;
        end

        function accessFcnName=writeForHeader(this,writerHFile,isMultiInstantiable)
            returnType=this.getReturnTypeAndVar;
            optInstanceArg=...
            autosar.mm.mm2rte.RTEDataItemPIM.getInstanceArg(isMultiInstantiable);
            accessFcnName=sprintf('Rte_Pim_%s',this.PIMName);
            writerHFile.wLine('%s %s(%s);',returnType,accessFcnName,...
            optInstanceArg);
        end

        function writeForSource(this,writerCFile,isMultiInstantiable)
            [returnType,returnVar]=this.getReturnTypeAndVar;
            optInstanceArg=...
            autosar.mm.mm2rte.RTEDataItemPIM.getInstanceArg(isMultiInstantiable);
            preserveDimensions=false;
            [declType,declVarName]=autosar.mm.mm2rte.RTEDataItemUtils.getDeclarationTypeAndVar(...
            this.TypeInfo,...
            this.getDataVarName(),...
            preserveDimensions);
            writerCFile.wLine('%s %s;',declType,declVarName);
            writerCFile.wBlockStart('%s Rte_Pim_%s(%s)',returnType,this.PIMName,...
            optInstanceArg);
            if~strcmp(optInstanceArg,"void")
                writerCFile.wLine('(void)%s;',AUTOSAR.CSC.getRTEInstanceName);
            end
            writerCFile.wLine('return %s;',returnVar);
            writerCFile.wBlockEnd;
        end
    end

    methods(Access='private')
        function dataVarName=getDataVarName(this)
            dataVarName=sprintf('Rte_Pim_%s_data',this.PIMName);
        end

        function[returnType,returnVar,dataVarName]=getReturnTypeAndVar(this)
            dataVarName=this.getDataVarName();
            if this.TypeInfo.IsArray
                returnType=[this.TypeInfo.BaseRteType,'*'];
                returnVar=dataVarName;
            else
                returnType=[this.TypeInfo.RteType,'*'];
                returnVar=['&',dataVarName];
            end
        end

    end
end
