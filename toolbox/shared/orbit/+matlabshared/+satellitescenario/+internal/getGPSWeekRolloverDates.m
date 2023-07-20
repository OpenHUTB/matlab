function d=getGPSWeekRolloverDates(sc)








    d={};

    if nargin~=0
        t=sc.StartTime;
    else
        t=datetime;
    end
    t.TimeZone='utcleapseconds';


    mod1024Weeks=1024*7;


    refTime=matlabshared.internal.gnss.GPSTime.getLocalTime(0,0,'UTCLeapSeconds');




    count=0;
    while refTime<=t
        count=count+1;
        d{count}=datestr(refTime,'dd-mmm-yyyy');
        refTime=refTime+days(mod1024Weeks);
    end


    d=d';
end
