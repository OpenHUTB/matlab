function elaborateMasterReadyLogic(~,hN,hChannel,...
    internal_ready,hStreamNetOutportSignals)




    if hChannel.isReadyPortAssigned


        user_ready=hStreamNetOutportSignals(end);
        pirelab.getWireComp(hN,internal_ready,user_ready);

    else

        if hChannel.NeedAutoReadyWiring


            auto_ready=hStreamNetOutportSignals(end);
            pirelab.getWireComp(hN,internal_ready,auto_ready);
        else











        end
    end

end

