function internal_ready=elaborateSlaveReadyLogic(~,hN,hChannel,...
    hStreamNetInportSignals)




    ufix1Type=pir_ufixpt_t(1,0);
    internal_ready=hN.addSignal(ufix1Type,'internal_ready');

    if hChannel.isReadyPortAssigned


        user_ready=hStreamNetInportSignals(end);
        pirelab.getWireComp(hN,user_ready,internal_ready);

    else

        if hChannel.NeedAutoReadyWiring


            auto_ready=hStreamNetInportSignals(end);
            pirelab.getWireComp(hN,auto_ready,internal_ready);
        else


            const_1=hN.addSignal(ufix1Type,'const_1');
            pirelab.getConstComp(hN,const_1,1);
            pirelab.getWireComp(hN,const_1,internal_ready);
        end
    end

end

