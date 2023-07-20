classdef abstractReg<hdlimplbase.HDLDirectCodeGen



    methods
        function this=abstractReg(~)
        end
    end

    methods
        context=beginClockBundleContext(this,hN,hC,hS,up,dn,off)
        endClockBundleContext(this,context)
        validSig=findSignalWithValidRate(this,hN,hC,hSignals)
        val=hasDesignDelay(~,~,~)
        [status,msg]=validateRegisterRates(this,hC)
    end


    methods(Static)
        hS=findSingleRateSignal(hC)
    end

end

