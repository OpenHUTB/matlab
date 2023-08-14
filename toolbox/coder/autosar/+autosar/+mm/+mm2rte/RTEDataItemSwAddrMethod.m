classdef RTEDataItemSwAddrMethod<handle




    properties(SetAccess='private',GetAccess='public')
        SwAddrMethodName;
    end

    methods(Access='public')
        function this=RTEDataItemSwAddrMethod(swAddrMethodName)
            this.SwAddrMethodName=swAddrMethodName;
        end

        function write(this,writerHFile,writerCFile,isMultiInstantiable)

            optInstanceArg=...
            autosar.mm.mm2rte.RTEDataItemPIM.getInstanceArg(isMultiInstantiable);
            writerHFile.wLine('%s* Rte_Pim_%s(%s);',this.TypeInfo.RteType,this.PIMName,...
            optInstanceArg);



            dataVarName=sprintf('Rte_Pim_%s_data',this.PIMName);
            writerCFile.wLine('%s %s;',this.TypeInfo.RteType,dataVarName);
            writerCFile.wBlockStart('%s* Rte_Pim_%s(%s)',this.TypeInfo.RteType,this.PIMName,...
            optInstanceArg);
            if~strcmp(optInstanceArg,"void")
                writerCFile.wLine('(void)%s;',AUTOSAR.CSC.getRTEInstanceName);
            end
            writerCFile.wLine('return &%s;',dataVarName);
            writerCFile.wBlockEnd;
        end
    end
end
