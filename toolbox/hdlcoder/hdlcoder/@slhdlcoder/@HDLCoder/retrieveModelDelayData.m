function delayData=retrieveModelDelayData(~,p)
    nw=p.getTopNetwork();
    delayData.m_sampleTime=nw.getInputDelayDataSampleTime();
    delayData.m_delays=nw.getInputDelayDataDelays();
    delayData.m_valid=nw.getInputDelayDataValidity();
end