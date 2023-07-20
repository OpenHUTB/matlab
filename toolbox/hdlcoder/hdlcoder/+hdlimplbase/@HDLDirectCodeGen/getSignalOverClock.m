function overClockRate=getSignalOverClock(this,signal)%#ok


    currentdriver=hdlcurrentdriver;
    baseSampleTime=currentdriver.PirInstance.DutBaseRate;
    gp=pir;
    baseOverClock=gp.getDutBaseRateScalingFactor;

    signalSampleTime=hdlsignalrate(signal);

    overClockRate=baseOverClock*(signalSampleTime/baseSampleTime);
end
