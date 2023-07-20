



classdef RTEDataItemServer<autosar.mm.mm2rte.RTEDataItemOperation

    properties(Access='private')
        RunnableSymbol;
    end

    methods(Access='public')

        function this=RTEDataItemServer(opName,portName,args,...
            lhsArgString,runnableSymbol)
            this@autosar.mm.mm2rte.RTEDataItemOperation(opName,...
            portName,args,lhsArgString)
            this.RunnableSymbol=runnableSymbol;
        end

        function accessFcnName=getAccessFcnName(this)
            accessFcnName=this.RunnableSymbol;
        end

    end

end
