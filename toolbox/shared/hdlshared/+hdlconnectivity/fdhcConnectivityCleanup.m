function fdhcConnectivityCleanup(mpcg,dutName,pass)











    if hdlgetparameter('multicyclepathinfo')
        hCD=hdlconnectivity.getConnectivityDirector;
        if~isempty(hCD),
            hB=hCD.builder;
        else
            hB=[];
        end


        if~isempty(mpcg)&&pass,
            mpcg.writeTXT(dutName);
        end




        hdlconnectivity.getConnectivityDirector([]);

        hdlconnectivity.genConnectivity(false);

        if~isempty(mpcg),delete(mpcg);end
        if~isempty(hCD),
            tU=hCD.timingUtil;
            delete(hCD);
            if~isempty(tU),delete(tU);end
        end
        if~isempty(hB),delete(hB);end


    end
