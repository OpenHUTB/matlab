classdef RTEDataItemInternalTriggeringPoint<handle





    properties(SetAccess=immutable,GetAccess=private)
        TriggeringRunnableSymbol;
        InternalTrigPointName;
        TriggeredRunnableSymbol;
    end

    methods(Access='public')
        function this=RTEDataItemInternalTriggeringPoint(...
            triggeringRunSymbol,internalTrigPointName,triggeredRunSymbol)
            this.TriggeringRunnableSymbol=triggeringRunSymbol;
            this.InternalTrigPointName=internalTrigPointName;
            this.TriggeredRunnableSymbol=triggeredRunSymbol;
        end

        function accessFcnName=getAccessFcnName(this)
            accessFcnName=sprintf('Rte_IrTrigger_%s_%s',...
            this.TriggeringRunnableSymbol,...
            this.InternalTrigPointName);
        end

        function runSymbol=getTriggeredRunnableSymbol(this)
            runSymbol=this.TriggeredRunnableSymbol;
        end
    end
end
