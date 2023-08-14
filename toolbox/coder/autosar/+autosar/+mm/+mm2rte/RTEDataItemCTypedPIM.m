classdef RTEDataItemCTypedPIM<autosar.mm.mm2rte.RTEDataItemPIM




    properties(Access='private')
        TypeStr;
        TypeDefinitionStr;
    end

    methods(Access='public')
        function this=RTEDataItemCTypedPIM(pimName,typeStr,...
            typeDefinitionStr)
            this=this@autosar.mm.mm2rte.RTEDataItemPIM(pimName);
            this.TypeStr=typeStr;
            this.TypeDefinitionStr=typeDefinitionStr;
        end

        function accessFcnName=writeForHeader(this,writerHFile,ASWCName,isMultiInstantiable)
            pimType=sprintf('Rte_PimType_%s_%s',ASWCName,this.TypeStr);
            writerHFile.wLine('typedef %s %s;',this.TypeDefinitionStr,pimType);
            writerHFile.wLine('typedef %s %s;',pimType,this.TypeStr);
            optInstanceArg=...
            autosar.mm.mm2rte.RTEDataItemPIM.getInstanceArg(isMultiInstantiable);
            accessFcnName=sprintf('Rte_Pim_%s',this.PIMName);
            writerHFile.wLine('%s* %s(%s);',this.TypeStr,accessFcnName,...
            optInstanceArg);
        end

        function writeForSource(this,writerCFile,ASWCName,isMultiInstantiable)
            dataVarName=sprintf('Rte_Pim_%s_data',this.PIMName);
            pimType=this.getPIMType(ASWCName);
            writerCFile.wLine('%s %s;',pimType,dataVarName);
            optInstanceArg=...
            autosar.mm.mm2rte.RTEDataItemPIM.getInstanceArg(isMultiInstantiable);
            writerCFile.wBlockStart('%s* Rte_Pim_%s(%s)',this.TypeStr,this.PIMName,...
            optInstanceArg);
            if~strcmp(optInstanceArg,"void")
                writerCFile.wLine('(void)%s;',AUTOSAR.CSC.getRTEInstanceName);
            end
            writerCFile.wLine('return &%s;',dataVarName);
            writerCFile.wBlockEnd;
        end
    end

    methods(Access='private')
        function pimType=getPIMType(this,ASWCName)
            pimType=sprintf('Rte_PimType_%s_%s',ASWCName,this.TypeStr);
        end
    end
end
