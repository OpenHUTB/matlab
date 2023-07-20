function fmt=getNiceDurationFormat(sec)

















    secondsInAMinute=60;
    secondsInAnHour=3600;

    if sec>secondsInAnHour
        fmt='hh:mm:ss.SSSSS';
    elseif sec>secondsInAMinute
        fmt='mm:ss.SSSSS';
    else
        fmt='s';
    end