function rc=buildStats(ts,tf)



    try
        rc.labindex=labindex;
    catch exc

        rc.labindex=0;
    end

    rc.PID=system_dependent('getpid');
    if ispc
        rc.hostName=getenv('COMPUTERNAME');
    else
        rc.hostName=getenv('HOST');
    end

    if isempty(rc.hostName)
        rc.hostName='unknown';
    end
    rc.buildTime=etime(tf,ts);


