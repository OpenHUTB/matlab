classdef RTEDataItemRunnable<handle




    properties(GetAccess='public',SetAccess='private')
        RunnableSymbol;
        SwAddrMethod;
    end

    methods(Access='public')
        function this=RTEDataItemRunnable(runnableSymbol,swAddrMethod)
            this.RunnableSymbol=runnableSymbol;
            this.SwAddrMethod=swAddrMethod;
        end

        function rhsString=getAccessFcnRHSArgs(this,isMultiInstantiable)%#ok<INUSL>
            if isMultiInstantiable
                rhsString=[AUTOSAR.CSC.getRTEInstanceType,' ',...
                AUTOSAR.CSC.getRTEInstanceName];
            else
                rhsString='void';
            end
        end

        function lhsString=getAccessFcnLHSArg(this,aswcName)








            lhsString=sprintf('extern FUNC(void, %s_%s)',aswcName,this.SwAddrMethod);
        end
    end
end


