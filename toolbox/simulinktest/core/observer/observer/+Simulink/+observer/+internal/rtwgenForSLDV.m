function isObsSupportON=rtwgenForSLDV(topBdHandle,obsBdHandle)



    topSession=sldvprivate('sldvGetActiveSession',topBdHandle);
    if isempty(topSession)


        designMdlName=get_param(topBdHandle,'DVDesignModelName');
        topSession=sldvprivate('sldvGetActiveSession',designMdlName);
    end

    isObsSupportON=topSession.generateIR(obsBdHandle);
end