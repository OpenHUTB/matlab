

function tickInterval=getTickInterval(min,max,tickInterval,scaleType)


    isTickIntervalAuto=false;
    if strcmpi(tickInterval,'auto')
        isTickIntervalAuto=true;
    end

    if isTickIntervalAuto
        switch scaleType
        case{'Log'}
            tickInterval=10;
        case{'Linear'}
            diffBetweenMaxAndMin=max-min;
            tickInterval=diffBetweenMaxAndMin/10;
        end
    else
        tickInterval=eval(tickInterval);
    end