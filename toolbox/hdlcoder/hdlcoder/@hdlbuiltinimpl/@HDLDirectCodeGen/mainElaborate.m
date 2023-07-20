function mainElaborate(this,hN,hC)

























    try

        hPreElabC=preElab(this,hN,hC);

        hPostElabC=elaborate(this,hN,hPreElabC);

        postElab(this,hN,hPreElabC,hPostElabC);

        setPseudoElabSettings(this,hN,hPreElabC,hPostElabC);

    catch mEx

        disp(mEx);
        arrayfun(@disp,mEx.stack);
        rethrow(mEx);
    end
