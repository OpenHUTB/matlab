function time=aftime2datetime(afTime)
    utcTime=afTime.UtcTime;
    time=icomm.pi.internal.dotnetdatetime2datetime(utcTime);
    time.TimeZone='UTC';
end