function ret=getSimulationStopTimeInTicks(baseRate,stopTimeInSeconds)






    if~isinf(stopTimeInSeconds)
        stopTimeInTicks=uint64(stopTimeInSeconds/baseRate);
        if stopTimeInTicks>=0xFFFFFFFF
            DAStudio.error('codertarget:utils:UnsupportedStopTime',stopTimeInSeconds);
        else
            ret=num2str(uint32(stopTimeInTicks));
        end
    else
        ret='-1';
    end
end