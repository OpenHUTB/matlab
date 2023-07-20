function ret=rtwShowRptNow(report)




    if rtwinbat
        disp([report,'  is not launched in BaT or during test execution.']);
        ret=false;
    else
        ret=true;
    end
