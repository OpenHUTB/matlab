classdef RTEDataItemOperationCall<autosar.mm.mm2rte.RTEDataItemOperation




    methods(Access='public')
        function this=RTEDataItemOperationCall(opName,portName,args)
            this@autosar.mm.mm2rte.RTEDataItemOperation(opName,...
            portName,args,'Std_ReturnType')
        end

        function accessFcnName=getAccessFcnName(this)
            accessFcnName=sprintf('Rte_Call_%s_%s',...
            this.PortName,...
            this.OpName);
        end
    end
end
