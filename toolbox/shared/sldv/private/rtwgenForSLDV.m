function isCompCompatible=rtwgenForSLDV(topBdHandle,compBdHandle,buildArgs)



    topSession=sldvprivate('sldvGetActiveSession',topBdHandle);
    if isempty(topSession)


        designMdlName=get_param(topBdHandle,'DVDesignModelName');
        topSession=sldvprivate('sldvGetActiveSession',designMdlName);
    end

    isMdlRef=true;
    isCompCompatible=topSession.generateIR(compBdHandle,isMdlRef,buildArgs);
end