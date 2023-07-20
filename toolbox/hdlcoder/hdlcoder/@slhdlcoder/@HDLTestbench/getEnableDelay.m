function enableDelay=getEnableDelay(this,hD)





    multiClockMode=~this.isDUTsingleClock;
    if hD.getParameter('MinimizeClockEnables')&&...
        ~multiClockMode&&...
        hD.getParameter('triggerasclock')~=1
        enableDelay=0;
    else
        enableDelay=hD.getParameter('TestBenchClockEnableDelay');
        if multiClockMode&&enableDelay>0



            clkMultiple=this.lcm_clocktable;
            enableDelay=(enableDelay-1)*clkMultiple+1;
        end
    end
end


