function ret=plotUpdateCompareSignals(~,sigID1,sigID2,hFig)



    ret=[sigID1,sigID2];
    if~Simulink.sdi.isValidSignalID(sigID1)||~Simulink.sdi.isValidSignalID(sigID2)
        return
    end


    dsr=Simulink.sdi.compareSignals(sigID1,sigID2);



    if~isempty(dsr)&&~dsr.unitsMatch
        msg=getString(message('SDI:sdi:unitsDidNotMatch'));
        hAxes=axes('Parent',hFig,'Visible',hFig.Visible);
        text(0.3,0.5,msg,'Parent',hAxes);
        return
    end


    ss=Simulink.sdi.CustomSnapshot;
    ss.plotComparison(dsr);
    ss.snapshot('figure',hFig);
end