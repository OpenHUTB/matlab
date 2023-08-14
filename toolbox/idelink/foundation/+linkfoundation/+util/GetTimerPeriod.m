function timerIntPeriod=GetTimerPeriod(numCycles,prescaler)




    if nargin==1,
        timerIntPeriod=floor(numCycles);
    else
        timerIntPeriod=floor(numCycles/prescaler);
    end

